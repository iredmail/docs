# Fixes you need after upgrading Debian from 12 to 13 (trixie)

!!! warning

    This is still a DRAFT document, it may miss some other important changes.


## Postfix

- Make sure you do not have line `check_policy_service inet:127.0.0.1:12340`
  in `/etc/postfix/main.cf`, because Dovecot is configured to not offer this
  service. Restart postfix after removed the line.

## Nginx

- Open file `/etc/nginx/sites-available/00-default-ssl.conf`, remove `http2` in
  `listen` directivies:
```
    listen 443 ssl http2;           # Remove `http2`
    listen [::]:443 ssl http2;      # Remove `http2`
```

     Add new line `http2 on;` right after last `listen` directive:
```
    http2 on;
```

### php-fpm

- Copy fpm pool config file, then restart php8.4-fpm service:

```shell
cp /etc/php/8.2/fpm/pool.d/www.conf /etc/php/8.4/fpm/pool.d/
systemctl restart php8.4-fpm
```

## Dovecot

- Backup your `/etc/dovecot/dovecot.conf` first.
- Replace `/etc/dovecot/dovecot.conf` by [this one](./files/dovecot/dovecot-2.4.conf).
- Open `/etc/dovecot/dovecot.conf`, find lines below, replace sample password
  of `vmailadmin` user by the real one (you can find it in old config file
  `/etc/dovecot/dovecot-used-quota.conf` or other files under `/etc/dovecot/`):
```
mysql 127.0.0.1 { 
    port = 3306
    dbname = vmail
    user = vmailadmin
    password = HdDDrA8a6Fwxc69z9CFB0TSryzxxR0Aw
}
```

## Re-upgrade iRedAPD, mlmmjadmin and iRedAdmin(-Pro)

If you already have latest iRedAPD, mlmmjadmin and iRedAdmin(-Pro) running,
you still need to re-download them and upgrade after you upgraded Debian OS,
because the Python environment changed after OS upgrade.

- [Upgrade iRedAPD](./upgrade.iredapd.html)
- [Upgrade mlmmjadmin](./upgrade.mlmmjadmin.html)
- [Upgrade iRedAdmin(-Pro)](./migrate.or.upgrade.iredadmin.html)
