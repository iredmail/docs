# Upgrade iRedMail from 1.6.3 to 1.6.4

!!! attention

	 Check out the on-premises, lightweight email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

- Jul 28, 2023: initial publish.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.6.4
```

### [REQUIRED] CentOS Stream / Rocky / AlmaLinux 8: Switch to PHP v8.0

CentOS / Rocky / AlmaLinux 8 offers php v8.0 in official yum repository, you
can switch to php v8.0 if you want by following this short tutorial, so that
you can upgrade Roundcube to latest v1.6.2.

- [Upgrade php to 8.0 on CentOS Stream / Rocky / AlmaLinux 8](./upgrade.php.v8.0.on.centos.8.html)

### Fix incorrect ssl CA file and IDN support in Postfix

Run shell commands below as root user to fix incorrect ssl ca file, also
disable IDN support.

* On RHEL/CentOS/Rocky/AlmaLinux:

```
postconf -e smtp_tls_CAfile='/etc/pki/tls/certs/ca-bundle.crt'
postconf -e smtpd_tls_CAfile='/etc/pki/tls/certs/ca-bundle.crt'
postconf -e smtputf8_enable=no
postfix reload
```

* On Debian and Ubuntu:

```
postconf -e smtp_tls_CAfile='/etc/ssl/certs/ca-certificates.crt'
postconf -e smtpd_tls_CAfile='/etc/ssl/certs/ca-certificates.crt'
postconf -e smtputf8_enable=no
postfix reload
```

* On FreeBSD and OpenBSD:

```
postconf -e smtp_tls_CAfile='/etc/ssl/cert.pem'
postconf -e smtpd_tls_CAfile='/etc/ssl/cert.pem'
postconf -e smtputf8_enable=no
postfix reload
```

### Upgrade iRedAPD (Postfix policy server) to the latest stable release (5.3)

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

### Upgrade netdata to the latest stable release (1.41.0)

If you have netdata installed, you can upgrade it by following this tutorial:
[Upgrade netdata](./upgrade.netdata.html).

### Upgrade Roundcube webmail to the latest stable release (1.6.2)

!!! warning "CentOS 7: please stick to Roundcube 1.5.2"

    If you're running CentOS 7, please upgrade to Roundcube 1.5.2 instead.
    Roundcube 1.5.3 requires PHP-7, but CentOS 7 ships PHP-5.4 which is not
    supported by Roundcube 1.5.3 (and the latest 1.6.0).

    It's time to leave your comfort zone and upgrade this server to at least
    CentOS Stream 8 or [Rocky Linux 8](https://docs.rockylinux.org/guides/migrate2rocky/).

Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release:

* [How to upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).
