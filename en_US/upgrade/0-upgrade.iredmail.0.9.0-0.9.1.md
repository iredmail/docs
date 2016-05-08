# Upgrade iRedMail from 0.9.0 to 0.9.1

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](../support.html) and [contact us](../contact.html).

## ChangeLog

* 2015-05-15: Initial public.

## General (All backends should apply these steps)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
# File: /etc/iredmail-release

0.9.1
```

### Upgrade Roundcube webmail to the latest stable release

Additional notes before upgrading Roundcube webmail 1.1.0 (or later releases):

* for Debian/Ubuntu users, please install package `php-pear` and `php5-intl`,
  enable `intl` module for PHP, then restart Apache service or `php5_fpm`
  service (if you're running Nginx):

```
# apt-get install php-pear php5-intl
# php5enmod intl
# service apache2 restart    # <- OR: `service php5_fpm restart` if you're running Nginx
```

* for OpenBSD users, please install package `php-intl`, then
  restart `php_fpm` service:

```
# pkg_add -r php-intl
# /etc/rc.d/php_fpm restart
```

Please download the `Complete` edition (e.g. `roundcubemail-1.1.1-complete.tar.gz`)
instead of `Dependent` edition (e.g. `roundcubemail-1.1.1.tar.gz`).

After you have additional packages installed, please follow Roundcube official
tutorial to upgrade Roundcube webmail to the latest stable release:
[How to upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).

Notes:

* If you're going to update PHP to 5.6, you should add below settings in
  Roundcube config file (`config/config.inc.php`) to avoid ssl certificate issue.
  If you don't know the location of this config file, check our tutorial here:
  [Locations of configuration and log files of major components](./file.locations.html#roundcube-webmail).

```
// Required if you're running PHP 5.6
$config['imap_conn_options'] = array(
    'ssl' => array(
        'verify_peer'  => false,
        'verify_peer_name' => false,
    ),
);

$config['smtp_conn_options'] = array(
    'ssl' => array(
        'verify_peer'      => false,
        'verify_peer_name' => false,
    ),
);
```

### Upgrade iRedAPD (Postfix policy server) to the latest 1.5.0

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

Detailed release notes are available here: [iRedAPD release notes](./iredapd.releases.html).

Note:

iRedAPD-1.5.0 is able to log rejection and other non-DUNNO actions in iRedAdmin
database, admin can view the log under menu `System -> Admin Log` of iRedAdmin.
If you want to log these actions, please add below new parameters in iRedAPD
config file `/opt/iredapd/settings.py`:

```
# Log reject (and other non-DUNNO) action in iRedAdmin SQL database
log_action_in_db = True
iredadmin_db_server = '127.0.0.1'
iredadmin_db_port = '3306'
iredadmin_db_name = 'iredadmin'
iredadmin_db_user = 'iredadmin'
iredadmin_db_password = 'password'
```
You can find SQL username/password of iRedAdmin database in iRedAdmin config
file.

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

### Fixed: Amavisd cannot ban zipped `.exe` attachment file.

Note: this is applicable to only RHEL/CentOS.

Amavisd on some Linux/BSD distribution uses `$banned_namepath_re`
instead of `$banned_filename_re` to check banned file types, but it
(`$banned_namepath_re`) was not defined, so we define some blocked file
types here.

Please append below settings in Amavisd config file `/etc/amavisd/amavisd.conf`,
before the last line (`1;  # insure a defined return`) in the same file:

