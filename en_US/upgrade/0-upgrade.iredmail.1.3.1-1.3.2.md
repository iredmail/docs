# Upgrade iRedMail from 1.3.1 to 1.3.2

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

* Oct 28, 2020: initial release.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.3.2
```

### SOGo: yum and apt repositories for SOGo v4 has been removed permanently by upstream

SOGo team removed nightly builds for SOGo v4 + v3 permanently (FYI: <https://sogo.nu/bugs/view.php?id=5157>), __ALL__ servers must update yum/apt repository files and switch to SOGo v5.

Please follow our tutorial to upgrade:

- [Upgrade SOGo from v4 to v5](./upgrade.sogo.4.to.5.html)

### Upgrade iRedAPD (Postfix policy server) to the latest stable release (4.6)

!!! attention

    iRedAPD has been migrated to Python 3 and doesn't support Python 2 anymore.

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

### Upgrade mlmmjadmin to the latest stable release (3.0.4)

!!! attention

    mlmmjadmin has been migrated to Python 3 and doesn't support Python 2 anymore.

Please follow below tutorial to upgrade mlmmjadmin to the latest stable release:
[Upgrade mlmmjadmin to the latest stable release](./upgrade.mlmmjadmin.html)

### Upgrade iRedAdmin (open source edition) to the latest stable release (1.1)

!!! attention

    iRedAdmin has been migrated to Python 3 and doesn't support Python 2 anymore.

Please follow below tutorial to upgrade iRedAdmin to the latest stable release:
[Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html).

### Upgrade Roundcube webmail to the latest stable release (1.4.9)

!!! warning "Roundcube 1.4"

    Since Roundcube 1.3, at least __PHP 5.4__ is required. If your server is
    running PHP 5.3 and cannot upgrade to 5.4, please upgrade Roundcube
    the latest 1.2 branch instead.

All users are encouraged to upgrade the latest Roundcube release.

* [How to upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).

References:

- 05 July 2020, [Security updates 1.4.7, 1.3.14 and 1.2.11 released](https://roundcube.net/news/2020/07/05/security-updates-1.4.7-1.3.14-and-1.2.11)
- 07 June 2020, [Updates 1.4.6 and 1.3.13 released](https://roundcube.net/news/2020/06/07/updates-1.4.6-and-1.3.13-released)
- 02 June 2020, [Security updates 1.4.5 and 1.3.12 released](https://roundcube.net/news/2020/06/02/security-updates-1.4.5-and-1.3.12)

### Upgrade netdata to the latest stable release (1.26.0)

If you have netdata installed, you can upgrade it by following this tutorial:
[Upgrade netdata](./upgrade.netdata.html).

### Fixed: update Fail2ban filter rules to match new error log produced by latest Roundcube

Please run commands below as root user to get latest filter file for Roundcube:

```
cd /etc/fail2ban/filter.d/
wget -O roundcube.iredmail.conf https://raw.githubusercontent.com/iredmail/iRedMail/1.3.2/samples/fail2ban/filter.d/roundcube.iredmail.conf
```

Restarting `fail2ban` service is required.

### [OPTIONAL] Amavisd: Log matched virus database name

Please update parameter `@av_scanner` in Amavisd config file as described
below, so that Amavisd logs matched virus database name.

- On RHEL/CentOS, it's `/etc/amavisd/amavisd.conf`
- On Debian/Ubuntu, it's `/etc/amavis/conf.d/50-user`
- On FreeBSD, it's `/usr/local/etc/amavisd.conf`
- On OpenBSD, it's `/etc/amavisd.conf`

Find parameter `@av_scanner` like below:

```
@av_scanners = (
    ...
    qr/\bOK$/,
    qr/\bFOUND$/,
    qr/^.*?: (?!Infected Archive)(.*) FOUND$/ ],
);
```

Append letter `m` after `OK$/` and `FOUND$/` like below:

```
@av_scanners = (
    ...
    qr/\bOK$/m,
    qr/\bFOUND$/m,
    qr/^.*?: (?!Infected Archive)(.*) FOUND$/m ],
);
```

Restarting Amavisd service is required.

## OpenLDAP backend

### Fixed: can not store mail sender address with utf8 characters in `amavisd` database

In `amavisd` database, column `msgs.from_addr` is defined as `VARCHAR(255)`, it
doesn't support emoji characters. Please login to MySQL/MariaDB server as `root`
user or `amavisd` user, then run SQL commands below to fix it:

```
USE amavisd;
ALTER TABLE msgs MODIFY COLUMN from_addr VARBINARY(255) NOT NULL DEFAULT '';
```

## MySQL/MariaDB backends

### Fixed: can not store mail sender address with utf8 characters in `amavisd` database

In `amavisd` database, column `msgs.from_addr` is defined as `VARCHAR(255)`, it
doesn't support emoji characters. Please login to MySQL/MariaDB server as `root`
user or `amavisd` user, then run SQL commands below to fix it:

```
USE amavisd;
ALTER TABLE msgs MODIFY COLUMN from_addr VARBINARY(255) NOT NULL DEFAULT '';
```

