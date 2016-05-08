# Upgrade iRedMail from 0.7.4 to 0.8.0

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](../support.html) and [contact us](../contact.html).

## ChangeLog

* 2012-07-12: [OPTIONAL] Enforce connections over HTTPS in Roundcube webmail
* 2012-07-12: [OPTIONAL] Enforce connections over POP3S/IMAPS in Dovecot
* 2012-05-10: Initial release.

## General (All backends should apply these upgrade steps)

### Update /etc/iredmail-release with iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
# File: /etc/iredmail-release

0.8.0
```

### Upgrade Roundcube webmail to the latest stable release

Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release immediately: [How to upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).

### Upgrade iRedAPD (Postfix policy server) to the latest stable release

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

### Upgrade iRedAdmin (open source edition) to the latest stable release

Please follow this tutorial to upgrade iRedAdmin open source edition to the
latest stable release: [Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html)

### Set strict file permission for Dovecot config files

There's one world-readable Dovecot config file, we should set strict file
owner and permission on it so that it won't leak SQL server infomation.

Please execute below command to fix it, then restart Dovecot service:

__NOTE__: The file name on different Linux/BSD distributions may be different,
it should be `dovecot-used-quota.conf` or `used-quota.conf`.

* On RHEL/CentOS/Scientific Linux 5.x:

```
# chown dovecot:dovecot /etc/dovecot-used-quota.conf
# chmod 0500 /etc/dovecot-used-quota.conf
```

* On RHEL/CentOS/Scientific Linux 6.x, Debian, Ubuntu, openSUSE:

```
# chown dovecot:dovecot /etc/dovecot/used-quota.conf
# chmod 0500 /etc/dovecot/used-quota.conf
```

* On FreeBSD:

```
# chown dovecot:dovecot /usr/local/etc/dovecot-used-quota.conf
# chmod 0500 /usr/local/etc/dovecot-used-quota.conf
```

### Enable greylist opt in and opt out in Policyd

Note: If you're running Ubuntu 11.10 or later releases, there's no Policyd
(v1.8) installed at all, it's replaced by Cluebringer, a.k.a. Policyd v2. So
it's safe to skip this step.

Some people are fairly irate when it comes to mail and 
refuse wanting to have any type of delay. this feature
enables each and every person the ability to not subject
themselves to greylisting. this feature is also VERY
usefull when you dont want to subject EVERY person to
greylisting at once but instead allows you to enable
it in batches/groups of users so you get a feel on the
type of complaints or praise from your users.

Please update Policyd setting `OPTINOUT` and `OPTINOUTALL=1` to 1 to enable
greylist opt-in/opt-out:

    * On RHEL/CentOS/Scientific Linux, it's set in file `/etc/policyd.conf`.
    * On Debian/Ubuntu, it's set in file `/etc/postfix-policyd.conf`.
    * On openSUSE, it's set in file `/etc/policyd.conf`.
    * On FreeBSD, it's set in file `/usr/local/etc/postfix-policyd-sf.conf`.

```
# Part of file: policyd.conf

OPTINOUT=1
OPTINOUTALL=1
```

Restarting Policyd service is required to make it work.

__Notes__:

* iRedAdmin-Pro customers can manage greylist opt-in with one lick with the
  latest iRedAdmin-Pro releases, in domain profile page or user profile page,
  under tab `Advanced`.
* For more details about how to set greylist opt-in manually with MySQL command
  line or phpMyAdmin, please refer to Policyd official document:
  http://policyd.sourceforge.net/readme.html (Section "Greylist Opt-in / Opt-out")

### Enable case insensitive user authentication in Roundcube webmail

Please change below setting to `true` in Roundcube webmail config file
'config/main.inc.php' to enable case insensitive user authentication. The
config file should be:

    * `/var/www/roundcubemail/config/main.inc.php` on RHEL/CentOS/Scientific Linux
    * `/usr/share/apache2/roundcubemail/config.inc.php` on Debian/Ubuntu
    * `/srv/www/roundcubemail/config/main.inc.php` on openSUSE
    * `/usr/local/www/roundcubemail/config/main.inc.php` on FreeBSD

```
# Part of file: config/main.inc.php

$rcmail_config['login_lc'] = false;
```

### Fix logrotate setting of Dovecot log files

Open `/etc/logrotate.d/dovecot` and `/etc/logrotate.d/sieve`, update postrotate commands:

* If you're running Dovecot-1.x, please update postrotate command with below value:

```
# Part of file: /etc/logrotate.d/dovecot and /etc/logrotate.d/sieve

