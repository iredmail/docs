# Upgrade iRedMail from 1.5.1 to 1.5.2

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

- March 22, 2022: 2 new sections:
    - SOGo: Re-create SQL table
    - Amavisd: Override `@av_scanners_backup` settings
- March 16, 2022: initial release.

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

### Amavisd: Override `@av_scanners_backup` settings

Amavisd is configured to run virus scanning by connecting to ClamAV daemon
socket first, if failed, try backup option which is calling `clamscan` command
directly. The problem with `clamscan` is it needs to load all clamav database
each time for each message, it may cause OOM (Out Of Memory) error or use too
much system resource and cause mail service unstable.

To prevent this case, we simply disable the backup option by adding (or
overwriting) parameter `@av_scanners_backup` in Amavisd config file:
    - On RHEL/CentOS/Rocky, it's `/etc/amavisd/amavisd.conf`
    - On Debian/Ubuntu, it's `/etc/amavis/conf.d/50-user`
    - On OpenBSD, it's `/etc/amavisd.conf`

```
@av_scanners_backup = ();
```

Restarting Amavisd service is required.

### Nginx: Increase proxy buffer size so that user can login to SOGo webmail

The cookie used by SOGo is now `much bigger than before (just below 4096
bytes, to accommodate longer passwords)`, so we have to increase Nginx proxy
buffer size too, otherwise user can not login to SOGo webmail.

Find below 3 `location` directives in 2 Nginx config files:

- On Linux and OpenBSD:
    - `/etc/nginx/templates/sogo.tmpl`
    - `/etc/nginx/templates/sogo-subdomain.tmpl`
- On FreeBSD:
    - `/usr/local/etc/nginx/templates/sogo.tmpl`
    - `/usr/local/etc/nginx/templates/sogo-subdomain.tmpl`

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

## For OpenLDAP and MariaDB backend

### SOGo: Re-create SQL table

SOGo has some internal change in March 2022, you may get error message like
below in SOGo log file `/var/log/sogo/sogo.log`:

> Mar 09 17:28:20 sogod ... cannot write record: ... NAME:ExecutionFailed REASON:__Data too long for column 'c_value'__{: .red } at row 1

Please drop SQL table `sogo.sogo_sessions_folder` and restart SOGo service to
fix it. SOGo will re-create this table automatically.

Please run shell commands below to fix it:
```
mysql sogo -e "DROP TABLE sogo_sessions_folder;"
service sogo restart        # On CentOS/Rocky, the service name is "sogod".
```

## For PostgreSQL backend
### SOGo: Re-create SQL table

SOGo has some internal change in March 2022, you may get error message like
below in SOGo log file `/var/log/sogo/sogo.log`:

> Mar 09 17:28:20 sogod ... cannot write record: ... NAME:ExecutionFailed REASON:__Data too long for column 'c_value'__{: .red } at row 1

Please drop SQL table `sogo.sogo_sessions_folder` and restart SOGo service to
fix it. SOGo will re-create this table automatically.

Please switch to PostgreSQL daemon user first:
```
su - postgres
```

Run run shell commands below as PostgreSQL daemon user to fix it:

```
psql -d sogo -c "DROP TABLE sogo_sessions_folder"
```

Switch back to root user, then restart SOGo service:
```
service sogo restart        # On CentOS/Rocky, the service name is "sogod".
```
