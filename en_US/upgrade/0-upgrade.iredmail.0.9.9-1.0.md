# Upgrade iRedMail from 0.9.9 to 1.0

[TOC]

!!! warning

    This is still a __DRAFT__ document, do __NOT__ apply it.

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
1.0
```

### Upgrade iRedAPD (Postfix policy server) to the latest stable release (2.5)

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

### Upgrade iRedAdmin (open source edition) to the latest stable release (0.9.5)

!!! attention

    In this release, iRedAdmin (and iRedAdmin-Pro) is running as a standalone
    service named "iredadmin", each time you modified its config file, please
    restart the service ("iredadmin").

Please follow this tutorial to upgrade iRedAdmin open source edition to the
latest stable release:
[Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html)

### Upgrade mlmmjadmin to the latest stable release (2.1)

Please follow below tutorial to upgrade mlmmjadmin to the latest stable release:
[Upgrade mlmmjadmin to the latest stable release](./upgrade.mlmmjadmin.html)

### Upgrade Roundcube webmail to the latest stable release

!!! warning "Roundcube 1.3"

    * Roundcube 1.3 requires at least __PHP 5.4__. If your server is still running
      PHP 5.3 and cannot upgrade to 5.4, please upgrade Roundcube to the latest
      1.2 branch (1.2.5) instead.
    * Roundcube 1.3 no longer supports IE < 10 and old versions of Firefox,
      Chrome and Safari.
    * Roundcube 1.3 uses jQuery 3.2 and will not work with current jQuery
      mobile plugin. If you use any third-party plugin, please check its
      website to make sure it's compatible with Roundcube 1.3 before upgrading.

    With the release of Roundcube 1.3.0, the previous stable release branches
    1.2.x and 1.1.x will switch in to LTS low maintenance mode which means
    they will only receive important security updates but no longer any regular
    improvement updates.

Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release immediately:

* [How to upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).

### Upgrade netdata to the latest stable release (1.12.1)

If you have netdata installed, you can upgrade it by following this tutorial: [Upgrade netdata](./upgrade.netdata.html).

### Fail2ban: slightly loose filter rule for postfix

We received few reports from clients that Outlook for macOS may trigger some
unexpected smtp errors, and caught by the Fail2ban filter rules shipped by
iRedMail, so we decide to remove the filter rule used to match Postfix log
`lost connection after EHLO`.

Please follow commands below to get the updated filter rules.

* On Linux:

```
cd /etc/fail2ban/filter.d/
wget -O postfix.iredmail.conf https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/fail2ban/filter.d/postfix.iredmail.conf
```

Restarting Fail2ban service is required.
