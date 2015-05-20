# Upgrade iRedMail from 0.8.7 to 0.9.0

[TOC]

## ChangeLog

> We provide remote upgrade service, check [the price](../support.html) and [contact us](../contact.html).

* 2015-01-05: [All backends] [OPTIONAL] Enable global sieve script in Dovecot to move spam to Junk folder by default.

----

* 2014-12-24: [All backends] Modify type of SQL column `policy.policy_name` to VARCHAR(255).
* 2014-12-04: [All backends] Disable SSL v3 in Apache, Postfix, Dovecot.
* 2014-11-13: [All backends] Add index for SQL column `msgs.spam_level` in `amavisd` database.
* 2014-11-06: <strike>[All backends] Fix improper SQL query command in domain transport query file.</strike>
* 2014-09-09: [All backends] Fix incorrect setting to enable daily cron job to update SpamAssassin rules.
* 2014-09-09: [All backends] Fix improper permission of Amavisd config file.
* 2014-07-15: <strike>[All backends] Fix improper Postfix setting in both main.cf and master.cf.</strike>
* 2014-06-19: [All backends] Add index for SQL column `policy.policy_name` in `amavisd` database.
* 2014-06-07:
    * [OpenLDAP] Add new value for existing mail users: enabledService=indexer-worker.
    * [MySQL/PostgreSQL] New SQL column in `vmail` database: mailbox.enableindexer-worker.

## General (All backends should apply these steps)

### Update /etc/iredmail-release with iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
# File: /etc/iredmail-release

