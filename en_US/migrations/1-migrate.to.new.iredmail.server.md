# Migrate old iRedMail server to the latest stable release

[TOC]

!!! warning

    Please practise the migration on a test server first, make sure you understand
    the whole procedure and migrate all required data.

Since new iRedMail server will install same components as old server, you can choose what data you want to migrate.

Most important data are:

* email accounts stored in SQL/LDAP.
* user mailboxes. Stored under /var/vmail by default.
* SQL database of Roundcube webmail. It stores per-user webmail preferences, and address book.
* <strike>Policyd/Cluebringer database. It stores white/blacklists records, greylisting records, etc.</strike> Note: Policyd/Cluebringer were removed since iRedMail-0.9.3.
* Amavisd database.
    * It stores per-recipient white/blacklists in SQL tables: `mailaddr`, `policy`, `users`, `wblist`.
    * Basic info of in/out emails are stored in SQL tables: `maddr`, `msgs`, `msgrcpt`. Quarantined emails are stored in `quarantine`, it requires other 3 tables. If you don't have any quarantined emails, it's safe to delete all records in these 4 tables.

!!! warning

    Do not restore database `mysql` exported from old server, it contains SQL
    usernames/passwords for Roundcube/Amavisd/iRedAPD/iRedAdmin/... used on
    old server. New iRedMail server has the same SQL usernames, but different
    passwords. So please do not restore it.

## Client settings (Outlook, Thunderbird)

Since iRedMail-0.8.7, iRedMail enforces secure POP3/IMAP/SMTP connections,
please update your mail client applications to use TLS connection.

* For SMTP service, use port `587` with `STARTTLS` (or `TLS`).
* For IMAP service, use port `143` with `STARTTLS` (or `TLS`), or port `993` with `SSL`.
* For POP3 service, use port `110` with `STARTTLS` (or `TLS`), or port `995` with `SSL`.

!!! note

    * If you want to enable smtp authentication on port `25` (again, not
      recommended), please comment out Postfix parameter `smtpd_tls_auth_only = yes`
      in its config file `/etc/postfix/main.cf`.

    * if you want to enable SMTPS (SMTP over SSL, port `465`) to support
      legacy mail clients, please follow this tutorial:
      [How to enable SMTPS service](./enable.smtps.html).

## LDAP: migrate mail accounts

Steps to migrate LDAP mail accounts:

* Setup a new server with the latest iRedMail, and make iRedAdmin-Pro-LDAP work as expected.
* Export mail accounts from LDAP on OLD mail server.

Normally, LDAP data can be exported into LDIF format. Here's backup/restore procedure: [Backup and Restore](./backup.restore.html).

Notes:

