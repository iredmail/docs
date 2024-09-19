# Upgrade Ubuntu from 22.04 to 24.04

!!! attention

    If you found some changes are required by uncovered in this tutorial,
    please do [contact us](https://www.iredmail.org/contact.html) to update.

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

### Upgrade iRedMail to the latest stable release first

Before upgrading server OS, it's better upgrade iRedMail to the latest stable
release first. You can find [all upgrade tutorials here](./iredmail.releases.html).

### Upgrade OS

After you have latest iRedMail release running, it's ok to upgrade server OS
with command `do-release-upgrade` now.

### Re-upgrade iRedAPD, iRedAdmin(-Pro), mlmmjadmin to the latest release

!!! attention

    Ubuntu 24.04 ships Python 3.12 which removes module `asynchat`, but it's
    required by iRedAPD. Please upgrade iRedAPD to at least `5.5.0` to get it
    working with Python 3.12.

After upgraded server OS, please re-upgrade iRedAPD, iRedAdmin(-Pro) and
mlmmjadmin even you're already running the latest versions before upgrading
OS, their upgrade scripts will help fix some issues caused by OS upgrade.

- [Upgrade iRedAPD](./upgrade.iredapd.html)
- [Upgrade iRedAdmin(-Pro)](./migrate.or.upgrade.iredadmin.html)
- [Upgrade mlmmjadmin](./upgrade.mlmmjadmin.html)

## Update php-fpm related configurations

* Create directory used to store log files:

```
mkdir /var/log/php-fpm
```

* Override config file `/etc/php/8.3/fpm/pool.d/www.conf` with content below:

```
[inet]
user = www-data
group = www-data

listen = 127.0.0.1:9999
listen.owner = www-data
listen.group = www-data
listen.mode = 0660

; IP addresses must be separated by comma, and no space between comma and ip.
listen.allowed_clients = 127.0.0.1

pm = dynamic
pm.max_children = 200
pm.start_servers = 10
pm.min_spare_servers = 5
pm.max_spare_servers = 10
pm.max_requests = 500

pm.status_path = /php-fpm-status
ping.path = /php-fpm-ping

request_terminate_timeout = 60s

access.log = /var/log/php-fpm/access.log
slowlog = /var/log/php-fpm/slow.log
request_slowlog_timeout = 10s
```

* Override file `/etc/nginx/conf-available/php-fpm.conf` with content below:

```
upstream php_workers {
    server 127.0.0.1:9999;
}
```

* Restart php8.3-fpm and nginx services:

```
service php8.3-fpm restart
service nginx restart
```