0.9.0
```

### Upgrade Roundcube webmail to the latest stable release

Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release immediately: [How to upgrade Roundcube](http://trac.roundcube.net/wiki/Howto_Upgrade)

### Upgrade iRedAPD (Postfix policy server) to the latest 1.4.4

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[How to upgrade iRedAPD-1.4.0 or later versions to the latest stable release](./upgrade.iredapd.html)

Important notes: 

* in iRedMail-0.9.0 and future iRedMail releases, we will use white/blacklists
  stored in Amavisd database in Amavisd (after-queue) and iRedAPD (before-queue),
  so you must enable iRedAPD plugin `amavisd_wblist`.
* it's strongly recommended to enable plugin `reject_null_sender` (as first
  plugin listed in iRedAPD parameter `plugins =`) to prevent spam.

iRedAPD-1.4.4 fixes several issues and brings some new features:

* iRedAPD now works with Postfix parameter `smtpd_end_of_data_restrictions`
  (smtp protocol state `END-OF-MESSAGE`).

* New plugins:
    * `reject_null_sender`: prevent authenticated user to send spam as null
      sender (`from=<>` in Postfix log file).

    * `amavisd_wblist`: it uses per-recipient white/blacklists stored in
      Amavisd SQL database to reject emails sent from blacklisted senders and
      bypass whitelisted senders.

        White/blacklist could be global (server-wide) setting, per-domain setting,
        or per-user setting. Priority: per-user > per-domain > global.

    * `amavisd_message_size_limit`: limit size of single incoming mail.

        Message size limit could be global (server-wide) setting, per-domain setting,
        or per-user setting. Priority: per-user > per-domain > global.

* Plugin `reject_sender_login_mismatch` now will allow user to send as their
  own alias addresses by default. You can still set
  `ALLOWED_LOGIN_MISMATCH_STRICTLY = False` in iRedAPD config file
  (`/opt/iredapd/settings.py`) to allow user to send as any sender if you want.

    It's recommended to enable this plugin right after plugin `reject_null_sender`.

Suggested order of above 3 plugins are (if you enabled them):

```
plugins = ['reject_null_sender', 'reject_sender_login_mismatch', 'amavisd_wblist', ...]
```

Important notes:

* If you want to manage white/blacklists with the latest iRedAdmin-Pro, you
  have to enable plugin `amavisd_wblist`.

* Plugin `amavisd_wblist` and `amavisd_message_size_limit` requires additional
  database related settings in iRedAPD config file, please set correct values
  for them. You can find SQL database settings in Amavisd config file,
  in parameter `@lookup_sql_dsn =`.

```
amavisd_db_server = '127.0.0.1'
amavisd_db_port = 3306
amavisd_db_name = 'amavisd'
amavisd_db_user = 'amavisd'
amavisd_db_password = 'password'
```

### Upgrade iRedAdmin (open source edition) to the latest stable release

Please follow this tutorial to upgrade iRedAdmin open source edition to the
latest stable release: [Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html)

### Disable SSLv3 support

I believe you already heard about the `POODLE` issue of SSL protocol v3.
POODLE stands for Padding Oracle On Downgraded Legacy Encryption. This
vulnerability allows a man-in-the-middle attacker to decrypt ciphertext using
a padding oracle side-channel attack. More details are available in the
upstream OpenSSL advisory: [Vulnerability Summary for CVE-2014-3566](http://web.nvd.nist.gov/view/vuln/detail?vulnId=CVE-2014-3566).

The safest short-term response is to disable SSLv3 support.

#### Disable SSLv3 in Apache

Please add or update `SSLProtocol` setting in Apache config file like below:

* on RHEL/CentOS, it's `/etc/httpd/conf.d/ssl.conf`.
* on Debian/Ubuntu, it's `/etc/apache2/apache2.conf`.
* on FreeBSD, it's `/usr/local/etc/apache2[X]/httpd.conf`. Please replace
  `apache2[X]` by the real Apache version number here.

```
SSLProtocol ALL -SSLv2 -SSLv3
```

Restarting Apache service is required.

#### Disable SSLv3 in Postfix

Please execute below commands to disable SSLv3 in Postfix:

```
# postconf -e smtpd_tls_protocols='!SSLv2 !SSLv3'
# postconf -e smtp_tls_protocols='!SSLv2 !SSLv3'
# postconf -e lmtp_tls_protocols='!SSLv2 !SSLv3'
# postconf -e smtpd_tls_mandatory_protocols='!SSLv2 !SSLv3'
# postconf -e smtp_tls_mandatory_protocols='!SSLv2 !SSLv3'
# postconf -e lmtp_tls_mandatory_protocols='!SSLv2 !SSLv3'
```

Restarting Postfix service is required.

#### Disable SSLv3 in Dovecot

Please add below setting in Dovecot main config file `/etc/dovecot/dovecot.conf`
(on Linux/OpenBSD) or `/usr/local/etc/dovecot/dovecot.conf` (on FreeBSD).

```
ssl_protocols = !SSLv2 !SSLv3
```

Restarting Dovecot service is required.

### Fix improper Postfix setting in both main.cf and master.cf

NOTE: This step is wrong, please do not apply it. If you already applied it,
please revert your changes.

if you send email to user `user@domain.com` and mail list/alias `list@domain.com`,
and `user@` is member of `list@`, then `user@` will receive duplicate email.

<strike>
Currently, we don't have Postfix parameter `receive_override_options=` set in
`/etc/postfix/main.cf`, instead, we have it in transport `127.0.0.1:10025`
(Amavisd) like this:

```
# Part of file: /etc/postfix/master.cf

127.0.0.1:10025 inet n  -   -   -   -  smtpd
    ...
    -o receive_override_options=no_header_body_checks,no_unknown_recipient_checks,no_address_mappings
```

Without `receive_override_options=no_address_mappings` in `main.cf`:

* Postfix will enable canonical address mapping, virtual alias map expansion,
  address masquerading, and automatic BCC (blind carbon-copy) recipients
  __BEFORE__ injecting emails to content filter (Amavisd, in our case). For
  example, if you forward email to 3 email addresses, Postfix will expand the
  original recipient to 3 recipients, then Amavisd will get 3 emails for
  scanning. But with `receive_override_options=no_address_mappings`, Postfix
  won't expand original recipient to 3 addresses, and Amavisd gets only 1 email
  for scanning. It slightly improves mail server performance.

* If a blacklisted sender (stored in Amavisd SQL database, not in
  Policyd/Cluebringer) sends email to user who forwards email to other
  addresses, Amavisd will quarantine the one sent to original recipient, but
  bypass emails sent to forwarded addresses.

Please apply below steps to fix above issues:

* Add `receive_override_options` in Postfix with below shell command:

```
# postconf -e receive_override_options='no_address_mappings'
```

* Open file `/etc/postfix/master.cf` (On Linux/OpenBSD) or
  `/usr/local/etc/postfix/master.cf` (on FreeBSD), find setting for transport
  `127.0.0.1:10025`, remove `no_address_mappings` for its
  `receive_override_options` option:

```
# Part of file: /etc/postfix/master.cf

