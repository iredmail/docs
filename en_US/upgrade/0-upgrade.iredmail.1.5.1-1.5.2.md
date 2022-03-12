# Upgrade iRedMail from 1.5.1 to 1.5.2

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

- XXX XX, 2022: initial release.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.5.2
```

### Upgrade netdata to the latest stable release (1.33.1)

If you have netdata installed, you can upgrade it by following this tutorial:
[Upgrade netdata](./upgrade.netdata.html).

### Nginx: Increase proxy buffer size so that user can login to SOGo webmail

The cookie used by SOGo is now `much bigger than before (just bellow 4096
bytes, to accommodate longer passwords)`, so we have to increase Nginx proxy
buffer size too, otherwise user can not login to SOGo webmail.

Please open `/etc/nginx/templates/sogo.tmpl` (on Linux/OpenBSD) or
`/usr/local/etc/nginx/templates/sogo.tmpl` (on FreeBSD), find below 3 `location`
directives:

```
location ^~ /SOGo {
    # ...omit existing parameters here ...
}

location ^~ /Microsoft-Server-ActiveSync {
    # ...omit existing parameters here ...
}

location ^~ /SOGo/Microsoft-Server-ActiveSync {
    # ...omit existing parameters here ...
}
```

Insert 3 new parameters into all above 3 `location` blocks like below:

```
location ^~ /SOGo {
    # ...omit existing parameters here ...

    proxy_busy_buffers_size   64k;
    proxy_buffers             8 64k;
    proxy_buffer_size         64k;
}

location ^~ /Microsoft-Server-ActiveSync {
    # ...omit existing parameters here ...

    proxy_busy_buffers_size   64k;
    proxy_buffers             8 64k;
    proxy_buffer_size         64k;
}

location ^~ /SOGo/Microsoft-Server-ActiveSync {
    # ...omit existing parameters here ...

    proxy_busy_buffers_size   64k;
    proxy_buffers             8 64k;
    proxy_buffer_size         64k;
}
```

Run command `nginx -t` first to verify the configuration, if no error reported
on console, then restart nginx service:

```
service nginx restart
```

### [OPTIONAL] Roundcube: Log client login IP addresses

It might be useful to log client IPs in Roundcube log file, for example, for
audit purpose. In this case you can add a new config in Roundcube config file
`/opt/www/roundcubemail/config/config.inc.php` like below:

```
$config['log_logins'] = true;
```

Restarting php-fpm service is recommended but not required.