* There might be some changes in LDAP schema, please find scripts
  [here](https://github.com/iredmail/iRedMail/tree/master/update/ldap) to apply
  all required changes.
* Here are all [upgrade tutorials for iRedMail](https://docs.iredmail.org/iredmail.releases.html).

## MySQL/MariaDB/PostgreSQL: Migrate mail accounts

All mail accounts are stored in database `vmail`.

* If both old and new servers are running same iRedMail version, you can simply
  export `vmail` database on old server, then import it on new server.

* If old server is running an old iRedMail version, there might be some changes
  in SQL structure, please read all upgrade tutorials for the old iRedMail
  release, then apply SQL structure related changes to make sure old server
  has same SQL structure. After you have same SQL structure on both servers,
  you can simply export `vmail` database on old server, then import it on new
  server. Check [upgrade tutorials for iRedMail](./iredmail.releases.html).

### MySQL/MariaDB inside FreeBSD Jail

If you run iRedMail server in a jailed FreeBSD system, restored SQL database
on new jailed system may have privilege error like this:

```
ERROR 1449 (HY000): The user specified as a definer ('root'@'10.195.20.1') does not exist
```

iRedMail installer created SQL tables (or VIEWs, TRIGGERs) as `root@10.195.20.1`
(`10.195.20.1` was private IP address of your old Jail system), but this
address was gone on new jailed system. You must replace old IP address by the
new one before restoring the SQL tables, otherwise, triggers might have to be
re-created manualy later. For example,

```
perl -pi -e 's#`root`@`10.195.20.1`#`root`@`10.20.21.3`#g' vmail-2020-04-26-01:25:21.sql
perl -pi -e 's#`root`@`10.195.20.1`#`root`@`10.20.21.3`#g' amavisd-2020-04-26-01:25:21.sql
```

Then import this modified SQL file instead.

## Migrate mailboxes (Maildir format)

!!! warning

    * Make sure the maildir path stored in SQL/LDAP matches the mailbox
      path on file system, so that mail clients can find migrated mail messages.
    * After migrated mailboxes, you may want to recalculate mailbox quota by
      following our tutorial:
      [Force Dovecot to recalculate mailbox quota](./recalculate.mailbox.quota.html)

* Copy all mailboxes (in Maildir format) to new iRedMail server with tools like `rsync`.
* Set correct file owner and permission of mailboxes. Default owner is `vmail`,
  group is `vmail`, permission is `0700`.

* With SQL backends, you can get full maildir path of user with below SQL command:

```
mysql> USE vmail;
mysql> SELECT CONCAT(storagebasedirectory, '/', storagenode, '/', maildir) FROM mailbox WHERE username='user@domain.com';
```

* With OpenLDAP backend, full maildir path is stored in LDAP attribute
  `homeDirectory` of mail user object. You can query with `ldapsearch` command:

```
$ ldapsearch -x -D 'cn=Manager,dc=xx,dc=xx' -b 'o=domains,dc=xx,dc=xx' -W "(mail=user@domain.com)" homeDirectory
```

## Migrate (mlmmj) mailing lists

!!! attention

    mlmmj mailing list was introduced in iRedMail-0.9.8.

Mailing lists are stored in 2 places:

- Mailing list accounts are stored in SQL database (for iRedMail SQL backends)
  or LDAP (for LDAP backends)
- Mailing list data:
    - `/var/vmail/mlmmj`: it stores active mailing lists.
    - `/var/vmail/mlmmj-archive`: it stores removed mailing lists.

For mailing list accounts, they should be migrated while migrating mail
accounts mentioned in steps above.

For mailing list data, you can simply copy them to new server. After copied,
the data must be owned by user/group `mlmmj:mlmmj` with permission `0700`.

## Migrate Roundcube webmail data

* Export/import roundcube webmail database, and upgrade database to work with
  new version of Roundcube.

Reference: <https://github.com/roundcube/roundcubemail/wiki/Upgrade>

## Migrate SOGo Groupware data

### Solution 1: Export and import SQL database

If you run same version of SOGo on old and new server, it's ok to migrate
data by simply exporting the `sogo` SQL database and import to new server.

For SQL backends, you need to re-create SQL table `sogo.users` after restored
database:

* For MySQL, MariaDB backends:

```
USE sogo;
DROP VIEW users;
CREATE VIEW users (c_uid, c_name, c_password, c_cn, mail, domain)
    AS SELECT username, username, password, name, username, domain
         FROM vmail.mailbox WHERE enablesogo=1 AND active=1;
```

* For PostgreSQL backend. Please switch to PostgreSQL daemon user `_postgres`
  first, then run `psql -d sogo` to connect to `sogo` database:

!!! warning

    Please replace `<vmail_user_password>` by the real password for SQL user `vmail`.

```
\c sogo;
CREATE EXTENSION IF NOT EXISTS dblink;

DROP VIEW users;
CREATE VIEW users AS
    SELECT * FROM dblink('host=127.0.0.1
                          port=5432
                          dbname=vmail
                          user=vmail
                          password=<vmail_user_password>',
                          'SELECT username AS c_uid,
                                  username AS c_name,
                                  password AS c_password,
                                  name     AS c_cn,
                                  username AS mail,
                                  domain   AS domain
                             FROM mailbox
                            WHERE enablesogo=1 AND active=1')
         AS users (c_uid         VARCHAR(255),
                   c_name        VARCHAR(255),
                   c_password    VARCHAR(255),
                   c_cn          VARCHAR(255),
                   mail          VARCHAR(255),
                   domain        VARCHAR(255));

ALTER TABLE users OWNER TO sogo;
```

### Solution 2: Backup and restore data

!!! attention

    It's strongly recommended to practice with a testing machine and verify
    the calendars, events and contacts after migrated.

iRedMail has daily cron job to backup SOGo data with script
`/var/vmail/backup/backup_sogo.sh`, you should run it manually
right before migration so that all recent data are exported.

Backup copies are stored under `/var/vmail/backup/sogo/<year>/<month>/` by
default.

Copy the latest backup file to new server, then follow this tutorial to
restore it: [How can I backup/restore my user data?](https://sogo.nu/support/faq/how-can-i-backuprestore-my-user-data.html)

## Migrate Amavisd, iRedAPD, iRedAdmin databases

Export those database on old server, then import them on new server.

## Migrate DKIM keys

Amavisd will read DKIM keys and sign outgoing emails. DKIM keys are stored
under `/var/lib/dkim` by default, you can copy all keys under this directory to
new server, and make sure they have correct file owner `amavis:amavis` and
permission `0600`.

If you prefer generating new DKIM keys on new server, don't forget to update
DNS records for mail domain names.

## Post-migration

After migration, please recalculate mailbox quota by following this tutorial:

* [Force Dovecot to recalculate mailbox quota](./recalculate.mailbox.quota.html)

# References

* [Password hashes](./password.hashes.html)
* [Reset user password](./reset.user.password.html)
* [Why append timestamp in maildir path](./why.append.timestamp.in.maildir.path.html)
