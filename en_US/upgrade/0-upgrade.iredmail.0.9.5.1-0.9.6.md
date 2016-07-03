# Upgrade iRedMail from 0.9.5-1 to 0.9.6

[TOC]

!!! warning

    This tutorial is still a __DRAFT__, do not apply it.

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](../support.html) and [contact us](../contact.html).

## TODO

* Separated SOGo address book for LDAP backend.
* List all contacts by default in SOGo global address book (`listRequiresDot`).
* Postfix parameter `smtpd_command_filter`.

## ChangeLog

* Jul  2, 2016: Fixed: SOGo-3.1.3 (and later releases) changed argument used by `sogo-tool` command
* Jun 10, 2016: Fixed: Nginx doesn't forward real client IP address to SOGo.
* Jun  8, 2016: Set correct file owner for config file of Roundcube password plugin.
* Jun  8, 2016: Fixed: one incorrect HELO restriction rule in Postfix.
* May 27, 2016: Fixed: not enable opportunistic TLS support in Postfix.
* May 24, 2016: Initial __DRAFT__.

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

### Fixed: one incorrect HELO restriction rule in Postfix

There's one incorrect HELO restriction rule file `helo_access.pcre`

* on Linux/OpenBSD, it's `/etc/postfix/helo_access.pcre`
* on FreeBSD, it's `/usr/local/etc/postfix/helo_access.pcre`

It will match HELO identity like `[192.168.1.1]` which is legal.
```
/(\d{1,3}[\.-]\d{1,3}[\.-]\d{1,3}[\.-]\d{1,3})/ REJECT ACCESS DENIED. Your email was rejected because the sending mail server appears to be on a dynamic IP address that should not be doing direct mail delivery (${1})
```

Please replace it by the correct one below (it matches the IP address with
`/^IP$/` strictly):
```
/^(\d{1,3}[\.-]\d{1,3}[\.-]\d{1,3}[\.-]\d{1,3})$/ REJECT ACCESS DENIED. Your email was rejected because the sending mail server appears to be on a dynamic IP address that should not be doing direct mail delivery (${1})
```

### Fixed: incorrect file owner and permission of config file of Roundcube password plugin

iRedMail-0.9.5-1 and earlier versions didn't correct set file owner and
permission of config file of Roundcube password plugin, other system users may
be able to see the SQL/LDAP username and password in the config file. Please
follow steps below to fix it.

* On RHEL/CentOS:

<h5>For Apache server:</h5>
```
chown apache:apache /var/www/roundcubemail/plugins/password/config.inc.php
chmod 0400 /var/www/roundcubemail/plugins/password/config.inc.php
```
<h5>For Nginx:</h5>
```
chown nginx:nginx /var/www/roundcubemail/plugins/password/config.inc.php
chmod 0400 /var/www/roundcubemail/plugins/password/config.inc.php
```

* On Debian/Ubuntu (Note: with old iRedMail release, Roundcube directory is
  `/usr/share/apache2/roundcubemail`):
```
chown www-data:www-data /opt/www/roundcubemail/plugins/password/config.inc.php
chmod 0400 /opt/www/roundcubemail/plugins/password/config.inc.php
```

* On FreeBSD:
```
chown www:www /usr/local/www/roundcubemail/plugins/password/config.inc.php
chmod 0400 /usr/local/www/roundcubemail/plugins/password/config.inc.php
```

* On FreeBSD:
```
chown www:www /var/www/roundcubemail/plugins/password/config.inc.php
chmod 0400 /var/www/roundcubemail/plugins/password/config.inc.php
```

### Fixed: Nginx doesn't forward real client IP address to SOGo

iRedMail-0.9.5-1 and earlier releases didn't correctly configure Nginx to
forward real client IP address to SOGo, this causes Fail2ban cannot catch
bad clients with failed authentication while logging to SOGo. Please try
steps below to fix it.

* Open file `/etc/nginx/templates/sogo.tmpl` (on Linux or OpenBSD) or
  `/usr/local/etc/nginx/templates/sogo.tmpl` (on FreeBSD), find 3 lines like
  below:

```
    #proxy_set_header X-Real-IP $remote_addr;
    #proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    #proxy_set_header Host $host;
```

* Remove the leading `#` to uncomment them:

```
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $host;
```

* Restart Nginx service.

### Fixed: SOGo-3.1.3 (and later releases) changed argument used by `sogo-tool` command

SOGo-3.1.3 (and late releases) changed `sogo-tool` argument `expire-autoreply`
to `update-autoreply`, and it's used in a daily cron job. Please update SOGo
cron job to fix it.

* Edit SOGo deamon user's cron job with command.
    * On Linux: ```crontab -e -u sogo```
    * On FreeBSD: ```crontab -e -u sogod```
    * On OpenBSD: ```crontab -e -u _sogo```

* Replace the argument `expire-autoreply` by `update-autoreply`.
