# Upgrade iRedMail from 1.6.8 to 1.7.0

!!! attention

	 Check out the on-premises, lightweight email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

!!! warning

    This is still a DRAFT document, it may miss some other important changes.

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

- May 17, 2024: initial publish.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.7.0
```

### Upgrade Roundcube webmail to the latest stable release (1.6.7)

!!! warning "CentOS 7: please stick to Roundcube 1.5.2"

    __It's time to leave your comfort zone and upgrade this server to at least
    CentOS Stream 8 or [Rocky Linux 8](https://docs.rockylinux.org/guides/migrate2rocky/).__

    If you're running CentOS 7, please upgrade to Roundcube 1.5.2 instead.
    Roundcube 1.5.3 requires PHP-7, but CentOS 7 ships PHP-5.4 which is not
    supported by Roundcube 1.5.3 and later releases, including 1.6.x.

    __Unfortunately, Roundcube 1.5.2 does NOT contains multiple security fixes
    which shipped in Roundcube 1.5.6 and 1.6.5.__

!!! warning "Ubuntu 18.04: please stick to Roundcube 1.5.7"

    Ubuntu 18.04 runs old php version, v1.5.6 contains the security fix too.
    Anyway, please consider upgrading your OS to at least 20.04 LTS as soon as
    possible.

* [Upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).

### Upgrade SOGo to latest 5.10.0 and add required new parameter

SOGo v5.10.0 introduces a required new parameter `OCSAdminURL` in config file.
Please add this new parameter and upgrade SOGo to latest nightly build.

Add new parameter `OCSAdminURL` in sogo.conf for the new SQL table `sogo_admin` introduced in SOGo v5.10.0.

### [OPTIONAL] Disable multi-threaded database reload in ClamAV

```
ConcurrentDatabaseReload no
```
