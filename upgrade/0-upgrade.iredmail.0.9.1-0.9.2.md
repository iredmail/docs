# Upgrade iRedMail from 0.9.1 to 0.9.2

[TOC]


## ChangeLog

> We provide remote upgrade service, check [the price](../support.html) and [contact us](../contact.html).

* 2015-05-23: [All backends] Fix the Logjam attack.
* 2015-05-22: [All backends][RHEL/CentOS 7] Update Cluebringer package to avoid database connection failure
* 2015-05-16: [All backends][RHEL/CentOS] Don't ban 'application/octet-stream,
              dat' files in Amavisd. It catches too many normal file types.
* 2015-05-16: [OPTIONAL][All backends] Update one Fail2ban filter regular
              expressio to help catch DoS attacks to SMTP service

## General (All backends should apply these steps)

### Fix 'The Logjam Attack'

For more details about The Logjam Attack, please visit this web site:
[The Logjam Attack](https://weakdh.org). It also provides a detailed
[tutorial](https://weakdh.org/sysadmin.html) to help you fix this issue. We
show you how to fix it on your iRedMail server based on that tutorial.

#### Generating a Unique DH Group

* On RHEL/CentOS: 

```
# openssl dhparam -out /etc/pki/tls/dhparams.pem 2048
```

* On Debian, Ubuntu, FreeBSD, OpenBSD:

```
# openssl dhparam -out /etc/ssl/dhparams.pem 2048
```

#### Update Apache setting

Note: This step is applicable if you have Apache running on your server.
----

* Check your Apache version first:

```
# apachectl -v
```

* Find below settings in Apache SSL config file and update them to below
values. If they don't exist, please add them.

    * on RHEL/CentOS, it's `/etc/httpd/conf.d/ssl.conf`.
    * on Debian/Ubuntu, it's `/etc/apache2/sites-available/default-ssl` (or `default-ssl.conf`).
    * on FreeBSD, it's `/usr/local/etc/apache2*/extra/httpd-ssl.conf`.
    * on OpenBSD, it's not applicable since we don't have Apache installed.

```
SSLProtocol all -SSLv2 -SSLv3

SSLCipherSuite ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA

SSLHonorCipherOrder on
```

* If you're running Apache-2.4.8 or later releases, please add one additional
  setting:

    * on RHEL/CentOS: ```SSLOpenSSLConfCmd DHParameters /etc/pki/tls/dhparams.pem```
    * on Debian/Ubuntu/FreeBSD: ```SSLOpenSSLConfCmd DHParameters /etc/ssl/dhparams.pem```

* If you're running Apache older than version 2.4.8, please append the DHparams
generated above to the end of the certificate file.

    * On RHEL/CentOS: ```# cat /etc/pki/tls/dhparams.pem >> /etc/pki/tls/certs/iRedMail.crt```
    * Debian/Ubuntu: ```# cat /etc/ssl/dhparams.pem >> /etc/ssl/certs/iRedMail.crt```

* Reloading or restarting Apache service is required:

```
# service httpd restart
```

#### Update Nginx setting

Add or update below settings in `/etc/nginx/conf.d/default.conf` (Linux/OpenBSD)
or `/usr/local/etc/nginx/conf.d/default.conf` (FreeBSD):

```
ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';

ssl_prefer_server_ciphers on;
ssl_dhparam /etc/ssl/dhparams.pem;
```

Note: on RHEL/CentOS, the path to `dhparams.pem` is `/etc/pki/tls/dhparams.pem`.

Reloading or restarting Nginx service is required:

```
# service nginx restart
```

#### Update Dovecot setting

Check Dovecot version number first:

```
# dovecot --version
```

Update Dovecot config file `/etc/dovecot/dovecot.conf` (Linux/OpenBSD) or
`/usr/local/etc/dovecot/dovecot.conf` (FreeBSD):

```
ssl_cipher_list = ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA
```

If you're running Dovecot-2.2.6 or later releases, please add some additional
settings in `dovecot.conf`:

```
ssl_prefer_server_ciphers = yes (Dovecot 2.2.6 or greater)

# Dovecot will regenerate dhparams.pem itself, here we ask it to regenerate
# with 2048 key length.
ssl_dh_parameters_length = 2048
```

Reloading or restarting Dovecot service is required:

```
# service dovecot restart
```

#### Update Postfix setting

Update Postfix settings with below commands:

```
# postconf -e smtpd_tls_exclude_ciphers='aNULL, eNULL, EXPORT, DES, RC4, MD5, PSK, aECDH, EDH-DSS-DES-CBC3-SHA, EDH-RSA-DES-CDC3-SHA, KRB5-DE5, CBC3-SHA'
# postconf -e smtpd_tls_dh1024_param_file='/etc/ssl/dhparams.pem'
```

Note: on RHEL/CentOS, the path to `dhparams.pem` is `/etc/pki/tls/dhparams.pem`.

Reloading or restarting Postfix service is required:

```
# service postfix restart
```

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
# File: /etc/iredmail-release

0.9.2
```

### [RHEL/CentOS 7] Update Cluebringer package to avoid database connection failure

Note: This is applicable to only RHEL/CentOS 7.

With old Cluebringer RPM package, Cluebringer starts before SQL database starts,
this causes Cluebringer cannot connect to SQL database, and all your Cluebringer
settings is not applied at all. Updating Cluebringer package to version
`2.0.14-5` fixes this issue.

How to update package:

```
# yum clean metadata
# yum update cluebringer
# systemctl enable cbpolicyd
```

New package will remove old SysV script `/etc/init.d/cbpolicyd`, and install
`/usr/lib/systemd/system/cbpolicyd.service` for service control. You have to
manage it (start, stop, restart) with `systemctl` command.


### [RHEL/CentOS] Don't ban `application/octet-stream, dat` file types in Amavisd

Note: This is applicable to only RHEL/CentOS.

* Find below lines in Amavisd config file `/etc/amavisd/amavisd.conf`:

```
$banned_namepath_re = new_RE(
    # Unknown binary files.
    [qr'M=application/(zip|rar|arc|arj|zoo|gz|bz2|octet-stream)(,|\t).*T=dat(,|\t)'xmi => 'DISCARD'],
    ...
);
```

* Remove `|octet-stream` in 3rd line. After modified, it's:

```
$banned_namepath_re = new_RE(
    # Unknown binary files.
    [qr'M=application/(zip|rar|arc|arj|zoo|gz|bz2)(,|\t).*T=dat(,|\t)'xmi => 'DISCARD'],
    ...
);
```

* Restart Amavisd service.

```
# service amavisd restart
```

### [OPTIONAL] Update one Fail2ban filter regular expressio to help catch DoS attacks to SMTP service

1. Open file `/etc/fail2ban/filters.d/postfix.iredmail.conf` or
`/usr/local/etc/fail2ban/filters.d/postfix.iredmail.conf` (on FreeBSD), find
below line under `[Definition]` section:

```
            lost connection after AUTH from (.*)\[<HOST>\]
```

Update above line to below one:

```
            lost connection after (AUTH|UNKNOWN|EHLO) from (.*)\[<HOST>\]
```

Restarting Fail2ban service is required.
