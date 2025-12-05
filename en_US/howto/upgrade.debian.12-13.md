# Fixes you need after upgrading Debian from 12 to 13 (trixie)

!!! warning

    This is still a DRAFT document, it may miss some other important changes.

[TOC]

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

- Add new line `http2 on;` right after last `listen` directive:
```
    http2 on;
```

- Restart `nginx` service:

```
systemctl restart nginx
```

## php-fpm

Copy fpm pool config file, then restart php8.4-fpm service:

```shell
cp /etc/php/8.2/fpm/pool.d/www.conf /etc/php/8.4/fpm/pool.d/
systemctl restart php8.4-fpm
```

## Dovecot

!!! attention

    Backup your `/etc/dovecot/dovecot.conf` first.

### For MariaDB backend

- Replace `/etc/dovecot/dovecot.conf` by [this one](./files/dovecot/dovecot-2.4-mariadb.conf).
- Open `/etc/dovecot/dovecot.conf`, find lines below, replace sample password
  of `vmailadmin` user by the real one (you can find it in old config file
  `/etc/dovecot/dovecot-used-quota.conf` or other files under `/etc/dovecot/`):
```
mysql 127.0.0.1 {
    port = 3306
    dbname = vmail
    user = vmailadmin
    password = AQjaT42HjU3sZfSHSC5h2og5iJEu22aT     # <- Replace this one
}
```
- Replace ssl cert and key files in parameters `ssl_server_cert_file` and `ssl_server_key_file`.
- Replace DH parameters file in parameter `ssl_server_dh_file`. To generate new parameters file, you can use command `openssl dhparam 4096 > /etc/dovecot/dh.pem`.

### For PostgreSQL backend

- Replace `/etc/dovecot/dovecot.conf` by [this one](./files/dovecot/dovecot-2.4-pgsql.conf).
- Open `/etc/dovecot/dovecot.conf`, find lines below, replace sample password
  of `vmailadmin` user by the real one (you can find it in old config file
  `/etc/dovecot/dovecot-used-quota.conf` or other files under `/etc/dovecot/`):

```
pgsql 127.0.0.1 {
    # Maximum number of parallel connections. Default is 5.
    connection_limit = 20
    host = 127.0.0.1
    parameters {
        port = 5432
        dbname = vmail
        user = vmailadmin
        password = AQjaT42HjU3sZfSHSC5h2og5iJEu22aT     # <- Replace this one
    }
}
```
- Replace ssl cert and key files in parameters `ssl_server_cert_file` and `ssl_server_key_file`.
- Replace DH parameters file in parameter `ssl_server_dh_file`. To generate new parameters file, you can use command `openssl dhparam 4096 > /etc/dovecot/dh.pem`.


### For OpenLDAP backend

- Replace `/etc/dovecot/dovecot.conf` by [this one](./files/dovecot/dovecot-2.4-openldap.conf).
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
- Replace ssl cert and key files in parameters `ssl_server_cert_file` and `ssl_server_key_file`.
- Replace DH parameters file in parameter `ssl_server_dh_file`. To generate new parameters file, you can use command `openssl dhparam 4096 > /etc/dovecot/dh.pem`.


## Re-upgrade iRedAPD, mlmmjadmin and iRedAdmin(-Pro)

If you already have latest iRedAPD, mlmmjadmin and iRedAdmin(-Pro) running,
you still need to re-download them and upgrade after you upgraded Debian OS,
because the Python environment changed after OS upgrade.

- [Upgrade iRedAPD](./upgrade.iredapd.html)
- [Upgrade mlmmjadmin](./upgrade.mlmmjadmin.html)
- [Upgrade iRedAdmin(-Pro)](./migrate.or.upgrade.iredadmin.html)
