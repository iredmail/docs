# Fixes you need after upgrading Ubuntu to 16.04 from 14.04

[TOC]

## Postfix

```
postconf -e daemon_directory='/usr/lib/postfix/sbin'
postconf -e shlib_directory='/usr/lib/postfix'
```

* Incorrect `daemon_directory` causes Postfix cannot start.
* Incorrect `shlib_directory` causes Postfix cannot find pcre/mysql/pgsql/ldap modules.

## iRedAPD

iRedAPD requires package `python-pymysql`:

```
apt -y install python-pymysql
```

## PHP [OPTIONAL]

> NOTE: This step is toally optional if you're fine with old PHP release.

php was not upgraded to 7.0 automatically, have to install them manually:

```
apt-get install php-json php-gd php-mcrypt php-curl mcrypt php-intl php-xml php-mbstring php-mysql libapache2-mod-php
```

### Nginx and php-fpm

If you're running Nginx, you must install package `php-fpm` too:

```
apt install php-fpm
```

php-fpm daemon socket file is changed:

* old one: `/var/run/php-fpm.socket`
* new one: `/var/run/php/php7.0-fpm.sock`

iRedMail hard-codes php-fpm socket file in `/etc/nginx/nginx.conf` or
`/etc/nginx/conf.d/default.conf`, you must update them to use new socket file.
