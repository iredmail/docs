# Upgrade iRedMail from 0.9.5-1 to 0.9.6

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](../support.html) and [contact us](../contact.html).

!!! warning

    This tutorial is still a __DRAFT__, do not apply it.

## TODO

* Separated SOGo address book for LDAP backend.

## ChangeLog

* May 27, 2016: Fixed: not enable opportunistic TLS support in Postfix.
* May 24, 2016: initial __DRAFT__.

## General (All backends should apply these steps)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
0.9.6
```

### Upgrade iRedAPD (Postfix policy server) to the latest stable release (1.9.2)

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

Detailed release notes are available [here](./iredapd.releases.html).

### Upgrade iRedAdmin (open source edition) to the latest stable release (0.7.2)

Please follow this tutorial to upgrade iRedAdmin open source edition to the
latest stable release:
[Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html)

### Upgrade Roundcube webmail to the latest stable release (1.2.0)

Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release immediately: [How to upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).

Note: package `rsync` must be installed on your server before upgrading.

### Fixed: not enable opportunistic TLS support in Postfix

iRedMail-0.9.5 and iRedMail-0.9.5-1 didn't enable opportunistic TLS support in
Postfix, this causes other servers cannot transfer emails via TLS secure
connection. Please fix it with commands below.

```
postconf -e smtpd_tls_security_level='may'
postfix reload
```
