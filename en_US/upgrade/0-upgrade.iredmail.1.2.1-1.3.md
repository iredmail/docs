# Upgrade iRedMail from 1.2.1 to 1.3

[TOC]

!!! warning

    THIS IS STILL A DRAFT DOCUMENT, DO NOT APPLY IT.

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

* May XX, 2020: initial release.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.3
```

### Fixed: inconsistent Fail2ban jail names

!!! attention

    This is applicable to Linux and OpenBSD.

iRedMail-1.2 and 1.2.1 introduced [SQL integration in
Fail2ban](./fail2ban.sql.html), but there're few inconsistent jail names which
caused unbanning IP from iRedAdmin-Pro doesn't work. Please run commands below
to fix them.

```
cd /etc/fail2ban/jail.d/
perl -pi -e 's#dovecot-iredmail#dovecot#g' dovecot.local

perl -pi -e 's#postfix-pregreet-iredmail#postfix-pregreet#g' postfix-pregreet.local
perl -pi -e 's#name=postfix,#name=postfix-pregreet,#g' postfix-pregreet.local

perl -pi -e 's#postfix-iredmail#postfix#g' postfix.local
perl -pi -e 's#roundcube-iredmail#roundcube#g' roundcube.local
perl -pi -e 's#sogo-iredmail#sogo#g' sogo.local
```

## OpenLDAP backend special

### Add missing index for SQL column `msgs.time_iso` in `amavisd` database

Please run SQL commands below as MySQL root user:

```
USE amavisd;
CREATE INDEX msgs_idx_time_iso ON msgs (time_iso);
```

## MySQL/MariaDB backend special

### Add missing index for SQL column `msgs.time_iso` in `amavisd` database

Please run SQL commands below as MySQL root user:

```
USE amavisd;
CREATE INDEX msgs_idx_time_iso ON msgs (time_iso);
```
