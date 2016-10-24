# Fixes you need after upgrading Ubuntu to 16.04 from 14.04

[TOC]

## Postfix

```
postconf -e daemon_directory='/usr/lib/postfix/sbin’
postconf -e shlib_directory='/usr/lib/postfix'
```

* Incorrect `daemon_directory` causes Postfix cannot start.
* Incorrect `shlib_directory` causes Postfix cannot find pcre/mysql/pgsql/ldap modules.

## PHP [OPTIONAL]

> NOTE: This step is toally optional if you're fine with old PHP release.

php was not upgraded to 7.0 automatically, have to install them manually:

```
apt-get install php-json php-gd php-mcrypt php-curl mcrypt php-intl php-xml php-mbstring php-mysql libapache2-mod-php
```