# ORIGINAL setting
#    -o receive_override_options=no_header_body_checks,no_unknown_recipient_checks,no_address_mappings

# MODIFIED setting
    -o receive_override_options=no_header_body_checks,no_unknown_recipient_checks
```

* Restart Postfix service.

__IMPORTANT NOTE__: If you want to disable `content_filter=` in Postfix, please
comment out `receive_override_options=` in Postfix config file `main.cf` too,
otherwise canonical address mapping, virtual alias map expansion, address
masquerading, and automatic BCC (blind carbon-copy) recipients will not work.
</strike>

### Fix improper file permission of Amavisd config file

__NOTE__: This step is applicable to only Red Hat/CentOS 6.

Amavisd config file `/etc/amavisd/amavisd.conf` must be owned by group `amavis`,
otherwise after you upgraded to Red Hat/CentOS 7, Amavisd service cannot start.

```
# chgrp amavis /etc/amavisd/amavisd.conf
```

### Fix incorrect setting to enable daily cron job to update SpamAssassin rules

__NOTE__: This step is applicable to only Debian and Ubuntu.

Please update file `/etc/default/spamassassin` to set `CRON=1`, so that
SpamAssassin daily cron job will update SpamAssassin rules automatically.

```
# Part of file: /etc/default/spamassassin

CRON=1
```

### [OPTIONAL] Enable global sieve script in Dovecot to move spam to Junk folder by default

Note: this is an optional step.

Please follow our separate tutorial [here](./move.detected.spam.to.junk.folder.html).

## OpenLDAP backend special

### Fix improper LDAP query command in domain transport query file

NOTE: This step is wrong, please do not apply it. If you already applied it,
please revert your changes.

<strike>
Please open file `/etc/postfix/ldap/transport_maps_domain.cf` (on Linux/OpenBSD)
or `/usr/local/etc/postfix/ldap/transport_maps_domain.cf` (on FreeBSD), add
additional LDAP filter `(!(domainBackupMX=yes))` in `query =` parameter:

```
# Part of file: /etc/postfix/ldap/transport_maps_domain.cf

# OLD setting
#query_filter    = (&(objectClass=mailDomain)(accountStatus=active)(enabledService=mail)(|(domainName=%s)(domainAliasName=%s)))

# NEW setting
query_filter    = (&(objectClass=mailDomain)(accountStatus=active)(enabledService=mail)(|(domainName=%s)(domainAliasName=%s))(!(domainBackupMX=yes)))
```

Restarting Postfix service is required.
</strike>

### Add new LDAP values for existing mail users

We will add new LDAP attribute/value pair for existing mail users:
`enabledService=indexer-worker`. It's used by Dovecot.

* Download below python script to adding new values for existing mail users.

```
# cd /root/
# wget https://bitbucket.org/zhb/iredmail/raw/default/extra/update/updateLDAPValues_087_to_090.py
```

* Open downloaded file `updateLDAPValues_087_to_090.py`, set LDAP server related
settings in this file. For example:

```
# Part of file: updateLDAPValues_087_to_090.py

