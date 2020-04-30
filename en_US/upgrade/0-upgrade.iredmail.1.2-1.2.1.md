# Upgrade iRedMail from 1.2 to 1.2.1

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

* Apr 30, 2020: initial release.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.2.1
```

### Upgrade Roundcube webmail to the latest stable release (1.4.4)

!!! warning "Roundcube 1.4"

    Since Roundcube 1.3, at least __PHP 5.4__ is required. If your server is
    running PHP 5.3 and cannot upgrade to 5.4, please upgrade Roundcube
    the latest 1.2 branch instead.

Roundcube 1.4.4 fixes few security issues, all users are encouraged to upgrade
as soon as possible.

* [How to upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).
