# Locations of configuration and log files of mojor components

[TOC]

## Postfix

* on `Linux` and `OpenBSD`, Postfix config files are placed under `/etc/postfix/`.
* on `FreeBSD`, Postfix config files are placed under `/usr/local/etc/postfix/`.

### Config files

Main config files:

* `main.cf`: contains most configurations.
* `master.cf`: contains transport related settings.
* `aliases`: aliases for system accounts.
* `helo_access.pcre`: PCRE regular expressions of HELO check rules.
* `ldap/*.cf`: used to query mail accounts. LDAP backends only.
* `mysql/*.cf`: used to query mail accounts. MySQL/MariaDB backends only.
* `pgsql/*.cf`: used to query mail accounts. PostgreSQL backend only.

### Log files

* on `RHEL/CentOS`, `FreeBSD`, `OpenBSD`, it's `/var/log/maillog`.
* on `Debian`, `Ubuntu`, it's `/var/log/mail.log`.

## Dovecot

* on `Linux` and `OpenBSD`, Dovecot config files are placed under `/etc/dovecot/`.
* on `FreeBSD`, Dovecot config files are placed under `/usr/local/etc/dovecot/`.

### Config files

Main config file is `dovecot.conf`. It contains most configurations.

Addition config files:

* `dovecot-ldap.conf`: used to query mail users and passwords. LDAP backends only.
* `dovecot-mysql.conf`: used to query mail users and passwords. MySQL/MariaDB backends only.
* `dovecot-pgsql.conf`: used to query mail users and passwords. PostgreSQL backend only.
* `dovecot-used-quota.conf`: used to store and query real-time per-user mailbox quota.
* `dovecot-share-folder.conf`: used to store settings of shared IMAP mailboxes.
* `dovecot-master-users-password`: used to store master users/passwords.

### Log files

* `/var/log/dovecot.log`: main log file.
* `/var/log/dovecot-sieve.log`: sieve related log. NOTE: on old iRedMail
  releases, it's `/var/log/sieve.log`.
* `/var/log/dovecot-lmtp.log`: LMTP related log.

## Amavisd

### Main config files

* on `RHEL/CentOS`: it's `/etc/amavisd/amavisd.conf`.
* on `Debian/Ubuntu`: it's `/etc/amavis/conf.d/50-user`.

    Debian/Ubuntu have some addition config files under `/etc/amavis/conf.d/`,
    but you can always override them in file `/etc/amavis/conf.d/50-user`.
    When we mention `amavisd.conf` in other tutorials, it means `50-user` on
    Debian/Ubuntu.

* on `FreeBSD`: it's `/usr/local/etc/amavisd.conf`.
* on `OpenBSD`: it's `/etc/amavisd.conf`.

### Log files

Amavisd is configured to log to [Postfix log file](#postfix) by iRedMail.
