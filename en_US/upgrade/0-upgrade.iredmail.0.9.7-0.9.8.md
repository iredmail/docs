# Upgrade iRedMail from 0.9.7 to 0.9.8

[TOC]

!!! warning "DO NOT APPLY THIS UPGRADE TUTORIAL"

    This document is still a __DRAFT__, do NOT apply it.

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](../support.html) and [contact us](../contact.html).

## ChangeLog


## General (All backends should apply these steps)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
0.9.7
```

### Upgrade iRedAPD (Postfix policy server) to the latest stable release (2.2)

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

## MySQL/MariaDB backends

### Fixed: User under disabled domain is able to send email with smtp protocol

Dovecot is IMAP/POP3/Managesieve server, also a SASL auth server for Postfix.
If mail domain is disabled, users under this domain are not able to use
IMAP/POP3/Managesieve services, but there's a bug in Dovecot SQL query, it
doesn't check domain status while performing smtp sasl auth.
Please follow steps below to fix it.

* Open file `/etc/dovecot/dovecot-mysql.conf` (Linux/OpenBSD) or
  `/usr/local/etc/dovecot/dovecot-mysql.conf` (FreeBSD), find the
  `password_query` line like below:

```
password_query = SELECT password, allow_nets FROM mailbox WHERE username='%u' AND enable%Ls%Lc=1 AND active=1
```

* Replace it by lines below:

```
password_query = SELECT mailbox.password, mailbox.allow_nets \
        FROM mailbox,domain \
       WHERE mailbox.username='%u' \
             AND mailbox.`enable%Ls%Lc`=1 \
             AND mailbox.active=1 \
             AND mailbox.domain=domain.domain \
             AND domain.backupmx=0 \
             AND domain.active=1
```

* Save your change and restart Dovecot service.

## PostgreSQL backend

### Fixed: User under disabled domain is able to send email with smtp protocol

Dovecot is IMAP/POP3/Managesieve server, also a SASL auth server for Postfix.
If mail domain is disabled, users under this domain are not able to use
IMAP/POP3/Managesieve services, but there's a bug in Dovecot SQL query, it
doesn't check domain status while performing smtp sasl auth.
Please follow steps below to fix it.

* Open file `/etc/dovecot/dovecot-pgsql.conf` (Linux/OpenBSD) or
  `/usr/local/etc/dovecot/dovecot-pgsql.conf` (FreeBSD), find the
  `password_query` line like below:

```
password_query = SELECT password, allow_nets FROM mailbox WHERE username='%u' AND enable%Ls%Lc=1 AND active=1
```

* Replace it by lines below:

```
password_query = SELECT mailbox.password, mailbox.allow_nets \
        FROM mailbox,domain \
       WHERE mailbox.username='%u' \
             AND mailbox."enable%Ls%Lc"=1 \
             AND mailbox.active=1 \
             AND mailbox.domain=domain.domain \
             AND domain.backupmx=0 \
             AND domain.active=1
```

* Save your change and restart Dovecot service.
