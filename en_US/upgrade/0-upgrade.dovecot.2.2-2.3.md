# Upgrade Dovecot from 2.2.x to 2.3.x

[TOC]

Dovecot 2.3 breaks some backward compatible, and here's a short tutorial to
convert your Dovecot 2.2 config file to fully work with Dovecot 2.3.

For more details, please read Dovecot wiki page: [Upgrading Dovecot v2.2 to v2.3](https://wiki2.dovecot.org/Upgrading/2.3).

!!! attention

    Dovecot 2.3 uses TLSv1 as minimal SSL protocol, if you prefer TLSv1.1 or
    TLSv1.2, please set the protocol version in parameter `ssl_min_protocol`
    like below:

    ```
    ssl_min_protocol = TLSv1.2
    ```

## Upgrade Dovecot on Linux/OpenBSD

Run commands below as root user:

```
perl -pi -e 's/^ssl_protocols/#${1}/g' /etc/dovecot/dovecot.conf
perl -pi -e 's#^(mail_plugins.*) stats(.*)#${1} old_stats${2}#g' /etc/dovecot/dovecot.conf
perl -pi -e 's#imap_stats#imap_old_stats#g' /etc/dovecot/dovecot.conf
perl -pi -e 's#service stats#service old-stats#g' /etc/dovecot/dovecot.conf
perl -pi -e 's#fifo_listener stats-mail#fifo_listener old-stats-mail#g' /etc/dovecot/dovecot.conf
perl -pi -e 's#stats_refresh#old_stats_refresh#g' /etc/dovecot/dovecot.conf
perl -pi -e 's#stats_track_cmds#old_stats_track_cmds#g' /etc/dovecot/dovecot.conf
perl -pi -e 's#(postmaster_address.*)##g' /etc/dovecot/dovecot.conf
```

* On RHEL/CentOS, please add new setting in `/etc/dovecot/dovecot.conf`:

```
ssl_dh = </etc/pki/tls/dh2048_param.pem
```

* On Debian/Ubuntu/OpenBSD, please add new setting in `/etc/dovecot/dovecot.conf`:

```
ssl_dh = </etc/ssl/dh2048_param.pem
```

## Upgrade Dovecot on FreeBSD

Run commands below as root user:

```
perl -pi -e 's/^ssl_protocols/#${1}/g' /usr/local/etc/dovecot/dovecot.conf
perl -pi -e 's#^(mail_plugins.*) stats(.*)#${1} old_stats${2}#g' /usr/local/etc/dovecot/dovecot.conf
perl -pi -e 's#imap_stats#imap_old_stats#g' /usr/local/etc/dovecot/dovecot.conf
perl -pi -e 's#service stats#service old-stats#g' /usr/local/etc/dovecot/dovecot.conf
perl -pi -e 's#fifo_listener stats-mail#fifo_listener old-stats-mail#g' /usr/local/etc/dovecot/dovecot.conf
perl -pi -e 's#stats_refresh#old_stats_refresh#g' /usr/local/etc/dovecot/dovecot.conf
perl -pi -e 's#stats_track_cmds#old_stats_track_cmds#g' /usr/local/etc/dovecot/dovecot.conf
perl -pi -e 's#(postmaster_address.*)##g' /usr/local/etc/dovecot/dovecot.conf
```

Add new setting in `/etc/dovecot/dovecot.conf`:

```
ssl_dh = </etc/ssl/dh2048_param.pem
```
