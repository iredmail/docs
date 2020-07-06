# Upgrade iRedMail from 1.3 to 1.3.1

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

* Jul XX, 2020: initial release.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.3
```

### Upgrade iRedAPD (Postfix policy server) to the latest stable release

The recent iRedAPD-4.1 has a critical bug which causes temporarily rejection,
this new release fixes it.

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

### Upgrade Roundcube webmail to the latest stable release (1.4.7)

!!! warning "Roundcube 1.4"

    Since Roundcube 1.3, at least __PHP 5.4__ is required. If your server is
    running PHP 5.3 and cannot upgrade to 5.4, please upgrade Roundcube
    the latest 1.2 branch instead.

Roundcube 1.4.6 fixes few security issues, 1.4.7 fixes a new one. All users are encouraged to upgrade
_as soon as possible_.

* [How to upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).

References:

- 05 July 2020, [Security updates 1.4.7, 1.3.14 and 1.2.11 released](https://roundcube.net/news/2020/07/05/security-updates-1.4.7-1.3.14-and-1.2.11)
- 07 June 2020, [Updates 1.4.6 and 1.3.13 released](https://roundcube.net/news/2020/06/07/updates-1.4.6-and-1.3.13-released)
- 02 June 2020, [Security updates 1.4.5 and 1.3.12 released](https://roundcube.net/news/2020/06/02/security-updates-1.4.5-and-1.3.12)

### Fixed: update Fail2ban filter rules to match new error log produced by latest Roundcube

Please run commands below as root user to get latest filter file for Roundcube:

```
cd /etc/fail2ban/filter.d/
wget -O roundcube.iredmail.conf https://raw.githubusercontent.com/iredmail/iRedMail/1.3.1/samples/fail2ban/filter.d/roundcube.iredmail.conf
```

Restart `fail2ban` service is required.
