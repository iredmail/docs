# Upgrade iRedMail from 1.7.3 to 1.7.4

!!! attention

	 Check out the on-premises, lightweight email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! note "Remote Upgrade Assistance"

    Check out our [remote upgrade support](https://www.iredmail.org/support.html) if you need assistance.

## ChangeLog

- Jun 3, 2025: initial publish.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.7.4
```

### Upgrade iRedAPD (Postfix policy server) to the latest stable release (5.9.1)

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

### Upgrade mlmmjadmin to the latest stable release (3.4.0)

Please follow below tutorial to upgrade mlmmjadmin to the latest stable release:
[Upgrade mlmmjadmin to the latest stable release](./upgrade.mlmmjadmin.html)

### Upgrade Roundcube webmail to the latest stable release (1.6.11 or 1.5.10)

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

### Upgrade netdata to the latest stable release (v2.5.2)

If you have netdata installed, you can upgrade it by following this tutorial:
[Upgrade netdata](./upgrade.netdata.html).
