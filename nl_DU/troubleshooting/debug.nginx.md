# Zet debug modus aan in Nginx

Om debug modus aan te zetten in Nginx moet je het Nginx configuratiebestand bewerken
`/etc/nginx/conf-enabled/log.conf` (Linux/OpenBSD) of
`/usr/local/etc/nginx/conf-enabled/log.conf` (FreeBSD), voeg string `debug`
toe aan parameter `error_log` zoals hieronder te zien is:

```
error_log ... debug;
```

Herstart dan Nginx service.

Nginx logt gedetailleerde debuginformatie naar  `/var/log/nginx/error.log` (Linux/FreeBSD)
of `/var/www/logs/error.log` (OpenBSD).
