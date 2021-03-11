# Upgrade iRedMail from 1.3.2 to 1.4.0

[TOC]

!!! warning

    THIS IS A DRAFT DOCUMENT, DO NOT APPLY IT.

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

* XX XX, 2021: initial release.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.4.0
```

### Upgrade iRedAPD (Postfix policy server) to the latest stable release (5.0)

!!! attention

    iRedAPD has been migrated to Python 3 and doesn't support Python 2 anymore.

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

### Upgrade iRedAdmin (open source edition) to the latest stable release (1.2)

!!! attention

    iRedAdmin has been migrated to Python 3 and doesn't support Python 2 anymore.

Please follow below tutorial to upgrade iRedAdmin to the latest stable release:
[Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html).

### Upgrade mlmmjadmin to the latest stable release (3.1)

Please follow below tutorial to upgrade mlmmjadmin to the latest stable release:
[Upgrade mlmmjadmin to the latest stable release](./upgrade.mlmmjadmin.html)

### Upgrade Roundcube webmail to the latest stable release (1.4.11)

!!! warning "Roundcube 1.4"

    Since Roundcube 1.3, at least __PHP 5.4__ is required. If your server is
    running PHP 5.3 and cannot upgrade to 5.4, please upgrade Roundcube
    the latest 1.2 branch instead.

Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release:

* [How to upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).

### Upgrade netdata to the latest stable release (1.29.3)

If you have netdata installed, you can upgrade it by following this tutorial:
[Upgrade netdata](./upgrade.netdata.html).

### Fail2ban: Fixed few issues in script `/usr/local/bin/fail2ban_banned_db`

Script `/usr/local/bin/fail2ban_banned_db` shipped in iRedMail-1.3.2 and
earlier releases have few issues:

- It can not store IP address when its country name contains quotes
- In some cases it can not correctly store matched log lines in SQL database.
  We now store (base64) encoded log lines instead, it also helps avoid possible
  SQL injection.

Please run command below as root user to get latest script with both issues fixed:

```
wget -O /usr/local/bin/fail2ban_banned_db \
    https://github.com/iredmail/iRedMail/raw/1.4.0/samples/fail2ban/bin/fail2ban_banned_db
```

Restarting `fail2ban` service is required.


## For OpenLDAP backend

### Update iRedMail LDAP schema file

iRedMail-1.4.0 introduces 2 new LDAP attributes for subscribeable mailing list:

* `listModerator`: used to store moderators' email address of mailing list.
* `listOwner`: used to store owners' email address of mailing list.

With these new attributes, if self-service is enabled in iRedAdmin-Pro,
mailing list owner is able to login to iRedAdmin-Pro and manage profile and
members of owned mailing lists.

Download the latest iRedMail LDAP schema file

* On RHEL/CentOS:

```
wget -O /tmp/iredmail.schema https://github.com/iredmail/iRedMail/raw/1.4.0/samples/iredmail/iredmail.schema
mv /etc/openldap/schema/iredmail.schema{,.bak}
cp -f /tmp/iredmail.schema /etc/openldap/schema/
service slapd restart
```

* On Debian/Ubuntu:
```
wget -O /tmp/iredmail.schema https://github.com/iredmail/iRedMail/raw/1.4.0/samples/iredmail/iredmail.schema
mv /etc/ldap/schema/iredmail.schema{,.bak}
cp -f /tmp/iredmail.schema /etc/ldap/schema/
service slapd restart
```

* On FreeBSD:

```
wget -O /tmp/iredmail.schema https://github.com/iredmail/iRedMail/raw/1.4.0/samples/iredmail/iredmail.schema
mv /usr/local/etc/openldap/schema/iredmail.schema{,.bak}
cp -f /tmp/iredmail.schema /usr/local/etc/openldap/schema/
service slapd restart
```

* On OpenBSD:

    > Note: if you're running ldapd as LDAP server, the schema directory is
    > `/etc/ldap`, and service name is `ldapd`.

```
cd /tmp
ftp https://github.com/iredmail/iRedMail/raw/1.0/samples/iredmail/iredmail.schema
mv /etc/openldap/schema/iredmail.schema{,.bak}
cp -f /tmp/iredmail.schema /etc/openldap/schema/
rcctl restart slapd
```

## For MySQL and MariaDB backends

#### Add new SQL table `vmail.maillist_owners` and drop 4 unused columns

- New SQL table `vmail.maillist_owners` is used to store owners' email addresses
  of subscribeable mailing lists. With this new table, if self-service is enabled
  in iRedAdmin-Pro, mailing list owner is able to login to iRedAdmin-Pro and
  manage profile and members of owned mailing lists.
- 4 columns in sql table `vmail.mailbox` are not used anymore, it's safe to
  drop them now:
    - `allowedsenders`
    - `rejectedsenders`
    - `allowedrecipients`
    - `rejectedrecipients`

Download plain SQL file used to apply changes, then import it directly as
MySQL root user (Please run commands below as `root` user):

```
wget -O /tmp/iredmail.mysql https://github.com/iredmail/iRedMail/raw/1.4.0/update/1.4.0/iredmail.mysql
mysql vmail < /tmp/iredmail.mysql
rm -f /tmp/iredmail.mysql
```

## For PostgreSQL backend

#### Add new SQL table `vmail.maillist_owners` and drop 4 unused columns

- New SQL table `vmail.maillist_owners` is used to store owners' email addresses
  of subscribeable mailing lists. With this new table, if self-service is enabled
  in iRedAdmin-Pro, mailing list owner is able to login to iRedAdmin-Pro and
  manage profile and members of owned mailing lists.
- 4 columns in sql table `vmail.mailbox` are not used anymore, it's safe to
  drop them now:
    - `allowedsenders`
    - `rejectedsenders`
    - `allowedrecipients`
    - `rejectedrecipients`

Download plain SQL file used to apply changes:

```
wget -O /tmp/iredmail.pgsql https://github.com/iredmail/iRedMail/raw/1.4.0/update/1.4.0/iredmail.pgsql
chmod +r /tmp/iredmail.pgsql
```

* Connect to PostgreSQL server as `postgres` user and import the SQL file:
    * on Linux, it's `postgres` user
    * on FreeBSD, it's `pgsql` user
    * on OpenBSD, it's `_postgresql` user

```
su - postgres
psql -d vmail < /tmp/iredmail.pgsql
```

* Remove downloaded file:

```
rm -f /tmp/iredmail.pgsql
```