postrotate
    /bin/kill -USR1 `cat /var/run/dovecot/master.pid 2>/dev/null` 2> /dev/null || true
endscript
```

* If you're running Dovecot-2.x, please update postrotate command with below value:

```
# Part of file: /etc/logrotate.d/dovecot, /etc/logrotate.d/sieve

postrotate
    doveadm log reopen
endscript
```

### [OPTIONAL] Enforce connections over HTTPS in Roundcube webmail

This step is optional but highly recommended for better security.

Please update below parameter in Roundcube config file
`roundcubemail/config/main.inc.php` to enforce connections over https for
better security. With this option enabled, all non-secure connections will be
redirected to httpS://.

    * On RHEL/CentOS/Scientific Linux, Gentoo, OpenBSD, it's `/var/www/roundcubemail/config/main.inc.php`.
    * On Debian/Ubuntu, it's `/usr/share/apache2/roundcubemail/config/main.inc.php`.
    * On openSUSE, it's `/srv/www/roundcubemail/config/main.inc.php`.
    * On FreeBSD, it's `/usr/local/www/roundcubemail/config/main.inc.php`.

```
# Part of file: roundcubemail/config/main.inc.php

$rcmail_config['force_https'] = true;
```

Restarting Apache web server is required.

### [OPTIONAL] Enforce connections over POP3S/IMAPS in Dovecot

This step is OPTIONAL but highly recommended for better security. Since it may
requires update on your mail users' MUA (e.g. Thunderbird, Outlook), please
notify your mail users before this change.

Since iRedMail-0.8.0, all clients are forced to use IMAPS and POPS (via
STARTTLS) for better security by default. To enable this feature, please update
below parameters in your Dovecot config file, `dovecot.conf`.

    * On RHEL/CentOS/Scientific Linux 5.x, it's `/etc/dovecot.conf`.
    * On RHEL/CentOS/Scientific Linux 6.x, it's `/etc/dovecot/dovecot.conf`.
    * On Debian/Ubuntu, it's `/etc/dovecot/dovecot.conf`.
    * On openSUSE, it's `/etc/dovecot/dovecot.conf`.
    * On FreeBSD, it's `/usr/local/etc/dovecot/dovecot.conf`.

```
# Part of file: dovecot.conf

ssl = required
disable_plaintext_auth = yes
```

Restarting Dovecot service is required.

## OpenLDAP backend special

### Add internal service required by Doveadm

__NOTE__: This step is applicable to both Dovecot-1.x and Dovecot-2.x.

To use `doveadm` command provided by Dovecot-2, please add one more value of
attribute 'enabledService' for mail user.

* Download python script used to adding missing values.

```
# cd /root/
# wget https://bitbucket.org/zhb/iredmail/raw/f0e7e84c4b8a/extra/update/updateLDAPValues_074_to_080.py
```

* Open `updateLDAPValues_074_to_080.py`, config LDAP server related settings in
  file head. e.g.

```
# Part of file: updateLDAPValues_074_to_080.py

uri = 'ldap://127.0.0.1:389'
basedn = 'o=domains,dc=example,dc=com'
bind_dn = 'cn=vmailadmin,dc=example,dc=com'
bind_pw = 'passwd'
```

You can find required LDAP credential in iRedAdmin config file or `iRedMail.tips`
file under your iRedMail installation directory. Using either
`cn=Manager,dc=xx,dc=xx` or `cn=vmailadmin,dc=xx,dc=xx` as bind dn is ok.

* Execute this script, it will add missing values for mail accounts:

```
# python updateLDAPValues_074_to_080.py
```

It will print progress message in the terminal, just be patient.

If you're running Dovecot-2, please add below lines in `dovecot-ldap.conf` to
make command `doveadm mailbox` work as expected:

```
# Part of file: dovecot-ldap.conf

iterate_attrs   = mail=user
iterate_filter  = (&(objectClass=mailUser)(accountStatus=active)(enabledService=mail))
```

## MySQL backend special

### Add internal service required by Doveadm

To use doveadm command provided by Dovecot-2, please add one more column in
MySQL table `vmail.mailbox` with below command:

```
# mysql -uroot -p
mysql> USE vmail;
mysql> ALTER TABLE mailbox ADD COLUMN enabledoveadm TINYINT(1) NOT NULL DEFAULT 1;
```