```
# Amavisd on some Linux/BSD distribution use \$banned_namepath_re
# instead of \$banned_filename_re, so we define some blocked file
# types here.
#
# Sample input for $banned_namepath_re:
#
#   P=p003\tL=1\tM=multipart/mixed\nP=p002\tL=1/2\tM=application/octet-stream\tT=dat\tN=my_docum.zip
#
# What it means:
#   - T: type. e.g. zip archive.
#   - M: MIME type. e.g. application/octet-stream.
#   - N: suggested (MIME) name. e.g. my_docum.zip.

$banned_namepath_re = new_RE(
    # Unknown binary files.
    [qr'M=application/(zip|rar|arc|arj|zoo|gz|bz2)(,|\t).*T=dat(,|\t)'xmi => 'DISCARD'],

    [qr'T=(exe|exe-ms|lha|cab|dll)(,|\t)'xmi => 'DISCARD'],       # banned file(1) types
    [qr'T=(pif|scr)(,|\t)'xmi => 'DISCARD'],                      # banned extensions - rudimentary
    [qr'T=ani(,|\t)'xmi => 'DISCARD'],                            # banned animated cursor file(1) type
    [qr'T=(mim|b64|bhx|hqx|xxe|uu|uue)(,|\t)'xmi => 'DISCARD'],   # banned extension - WinZip vulnerab.
    [qr'M=application/x-msdownload(,|\t)'xmi => 'DISCARD'],       # block these MIME types
    [qr'M=application/x-msdos-program(,|\t)'xmi => 'DISCARD'],
    [qr'M=application/hta(,|\t)'xmi => 'DISCARD'],
    [qr'M=(application/x-msmetafile|image/x-wmf)(,|\t)'xmi => 'DISCARD'],  # Windows Metafile MIME type
);
```

Restarting Amavisd service is required.

### Fixed: Amavisd cannot detect `.exe` file in rar compressed attachment.

Note: This fix is applicable to RHEL/CentOS, Debian and Ubuntu.

* On RHEL/CentOS, iRedMail doesn't install `unrar`.
* On Debian/Ubuntu, iRedMail installs package `unrar-free` as unarchiver to
  uncompress `.rar` attachment, but Amavisd cannot correctly detect `.exe` file
  in rar compressed file.

Steps to fix this issue on RHEL/CentOS:

```
# yum clean metadata
# yum install unrar
# service amavisd restart
```

----

Steps to fix this issue on Debian:

* Install package `unrar-free`, restart Amavisd service.

```
# apt-get install unrar-free
# service amavis restart
```

----

Steps to fix this issue on Ubuntu:

* Make sure you have `multiverse` section enabled in `/etc/apt/sources.list`.
  for example:

```
# For Ubuntu 14.04 LTS
deb http://[ubuntu_mirror_site]/ubuntu/ trusty main restricted universe multiverse
deb http://[ubuntu_mirror_site]/ubuntu/ trusty-updates main restricted universe multiverse

# For Ubuntu 15.04
deb http://[ubuntu_mirror_site]/ubuntu/ vivid main restricted universe multiverse
deb http://[ubuntu_mirror_site]/ubuntu/ vivid-updates main restricted universe multiverse
```

* Delete package `unrar-free`, install package `unrar`.

```
# apt-get remove --purge unrar-free
# apt-get install unrar
```

* Add below setting in Amavisd config file `/etc/amavis/conf.d/50-user` to ask
  Amavisd to use `unrar-nonfree` as unarchiver:

```
$unrar = ['unrar-nonfree'];
```

* Restart Amavisd service:

```
# service amavis restart
```

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

### Fixed: Incorrect log file and owner/group in logrotate config file: `/etc/logrotate.d/policyd`

Note: This is applicable to Linux and FreeBSD, we don't have Cluebringer
installed on OpenBSD.

iRedMail-0.9.0 generates logrotate config file `/etc/logrotate.d/policyd` with
incorrect log file name and owner/group.

The original setting looks like below:

```
/var/log/amavisd.log {
    ...
    create 0600 amavis amavis
    ...
}
```

Please change the log file name and owner/group to below settings:

```
/var/log/cbpolicyd.log {
    ...
    create 0600 cluebringer cluebringer
    ...
}
```

Note: on FreeBSD, the owner/group name is `policyd`, not `cluebringer`.

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

### [__OPTIONAL__] Make Dovecot subscribe newly created folder automatically

