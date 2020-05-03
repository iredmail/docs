# Upgrade Ubuntu from 18.04 to 20.04

!!! warning

    THIS IS A DRAFT DOCUMENT, DO NOT APPLY IT.

## Packages

Install required Python-2 packages:

```
apt install python2-dev
pip2 install uwsgi web.py==0.51 pycurl netifaces
ln -sf /usr/local/bin/uwsgi /etc/alternatives/uwsgi
echo "SQL_DB_DRIVER = 'pymysql'" >> /opt/iredapd/settings.py
```

If you're running OpenLDAP backend:

```
pip2 install python-ldap==3.2.0
```

## Configurations

* `/etc/php/7.4/fpm/pool.d/www.conf`

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
