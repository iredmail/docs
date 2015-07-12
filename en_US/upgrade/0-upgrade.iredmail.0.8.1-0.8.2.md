# Upgrade iRedMail from 0.8.1 to 0.8.2

[TOC]

## ChangeLog

> We provide remote upgrade service, check [the price](../support.html) and [contact us](../contact.html).

* 2012-09-21: Add link of upgrading iRedAdmin open source edition.
* 2012-09-21: Add link of upgrading iRedAPD.
* 2012-09-21: Add link of upgrading Roundcube webmail.
* 2012-09-21: [LDAP] checkpoint setting must be added after line "suffix dc=xxx,dc=xxx". Thanks Jonathan Vomacka <jjvomacka _at_ gmail.com> for the report.
* 2012-09-08: Add SQL changes for MySQL and PostgreSQL backend, 3 new columns are required: mailbox.isadmin, mailbox.isglobaladmin, mailbox.language.
* 2012-09-08: Remove SpamAssassin score setting: SPF_PASS, SPF_FAIL.
* 2012-06-22: [LDAP] Add checkpoint setting in slapd.conf, used for BDB recovery
* 2012-06-22: [LDAP] Return correct maildir path while using virtual transport.
* 2012-06-21: Add missing log rotate setting for Dovecot log files on OpenBSD and FreeBSD.
* 2012-06-17: [LDAP] Use the latest iRedMail LDAP schema file.
* 2012-06-14: Fix incorrect log rotate setting for iRedAPD on FreeBSD.

## General (All backends should apply these upgrade steps)

### Update /etc/iredmail-release with iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
# File: /etc/iredmail-release

0.8.2
```

### Upgrade Roundcube webmail to the latest stable release

Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release immediately: [How to upgrade Roundcube](http://trac.roundcube.net/wiki/Howto_Upgrade)

### Upgrade iRedAPD (Postfix policy server) to the latest stable release

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[How to upgrade iRedAPD-1.4.0 or later versions to the latest stable release](./upgrade.iredapd.html)

### Upgrade iRedAdmin (open source edition) to the latest stable release

Please follow this tutorial to upgrade iRedAdmin open source edition to the
latest stable release: [Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html)

### Remove improper SpamAssassin SPF score settings

Please remove below two settings in SpamAssassin config file:

    * On Linux and OpenBSD, it's `/etc/mail/spamassassin/local.cf`.
    * On FreeBSD, it's `/usr/local/etc/mail/spamassassin/local.cf`.

```
# Part of file: etc/mail/spamassassin/local.cf

score SPF_PASS -10.000
score SPF_FAIL 5.00
```

### Add missing log rotate settings for Dovecot log files on OpenBSD

__NOTE__: This is only applicable to OpenBSD.

Please add below two lines in `/etc/newsyslog.conf` to rotate Dovecot log
files: `/var/log/dovecot.log`, `/var/log/sieve.log`.

```
# Part of file: /etc/newsyslog.conf

/var/log/dovecot.log    vmail:vmail     600  7     *    24    Z "doveadm log reopen"
/var/log/sieve.log      vmail:vmail     600  7     *    24    Z "doveadm log reopen"
```

### Add missing log rotate settings for Dovecot log files on FreeBSD

__NOTE__: This fix is only applicable to FreeBSD.

Please add below two lines in `/etc/newsyslog.conf` to rotate Dovecot log
files: `/var/log/dovecot.log`, `/var/log/sieve.log`.

```
# Part of file: /etc/newsyslog.conf

/var/log/dovecot.log    vmail:vmail     600  7     *    24    Z    /var/run/dovecot/master.pid
/var/log/sieve.log      vmail:vmail     600  7     *    24    Z    /var/run/dovecot/master.pid
```

### Fix incorrect rotate setting for iRedAPD log file on FreeBSD

__NOTE__: This fix is only applicable to FreeBSD.

iRedMail-0.8.1 defines incorrectly path of iRedAPD PID file in
`/etc/newsyslog.conf`, so please fix it manually by editing `/etc/newsyslog.conf`.

* Make sure you have below line in `/etc/newsyslog.conf`:

```
# Part of file: /etc/newsyslog.conf

/var/log/iredapd.log    root:wheel      640  7     *    24    Z /var/run/iredapd.pid
```

Be careful, don't use quotes around path of pid file.

* Then restart syslogd service:

```
# /etc/rc.d/syslogd restart
```

## OpenLDAP backend special

### Use the newest schema file

Changes in the newest LDAP schema file shipped in iRedMail-0.8.2:

* It allows normal mail user to use attribute `domainGlobalAdmin`. With this
  attribute, you can mark mail user as a global admin to manage mail accounts
  with iRedAdmin-Pro.
* It allows mail list to use `shadowAddress` for alias domain support.

To use the newest iRedMail ldap schem file, we have to:

* Download the newest iRedMail ldap schema file
* Copy old ldap schema file as a backup copy
* Replace the old one
* Restart OpenLDAP service.

Here we go:

* On RHEL/CentOS/Scientific Linux (both release 5.x and 6.x), openSUSE, Gentoo, OpenBSD:

```
# cd /tmp
# wget https://bitbucket.org/zhb/iredmail/raw/a4d8b730d147/iRedMail/samples/iredmail.schema

# cd /etc/openldap/schema/
# cp iredmail.schema iredmail.schema.bak

# cp -f /tmp/iredmail.schema /etc/openldap/schema/
# /etc/init.d/slapd restart       # <-- Or: /etc/init.d/ldap restart
```

* On Debian/Ubuntu:
```
# cd /tmp
# wget https://bitbucket.org/zhb/iredmail/raw/a4d8b730d147/iRedMail/samples/iredmail.schema

