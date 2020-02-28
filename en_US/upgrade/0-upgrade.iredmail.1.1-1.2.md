# Upgrade iRedMail from 1.1 to 1.2

[TOC]

!!! warning

    This is still a DRAFT document, do __NOT__ apply it.

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

* XXX XX, 2020: initial release.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.2
```

## For OpenLDAP backend

### Improved last login track

In iRedMail-1.0, Dovecot is configured to store user last login time in SQL
database `iredadmin`, but it only tracks either POP3 or IMAP login. In
iRedMail-1.2, it tracks both, also track when new email was delivered via
LMTP or LDA. Please follow steps below to implement this improvement.

* Open file `/etc/dovecot/dovecot.conf` (Linux/OpenBSD) or
  `/usr/local/etc/dovecot/dovecot.conf` (FreeBSD), find the `last_login_key`
  parameter and replace it by below one:

```
    last_login_key = last-login/%s/%u/%d
```

* Open file `/etc/dovecot/dovecot-last-login.conf` (Linux/OpenBSD) or
  `/usr/local/etc/dovecot/dovecot-last-login.conf` (FreeBSD), __remove__ existing
  `map {}` block and __add__ 4 new `map {}` blocks used to track
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

map {
    pattern = shared/last-login/lda/$user/$domain
    table = last_login
    value_field = lda
    value_type = uint

    fields {
        username = $user
        domain = $domain
    }
}

# Treat lmtp as lda
map {
    pattern = shared/last-login/lmtp/$user/$domain
    table = last_login
    value_field = lda
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

## For MySQL/MariaDB backends

### Improved last login track

In iRedMail-1.0, Dovecot is configured to store user last login time in SQL
database `iredadmin`, but it only tracks either POP3 or IMAP login. In
iRedMail-1.2, it tracks both, also track when new email was delivered via
LMTP or LDA. Please follow steps below to implement this improvement.

* Open file `/etc/dovecot/dovecot.conf` (Linux/OpenBSD) or
  `/usr/local/etc/dovecot/dovecot.conf` (FreeBSD), find the `last_login_key`
  parameter and replace it by below one:

```
    last_login_key = last-login/%s/%u/%d
```

* Open file `/etc/dovecot/dovecot-last-login.conf` (Linux/OpenBSD) or
  `/usr/local/etc/dovecot/dovecot-last-login.conf` (FreeBSD), __remove__ existing
  `map {}` block and __add__ 4 new `map {}` blocks used to track
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

map {
    pattern = shared/last-login/lda/$user/$domain
    table = last_login
    value_field = lda
    value_type = uint

    fields {
        username = $user
        domain = $domain
    }
}

# Treat lmtp as lda
map {
    pattern = shared/last-login/lmtp/$user/$domain
    table = last_login
    value_field = lda
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