uri = 'ldap://127.0.0.1:389'
basedn = 'o=domains,dc=example,dc=com'
bind_dn = 'cn=vmailadmin,dc=example,dc=com'
bind_pw = 'passwd'
```

You can find required LDAP credential in iRedAdmin config file or `iRedMail.tips`
file under your iRedMail installation directory. Using either
`cn=Manager,dc=xx,dc=xx` or `cn=vmailadmin,dc=xx,dc=xx` as bind dn is ok.

* Execute this script, it will add required data:

```
# python updateLDAPValues_087_to_090.py
```

That's all.

### Add index for SQL column in `amavisd` database

We need indexes for some SQL columns in `amavisd` database:
`policy.policy_name`, `msgs.spam_level`. Both are used by iRedAdmin-Pro.

Now connect to SQL server as MySQL root user, create new columns, add required INDEX:

```
$ mysql -uroot -p
mysql> USE amavisd;
mysql> ALTER TABLE policy MODIFY COLUMN policy_name VARCHAR(255) NOT NULL DEFAULT '';
mysql> CREATE UNIQUE INDEX policy_idx_policy_name ON policy (policy_name);
mysql> CREATE INDEX msgs_idx_spam_level ON msgs (spam_level);
```

## MySQL backend special

### Fix improper SQL query command in domain transport query file

NOTE: This step is wrong, please do not apply it. If you already applied it,
please revert your changes.

<strike>
Please open file `/etc/postfix/mysql/transport_maps_domain.cf` (on Linux/OpenBSD)
or `/usr/local/etc/postfix/mysql/transport_maps_domain.cf` (on FreeBSD), add
additional SQL statement `AND backupmx=0` in `query =` parameter:

```
# Part of file: /etc/postfix/mysql/transport_maps_domain.cf

# OLD setting
#query       = SELECT transport FROM domain WHERE domain='%s' AND active=1

# NEW setting
query       = SELECT transport FROM domain WHERE domain='%s' AND active=1 AND backupmx=0
```

Restarting Postfix service is required.
</strike>

### Add and remove SQL columns in `vmail` and `amavisd` databases

* We need new SQL columns in `vmail` database: `mailbox.enableindexer-worker`,
  it's used by Dovecot.

* We need new indexes for some 2 columns in `amavisd` database:
  `policy.policy_name`, `msgs.spam_level`. Both are used by iRedAdmin-Pro.

Now connect to SQL server as MySQL root user, create new columns, add required
indexes:

```
$ mysql -uroot -p
mysql> USE vmail;
mysql> ALTER TABLE mailbox ADD COLUMN `enableindexer-worker` TINYINT(1) NOT NULL DEFAULT 1;
mysql> ALTER TABLE mailbox ADD INDEX (`enableindexer-worker`);

mysql> USE amavisd;
mysql> ALTER TABLE policy MODIFY COLUMN policy_name VARCHAR(255) NOT NULL DEFAULT '';
mysql> CREATE UNIQUE INDEX policy_idx_policy_name ON policy (policy_name);
mysql> CREATE INDEX msgs_idx_spam_level ON msgs (spam_level);
```

## PostgreSQL backend special

### Fix improper SQL query command in domain transport query file

NOTE: This step is wrong, please do not apply it. If you already applied it,
please revert your changes.

<strike>
Please open file `/etc/postfix/pgsql/transport_maps_domain.cf` (on Linux/OpenBSD)
or `/usr/local/etc/postfix/pgsql/transport_maps_domain.cf` (on FreeBSD), add
additional SQL statement `AND backupmx=0` in `query =` parameter:

```
# Part of file: /etc/postfix/pgsql/transport_maps_domain.cf

# OLD setting
#query       = SELECT transport FROM domain WHERE domain='%s' AND active=1

# NEW setting
query       = SELECT transport FROM domain WHERE domain='%s' AND active=1 AND backupmx=0
```

Restarting Postfix service is required.
</strike>

### Add and remove SQL columns in `vmail` and `amavisd` databases

* We need new SQL columns in `vmail` database: `mailbox.enableindexer-worker`,
  it's used by Dovecot.

* We need new indexes for some 2 columns in `amavisd` database:
  `policy.policy_name`, `msgs.spam_level`. Both are used by iRedAdmin-Pro.

Now connect to SQL server as PostgreSQL admin user, create new columns, add
required indexes:

```
# su - postgres
$ psql -d vmail
sql> ALTER TABLE mailbox ADD COLUMN "enableindexer-worker" INT2 NOT NULL DEFAULT 1;
sql> CREATE INDEX idx_mailbox_enableindexer_worker ON mailbox ("enableindexer-worker");

sql> \c amavisd;
sql> ALTER TABLE policy ALTER COLUMN policy_name TYPE varchar(255);
sql> CREATE UNIQUE INDEX policy_idx_policy_name ON policy (policy_name);
sql> CREATE INDEX msgs_idx_spam_level ON msgs (spam_level);
```
