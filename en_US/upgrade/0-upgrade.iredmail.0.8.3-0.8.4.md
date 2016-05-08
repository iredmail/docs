# Upgrade iRedMail from 0.8.3 to 0.8.4

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](../support.html) and [contact us](../contact.html).

## ChangeLog

* 2013-03-28: Update /etc/iredmail-release with iRedMail version number.
* 2013-03-28: Upgrade Roundcube webmail to the latest 0.8.6.
* 2013-03-25: [ldap] Fix incorrect LDAP query filter in Postfix.
* 2013-01-08: [sql] Add 4 new columns in table `vmail.mailbox` for MySQL/PostgreSQL backends.
* 2012-10-24: [ldap] Supports alias domains in Postfix per-user bcc lookup files.

## General (All backends should apply these steps)

### Update /etc/iredmail-release with iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
# File: /etc/iredmail-release

0.8.4
```

### Upgrade Roundcube webmail to the latest stable release

Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release immediately: [How to upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).

### Upgrade iRedAPD (Postfix policy server) to the latest stable release

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

### Upgrade iRedAdmin (open source edition) to the latest stable release

Please follow this tutorial to upgrade iRedAdmin open source edition to the
latest stable release: [Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html)

### Add new alias `virusalert` in Postfix for Amavisd

Amavisd will send an email notification to address `virusalert@[YOUR_HOSTNAME]`
by default, but we don't have this user in Postfix alias file
`/etc/postfix/aliases` (on Linux/OpenBSD), or /usr/local/etc/postfix/aliases
(on FreeBSD) or SQL/LDAP database, so emails cannot be delivered. Below steps
add an alias in Postfix alias file, and it will be forwarded to root user by
default.

Add new alias (Note, use '/usr/local/etc/postfix/aliases' on FreeBSD instead),
and update the database:

```
# echo 'virusalert: root' >> /etc/postfix/aliases
# postalias /etc/postfix/aliases
```

## OpenLDAP backend special

### Fix incorrect LDAP query filter in Postfix

If you add external email addresses as mail list members, iRedAdmin-Pro will
store them in attribute `memberOfGroup`, this will cause exported LDIF data
cannot be restored. Below are steps to fix this issue.

To fix this issue, we need the latest LDAP schema file provided by iRedMail.
Steps are:

* Download the newest iRedMail ldap schema file
* Copy old ldap schema file as a backup copy
* Replace the old one
* Restart OpenLDAP service.

Here we go:

#### Use the latest LDAP schema file provided by iRedMail

* On RHEL/CentOS/Scientific Linux (both release 5.x and 6.x), openSUSE, Gentoo, OpenBSD:

```
# cd /tmp
# wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/iredmail.schema

# cd /etc/openldap/schema/
# cp iredmail.schema iredmail.schema.bak

# cp -f /tmp/iredmail.schema /etc/openldap/schema/
# /etc/init.d/slapd restart       # <-- Or: /etc/init.d/ldap restart
```

* On Debian/Ubuntu:

```
# cd /tmp
# wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/iredmail.schema

# cd /etc/ldap/schema/
# cp iredmail.schema iredmail.schema.bak

# cp -f /tmp/iredmail.schema /etc/ldap/schema/
# /etc/init.d/slapd restart
```

* On FreeBSD:

```
# cd /tmp
# wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/iredmail.schema

# cd /usr/local/etc/ldap/schema/
# cp iredmail.schema iredmail.schema.bak

# cp -f /tmp/iredmail.schema /usr/local/etc/openldap/schema/
# /usr/local/etc/rc.d/slapd restart
```

#### Update existing accounts

* Download python script used to adding missing values.

```
# cd /root/
# wget https://bitbucket.org/zhb/iredmail/raw/default/extra/update/updateLDAPValues_083_to_084.py
```

Open downloaded file `updateLDAPValues_083_to_084.py`, set LDAP server related
settings in file head. for example,

```
# Part of file: updateLDAPValues_083_to_084.py

uri = 'ldap://127.0.0.1:389'
basedn = 'o=domains,dc=example,dc=com'
bind_dn = 'cn=vmailadmin,dc=example,dc=com'
bind_pw = 'passwd'
```

You can find required LDAP credential in iRedAdmin config file or `iRedMail.tips`
file under your iRedMail installation directory. Using either
`cn=Manager,dc=xx,dc=xx` or `cn=vmailadmin,dc=xx,dc=xx` as bind dn is ok.

Execute this script, it will fix incorrect values and add correct ones:

```
# python updateLDAPValues_083_to_084.py
```

#### Fix incorrect LDAP query filter in Postfix

* On Linux/OpenBSD, please update `/etc/postfix/ldap/virtual_group_maps.cf`.
  On FreeBSD, update `/usr/local/etc/postfix/ldap/virtual_group_maps.cf` instead.

```
# Part of file: ldap/virtual_group_maps.cf

# OLD setting
#query_filter    = (&(memberOfGroup=%s)(accountStatus=active)(enabledService=mail)(enabledService=deliver)(|(objectClass=mailUser)(objectClass=mailExternalUser)))

