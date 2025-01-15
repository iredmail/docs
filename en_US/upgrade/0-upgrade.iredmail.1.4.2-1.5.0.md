# Upgrade iRedMail from 1.4.2 to 1.5.0

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! note "Remote Upgrade Assistance"

    Check out our [remote upgrade support](https://www.iredmail.org/support.html) if you need assistance.

## ChangeLog

- Dec 27, 2021: initial release.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.5.0
```

### Upgrade iRedAPD (Postfix policy server) to the latest stable release (5.0.4)

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

### Upgrade iRedAdmin (open source edition) to the latest stable release (1.6)

Please follow below tutorial to upgrade iRedAdmin to the latest stable release:
[Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html).

### Upgrade mlmmjadmin to the latest stable release (3.1.3)

Please follow below tutorial to upgrade mlmmjadmin to the latest stable release:
[Upgrade mlmmjadmin to the latest stable release](./upgrade.mlmmjadmin.html)

### Upgrade Roundcube webmail to the latest stable release (1.5.1)

!!! warning "MySQL and MariaDB server tunning"

    On CentOS 7, Debian 10 and Ubuntu 18.04, you must add 2 parameters in
    MySQL or MariaDB config file to avoid error
    `Specified key was too long; max key length is 767 bytes`:

    - On CentOS 7: it's `/etc/my.cnf`
    - On Debian 10: it's `/etc/mysql/my.cnf`

```
[mysqld]
innodb_large_prefix=ON
innodb_file_format=Barracuda
```

Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release:

* [How to upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).

### Upgrade netdata to the latest stable release (1.32.1)

If you have netdata installed, you can upgrade it by following this tutorial:
[Upgrade netdata](./upgrade.netdata.html).

### Nginx: several improvements

!!! attention

    All credit goes to GitHub user
    [@ludovicandrieux](https://github.com/ludovicandrieux), thanks for the
    contributions. See also:
    [#136](https://github.com/iredmail/iRedMail/issues/136), 
    [#137](https://github.com/iredmail/iRedMail/issues/137),
    [#138](https://github.com/iredmail/iRedMail/issues/138).

- Enable TLSv1.3. WARNING: It requires Nginx 1.13 or later releases, which is
  available on:
    - CentOS 7 and later
    - Debian 10 and later
    - Ubuntu 18.04 and later
    - FreeBSD
    - OpenBSD
- Greatly improve the performance of http keep-alive connections over SSL by
  enabling `ssl_session_cache` parameter. See also:
    - [Speeding up TLS: enabling session reuse](https://vincent.bernat.ch/en/blog/2011-ssl-session-reuse-rfc5077)
    - [ssl_session_cache in Nginx and the ab benchmark](https://www.peterbe.com/plog/ssl_session_cache-ab)
- Add new ssl cipher: `EECDH+CHACHA20`. It requires openssl 1.1.0, which is
  available on:
    - CentOS 7 and later
    - Debian 9 and later
    - Ubuntu 18.04 and later
    - FreeBSD
    - OpenBSD
- Remove weak ssl cipher: `AES256+EDH`.

To apply these changes, please open file `/etc/nginx/templates/ssl.tmpl` with
your favourite text editor, then:

- Append `TLSv1.3` in parameter `ssl_protocols`. For example:

```
ssl_protocols TLSv1.2 TLSv1.3;
```

- Prepend `EECDH+CHACHA20` in parameter `ssl_ciphers`, also remove `AES256+EDH`.
  For example:

```
ssl_ciphers EECDH+CHACHA20:EECDH+AESGCM:EDH+AESGCM:AES256+EECDH;
```

- Add new parameter `ssl_session_cache` and optional comment lines:

```
# Greatly improve the performance of keep-alive connections over SSL.
# With this enabled, client is not necessary to do a full SSL-handshake for
# every request, thus saving time and cpu-resources.
ssl_session_cache shared:SSL:10m;
```

Restarting Nginx service is required.

### Dovecot: enable a new ssl cipher and remove a weak one

Please open file `/etc/dovecot/dovecot.conf` (Linux/OpenBSD) or
`/usr/local/etc/dovecot/dovecot.conf` (FreeBSD), update parameter
`ssl_cipher_list` to below value, it adds new cipher `EECDH+CHACHA20` and
removes the weak one `AES256+EDH`:

```
ssl_cipher_list = EECDH+CHACHA20:EECDH+AESGCM:EDH+AESGCM:AES256+EECDH
```

Restarting Dovecot service is required.
