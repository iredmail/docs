# Fixes you need after upgrading Debian from 10 to 11

[TOC]

!!! warning

    This is still a DRAFT document, it may miss some other important changes.

## Dovecot

Please remove these lines from `/etc/dovecot/dovecot.conf`:

```
metric imap_command_finished {
    event_name = imap_command_finished
}
```

The newer Dovecot release uses a different syntax for this metric. Since
netdata doesn't yet support Dovecot 2.3, we've removed it for now.

## iRedAPD and iRedAdmin(-Pro)

Because Debian 11 offers a newer Python release, a few Python modules must be
re-installed:

```
pip3 install -U web.py
```

These services must be restarted:

```
service iredapd restart
service iredadmin restart
```

## php-fpm

Debian 11 ships with php 7.4, while Debian 10 ships with php 7.3.
Although Debian 11 starts the `php7.4-fpm` service by default after an OS
upgrade, you still need to copy the old php-fpm config file and restart
the php7.4-fpm service, so that php7.4-fpm listens on same network address
(`127.0.0.1:9999`) and Nginx can communicate with php7.4-fpm:

```
cp /etc/php/7.3/fpm/pool.d/www.conf /etc/php/7.4/fpm/pool.d/www.conf
service php7.4-fpm restart
```
