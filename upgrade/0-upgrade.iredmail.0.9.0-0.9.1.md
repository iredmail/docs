# Upgrade iRedMail from 0.9.0 to 0.9.1

[TOC]


__WARNING: Still working in progress, do _NOT_ apply it.__

## ChangeLog

* 2015-02-25: [All backends] [__OPTIONAL__] Bypass greylisting for some big ISPs.
* 2015-02-25: [All backends] [__OPTIONAL__] Add one more Fail2ban filter to help catch spam (POP3/IMAP flood).
* 2015-02-17: [All backends ] Upgrade Roundcube webmail to the latest stable release.
* 2015-02-11: [All backends] [__OPTIONAL__] Setup Fail2ban to monitor password failures in SOGo log file.
* 2015-02-11: [All backends] Fixed: Cannot run PHP script under web document root with Nginx.
* 2015-02-09: [All backends] [__OPTIONAL__] Add one more Fail2ban filter to help catch spam.
* 2015-02-04: [All backends] Fixed: return receipt response rejected by iRedAPD plugin `reject_null_sender`.
* 2015-02-02: [All backends] Fixed: Not backup SOGo database. Note: this step
              is not applicable if you don't use SOGo groupware.
* 2015-01-13: [All backends] Fixed: Incorrect path of command `sogo-tool` on OpenBSD.
* 2015-01-12: [SQL backends] Fixed: Not apply service restriction in Dovecot
              SQL query file while acting as SASL server.

## General (All backends should apply these steps)

### Upgrade Roundcube webmail to the latest stable release

Additional notes before upgrading Roundcube webmail 1.1.0 (or later releases):

