# Upgrade iRedMail from 0.9.0 to 0.9.1

[TOC]


WARNING: This is still a working in progress draft document, do __NOT__ apply it.


## ChangeLog

* 2015-01-12: [SQL backends] Fixed: Not apply service restriction in Dovecot SQL query file while acting as SASL server.

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