# New setting
query_filter    = (&(accountStatus=active)(enabledService=mail)(enabledService=deliver)(|(memberOfGroup=%s)(shadowAddress=%s))(|(objectClass=mailUser)(objectClass=mailExternalUser)))
```

Restarting Postfix service is required.

### Supports alias domains in Postfix per-user bcc lookup files

* In `/etc/postfix/ldap/sender_bcc_maps_user.cf`, replace `(mail=%s)` by
  `(|(mail=%s)(&(enabledService=shadowaddress)(shadowAddress=%s)))` in parameter
  `query_filter =`. The final LDAP filter looks like below:

```
# Part of file: ldap/sender_bcc_maps_user.cf

query_filter    = (&(|(mail=%s)(&(enabledService=shadowaddress)(shadowAddress=%s)))(objectClass=mailUser)(accountStatus=active)(enabledService=mail)(enabledService=senderbcc))
```

* Perform the same modification in file `/etc/postfix/ldap/recipient_bcc_maps_user.cf`,
  the final LDAP filter looks like below:

```
# Part of file: ldap/recipient_bcc_maps_user.cf

query_filter    = (&(|(mail=%s)(&(enabledService=shadowaddress)(shadowAddress=%s)))(objectClass=mailUser)(accountStatus=active)(enabledService=mail)(enabledService=recipientbcc))
```

Restarting Postfix service is required.

### Create additional SQL index for Amavisd database

We need one new SQL index for Amavisd database, it's used to speed up
performance of viewing quarantined mails.

__Note__: It may take long time if you have many records in sql table `amavisd.msgs`.

```
$ mysql -uroot -p
mysql> USE amavisd;
mysql> ALTER TABLE msgs ADD INDEX (quar_type);
```

## MySQL backend special

### Add 4 new columns used for per-user restriction

New version of iRedAPD (Postfix policy daemon) requires 4 new columns in table
`vmail.mailbox`:

* allowedsenders
* rejectedsenders
* allowedrecipients
* rejectedrecipients

They're used for per-user restriction. For example, you can now define who can
send email to your local user, or your user can send email to which external
domains or users.

Please login to MySQL server as root user, execute SQL commands to add required
columns and indexes.

```
# mysql -uroot -p
mysql> USE vmail;
mysql> ALTER TABLE mailbox ADD COLUMN allowedsenders TEXT NOT NULL DEFAULT '';
mysql> ALTER TABLE mailbox ADD COLUMN rejectedsenders TEXT NOT NULL DEFAULT '';
mysql> ALTER TABLE mailbox ADD COLUMN allowedrecipients TEXT NOT NULL DEFAULT '';
mysql> ALTER TABLE mailbox ADD COLUMN rejectedrecipients TEXT NOT NULL DEFAULT '';
```

Supported formats of sender/recipients are:

* `user@example.com`: single user
* `@example.com`: entire domain
* `@.example.com`: entire domain and all its sub domains
* `@.`: any users

Multiple senders/recipients must be separated by comma, for example:

```
sql> INSERT INTO mailbox SET allowedsenders='@gmail.com,user@example.com';
```

### Create additional SQL index for Amavisd database

We need one new SQL index for Amavisd database, it's used to speed up
performance of viewing quarantined mails.

__Note__: It may take long time if you have many records in sql table `amavisd.msgs`.

```
$ mysql -uroot -p
mysql> USE amavisd;
mysql> ALTER TABLE msgs ADD INDEX (quar_type);
```

## PostgreSQL backend special

### Add 4 new columns used for per-user restriction

New version of iRedAPD (Postfix policy daemon) requires 4 new columns in table
`vmail.mailbox`:

* allowedsenders
* rejectedsenders
* allowedrecipients
* rejectedrecipients

They're used for per-user restriction. For example, you can now define who can
send email to your local user, or your user can send email to which external
domains or users.

Please switch to PostgreSQL daemon user, then execute SQL commands to add
required new columns and indexes:

* On Linux, PostgreSQL daemon user is `postgres`.
* On FreeBSD, PostgreSQL daemon user is `pgsql`.
* On OpenBSD, PostgreSQL daemon user is `_postgresql`.

```
# su - postgres
$ psql -d vmail
sql> ALTER TABLE mailbox ADD COLUMN allowedsenders TEXT NOT NULL DEFAULT '';
sql> ALTER TABLE mailbox ADD COLUMN rejectedsenders TEXT NOT NULL DEFAULT '';
sql> ALTER TABLE mailbox ADD COLUMN allowedrecipients TEXT NOT NULL DEFAULT '';
sql> ALTER TABLE mailbox ADD COLUMN rejectedrecipients TEXT NOT NULL DEFAULT '';
```

Supported formats of sender/recipients are:

* `user@example.com`: single user
* `@example.com`: entire domain
* `@.example.com`: entire domain and all its sub domains
* `@.`: any users

Multiple senders/recipients must be separated by comma, for example:
```
sql> INSERT INTO mailbox SET allowedsenders='@gmail.com,user@example.com';
```

### Create additional SQL index for Amavisd database

We need one new SQL index for Amavisd database, it's used to speed up
performance of viewing quarantined mails.

__Note__: It may take long time if you have many records in sql table `amavisd.msgs`.

Please switch to PostgreSQL daemon user, then execute SQL commands to add required columns and indexes:

* On Linux, PostgreSQL daemon user is `postgres`.
* On FreeBSD, PostgreSQL daemon user is `pgsql`.
* On OpenBSD, PostgreSQL daemon user is `_postgresql`.
```
# su - postgres
$ psql -d amavisd
sql> CREATE INDEX idx_msgs_quar_type ON msgs (quar_type);
```