* for RHEL/CentOS users, please install package `php-pear-Net-IDNA2`, then
  restart Apache service or php5-fpm service (if you're running Nginx):

```
# yum install php-pear-Net-IDNA2
# service httpd restart       # <- OR: service php-fpm restart
```

* for Debian/Ubuntu users, please install package `php-pear` and `php5-intl`,
  enable `intl` module for PHP, then restart Apache service or `php5_fpm`
  service (if you're running Nginx):

```
# apt-get install php-pear php5-intl
# php5enmod intl
# service apache2 resart    # <- OR: service php5_fpm restart
```

* for OpenBSD users, please install package `php-intl`, then
  restart `php_fpm` service:

```
# pkg_add -r php-intl
# /etc/rc.d/php_fpm restart
```

After you have additional packages installed, please follow Roundcube official
tutorial to upgrade Roundcube webmail to the latest stable release:
[How to upgrade Roundcube](http://trac.roundcube.net/wiki/Howto_Upgrade)

Note: it's recommended to download the `Complete` edition (e.g.
`roundcubemail-1.1.0-complete.tar.gz` instead of `Dependent` edition (e.g.
`roundcubemail-1.1.0.tar.gz`).

### Fixed: return receipt response rejected by iRedAPD plugin `reject_null_sender`

Note: this is applicable if you want to keep iRedAPD plugin `reject_null_sender`
but still able to send return receipt with Roundcube webmail.

According to RFC2298, return receipt envelope sender address must be empty. If
you have iRedAPD plugin `reject_null_sender` enabled, it will reject return
receipt response. To particularly solve this issue, you can set below setting
in Roundcube config file `config/config.inc.php`:

* on RHEL/CentOS/OpenBSD, it's `/var/www/roundcubemail/config/config.inc.php`.
* on Debian/Ubuntu, it's `/usr/share/apache2/roundcubemail/config/config.inc.php`.
* on FreeBSD, it's `/usr/local/www/roundcube/config/config.inc.php`.

```
$config['mdn_use_from'] = true;
```

Note: if other mail client applications don't set smtp authentication user as
envelope sender of return receipt, same issue will occurs. You must disable
iRedAPD plugin `reject_null_sender` in `/opt/iredapd/settings.py` to make all
mail clients work.

iRedAPD plugin `reject_null_sender` rejects message submitted by sasl
authenticated user but with null sender in `From:` header (`from=<>` in Postfix
log). If your user's password was cracked by spammer, spammer can use this
account to bypass smtp authentication, but with a null sender in `From:`
header, throttling won't be triggered.

### Fixed: Cannot run PHP script under web document root with Nginx.

With previous release of iRedMail, Nginx won't run PHP scripts under
sub-directories of web document root, this step will fix it.

* Open Nginx config file `/etc/nginx/conf.d/default.conf` (on Linux/OpenBSD)
or `/usr/local/etc/nginx/conf.d/default.conf`, add one more setting in
configuration block `location ~ \.php$ {}` like below:

```
...
root /var/www/html;
...
location ~ \.php$ {
    ...
    fastcgi_param SCRIPT_FILENAME /var/www/html$fastcgi_script_name;    # <- Add this line
}
```

* Save your changes and restart Nginx service.

Notes:

* There're two `location ~ \.php$ {}` blocks, please update both of them.
* You must replace `/var/www/html` in above sample code to the value of `root`
  setting defined in same config file.

    * on RHEL/CentOS, it's `/var/www/html`.
    * on Debian/Ubuntu, it's `/var/www`.
    * on FreeBSD, it's `/usr/local/www/apache22/data`.
      Note: if you're running Apache-2.4, the directory name should be
      `apache24`, not `apache22`.
    * on OpenBSD, it's `/var/www/htdocs`.

### Fixed: Incorrect path of command `sogo-tool` on OpenBSD

Note: this step is applicable to only OpenBSD.

Please check user `_sogo`'s cron job, make sure path to `sogo-tool` command is
`/usr/local/sbin/sogo-tool`:

```
# crontab -l -u _sogo
```

If it's not `/usr/local/sbin/sogo-tool`, please edit its cron job with below
command and fix it:

```
# crontab -e -u _sogo
```

### [__OPTIONAL__] Setup Fail2ban to monitor password failures in SOGo log file

To improve server security, we'd better block clients which have too many
failed login attempts from SOGo.

Please append below lines in Fail2ban main config file `/etc/fail2ban/jail.local`:

```
[SOGo]
enabled     = true
filter      = sogo-auth
port        = http, https
# without proxy this would be:
# port    = 20000
action      = iptables-multiport[name=SOGo, port="http,https", protocol=tcp]
logpath     = /var/log/sogo/sogo.log
```

Restarting Fail2ban service is required.

### [OPTIONAL] Add two more Fail2ban filter regular expressios to help catch spam

We have two new Fail2ban filters to help catch spam:

1. first one will scan HELO rejections in Postfix log file.
1. second one will scan aborded pop3/imap login in Dovecot log file.

Steps:

1. Open file `/etc/fail2ban/filters.d/postfix.iredmail.conf` or
`/usr/local/etc/fail2ban/filters.d/postfix.iredmail.conf` (on FreeBSD), append
below line under `[Definition]` section:

```
            reject: RCPT from (.*)\[<HOST>\]: 504 5.5.2 (.*) Helo command rejected: need fully-qualified hostname
```

After modification, the whole content is:

```
[Definition]
failregex = \[<HOST>\]: SASL (PLAIN|LOGIN) authentication failed
            lost connection after AUTH from (.*)\[<HOST>\]
            reject: RCPT from (.*)\[<HOST>\]: 550 5.1.1
            reject: RCPT from (.*)\[<HOST>\]: 450 4.7.1
            reject: RCPT from (.*)\[<HOST>\]: 554 5.7.1
            reject: RCPT from (.*)\[<HOST>\]: 504 5.5.2 (.*) Helo command rejected: need fully-qualified hostname
ignoreregex =
```

2. Open file `/etc/fail2ban/filters.d/dovecot.iredmail.conf` or
`/usr/local/etc/fail2ban/filters.d/dovecot.iredmail.conf` (on FreeBSD), append
below line under `[Definition]` section:

```
            Aborted login \(no auth attempts in .* rip=<HOST>
```

After modification, the whole content is:

```
[Definition]
failregex = (?: pop3-login|imap-login): .*(?:Authentication failure|Aborted login \(auth failed|Aborted login \(tried to use disabled|Disconnected \(auth failed).*rip=(?P<host>\S*),.*
            Aborted login \(no auth attempts in .* rip=<HOST>
ignoreregex =
```

Restarting Fail2ban service is required.

## OpenLDAP backend special

### Fixed: not backup SOGo database

Note: this step is not applicable if you don't use SOGo groupware.

Open backup script `/var/vmail/backup/backup_mysql.sh`, append SOGo SQL
database name in variable `DATABASES=`. For example:

```
DATABASES='... sogo'
```

Save your change and that's all.

### [__OPTIONAL__] Bypass greylisting for some big ISPs

ISPs' mail servers send out spams, but also normal business mails. Applying
greylisting on them is helpless.

* Download SQL template file:

```
# cd /tmp
# wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/cluebringer/greylisting-whitelist.sql
```

* Login to MySQL database and import this file:

```
$ mysql -uroot -p
mysql> USE cluebringer;
mysql> SOURCE /tmp/greylisting-whitelist.sql;
```

That's all.

## MySQL/MariaDB backend special

### Fixed: Not apply service restriction in Dovecot SQL query file while acting as SASL server

Please open Dovecot config file `/etc/dovecot/dovecot-mysql.conf`
(Linux/OpenBSD) or `/usr/local/etc/dovecot/dovecot-mysql.conf` (FreeBSD), find
below line:

```
# Part of file: /etc/dovecot/dovecot-mysql.conf

password_query = SELECT password FROM mailbox WHERE username='%u' AND active='1'
```

Add additional query `AND enable%Ls%Lc=1` like below:

```
# Part of file: /etc/dovecot/dovecot-mysql.conf

password_query = SELECT password FROM mailbox WHERE username='%u' AND enable%Ls%Lc=1 AND active='1'
```

Save your change and restart Dovecot service.

### Fixed: not backup SOGo database

Note: this step is not applicable if you don't use SOGo groupware.

Open backup script `/var/vmail/backup/backup_mysql.sh`, append SOGo SQL
database name in variable `DATABASES=`. For example:

```
DATABASES='... sogo'
```

Save your change and that's all.

### [__OPTIONAL__] Bypass greylisting for some big ISPs

ISPs' mail servers send out spams, but also normal business mails. Applying
greylisting on them is helpless.

* Download SQL template file:

```
# cd /tmp
# wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/cluebringer/greylisting-whitelist.sql
```

* Login to MySQL database and import this file:

```
$ mysql -uroot -p
mysql> USE cluebringer;
mysql> SOURCE /tmp/greylisting-whitelist.sql;
```

That's all.

## PostgreSQL backend special

### Fixed: Not apply service restriction in Dovecot SQL query file while acting as SASL server

Please open Dovecot config file `/etc/dovecot/dovecot-pgsql.conf`
(Linux/OpenBSD) or `/usr/local/etc/dovecot/dovecot-pgsql.conf` (FreeBSD), find
below line:

```
# Part of file: /etc/dovecot/dovecot-pgsql.conf

password_query = SELECT password FROM mailbox WHERE username='%u' AND active='1'
```

Add additional query like below:

```
# Part of file: /etc/dovecot/dovecot-pgsql.conf

password_query = SELECT password FROM mailbox WHERE username='%u' AND enable%Ls%Lc=1 AND active='1'
```

Save your change and restart Dovecot service.

### Fixed: not backup SOGo database

Note: this step is not applicable if you don't use SOGo groupware.

Open backup script `/var/vmail/backup/backup_mysql.sh`, append SOGo SQL
database name in variable `DATABASES=`. For example:

```
DATABASES='... sogo'
```

Save your change and that's all.

### [__OPTIONAL__] Bypass greylisting for some big ISPs

ISPs' mail servers send out spams, but also normal business mails. Applying
greylisting on them is helpless.

* Download SQL template file:

```
# cd /tmp
# wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/cluebringer/greylisting-whitelist.sql
```

* Switch to PostgreSQL daemon user, then execute SQL commands to import it:

    * On Linux, PostgreSQL daemon user is `postgres`.
    * On FreeBSD, PostgreSQL daemon user is `pgsql`.
    * On OpenBSD, PostgreSQL daemon user is `_postgresql`.

```
# su - postgres
$ psql -d cluebringer
sql> \i /tmp/greylisting-whitelist.sql;
```

That's all.
