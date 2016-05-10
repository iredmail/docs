# Upgrade iRedMail from 0.9.5 to 0.9.5-1

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](../support.html) and [contact us](../contact.html).

## ChangeLog

* May 10, 2016: Initial publish.

## General (All backends should apply these steps)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
0.9.5-1
```

### Upgrade iRedAPD (Postfix policy server) to the latest stable release (1.9.1)

> iRedAPD-1.9.1 fixes a bug in `tools/spf_to_greylist_whitelists.py` which was
> introduced in iRedAPD-1.9.0.

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

Detailed release notes are available [here](./iredapd.releases.html).

### Fixed: cannot deliver email to system account.

iRedMail-0.9.5 and early releases have incorrect Postfix settings which causes
emails sent to system account cannot be delivered to mailbox. Please follow
steps below fix it.

Please open file `/etc/postfix/main.cf` (Linux/OpenBSD) or
`/usr/local/etc/postfix/main.cf` (FreeBSD), remove below 2 parameters:

```
home_mailbox = ...
mailbox_command = ...
```

Restarting or reloading Postfix service is required.

### Fixed: Incorrect compress and uncompress command in logrotate config files

> This bug was introduced in iRedMail-0.9.5. If you're upgrading from
> iRedMail-0.9.4 or earlier release, it's safe to ignore this step.

iRedMail-0.9.5 sets incorrect command for parameter `compresscmd` and
`uncompresscmd`, please fix it with commands below:

* On RHEL/CentOS:

```
perl -pi -e 's#\$\(which bzip2\)#/usr/bin/bzip2#g' /etc/logrotate.d/*
perl -pi -e 's#\$\(which bunzip2\)#/usr/bin/bunzip2#g' /etc/logrotate.d/*
```

* On Debian/Ubuntu:

```
perl -pi -e 's#\$\(which bzip2\)#/bin/bzip2#g' /etc/logrotate.d/*
perl -pi -e 's#\$\(which bunzip2\)#/bin/bunzip2#g' /etc/logrotate.d/*
```

* On FreeBSD, OpenBSD: no fix required since FreeBSD/OpenBSD rotates log files
  with `newsyslog` (`/etc/newsyslog.conf`), not `logrotate` program.

### Fixed: Allow two functions in PHP

> This bug was introduced in iRedMail-0.9.5. If you're upgrading from
> iRedMail-0.9.4 or earlier release, it's safe to ignore this step.

Roundcube cannot call command to change password without PHP functions:
`popen`, `openlog`, please remove them in PHP config file `php.ini`.

* on RHEL/CentOS: it's `/etc/php.ini`
* on Debian/Ubuntu:
    * If you're running Apache as web server:
        * If you're running PHP-5: it's `/etc/php5/apache2/php.ini` (Debian 8, Ubuntu 14.04)
        * If you're running PHP-7: it's `/etc/php/7.0/cli/php.ini` (Ubuntu 16.04)
    * If you're running Nginx as web server: it's `/etc/php5/fpm/php.ini`.
        * If you're running PHP-5: it's `/etc/php5/fpm/php.ini` (Debian 8, Ubuntu 14.04)
        * If you're running PHP-7: it's `/etc/php/7.0/fpm/php.ini` (Ubuntu 16.04)
* on FreeBSD: it's `/usr/local/etc/php.ini`.
* on OpenBSD: it's `/etc/php-5.X.ini`

Find parameter `disable_functions =`, remove function name `popen` and
`openlog`, then restart Apache or php fpm service.

### [RHEL/CentOS 6] Fixed: Roundcube cannot change password

> This bug was introduced in iRedMail-0.9.5. If you're upgrading from
> iRedMail-0.9.4 or earlier release, it's safe to ignore this step.

Roundcube cannot change password due to miss package `mcrypt`, please install
it as root user with commands below:

```
yum -y install mcrypt
```
