# Fixes you need after upgrading Debian from 9 to 10

[TOC]

!!! warning

    This is still a DRAFT document, it may miss some other important changes.

## Dovecot

* Remove parameter `ssl_protocols =`.
* Add new parameter `ssl_min_protocols` like this:

```
ssl_min_protocols = TLSv1.2
```

Note: if you need to support old mail client applications which don't support
`TLSv1.2`, you may need to set it to `TLSv1.1`. Please use `TLSv1.2` if possible.

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

## SOGo Groupware

SOGo packages were removed during upgrading Debian, but SOGo team doesn't
offer nightly build binary packages for Debian 10. We have to remove the
old apt repo (`/etc/apt/sources.list.d/sogo-nightly.list`) and use the sogo
packages offered in Debian 10 official apt repo.

```
rm -f /etc/apt/sources.list.d/sogo-nightly.repo
apt update
apt install sogo
service sogo restart
```