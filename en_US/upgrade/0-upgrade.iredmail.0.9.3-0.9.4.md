# Upgrade iRedMail from 0.9.3 to 0.9.4

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](../support.html) and [contact us](../contact.html).

## ChangeLog

* 2016-01-25: Initial publish.

## General (All backends should apply these steps)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
# File: /etc/iredmail-release

0.9.4
```

### Upgrade iRedAPD (Postfix policy server) to the latest 1.8.0

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

Detailed release notes are available [here](./iredapd.releases.html).

### Upgrade iRedAdmin (open source edition) to the latest stable release

Please follow this tutorial to upgrade iRedAdmin open source edition to the
latest stable release:
[Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html)

### Upgrade Roundcube webmail to the latest stable release

Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release immediately: [How to upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).

Note: package `rsync` must be installed on your server before upgrading.

### Fixed: No daily cron job to backup SQL/LDAP database

In iRedMail-0.9.3, there's no daily cron job to backup SQL/LDAP databases.
Please add them manually with command `crontab -e -u root`.

> If you downloaded iRedMail-0.9.3 right after it had been released, the daily
> cron job which is used to backup SQL/LDAP database is missing. We re-packed
> iRedMail-0.9.3 with this fix to avoid trouble for users. So if don't have this
> cron job, please add it by following steps below. If you already have it,
> it's safe to ignore steps below.

> Notes:
>
> * Please make sure the path to backup scripts
>   (`/var/vmail/backup/backup_XXX.sh`) are correct.
>
> * On FreeBSD and OpenBSD, the path of `bash` shell is `/usr/local/bin/bash`.

* For OpenLDAP backend, you need 2 daily cron jobs, one for SQL database, one
  another one for LDAP:

```
# iRedMail: Backup OpenLDAP data (at 03:00 AM)
0   3   *   *   *   /bin/bash /var/vmail/backup/backup_openldap.sh

# iRedMail: Backup MySQL databases (at 03:30AM)
30   3   *   *   *   /bin/bash /var/vmail/backup/backup_mysql.sh
```

* For MySQL/MariaDB backends, you need 1 daily cron job:

```
# iRedMail: Backup MySQL databases (at 03:30AM)
30   3   *   *   *   /bin/bash /var/vmail/backup/backup_mysql.sh
```

* For PostgreSQL backend, you need 1 daily cron job:
```
# iRedMail: Backup PostgreSQL databases (at 03:01AM)
1   3   *   *   *   /bin/bash /var/vmail/backup/backup_pgsql.sh
```

### FreeBSD: Fix incorrect file permission of /etc/mail/mailer.conf

> This is applicable to only FreeBSD.

iRedMail generates /etc/mail/mailer.conf with permission 0600 during
installation, but it should be world-readable. Please fix this issue with
command below:

```
chmod +r /etc/mail/mailer.conf
```

### OpenBSD: Fixed: Not open port 25 in firewall rule

> This is applicable to only OpenBSD.

The sample PF firewall rule shipped in iRedMail-0.9.3 doesn't enable port 25
by default, please add service name `smtp` in `mail_services=` manually, then
reload pf rules.

* Add service name `smtp` in parameter `mail_services=` in `/etc/pf.conf`:

```
mail_services="{ ... smtp}"
```

* Reload pf firewall:

```
# pfctl -d
# pfctl -ef /etc/pf.conf
```
