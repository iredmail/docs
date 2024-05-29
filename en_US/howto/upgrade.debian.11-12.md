# Fixes you need after upgrading Debian from 11 to 12

[TOC]

!!! warning

    This is still a DRAFT document, it may miss some other important changes.

## php-fpm

Debian 12 ships with php 8.2, while Debian 11 ships with php 7.4.
Although Debian 12 starts the `php8.2-fpm` service by default after an OS
upgrade, you still need to copy the old php-fpm config file and restart
`php8.2-fpm` service, so that php-fpm listens on same network address
(`127.0.0.1:9999`) and Nginx can communicate with php-fpm:

```
cp /etc/php/7.4/fpm/pool.d/www.conf /etc/php/8.2/fpm/pool.d/www.conf
service php8.2-fpm restart
```

