# Upgrade iRedMail from 0.9.1 to 0.9.2

[TOC]

## ChangeLog

> We provide remote upgrade service, check [the price](../support.html) and [contact us](../contact.html).

* 2015-06-03: Fixed: `SSLOpenSSLConfCmd` is used on Ubuntu 15.04 and later releases, not on other Linux/BSD distributions.

----

* 2015-06-03: Initial release.

## General (All backends should apply these steps)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
# File: /etc/iredmail-release

0.9.2
```

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

On Ubuntu 15.04 and later releases, please add one additional setting:

```
SSLOpenSSLConfCmd DHParameters /etc/ssl/dhparams.pem
```

----

Applicable to all Linux/BSD distributions:

----

If you're running Apache older than version 2.4.8, please append the DHparams
generated above to the end of the certificate file. Note: if you use a bought
SSL certificate, append it to your cert file.

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
# Dovecot 2.2.6 or later releases
ssl_prefer_server_ciphers = yes

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

### Upgrade iRedAPD (Postfix policy server) to the latest 1.6.0

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[How to upgrade iRedAPD-1.4.0 or later versions to the latest stable release](./upgrade.iredapd.html)

Detailed release notes are available here: [iRedAPD release notes](./iredapd.releases.html).

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


### [RHEL/CentOS] Update uwsgi config file to make it work with new uwsgi package

A new version of uwsgi package was submitted to EPEL repo, so if you update
packages with command `yum update`, it will be installed. But it's not
compatible with settings configured by iRedMail, this causes uwsgi service
cannot be started, and iRedAdmin is unaccessible. Below steps fix this issue.

* Make sure you're running the uwsgi package provided in EPEL repo:

```
# yum clean metadata
# yum update uwsgi
```

It will create file `/etc/uwsgi.ini` and directory `/etc/uwsgi.d/`.

* Copy a working `/etc/uwsgi.ini` config file from iRedMail repo directly, and
  create required log directory:

```
# cd /tmp/
# wget https://bitbucket.org/zhb/iredmail/raw/1e45afade3af2b214fe7b1dbee2b753cee27a52a/iRedMail/samples/nginx/uwsgi.ini
# mv /etc/uwsgi.ini /etc/uwsgi.ini.bak
# mv /tmp/uwsgi.ini /etc/uwsgi.ini
# mkdir /var/log/uwsgi
# chown root:root /var/log/uwsgi
```

* Now copy old uwsgi instance config file of iRedAdmin to new directory:

```
# mv /etc/uwsgi/iredadmin.ini /etc/uwsgi.d/
# rmdir /etc/uwsgi
```

Note: if you don't have `/etc/uwsgi/iredadmin.ini`, it's ok to use below
one. Be careful, if your web server is running as different daemon user and
group, you must update `chown-socket =` line with correct daemon user/group
name.

```
[uwsgi]
plugins = python
vhost = true
socket = /var/run/uwsgi_iredadmin.socket
pidfile = /var/run/uwsgi_iredadmin.pid
chown-socket = apache:apache
chmod-socket = 660
uid = iredadmin
gid = iredadmin
enable-threads = true
```

* Restart uwsgi service.

```
# service uwsgi restart
```

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

### Update SOGo to the latest stable release, v2.3.0

__Note: this step is required if you're running SOGo on RHEL/CentOS, Debian/Ubuntu.__

SOGo team released new stable version v2.3.0 on Jun 2, it requires system
admin to run a shell script to update SQL structure manually if you're currently
running an old version of SOGo.
http://www.sogo.nu/files/docs/SOGo%20Installation%20Guide.pdf

SOGo-2.3.0 ships this update script, please find it with your package management
tool like `yum`, `dpkg`.

* Update SOGo packages:

    * on RHEL/CentOS: `# yum update`
    * on Debian/Ubuntu: `# apt-get update && apt-get upgrade`
    * on OpenBSD: new SOGo version is not available in ports tree on OpenBSD
      5.7, so you have to stick with current old version on OpenBSD. But if
      you need to update to SOGo-2.3.0 someday, you should apply this step
      too.

Find the update script shipped in SOGo-2.3.0 and run it:

* on RHEL/CentOS:

```
# rpm -ql sogo | grep 'sql-update-2.2.17'
/usr/share/doc/sogo-2.3.0/sql-update-2.1.17_to_2.3.0-mysql.sh   # <- for MySQL
/usr/share/doc/sogo-2.3.0/sql-update-2.1.17_to_2.3.0.sh         # <- for PostgreSQL
```

* on Debian/Ubuntu:

```
# dpkg -L sogo | grep 'sql-update-2.2.17'
/usr/share/doc/sogo/sql-update-2.1.17_to_2.3.0-mysql.sh     # <- for MySQL
/usr/share/doc/sogo/sql-update-2.1.17_to_2.3.0.sh           # <- for PostgreSQL
```

Please pick the one for your SQL server. here we use the one for MySQL
backend on CentOS for example:

```
# bash /usr/share/doc/sogo-2.3.0/sql-update-2.1.17_to_2.3.0-mysql.sh
Username (root): root                                
Hostname (127.0.0.1): 
Database (root): sogo
This script will ask for the sql password twice
Converting c_partstates from VARCHAR(255) to mediumtext in calendar quick tables
Enter password: 
Enter password:
```

After you typed correct SQL admin account and password (twice), the script will
update SQL database and exit silently.

* Restart SOGo service.

    * on RHEL/CentOS: `# service sogod restart`
    * on Debian/Ubuntu: `# service sogo restart`

### [OPTIONAL] Update one Fail2ban filter regular expression to help catch DoS attacks to SMTP service

1. Open file `/etc/fail2ban/filter.d/postfix.iredmail.conf` or
`/usr/local/etc/fail2ban/filter.d/postfix.iredmail.conf` (on FreeBSD), find
below line under `[Definition]` section:

```
            lost connection after AUTH from (.*)\[<HOST>\]
```

Update above line to below one:

```
            lost connection after (AUTH|UNKNOWN|EHLO) from (.*)\[<HOST>\]
```

Restarting Fail2ban service is required.

## OpenLDAP backend special

### Fixed: catch-all support doesn't work with email address which contains address extension

In iRedMail-0.9.1 and earlier versions, there's a known bug that per-domain
catch-all support doesn't work with email address which contains address
extension. for example, email address `username+extension@domain.com`. Below
command fixes this issue.

Notes:

* on Linux/OpenBSD, it's `/etc/postfix/ldap/catchall_maps.cf`.
* on FreeBSD, it's `/usr/local/etc/postfix/ldap/catchall_maps.cf`

```
# perl -pi -e 's#@%d#%s#g' /etc/postfix/ldap/catchall_maps.cf
```

* Restart Postfix service is required.