# cd /etc/ldap/schema/
# cp iredmail.schema iredmail.schema.bak

# cp -f /tmp/iredmail.schema /etc/ldap/schema/
# /etc/init.d/slapd restart
```

* On FreeBSD:
```
# cd /tmp
# wget https://bitbucket.org/zhb/iredmail/raw/a4d8b730d147/iRedMail/samples/iredmail.schema

# cd /usr/local/etc/ldap/schema/
# cp iredmail.schema iredmail.schema.bak

# cp -f /tmp/iredmail.schema /usr/local/etc/openldap/schema/
# /etc/init.d/slapd restart
```

### Return correct maildir path while using `virtual` transport

Postfix setting `virtual_mailbox_maps` doesn't return correct maildir path.
Usually, this is fine because iRedMail uses transport program provided by
Dovecot (command name `deliver`). But if you want to use Postfix built-in
transport program `virtual`, mails will be delivered to incorrect path.

To fix it, please open `/etc/postfix/ldap/virtual_mailbox_maps.cf` (on Linux
and OpenBSD) or `/usr/local/etc/postfix/ldap/virtual_mailbox_maps.cf` (on
FreeBSD), append parameter `result_format = %s/Maildir/` line after line
`result_attribute= mailMessageStore`.

```
# Part of file: etc/postfix/ldap/virtual_mailbox_maps.cf

result_attribute = mailMessageStore
result_format   = %s/Maildir/
```

Restarting Postfix service is required.

### Add checkpoint setting in slapd.conf, used for BDB recovery

Add below lines in your OpenLDAP config file, `slapd.conf`, after the line
`suffix dc=xxx,dc=xxx`. Please read comments below for more details about what
it's used for.

    * On RHEL/CentOS/Scientific Linux, openSUSE, Gentoo, OpenBSD, it's `/etc/openldap/slapd.conf`.
    * On Debian, Ubuntu, it's `/etc/ldap/slapd.conf`.
    * On FreeBSD, it's `/usr/local/etc/openldap/slapd.conf`.

```
# Part of file: slapd.conf

# This directive specifies how often to checkpoint the BDB transaction log.
# A checkpoint operation flushes the database buffers to disk and writes a
# checkpoint record in the log. The checkpoint will occur if either <kbyte>
# data has been written or <min> minutes have passed since the last checkpoint.
# Both arguments default to zero, in which case they are ignored. When the
# <min> argument is non-zero, an internal task will run every <min> minutes
# to perform the checkpoint. See the Berkeley DB reference guide for more
# details.
#
# OpenLDAP default is NO CHECKPOINTING.
#
# whenever 128kb data bytes written or 5 minutes has elapsed
checkpoint  128 5
```

Restarting OpenLDAP service is required.

## MySQL backend special

### Add 3 new columns required by iRedAdmin

New version of iRedAdmin (both open source edition and iRedAdmin-Pro) requires
three new columns: `mailbox.isadmin`, `mailbox.isglobaladmin`,
`mailbox.language`.

    * With `mailbox.isadmin=1`, this user is a domain admin.
    * With `mailbox.isadmin=1` AND `mailbox.isglobaladmin=1`, this user is a
      global admin.
    * Column `mailbox.language` is used to store short code of language. e.g.
      de_DE for German, cs_CZ for Czech.

Please login to MySQL server as root user, execute SQL commands to add required
columns and indexes.
```
# mysql -uroot -p
mysql> USE vmail;
mysql> ALTER TABLE mailbox ADD COLUMN isadmin TINYINT(1) NOT NULL DEFAULT 0;
mysql> ALTER TABLE mailbox ADD COLUMN isglobaladmin TINYINT(1) NOT NULL DEFAULT 0;
mysql> ALTER TABLE mailbox ADD COLUMN language VARCHAR(5) NOT NULL DEFAULT 'en_US';
mysql> ALTER TABLE mailbox ADD INDEX (isadmin);
mysql> ALTER TABLE mailbox ADD INDEX (isglobaladmin);
```

## PostgreSQL backend special

### Add 3 new columns required by iRedAdmin

New version of iRedAdmin (both open source edition and iRedAdmin-Pro) requires
three new columns: `mailbox.isadmin`, `mailbox.isglobaladmin`,
`mailbox.language`.

    * With `mailbox.isadmin=1`, this user becomes a domain admin.
    * With `mailbox.isadmin=1` AND `mailbox.isglobaladmin=1`, this user becomes
      a global admin.
    * Column `mailbox.language` is used to store short code of language. e.g.
      de_DE for German, cs_CZ for Czech.

Please switch to PostgreSQL daemon user, then execute SQL commands to add required columns and indexes:

    * On Linux, PostgreSQL daemon user is `postgres`.
    * On FreeBSD, PostgreSQL daemon user is `pgsql`.
    * On OpenBSD, PostgreSQL daemon user is `_postgresql`.

```
# su - postgres
$ psql -d vmail
sql> ALTER TABLE mailbox ADD COLUMN isadmin INT2 NOT NULL DEFAULT 0;
sql> ALTER TABLE mailbox ADD COLUMN isglobaladmin INT2 NOT NULL DEFAULT 0;
sql> ALTER TABLE mailbox ADD COLUMN language VARCHAR(5) NOT NULL DEFAULT 'en_US';
sql> CREATE INDEX idx_mailbox_isadmin ON mailbox (isadmin);
sql> CREATE INDEX idx_mailbox_isglobaladmin ON mailbox (isglobaladmin);
```
