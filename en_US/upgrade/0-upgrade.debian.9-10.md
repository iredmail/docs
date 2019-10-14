# Fixes you need after upgrading Debian from 9 to 10

[TOC]

!!! warning

    This is still a DRAFT document, it may miss some other important changes.

## Postfix

* If you're running MySQL/MariaDB or PostgreSQL backend, you need to remove
  parameter `port =` in `/etc/postfix/mysql/*.cf` and `/etc/postfix/pgsql/*.cf`.

## Dovecot

Changes required to be made in Dovecot main config file `/etc/dovecot/dovecot.conf`:

* Remove all `postmaster_address =`.
* Remove parameter `ssl_protocols =`.
* Add new parameter `ssl_min_protocols` like this:

```
ssl_min_protocols = TLSv1.2
```

* Add new parameter `ssl_dh` and load existing file:
    * on CentOS, it's `/etc/pki/tls/dhparams.pem`
    * on Debian/Ubuntu, FreeBSD, OpenBSD, it's `/etc/ssl/dhparams.pem`

```
ssl_dh = </etc/ssl/dhparams.pem
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

Restart Dovecot service is required.

## PHP

Debian 9 offers PHP-5, but Debian 10 has PHP-7.3, you need to upgrade it to 7.3 manually.

## SOGo Groupware

Please replace `stretch` by `buster` in file
`/etc/apt/sources.list.d/sogo-nightly.repo`, then upgrade sogo packages.
