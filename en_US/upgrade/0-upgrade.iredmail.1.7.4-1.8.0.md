# Upgrade iRedMail from 1.7.4 to 1.8.0

!!! attention

    - iRedMail team recommends [iRedMail Enterprise Edition](https://www.iredmail.org/ee.html) for deploying new email server.
    - Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! note "Remote Upgrade Assistance"

    Check out our [remote upgrade support](https://www.iredmail.org/support.html) if you need assistance.

## ChangeLog

- Apr 14, 2026: initial publish.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.8.0
```

### Upgrade iRedAPD (Postfix policy server) to the latest stable release (6.1)

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

### Upgrade mlmmjadmin to the latest stable release (3.6.2)

Please follow below tutorial to upgrade mlmmjadmin to the latest stable release:
[Upgrade mlmmjadmin to the latest stable release](./upgrade.mlmmjadmin.html)

### Upgrade iRedAdmin (open source edition) to the latest stable release (2.8.1)

Please follow below tutorial to upgrade iRedAdmin to the latest stable release:
[Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html).

### Upgrade Roundcube webmail to the latest release (1.6.15 or 1.5.15)

!!! warning "Roundcube Security Fixes"

    - [Roundcube 1.6.12 addressed 2 security vulnerabilities.](https://roundcube.net/news/2025/12/13/security-updates-1.6.12-and-1.5.12)
    - [Roundcube 1.6.13 addressed 2 security vulnerabilities.](https://roundcube.net/news/2026/02/08/security-updates-1.6.13-and-1.5.13)
    - [Roundcube 1.6.14 addressed 3 security vulnerabilities.](https://roundcube.net/news/2026/03/18/security-updates-1.7-rc5-1.6.14-1.5.14)
    - [Roundcube 1.6.15 addressed 1 security vulnerability.](https://roundcube.net/news/2026/03/29/security-updates-1.7-rc6-1.6.15-1.5.15)

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

### Upgrade netdata to the latest stable release (v2.10.1)

If you have netdata installed, you can upgrade it by following this tutorial:
[Upgrade netdata](./upgrade.netdata.html).
