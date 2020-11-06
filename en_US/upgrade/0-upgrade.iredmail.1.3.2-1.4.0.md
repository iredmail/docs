# Upgrade iRedMail from 1.3.2 to 1.4.0

[TOC]

!!! warning

    THIS IS A DRAFT DOCUMENT, DO NOT APPLY IT.

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

* XX XX, 2020: initial release.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.4.0
```

### Upgrade iRedAdmin (open source edition) to the latest stable release (1.2)

!!! attention

    iRedAdmin has been migrated to Python 3 and doesn't support Python 2 anymore.

Please follow below tutorial to upgrade iRedAdmin to the latest stable release:
[Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html).

### Fixed: Fail2ban can not store IP address when its country name contains quotes

Please run commands below as root user to get latest filter file for Roundcube:

```
wget -O /usr/local/bin/fail2ban_banned_db https://github.com/iredmail/iRedMail/raw/1.4.0/samples/fail2ban/bin/fail2ban_banned_db
```

No need to restart `fail2ban` service.
