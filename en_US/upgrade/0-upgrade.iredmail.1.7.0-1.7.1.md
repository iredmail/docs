# Upgrade iRedMail from 1.7.0 to 1.7.1

!!! attention

	 Check out the on-premises, lightweight email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

!!! warning

    THIS IS A DRAFT DOCUMENT, DO NOT APPLY IT ON PRODUCTION SERVER.

## ChangeLog

- Aug 05, 2024: initial publish.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.7.1
```

## General (All backends should apply these changes)

### Upgrade Roundcube webmail to the latest stable release (1.6.8 or 1.5.8)

!!! warning "CentOS 7: please stick to Roundcube 1.5.2"

    __It's time to leave your comfort zone and upgrade this server to at least
    CentOS Stream 8 or [Rocky Linux 8](https://docs.rockylinux.org/guides/migrate2rocky/).__

    If you're running CentOS 7, please upgrade to Roundcube 1.5.2 instead.
    Roundcube 1.5.3 requires PHP-7, but CentOS 7 ships PHP-5.4 which is not
    supported by Roundcube 1.5.3 and later releases, including 1.6.x.

    __Unfortunately, Roundcube 1.5.2 does NOT contains multiple security fixes
    which shipped in Roundcube 1.5.6 and 1.6.5.__

!!! warning "Ubuntu 18.04: please stick to Roundcube 1.5.8"

    Ubuntu 18.04 runs old php version, v1.5.6 contains the security fix too.
    Anyway, please consider upgrading your OS to at least 20.04 LTS as soon as
    possible.

Both Roundcube 1.6.8 and 1.5.8 contain fixes to 3 security vulnerabilities,
please upgrade as soon as possible.

* [Upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).

### Upgrade netdata to the latest stable release (1.46.3)

If you have netdata installed, you can upgrade it by following this tutorial:
[Upgrade netdata](./upgrade.netdata.html).

## For MariaDB backend

### Fixed: Amavisd cannot save mail subject longer than 255 characters.

iRedMail uses `VARBINARY(255)` to store mail subject in Amavisd database,
it fails if subject is longer.

```
wget -O /tmp/amavisd.sql https://raw.githubusercontent.com/iredmail/iRedMail/1.7.1/update/1.7.1/amavisd.mysql
mysql amavisd < /tmp/amavisd.sql
rm -f /tmp/amavisd.sql
```
