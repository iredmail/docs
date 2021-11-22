# Fixes you need after upgrading Debian from 9 to 10

[TOC]

!!! warning

    This is still a DRAFT document, it may miss some other important changes.

## Postfix

* If you're running MySQL/MariaDB or PostgreSQL backend, you need to remove
  parameter `port =` in `/etc/postfix/mysql/*.cf` (MySQL/MariaDB backend) or
  `/etc/postfix/pgsql/*.cf` (PostgreSQL backend).

## Dovecot

Changes required to be made in Dovecot main config file `/etc/dovecot/dovecot.conf`:

* Remove all `postmaster_address =`.
* Remove parameter `ssl_protocols =`.
* Add new parameter `ssl_min_protocol` like this:

```
ssl_min_protocol = TLSv1.2
```

Note: If your end users run old mail client applications, it may not support
TLSv1.2, you may want to use weaker one like `TLSv1.1`, `TLSv1` instead.

* Add new parameter `ssl_dh` and load existing file:
    * on CentOS, it's `/etc/pki/tls/dh2048_param.pem`
    * on Debian/Ubuntu, FreeBSD, OpenBSD, it's `/etc/ssl/dh2048_param.pem`

```
ssl_dh = </etc/ssl/dh2048_param.pem
```

* If you have plugin `stats` enabled, you need to rename it:

Old | New
---|---
`mail_plugins = ... stats` | `mail_plugins = ... old_stats`
`protocol imap { mail_plugins = ... imap_stats }` | `protocol imap { mail_plugins = ... imap_old_stats}`
`service stats {}` | `service old-stats {}`<br/>Warning: It's a dash (`-`), not underscore (`_`).
`fifo_listener stats-mail` | `fifo_listener old-stats-mail`<br/>Warning: It's a dash (`-`), not underscore (`_`).
`fifo_listener stats-user` | `fifo_listener old-stats-user`<br/>Warning: It's a dash (`-`), not underscore (`_`).
`unix_listener stats` | `unix_listener old-stats`<br/>Warning: It's a dash (`-`), not underscore (`_`).
`plugin { stats_refresh = ... }` | `plugin { old_stats_refresh = ...}`
`plugin { stats_track_cmds = ...}` | `plugin { old_stats_track_cmds = ...}`

Inside `service old-status {}` block, please add new content:

```
    unix_listener old-stats-reader {
        user = vmail
        group = vmail
        mode = 0660
    }
    unix_listener old-stats-writer {
        user = vmail
        group = vmail
        mode = 0660
    }
```

If you get this kind of error in your mail.log:

```
Error: net_connect_unix(/var/run/dovecot/stats-writer) failed: Permission deni))
```
You may be able to fix it by adding the new service stats configuration to /etc/dovecot/dovecot.conf.  See [this](https://forum.iredmail.org/topic15113-error-netconnectunixvarrundovecotstatswriter-failed.html) thread.  

```
service stats {
    unix_listener stats-reader {
        user = vmail
        group = vmail
        mode = 0660
    }

    unix_listener stats-writer {
        user = vmail
        group = vmail
        mode = 0660
    }
}
```


Restart Dovecot service is required.

## ClamAV
You may see errors like this in your mail.log:

```
!)ClamAV-clamd av-scanner FAILED: run_av error: Too many retries to talk to /var/run/clamav/clamd.ctl (All attempts (1) failed connecting to /var/run/clamav/clamd.ctl) at (eval 114) 
```
The issue is that /etc/clamav/clamd.conf has deprecated entries preventing the daemon from starting. Comment/remove them:

```
#DetectBrokenExecutables false
#ScanOnAccess false
#StatsEnabled false
#StatsPEDisabled true
#StatsHostID auto
#StatsTimeout 10
```
Restart the clamav-daemon service afterwards

## PHP

Debian 9 offers PHP-5, but Debian 10 offers PHP-7.3, you have to upgrade php manually. 

One issue that has been seen has been with php-fpm with Nginx in the error.og:

```
[crit] 629#629: *8 connect() to unix:/var/run/php-fpm.socket failed (2: No such file or directory) while connecting to upstream
```
The existing /etc/nginx/conf-enabled/php-fpm.conf needs to be refactored to support the name of the /var/run/php/php*.sock file so make sure they match.  Restart the service (In the example: service php7.3-fpm restart) first to make sure the sock files are generated correctly before editiong the php-fpm.conf.

For example:

Old
```
upstream php_workers {
    server unix:/var/run/php-fpm.socket;}
```

New (based on actual file)
```
upstream php_workers {
    server unix:/var/run/php/php7.3-fpm.sock;}
```


## SOGo Groupware

Please replace `stretch` by `buster` in file
`/etc/apt/sources.list.d/sogo-nightly.repo`, then upgrade sogo packages.
