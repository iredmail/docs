# Upgrade iRedMail from 0.9.0 to 0.9.1

[TOC]


WARNING: This is still a working in progress draft document, do __NOT__ apply it.


## ChangeLog

* 2015-02-04: [All backends] [__OPTIONAL__] Fixed: return receipt response rejected
              by iRedAPD plugin `reject_null_sender`.
* 2015-02-02: [All backends] Fixed: Not backup SOGo database. Note: this step
              is not applicable if you don't use SOGo groupware.
* 2015-01-13: [All backends] Fixed: Incorrect path of command 'sogo-tool` on OpenBSD.
* 2015-01-12: [SQL backends] Fixed: Not apply service restriction in Dovecot
              SQL query file while acting as SASL server.

## General (All backends should apply these steps)

### [OPTIONAL] Fixed: return receipt response rejected by iRedAPD plugin `reject_null_sender`

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

## OpenLDAP backend special

### Fixed: not backup SOGo database

Note: this step is not applicable if you don't use SOGo groupware.

Open backup script `/var/vmail/backup/backup_mysql.sh`, append SOGo SQL
database name in variable `DATABASES=`. For example:

```
DATABASES='... sogo'
```

Save your change and that's all.

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
