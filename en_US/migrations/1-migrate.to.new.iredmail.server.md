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
      legency mail clients, please follow this tutorial:
      [How to enable SMTPS service](./enable.smtps.html).

## LDAP: migrate mail accounts

Steps to migrate LDAP mail accounts:

* Setup a new server with the latest iRedMail, and make iRedAdmin-Pro-LDAP work as expected.
* Export mail accounts from LDAP on OLD mail server.

Normally, LDAP data can be exported into LDIF format. Here's backup/restore procedure: [Backup and Restore](./backup.restore.html).

Notes:

* There might be some changes in LDAP schema, please find scripts [here](https://bitbucket.org/zhb/iredmail/src/default/extra/update/) to apply all required changes.
* Here are all [upgrade tutorials for iRedMail](http://www.iredmail.org/docs/iredmail.releases.html).

## MySQL/PostgreSQL: Migrate mail accounts

All mail accounts are stored in database `vmail` by default, to migrate mail
accounts, you can simply export this database on old server, then import it
on new server.

__IMPORTANT NOTE__: iRedMail-0.8.7 drops several SQL columns, so before you
import backup SQL database, please add them first. It's safe to drop them
after you imported old database on new server.

```mysql
mysql> USE vmail;

mysql> ALTER TABLE mailbox ADD COLUMN bytes BIGINT(20) NOT NULL DEFAULT 0;
mysql> ALTER TABLE mailbox ADD COLUMN messages BIGINT(20) NOT NULL DEFAULT 0;

mysql> ALTER TABLE domain ADD COLUMN defaultlanguage VARCHAR(5) NOT NULL DEFAULT 'en_US';
mysql> ALTER TABLE domain ADD COLUMN defaultuserquota BIGINT(20) NOT NULL DEFAULT '1024';
mysql> ALTER TABLE domain ADD COLUMN defaultuseraliases TEXT;
mysql> ALTER TABLE domain ADD COLUMN disableddomainprofiles VARCHAR(255) NOT NULL DEFAULT '';
mysql> ALTER TABLE domain ADD COLUMN disableduserprofiles VARCHAR(255) NOT NULL DEFAULT '';
mysql> ALTER TABLE domain ADD COLUMN defaultpasswordscheme VARCHAR(10) NOT NULL DEFAULT '';
mysql> ALTER TABLE domain ADD COLUMN minpasswordlength INT(10) NOT NULL DEFAULT 0;
mysql> ALTER TABLE domain ADD COLUMN maxpasswordlength INT(10) NOT NULL DEFAULT 0;

mysql> ALTER TABLE alias ADD COLUMN islist TINYINT(1) NOT NULL DEFAULT 0;
```

After imported backup SQL databases, please execute below commands to mark
mail alias accounts and drop above newly created columns:

```mysql
mysql> USE vmail;
mysql> UPDATE alias SET islist=1 WHERE address NOT IN (SELECT username FROM mailbox);
mysql> UPDATE alias SET islist=0 WHERE address=domain;    -- domain catch-all account

-- Store values into new column: domain.settings and drop them
mysql> UPDATE domain SET settings='';
mysql> UPDATE domain SET settings=CONCAT(settings, IF(defaultlanguage IS NULL OR defaultlanguage='', '', CONCAT('default_language:', defaultlanguage, ';')));
mysql> UPDATE domain SET settings=CONCAT(settings, IF(defaultuserquota IS NULL OR defaultuserquota=0, '', CONCAT('default_user_quota:', defaultuserquota, ';')));
mysql> UPDATE domain SET settings=CONCAT(settings, IF(defaultuseraliases IS NULL OR defaultuseraliases='', '', CONCAT('default_groups:', defaultuseraliases, ';')));
mysql> UPDATE domain SET settings=CONCAT(settings, IF(minpasswordlength IS NULL OR minpasswordlength=0, '', CONCAT('min_passwd_length:', minpasswordlength, ';')));
mysql> UPDATE domain SET settings=CONCAT(settings, IF(maxpasswordlength IS NULL OR maxpasswordlength=0, '', CONCAT('max_passwd_length:', maxpasswordlength, ';')));
mysql> UPDATE domain SET settings=CONCAT(settings, IF(disableddomainprofiles IS NULL OR disableddomainprofiles='', '', CONCAT('disabled_domain_profiles:', disableddomainprofiles, ';')));
mysql> UPDATE domain SET settings=CONCAT(settings, IF(disableduserprofiles IS NULL OR disableduserprofiles='', '', CONCAT('disabled_user_profiles:', disableduserprofiles, ';')));

mysql> ALTER TABLE domain DROP defaultlanguage;
mysql> ALTER TABLE domain DROP defaultuserquota;
mysql> ALTER TABLE domain DROP defaultuseraliases;
mysql> ALTER TABLE domain DROP minpasswordlength;
mysql> ALTER TABLE domain DROP maxpasswordlength;
mysql> ALTER TABLE domain DROP disableddomainprofiles;
mysql> ALTER TABLE domain DROP disableduserprofiles;
```

__IMPORTANT NOTE__: There might be some changes in SQL structure, please read
all upgrade tutorials for your current iRedMail release, then apply SQL
structure related changes. Check [upgrade tutorials for iRedMail](./iredmail.releases.html).

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

## Migrate Roundcube webmail data

* Export/import roundcube webmail database, and upgrade database to work with
  new version of Roundcube.

Reference: <https://github.com/roundcube/roundcubemail/wiki/Upgrade>

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
