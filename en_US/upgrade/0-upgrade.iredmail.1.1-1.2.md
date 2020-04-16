# Upgrade iRedMail from 1.1 to 1.2

[TOC]

!!! warning

    This is still a DRAFT document, do __NOT__ apply it.

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

* Apr 17, 2020: initial release.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.2
```

### Upgrade iRedAPD (Postfix policy server) to the latest stable release

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

### Upgrade Roundcube webmail to the latest stable release (1.4.3)

!!! warning "Roundcube 1.4"

    Since Roundcube 1.3, at least __PHP 5.4__ is required. If your server is
    running PHP 5.3 and cannot upgrade to 5.4, please upgrade Roundcube
    the latest 1.2 branch instead.

* [How to upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).

### Upgrade netdata to the latest stable release (1.21.1)

If you have netdata installed, you can upgrade it by following this tutorial:
[Upgrade netdata](./upgrade.netdata.html).

### Fixed: mail delivery abort if program 'altermime' is not available

The script `mlmmj-amime-receive` has a bug which may abort mail delivery if
program `altermime` is not available on the system, this update fixes it.

Run commands below to update file `/usr/bin/mlmmj-amime-receive` (Linux) or
`/usr/local/bin/mlmmj-amime-receive` (FreeBSD/OpenBSD):

On Linux:

```
cd /usr/bin/
wget -O mlmmj-amime-receive https://github.com/iredmail/iRedMail/raw/1.2/samples/mlmmj/mlmmj-amime-receive
chown mlmmj:mlmmj mlmmj-amime-receive
chmod 0550 mlmmj-amime-receive
```

On FreeBSD or OpenBSD:

```
cd /usr/local/bin/
wget -O mlmmj-amime-receive https://github.com/iredmail/iRedMail/raw/1.2/samples/mlmmj/mlmmj-amime-receive
chown mlmmj:mlmmj mlmmj-amime-receive
chmod 0550 mlmmj-amime-receive
```

## For OpenLDAP backend

### Improved last login track

In iRedMail-1.0, Dovecot is configured to store user last login time in SQL
database `iredadmin`, but it only tracks either POP3 or IMAP login. In
iRedMail-1.2, it tracks both. Please follow steps below to implement this
improvement.

* Open file `/etc/dovecot/dovecot.conf` (Linux/OpenBSD) or
  `/usr/local/etc/dovecot/dovecot.conf` (FreeBSD), find the `last_login_key`
  parameter and replace it by below one:

```
    last_login_key = last-login/%s/%u/%d
```

* Open file `/etc/dovecot/dovecot-last-login.conf` (Linux/OpenBSD) or
  `/usr/local/etc/dovecot/dovecot-last-login.conf` (FreeBSD), __remove__ existing
  `map {}` block and __add__ 2 new `map {}` blocks used to track
  POP3/IMAP/LMTP/LDA services.

```
map {
    pattern = shared/last-login/imap/$user/$domain
    table = last_login
    value_field = imap
    value_type = uint

    fields {
        username = $user
        domain = $domain
    }
}

map {
    pattern = shared/last-login/pop3/$user/$domain
    table = last_login
    value_field = pop3
    value_type = uint

    fields {
        username = $user
        domain = $domain
    }
}
```

* Download prepared SQL file used to alter SQL tables:

```
wget -O /root/last_login.mysql https://github.com/iredmail/iRedMail/raw/1.2/update/1.2/last_login.mysql
mysql iredadmin < /root/last_login.mysql
rm -f /root/last_login.mysql
```

* Restarting Dovecot service is required.

### Fixed: can not store mail subject with emoji characters in `amavisd` database

In `amavisd` database, column `msgs.subject` is defined as `VARCHAR(255)`, it
doesn't support emoji characters. Please login to MySQL/MariaDB server as `root`
user or `amavisd` user, then run SQL commands below to fix it:

```
USE amavisd;
ALTER TABLE msgs MODIFY COLUMN subject VARBINARY(255) NOT NULL DEFAULT '';
```

## For MySQL/MariaDB backends

### Improved last login track

In iRedMail-1.0, Dovecot is configured to store user last login time in SQL
database `iredadmin`, but it only tracks either POP3 or IMAP login. In
iRedMail-1.2, it tracks both. Please follow steps below to implement this
improvement.

* Open file `/etc/dovecot/dovecot.conf` (Linux/OpenBSD) or
  `/usr/local/etc/dovecot/dovecot.conf` (FreeBSD), find the `last_login_key`
  parameter and replace it by below one:

```
    last_login_key = last-login/%s/%u/%d
```

* Open file `/etc/dovecot/dovecot-last-login.conf` (Linux/OpenBSD) or
  `/usr/local/etc/dovecot/dovecot-last-login.conf` (FreeBSD), __remove__ existing
  `map {}` block and __add__ 2 new `map {}` blocks used to track
  POP3/IMAP/LMTP/LDA services.

```
map {
    pattern = shared/last-login/imap/$user/$domain
    table = last_login
    value_field = imap
    value_type = uint

    fields {
        username = $user
        domain = $domain
    }
}

map {
    pattern = shared/last-login/pop3/$user/$domain
    table = last_login
    value_field = pop3
    value_type = uint

    fields {
        username = $user
        domain = $domain
    }
}
```

* Download prepared SQL file used to alter SQL tables:

```
wget -O /root/last_login.mysql https://github.com/iredmail/iRedMail/raw/1.2/update/1.2/last_login.mysql
mysql vmail < /root/last_login.mysql
rm -f /root/last_login.mysql
```

* Restarting Dovecot service is required.

### Fixed: can not store mail subject with emoji characters in `amavisd` database

In `amavisd` database, column `msgs.subject` is defined as `VARCHAR(255)`, it
doesn't support emoji characters. Please login to MySQL/MariaDB server as `root`
user or `amavisd` user, then run SQL commands below to fix it:

```
USE amavisd;
ALTER TABLE msgs MODIFY COLUMN subject VARBINARY(255) NOT NULL DEFAULT '';
```