With default iRedMail setting, Dovecot will create folder automatically (for
example, send email to `user+extension@domain.com` will create folder
`extension` in `user@domain.com`'s mailbox), but not subscribe it. Below change
will make it subscribe to new folder automatically.

* Open Dovecot config file `/etc/dovecot/dovecot.conf` (Linux/OpenBSD) or
  `/usr/local/etc/dovecot/dovecot.conf` (FreeBSD), find block `protocol lda {}`
  like below:

```
protocol lda {
    ...
}
```

* Add one more setting in this block:

```
protocol lda {
    ...
    lda_mailbox_autosubscribe = yes
}
```

* Restarting Dovecot service.

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

1. Open file `/etc/fail2ban/filter.d/postfix.iredmail.conf` or
`/usr/local/etc/fail2ban/filter.d/postfix.iredmail.conf` (on FreeBSD), append
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

2. Open file `/etc/fail2ban/filter.d/dovecot.iredmail.conf` or
`/usr/local/etc/fail2ban/filter.d/dovecot.iredmail.conf` (on FreeBSD), replace
its content by below text:

```
[Definition]
failregex = Authentication failure.* rip=<HOST>
            Aborted login \(no auth attempts in .* rip=<HOST>
            Aborted login \(auth failed.* rip=<HOST>
            Aborted login \(tried to use disallowed .* rip=<HOST>
            Aborted login \(tried to use disabled .* rip=<HOST>

ignoreregex =
```

Restarting Fail2ban service is required.

## OpenLDAP backend special

### Use the latest LDAP schema file provided by iRedMail

We have a new attribute `allowNets` for mail user in the latest LDAP schema
file. With this new attribute, you can restrict mail users to login from
specified IP addresses or networks, multiple IP/nets must be separated by
comma.

Steps to use the latest LDAP schema file are:

* Download the newest iRedMail ldap schema file
* Copy old ldap schema file as a backup copy
* Replace the old one
* Restart OpenLDAP service.

Here we go:

* On RHEL/CentOS, OpenBSD:

```
# cd /tmp
# wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/iredmail.schema

# cd /etc/openldap/schema/
# cp iredmail.schema iredmail.schema.bak

# cp -f /tmp/iredmail.schema /etc/openldap/schema/
# /etc/init.d/slapd restart
```

* On Debian/Ubuntu:
```
# cd /tmp
# wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/iredmail.schema

# cd /etc/ldap/schema/
# cp iredmail.schema iredmail.schema.bak

# cp -f /tmp/iredmail.schema /etc/ldap/schema/
# /etc/init.d/slapd restart
```

* On FreeBSD:

```
# cd /tmp
# wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/iredmail.schema

# cd /usr/local/etc/ldap/schema/
# cp iredmail.schema iredmail.schema.bak

# cp -f /tmp/iredmail.schema /usr/local/etc/openldap/schema/
# /etc/init.d/slapd restart
```

### Restrict mail user to login from specified IP addresses or networks

With the latest LDAP schema file, it's able to restrict mail users to login
from specified IP/networks.

Open Dovecot config file `/etc/dovecot/dovecot-ldap.conf` (Linux/OpenBSD) or
`/usr/local/etc/dovecot/dovecot-ldap.conf` (FreeBSD), append
`allowNets=allow_nets` in parameter `pass_attrs`. The final setting should be:

```
pass_attrs      = mail=user,userPassword=password,allowNets=allow_nets             
```

Restarting Dovecot service is required.

> Sample usage: allow user `user@domain.com` to login from IP `172.16.244.1`
> and network `192.168.1.0/24`:
>
```
dn: mail=user@domain.com,ou=Users,domainName=domain.com,o=domains,dc=xx,dc=xx
objectClass: mailUser
mail: user@domain.com
allowNets: 192.168.1.10,192.168.1.0/24
...
```
>
>To remove this restriction, just remove attribute `allowNets` for this user.

### Fixed: not backup SOGo database

Note: this step is not applicable if you don't use SOGo groupware.

Open backup script `/var/vmail/backup/backup_mysql.sh`, append SOGo SQL
database name in variable `DATABASES=`. For example:

```
DATABASES='... sogo'
```

Save your change and that's all.

### Fixed: drop retired column in Amavisd database: `policy.spam_modifies_subj`

Note: This is applicable to Amavisd-new-2.7.0 and later releases.

Amavisd drops column `policy.spam_modifies_subj` since amavisd-new-2.7.0
release, we'd better remove this column.

Login to MySQL server as root user, then execute below SQL commands to drop it:

```
mysql> USE amavisd;
mysql> ALTER TABLE policy DROP COLUMN spam_modifies_subj;
```

### [__OPTIONAL__] Bypass greylisting for some big ISPs

ISPs' mail servers send out spams, but also normal business mails. Applying
greylisting on them is helpless.

* Download SQL template file:

```
# cd /tmp
# wget https://bitbucket.org/zhb/iredmail/raw/40b98d7dde0178d54498e170c8b5165c0316dc96/iRedMail/samples/cluebringer/greylisting-whitelist.sql
```

* Login to MySQL database and import this file:

```
$ mysql -uroot -p
mysql> USE cluebringer;
mysql> SOURCE /tmp/greylisting-whitelist.sql;
```

That's all.

## MySQL/MariaDB backend special

### Add new SQL column in `vmail` database

We have a new SQL column `mailbox.allow_nets` in `vmail` database, it's used
to restrict mail users to login from specified IP addresses or networks,
multiple IP/nets must be separated by comma.

Connect to SQL server as MySQL root user, create new column:

```
$ mysql -uroot -p
mysql> USE vmail;
mysql> ALTER TABLE mailbox ADD COLUMN `allow_nets` TEXT DEFAULT NULL;
```

### Restrict mail user to login from specified IP addresses or networks, and apply service restriction while acting as SASL server

* With new SQL column `mailbox.allow_nets`, it's able to restrict mail users to
  login from specified IP/networks. We have sample usage below.

* With new service restriction, it's able to enable or disable smtp service for
  mail users.

Open Dovecot config file `/etc/dovecot/dovecot-mysql.conf` (Linux/OpenBSD) or
`/usr/local/etc/dovecot/dovecot-mysql.conf` (FreeBSD), then:

* append `allow_nets` in parameter `password_query`
* append `AND enable%Ls%Lc=1` in `WHERE` statement

The final setting should be:

```
password_query = SELECT password, allow_nets FROM mailbox WHERE username='%u' AND enable%Ls%Lc=1 AND active='1'
```

Restarting Dovecot service is required.

> Sample usage: allow user `user@domain.com` to login from IP `172.16.244.1`
> and network `192.168.1.0/24`:
>
```
sql> USE vmail;
sql> UPDATE mailbox SET allow_nets='172.16.244.1,192.168.1.0/24' WHERE username='user@domain.com`;
```
>
>To remove this restriction, just set `mailbox.allow_nets` to `NULL`, not empty string.

### Fixed: user+extension@domain.com doesn't work with per-domain catch-all

With iRedMail-0.9.0 and earlier versions, if you have per-domain catch-all
enabled, email sent to `user+extension@domain.com` will be delivered to
catch-all address instead of `user@domain.com`. Below steps fix this issue.

* Open file `/etc/postfix/mysql/catchall_maps.cf` (Linux/OpenBSD) or
  `/usr/local/etc/postfix/mysql/catchall_maps.cf` (FreeBSD), find below line:

```
query = ... WHERE alias.address='%d' AND alias.address=domain.domain ...
```

* Append one more statement after `alias.address='%d'`, the final setting
  should be:

```
query = ... WHERE alias.address='%d' AND '%u' NOT LIKE '%%+%%' AND alias.address=domain.domain ...
```

* Save your change and restart Postfix service.

### Fixed: not backup SOGo database

Note: this step is not applicable if you don't use SOGo groupware.

Open backup script `/var/vmail/backup/backup_mysql.sh`, append SOGo SQL
database name in variable `DATABASES=`. For example:

```
DATABASES='... sogo'
```

Save your change and that's all.

### Fixed: drop retired column in Amavisd database: `policy.spam_modifies_subj`

Note: This is applicable to Amavisd-new-2.7.0 and later releases.

Amavisd drops column `policy.spam_modifies_subj` since amavisd-new-2.7.0
release, we'd better remove this column.

Login to MySQL server as root user, then execute below SQL commands to drop it:

```
mysql> USE amavisd;
mysql> ALTER TABLE policy DROP COLUMN spam_modifies_subj;
```

### [__OPTIONAL__] Bypass greylisting for some big ISPs

ISPs' mail servers send out spams, but also normal business mails. Applying
greylisting on them is helpless.

* Download SQL template file:

```
# cd /tmp
# wget https://bitbucket.org/zhb/iredmail/raw/40b98d7dde0178d54498e170c8b5165c0316dc96/iRedMail/samples/cluebringer/greylisting-whitelist.sql
```

* Login to MySQL database and import this file:

```
$ mysql -uroot -p
mysql> USE cluebringer;
mysql> SOURCE /tmp/greylisting-whitelist.sql;
```

That's all.

## PostgreSQL backend special

### Add new SQL column in `vmail` database

We have a new SQL column `mailbox.allow_nets` in `vmail` database, it's used
to restrict mail users to login from specified IP addresses or networks,
multiple IP/nets must be separated by comma.

Now connect to PostgreSQL server as admin user, create new column:

```
# su - postgres
$ psql -d vmail
sql> ALTER TABLE mailbox ADD COLUMN allow_nets TEXT DEFAULT NULL;
```

### Restrict mail user to login from specified IP addresses or networks, and apply service restriction while acting as SASL server

* With new SQL column `mailbox.allow_nets`, it's able to restrict mail users to
  login from specified IP/networks. We have sample usage below.

* With new service restriction, it's able to enable or disable smtp service for
  mail users.

Open Dovecot config file `/etc/dovecot/dovecot-pgsql.conf` (Linux/OpenBSD) or
`/usr/local/etc/dovecot/dovecot-pgsql.conf` (FreeBSD), then:

* append `allow_nets` in parameter `password_query`
* append `AND enable%Ls%Lc=1` in `WHERE` statement

The final setting should be:

```
password_query = SELECT password, allow_nets FROM mailbox WHERE username='%u' AND enable%Ls%Lc=1 AND active='1'
```

Restarting Dovecot service is required.

> Sample usage: allow user `user@domain.com` to login from IP `172.16.244.1`
> and network `192.168.1.0/24`:
>
```
sql> \c vmail;
sql> UPDATE mailbox SET allow_nets='172.16.244.1,192.168.1.0/24' WHERE username='user@domain.com`;
```
>
> To remove this restriction, just set `mailbox.allow_nets` to `NULL`, not empty string.

### Fixed: user+extension@domain.com doesn't work with per-domain catch-all

With iRedMail-0.9.0 and earlier versions, if you have per-domain catch-all
enabled, email sent to `user+extension@domain.com` will be delivered to
catch-all address instead of `user@domain.com`. Below steps fix this issue.

* Open file `/etc/postfix/pgsql/catchall_maps.cf` (Linux/OpenBSD) or
  `/usr/local/etc/postfix/pgsql/catchall_maps.cf` (FreeBSD), find below line:

```
query = ... WHERE alias.address='%d' AND alias.address=domain.domain ...
```

* Append one more statement after `alias.address='%d'`, the final setting
  should be:

```
query = ... WHERE alias.address='%d' AND '%u' NOT LIKE '%%+%%' AND alias.address=domain.domain ...
```

* Save your change and restart Postfix service.

### Fixed: not backup SOGo database

Note: this step is not applicable if you don't use SOGo groupware.

Open backup script `/var/vmail/backup/backup_mysql.sh`, append SOGo SQL
database name in variable `DATABASES=`. For example:

```
DATABASES='... sogo'
```

Save your change and that's all.

### Fixed: drop retired column in Amavisd database: `policy.spam_modifies_subj`

Note: This is applicable to Amavisd-new-2.7.0 and later releases.

Amavisd drops column `policy.spam_modifies_subj` since amavisd-new-2.7.0
release, we'd better remove this column.

Login to PostgreSQL server as admin user, then execute below SQL commands to drop it:

```
sql> \c amavisd;
sql> ALTER TABLE policy DROP COLUMN spam_modifies_subj;
```

### [__OPTIONAL__] Bypass greylisting for some big ISPs

ISPs' mail servers send out spams, but also normal business mails. Applying
greylisting on them is helpless.

* Download SQL template file:

```
# cd /tmp
# wget https://bitbucket.org/zhb/iredmail/raw/40b98d7dde0178d54498e170c8b5165c0316dc96/iRedMail/samples/cluebringer/greylisting-whitelist.sql
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
