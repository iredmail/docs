# Upgrade iRedMail from 0.8.5 to 0.8.6

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](../support.html) and [contact us](../contact.html).

!!! note

    Policyd doesn't provide upgrade tutorial officially, so
    if you're running Policyd-1.8, please stay with it right now. Be patient
    and wait for our upgrade tutorial if you want to upgrade to Cluebringer.

## ChangeLog

> We provide remote upgrade service, check [the price](../support.html) and [contact us](../contact.html).

* 2014-01-08: Remove backup mx related sections, it's wrong.
* 2013-12-17: New section: Alter Cluebringer database.
* 2013-12-17: public release.
* 2013-11-30: Check whether hosted domain is backup mx or not in Postfix transport map query.
* 2013-09-14: Add cron job to cleanup Cluebringer database.
* 2013-09-2: Enable Opportunistic TLS support in Postfix when sending mail to remote SMTP server.
* 2013-08-25: Upgrade Roundcube to 0.9.3.

## General (All backends must apply these steps)

### Update /etc/iredmail-release with iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
# File: /etc/iredmail-release

0.8.6
```

### Upgrade Roundcube webmail to the latest stable release

Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release immediately: [How to upgrade Roundcube](http://trac.roundcube.net/wiki/Howto_Upgrade)

### Upgrade iRedAPD (Postfix policy server) to the latest stable release

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

### Upgrade iRedAdmin (open source edition) to the latest stable release

Please follow this tutorial to upgrade iRedAdmin open source edition to the
latest stable release: [Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html)

### Upgrade phpMyAdmin to the latest stable release

Please follow this short tutorial to upgrade phpMyAdmin to the latest stable
release: http://docs.phpmyadmin.net/en/latest/setup.html#upgrading-from-an-older-version

### Enable Opportunistic TLS support in Postfix when sending mail to remote SMTP server

This feature is used to secure your mail transaction when sending email from
your iRedMail server (Postfix) to remote SMTP server. Refer to Postfix document
for more technical details: [smtp_tls_security_level](http://www.postfix.org/postconf.5.html#smtp_tls_security_level)

* Add required parameters in Postfix:

```
# postconf -e smtp_tls_security_level='may'
# postconf -e smtp_tls_CAfile='$smtpd_tls_CAfile'
```

* Then restart Postfix service:

```
# ---- On Linux ----
# /etc/init.d/postfix restart

# ---- On FreeBSD ----
# /usr/local/etc/rc.d/postfix restart

# ---- On OpenBSD ----
# /etc/rc.d/postfix restart
```

### Alter Cluebringer database

__IMPORTANT NOTE__: This step is required if you're running Cluebringer. And
please skip this step if you're running Policyd-1.8.

For better management, we have to do some modification on Cluebringer database,
for example, add new columns, add new indexes. We have a SQL file you can use
to finish this in one step.

Please download below two SQL files shipped in iRedMail-0.8.6, and save it as
file /root/extra.sql, and /root/column_character_set.mysql:

* https://bitbucket.org/zhb/iredmail/raw/4d7b14fc40bb2467fb4efcc4ce08ac9fc037224c/iRedMail/samples/cluebringer/extra.sql
* https://bitbucket.org/zhb/iredmail/raw/4d7b14fc40bb2467fb4efcc4ce08ac9fc037224c/iRedMail/samples/cluebringer/column_character_set.mysql

For MySQL, please login to MySQL server as `root` user and import this sql file:

```
# mysql -uroot -p
mysql> USE cluebringer;
mysql> SOURCE /root/extra.sql;
mysql> SOURCE /root/column_character_set.mysql;
```

For PostgreSQL, please login to PostgreSQL admin user `postgres` and import
this sql file:

```
# su - postgres
$ psql -d cluebringer
sql> \i /root/extra.sql;
```

That's all.

### Add cron job to cleanup Cluebringer database

__IMPORTANT NOTE__: This step is required if you're running Cluebringer. And
please skip this step if you're running Policyd-1.8.

We have to delete old/expired entries from database to keep SQL query fast.

NOTE: On RHEL/CentOS and openSUSE, you must update cluebringer package to
version '2.0.13-3' with yum first:

```
# yum update cluebringer
```

* Add cron job with command `crontab`:

```
# crontab -e -u root
```

Now add cron job:

*  On RHEL/CentOS, openSUSE
```
1   3   *   *   *   /usr/sbin/cbpadmin --config=/etc/policyd/cluebringer.conf --cleanup > /dev/null
```

* On Debian/Ubuntu:
```
1   3   *   *   *   /usr/sbin/cbpadmin --config=/etc/cluebringer/cluebringer.conf --cleanup > /dev/null
```

* On FreeBSD:
```
1   3   *   *   *   /usr/local/bin/cbpadmin --config=/usr/local/etc/cluebringer.conf --cleanup > /dev/null
```

* On OpenBSD: not required since OpenBSD doesn't have cluebringer package installed.
