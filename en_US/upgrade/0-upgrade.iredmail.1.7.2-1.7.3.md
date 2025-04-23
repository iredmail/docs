# Upgrade iRedMail from 1.7.2 to 1.7.3

!!! attention

	 Check out the on-premises, lightweight email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! note "Remote Upgrade Assistance"

    Check out our [remote upgrade support](https://www.iredmail.org/support.html) if you need assistance.

## ChangeLog

- Apr 10, 2025: fix incorrect ldap schema file.
- Apr 4, 2025: initial publish.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.7.3
```

### Upgrade iRedAPD (Postfix policy server) to the latest stable release (5.9.0)

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

### Upgrade mlmmjadmin to the latest stable release (3.3.1)

Please follow below tutorial to upgrade mlmmjadmin to the latest stable release:
[Upgrade mlmmjadmin to the latest stable release](./upgrade.mlmmjadmin.html)

### Upgrade Roundcube webmail to the latest stable release (1.6.10 or 1.5.9)

!!! warning "CentOS 7: please stick to Roundcube 1.5.2"

    __It's time to leave your comfort zone and upgrade this server to at least
    CentOS Stream 8 or [Rocky Linux 8](https://docs.rockylinux.org/guides/migrate2rocky/).__

    If you're running CentOS 7, please upgrade to Roundcube 1.5.2 instead.
    Roundcube 1.5.3 requires PHP-7, but CentOS 7 ships PHP-5.4 which is not
    supported by Roundcube 1.5.3 and later releases, including 1.6.x.

    __Unfortunately, Roundcube 1.5.2 does NOT contains multiple security fixes
    which shipped in Roundcube 1.5.6 and 1.6.5.__

!!! warning "Ubuntu 18.04: please stick to Roundcube 1.5.9"

    Ubuntu 18.04 runs old php version which is not supported by Roundcube 1.6.

* [Upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).

### Upgrade netdata to the latest stable release (v2.3.2)

If you have netdata installed, you can upgrade it by following this tutorial:
[Upgrade netdata](./upgrade.netdata.html).

## For OpenLDAP backend

### Update LDAP schema file

New schema allows mail user account to use 2 more attributes: `recoveryEmail`, `birthday`.

Download the latest iRedMail LDAP schema file:

* On RHEL/CentOS:

```
wget -O /tmp/iredmail.schema https://github.com/iredmail/iRedMail/raw/1.7.3/samples/iredmail/iredmail.schema
mv /etc/openldap/schema/iredmail.schema{,.bak}
cp -f /tmp/iredmail.schema /etc/openldap/schema/
service slapd restart
```

* On Debian/Ubuntu:
```
wget -O /tmp/iredmail.schema https://github.com/iredmail/iRedMail/raw/1.7.3/samples/iredmail/iredmail.schema
mv /etc/ldap/schema/iredmail.schema{,.bak}
cp -f /tmp/iredmail.schema /etc/ldap/schema/
service slapd restart
```

* On FreeBSD:

```
wget -O /tmp/iredmail.schema https://github.com/iredmail/iRedMail/raw/1.7.3/samples/iredmail/iredmail.schema
mv /usr/local/etc/openldap/schema/iredmail.schema{,.bak}
cp -f /tmp/iredmail.schema /usr/local/etc/openldap/schema/
service slapd restart
```

* On OpenBSD:

```
ftp -o /tmp/iredmail.schema https://github.com/iredmail/iRedMail/raw/1.7.3/samples/iredmail/iredmail.schema
mv /etc/openldap/schema/iredmail.schema{,.bak}
cp -f /tmp/iredmail.schema /etc/openldap/schema/
rcctl restart slapd
```

### Add new columns in SQL table `iredadmin.deleted_mailboxes`

Two new SQL columns are introduced in `iredadmin.deleted_mailboxes` table: `bytes`, `messages`.

Please run shell commands below to add them:

```
wget -O /tmp/iredadmin.mysql https://github.com/iredmail/iRedMail/raw/1.7.3/update/1.7.3/iredadmin.mysql
mysql iredadmin < /tmp/iredadmin.mysql
rm -f /tmp/iredadmin.mysql
```

## For MariaDB backend

### Add new columns in `vmail` database

Please run shell commands below to add new SQL columns:

- 6 columns in `vmail.mailbox` table: `first_name`, `last_name`, `mobile`, `telephone`, `birthday`, `recovery_email`.
- 2 columns in `vmail.deleted_mailboxes` table: `bytes`, `messages`.

```
wget -O /tmp/vmail.mysql https://github.com/iredmail/iRedMail/raw/1.7.3/update/1.7.3/vmail.mysql
mysql vmail < /tmp/vmail.mysql
rm -f /tmp/vmail.mysql
```

## For PostgreSQL backend

### Add new columns in `vmail` database

Please run shell commands below to add new SQL columns:

- 6 columns in `vmail.mailbox` table: `first_name`, `last_name`, `mobile`, `telephone`, `birthday`, `recovery_email`.
- 2 columns in `vmail.deleted_mailboxes` table: `bytes`, `messages`.

```
wget -O /tmp/vmail.pgsql https://github.com/iredmail/iRedMail/raw/1.7.3/update/1.7.3/vmail.pgsql
su - postgres
psql -d vmail < /tmp/vmail.pgsql
```
