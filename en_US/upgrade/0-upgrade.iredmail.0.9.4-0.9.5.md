# Upgrade iRedMail from 0.9.4 to 0.9.5

[TOC]

## ChangeLog

> We offer remote upgrade service, check [the price](../support.html) and [contact us](../contact.html).

* 2016-02-25:
    * [RHEL/CentOS] Fixed: Not create required directory used to store PHP session files
    * [RHEL/CentOS] Fixed: Not enable cron job to update SpamAssassin rules
    * Fixed: not add alias for `virusalert` on non-Debian/Ubuntu OSes

## General (All backends should apply these steps)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
# File: /etc/iredmail-release

0.9.5
```

### Upgrade iRedAPD (Postfix policy server) to the latest 1.9.0

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

Detailed release notes are available [here](./iredapd.releases.html).

### [RHEL/CentOS] Fixed: Not enable cron job to update SpamAssassin rules

Note: this is applicable to only RHEL and CentOS.

In iRedMail-0.9.4 and earlier releases, iRedMail didn't enable cron job to
update SpamAssassin rules. Please run commands below to fix it.

```shell
perl -pi -e 's/^(SAUPDATE=yes)/#${1}/' /etc/sysconfig/sa-update
echo 'SAUPDATE=yes' >> /etc/sysconfig/sa-update
```

### [RHEL/CentOS] Fixed: Not create required directory used to store PHP session files

Note: this is applicable to only RHEL and CentOS if you're __running Nginx + php-fpm__.

In iRedMail-0.9.4 and earlier releases, iRedMail didn't create directory used
to store PHP session files, it will cause error when your PHP application tries
to create session file. Please fix it with commands below:

```shell
mkdir /var/lib/php/session
chown root:root /var/lib/php/session
chmod 0733 /var/lib/php/session
chmod o+t /var/lib/php/session
```

### Fixed: not add alias for `virusalert` on non-Debian/Ubuntu OSes

Note: this is __NOT__ applicable to Debian and Ubuntu.

There's a bug in iRedMail-0.9.4, it adds alias `virusalert` on only Debian and
Ubuntu, but not other OSes. Please fix it with below commands:

* For Linux and OpenBSD:

```shell
perl -pi -e 's/(virusalert:.*)/#${1}/g' /etc/postfix/aliases
echo 'virusalert: root' >> /etc/postfix/aliases
postalias /etc/postfix/aliases
```

* For FreeBSD:

```shell
perl -pi -e 's/(virusalert:.*)/#${1}/g' /usr/local/etc/postfix/aliases
echo 'virusalert: root' >> /usr/local/etc/postfix/aliases
postalias /usr/local/etc/postfix/aliases
```
