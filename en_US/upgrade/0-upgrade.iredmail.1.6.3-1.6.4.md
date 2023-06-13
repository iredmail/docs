# Upgrade iRedMail from 1.6.3 to 1.6.4

!!! attention

	 Check out the on-premises, lightweight email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

- Jun 13, 2023: initial publish.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.6.4
```

### Fix incorrect ssl CA file in Postfix

Run shell commands below as root user to fix incorrect ssl ca file:

* On RHEL/CentOS/Rocky/AlmaLinux:

```
postconf -e smtp_tls_CAfile='/etc/pki/tls/certs/ca-bundle.crt'
postconf -e smtpd_tls_CAfile='/etc/pki/tls/certs/ca-bundle.crt'
postfix reload
```

* On Debian and Ubuntu:

```
postconf -e smtp_tls_CAfile='/etc/ssl/certs/ca-certificates.crt'
postconf -e smtpd_tls_CAfile='/etc/ssl/certs/ca-certificates.crt'
postfix reload
```

* On FreeBSD and OpenBSD:

```
postconf -e smtp_tls_CAfile='/etc/ssl/cert.pem'
postconf -e smtpd_tls_CAfile='/etc/ssl/cert.pem'
postfix reload
```

