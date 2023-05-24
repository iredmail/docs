# Upgrade iRedMail from 1.6.1 (or 1.6.2) to 1.6.3

!!! attention

	 Check out the on-premises, lightweight email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

- May 24, 2023: Mention breaking changes between Roundcube 1.5.x and 1.6.x.
- May 23, 2023: initial publish.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.6.3
```

### Disable TLSv1 and TLSv1.1 in Postfix

!!! attention

    - TLS 1.0 and 1.1 are vulnerable to downgrade attacks since they rely on
      SHA-1 hash for the integrity of exchanged messages.
    - TLS 1.1 was deprecated in March 2021.

Run shell commands below as root user to disable TLSv1 and TLSv1.1 for SMTP service:

```
postconf -e smtpd_tls_protocols='!SSLv2 !SSLv3 !TLSv1 !TLSv1.1'
postconf -e smtpd_tls_mandatory_protocols='!SSLv2 !SSLv3 !TLSv1 !TLSv1.1'
postconf -e smtp_tls_protocols='!SSLv2 !SSLv3 !TLSv1 !TLSv1.1'
postconf -e smtp_tls_mandatory_protocols='!SSLv2 !SSLv3 !TLSv1 !TLSv1.1'
postconf -e lmtp_tls_protocols='!SSLv2 !SSLv3 !TLSv1 !TLSv1.1'
postconf -e lmtp_tls_mandatory_protocols='!SSLv2 !SSLv3 !TLSv1 !TLSv1.1'
postfix reload
```

### Upgrade iRedAPD (Postfix policy server) to the latest stable release (5.3)

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

### Upgrade iRedAdmin (open source edition) to the latest stable release (2.3)

Please follow below tutorial to upgrade iRedAdmin to the latest stable release:
[Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html).

### Upgrade Roundcube webmail to the latest stable release (1.6.1). WARNING: There're breaking changes.

!!! warning "CentOS 7: please stick to Roundcube 1.5.2"

    If you're running CentOS 7, please upgrade to Roundcube 1.5.2 instead.
    Roundcube 1.5.3 requires PHP-7, but CentOS 7 ships PHP-5.4 which is not
    supported by Roundcube 1.5.3 (and the latest 1.6.0).

    It's time to leave your comfort zone and upgrade this server to CentOS
    Stream 8 or [Rocky Linux 8](https://docs.rockylinux.org/guides/migrate2rocky/).

!!! warning "PHP Version"

    Roundcube 1.6.x requires PHP 7.3 or later releases.

Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release:

!!! attention

    Please upgrade `/opt/www/roundcubemail/composer.json` before upgrade.

* [How to upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).

Few changes  are required if you upgrade from Roundcube 1.5.x or earlier to 1.6.x:

- Main config file `/opt/www/roundcubemail/config/config.inc.php`:
    - Remove (or comment out) `smtp_server` and `smtp_port` parameters, add new
      parameter `smtp_host`.
    - Remove (or comment out) `default_host` and `default_port`, add `imap_host`.
    - Set `auto_create_user` to `true` (default value is `false`). Otherwise newly
      created mail users can not login to Roundcube.

```
$config["smtp_host"] = "tls://127.0.0.1:587";
$config["imap_host"] = "tls://127.0.0.1:143";
$config['auto_create_user'] = true;
```

- Plugin `managesieve` config file `/opt/www/roundcubemail/plugins/managesieve/config.inc.php`:
    - Remove (or comment out) `managesieve_port` and `managesieve_usetls`,
      add new parameter `managesieve_host`.

```
$config["managesieve_host"] = "tls://127.0.0.1:4190";
```

### Upgrade netdata to the latest stable release (1.39.1)

If you have netdata installed, you can upgrade it by following this tutorial:
[Upgrade netdata](./upgrade.netdata.html).

## For MySQL/MariaDB backends

### Add missing index for SQL column `forwardings.forwarding`

Download plain SQL file used to update SQL table, then import it as
MySQL root user (Please run commands below as `root` user):

```
wget -O /tmp/iredmail.mysql https://github.com/iredmail/iRedMail/raw/1.6.3/update/1.6.3/iredmail.mysql
mysql vmail < /tmp/iredmail.mysql
rm -f /tmp/iredmail.mysql
```
