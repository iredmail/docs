# Upgrade iRedMail from 1.0 to 1.1

[TOC]

!!! warning

    THIS IS A __DRAFT__ DOCUMENT, DO __NOT__ APPLY IT.

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

TODO

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.1
```

### Upgrade iRedAPD (Postfix policy server) to the latest stable release

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

### Upgrade iRedAdmin (open source edition) to the latest stable release

Please follow this tutorial to upgrade iRedAdmin open source edition to the
latest stable release:
[Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html)

### Upgrade mlmmjadmin to the latest stable release

Please follow below tutorial to upgrade mlmmjadmin to the latest stable release:
[Upgrade mlmmjadmin to the latest stable release](./upgrade.mlmmjadmin.html)

### Upgrade Roundcube webmail to the latest stable release

!!! warning "Roundcube 1.4"

    Since Roundcube 1.3, at least __PHP 5.4__ is required. If your server is
    running PHP 5.3 and cannot upgrade to 5.4, please upgrade Roundcube
    the latest 1.2 branch instead.

The latest Roundcube webmail 1.4.1 offers a shiny new web UI.
Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release (1.4.1):

* [How to upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).

### Upgrade netdata to the latest stable release

If you have netdata installed, you can upgrade it by following this tutorial:
[Upgrade netdata](./upgrade.netdata.html).

### Fixed: SOGo backup script doesn't relies on Python anymore

SOGo backup script `/var/vmail/backup/backup_sogo.sh` shipped in iRedMail-1.0
and earlier releases relies on Python to calculate the date of old backup for
removal, but not anymore in iRedMail-1.1. Please download the latest version
and override the one on your system:

```
cd /var/vmail/backup/
wget -O backup_sogo.sh https://github.com/iredmail/iRedMail/raw/1.1/tools/backup_sogo.sh
chown root backup_sogo.sh
chmod 0500 backup_sogo.sh
```

## For OpenLDAP backend

### Fixed: OpenLDAP backup script doesn't relies on Python anymore

OpenLDAP backup script `/var/vmail/backup/backup_openldap.sh` shipped in iRedMail-1.0
and earlier releases relies on Python to calculate the date of old backup for
removal, but not anymore in iRedMail-1.1. Please download the latest version
and override the one on your system:

```
cd /var/vmail/backup/
wget -O backup_openldap.sh https://github.com/iredmail/iRedMail/raw/1.1/tools/backup_openldap.sh
chown root backup_openldap.sh
chmod 0500 backup_openldap.sh
```

## For MySQL/MariaDB backends

### Fixed: MySQL backup script doesn't relies on Python anymore

Backup script `/var/vmail/backup/backup_mysql.sh` shipped in iRedMail-1.0
and earlier releases relies on Python to calculate the date of old backup for
removal, but not anymore in iRedMail-1.1. Please download the latest version
and override the one on your system:

```
cd /var/vmail/backup/
wget -O backup_mysql.sh https://github.com/iredmail/iRedMail/raw/1.1/tools/backup_mysql.sh
chown root backup_mysql.sh
chmod 0500 backup_mysql.sh
```

## For PostgreSQL backend

### Fixed: PostgreSQL backup script doesn't relies on Python anymore

Backup script `/var/vmail/backup/backup_pgsql.sh` shipped in iRedMail-1.0
and earlier releases relies on Python to calculate the date of old backup for
removal, but not anymore in iRedMail-1.1. Please download the latest version
and override the one on your system:

```
cd /var/vmail/backup/
wget -O backup_pgsql.sh https://github.com/iredmail/iRedMail/raw/1.1/tools/backup_pgsql.sh
chown root backup_pgsql.sh
chmod 0500 backup_pgsql.sh
```

