# Fixes you need after upgrading Debian from 10 to 11

[TOC]

!!! warning

    This is still a DRAFT document, it may miss some other important changes.

## SOGo Groupware

SOGo team doesn't offer binary packages for Debian 11 yet, so you can not use
SOGo at all.

## iRedAPD and iRedAdmin(-Pro)

Debian 11 offers newer Python release, few Python modules must be re-installed:

```
pip3 install -U web.py
```

Services must be restarted:

```
service iredapd restart
service iredadmin restart
```

## php-fpm

Debian 11 ships php 7.4, but Debian 10 ships php 7.3. Although php7.4-fpm
service is started by default after OS upgrade, but you still need to copy
old php-fpm config file and restart php7.4-fpm service:

```
cp /etc/php/7.3/fpm/pool.d/www.conf /etc/php/7.4/fpm/pool.d/www.conf
service php7.4-fpm restart
```
