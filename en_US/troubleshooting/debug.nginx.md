# Turn on debug mode in Nginx

To turn on debug mode in Nginx, please update Nginx config file
`/etc/nginx/conf-enabled/log.conf` (Linux/OpenBSD) or
`/usr/local/etc/nginx/conf-enabled/log.conf` (FreeBSD), append string `debug`
in parameter `error_log` like below:

```
error_log ... debug;
```

Then restart Nginx service.

Nginx logs detailed debug info to `/var/log/nginx/error.log` (Linux/FreeBSD)
or `/var/www/logs/error.log` (OpenBSD).
