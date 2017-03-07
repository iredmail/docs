# Upgrade iRedMail from 0.9.6 to 0.9.7

[TOC]

!!! warning

    THIS IS A DRAFT, DO NOT APPLY ANY STEPS MENTIONED IN THIS TUTORIAL.

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](../support.html) and [contact us](../contact.html).

## ChangeLog

* Mar 8, 2017: [RHEL/CentOS][Nginx] Fix incorrect session.save_path in php-fpm pool config file.
* Feb 9, 2017: Fixed improper Fail2ban filter for Dovecot.

## General (All backends should apply these steps)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
0.9.7
```

### Fixed: incorrect session.save_path in php-fpm pool config file on RHEL/CentOS

!!! attention

    This is applicable to RHEL/CentOS system, and Nginx web server.

iRedMail-0.9.6 doesn't set path for `session.save_path` parameter in php-fpm
pool config file `/etc/php-fpm.d/www.conf`, please fix it with steps below:

* Open file `/etc/php-fpm.d/www.conf`, find line:

```
php_value[session.save_path] = "/var/lib/php/session"
```

* The directory name should be `sessions` (ends with `s`), not `session`. So
  please change it to:

```
php_value[session.save_path] = "/var/lib/php/sessions"
```

* Restarting php-fpm service is required:

```
service php-fpm restart
```

### Fixed: Improper Fail2ban filter which causes incorrect ban

Please open file `/etc/fail2ban/filter.d/dovecot.iredmail.conf`, remove line
below:

```
            \(no auth attempts in .* rip=<HOST>
```

Then restart or reload Fail2ban service.
