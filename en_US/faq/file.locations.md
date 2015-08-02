# Locations of configuration and log files of mojor components

[TOC]

## Apache

* On RHEL/CentOS: Apache config files are placed under `/etc/httpd/`.

    * Main config file is `/etc/httpd/conf/httpd.conf`.
    * Module config files are placed under `/etc/httpd/conf.d/` (old releases)
      or `/etc/httpd/conf.modules.d/`.
    * Root directory used to store web applications is `/var/www`, document
      root is `/var/www/html/`.
    * Log files are placed under `/var/www/httpd/`.

* On Debian/Ubuntu: Apache config files are placed under `/etc/apache2`.

    * Main config file is `/etc/apache2/apache2.conf`.
    * Module config files are placed under `/etc/apache2/conf.d/` (old
      releases) or `/etc/apache2/conf-available/`.
    * Root directory used to store web applications is `/usr/share/apache2`,
      document root is `/var/www/` (old releases) or `/var/www/html/`.
    * Log files are placed under `/var/log/apache2/`.

* On FreeBSD: Apache config files are placed under `/usr/local/etc/apache2`.

    * Main config file is `/usr/local/etc/apache2/httpd.conf`.
    * Module config files are placed under `/usr/local/etc/apache2/Includes/`.
    * Root directory used to store web applications is `/usr/local/www/`,
      document root is `/usr/local/www/apache22/data/`.
    * Log files are placed under `/var/log/`, main log files are
      `/var/log/httpd-access.log` and `/var/log/httpd-error.log`.

* On OpenBSD: Apache (the one shipped in OpenBSD base system) config files
  are placed under `/var/www/conf`.

    * Main config file is `/var/www/conf/httpd.conf`.
    * Module config files are placed under `/var/www/conf/modules/`.
    * Root directory used to store web applications is `/var/www/`,
      document root is `/var/www/htdocs/`.
    * Log files are placed under `/var/www/logs/`.

## Nginx

* On `Linux` and OpenBSD: Nginx config files are placed under `/etc/nginx/`,
  uWSGI config files are placed under `/etc/uwsgi/`.
* On FreeBSD: Nginx config files are placed under `/usr/local/etc/nginx`,
  uWSGI config files are placed under `/usr/local/etc/uwsgi/`.

Main config files are `nginx.conf` and `default.conf`.

* On `Linux` and FreeBSD: log files are placed under `/var/log/nginx/`.
* On OpenBSD: log files are placed under `/var/www/logs/` (same as Apache).

## Postfix

* on `Linux` and OpenBSD, Postfix config files are placed under `/etc/postfix/`.
* on FreeBSD, Postfix config files are placed under `/usr/local/etc/postfix/`.

### Main config files:

* `main.cf`: contains most configurations.
* `master.cf`: contains transport related settings.
* `aliases`: aliases for system accounts.
* `helo_access.pcre`: PCRE regular expressions of HELO check rules.
* `ldap/*.cf`: used to query mail accounts. LDAP backends only.
* `mysql/*.cf`: used to query mail accounts. MySQL/MariaDB backends only.
* `pgsql/*.cf`: used to query mail accounts. PostgreSQL backend only.

### Log files

* on RHEL/CentOS, FreeBSD, OpenBSD, it's `/var/log/maillog`.
* on Debian, Ubuntu, it's `/var/log/mail.log`.

## Dovecot

* on `Linux` and OpenBSD, Dovecot config files are placed under `/etc/dovecot/`.
* on FreeBSD, Dovecot config files are placed under `/usr/local/etc/dovecot/`.

### Config files

Main config file is `dovecot.conf`. It contains most configurations.

Additional config files under `/etc/dovecot/`:

* `dovecot-ldap.conf`: used to query mail users and passwords. LDAP backends only.
* `dovecot-mysql.conf`: used to query mail users and passwords. MySQL/MariaDB backends only.
* `dovecot-pgsql.conf`: used to query mail users and passwords. PostgreSQL backend only.
* `dovecot-used-quota.conf`: used to store and query real-time per-user mailbox quota.
* `dovecot-share-folder.conf`: used to store settings of shared IMAP mailboxes.
* `dovecot-master-users-password` or `dovecot-master-users`: used to store Dovecot master user accounts.

### Log files

* `/var/log/dovecot.log`: main log file. IMAP/POP3 sessions, login, lotout,
  some error messages will be logged in this file.
* `/var/log/dovecot-sieve.log`: sieve LDA (Local Delivery Agent) related log.
  Mail delivery related log will be logged in this file. NOTE: on old iRedMail
  releases, it's `/var/log/sieve.log`.
* `/var/log/dovecot-lmtp.log`: LMTP related log. Mail delivery (via LMTP)
  related log will be logged in this file. Note: there's no such file on
  iRedMail-0.8.6 and old iRedMail releases.

## OpenLDAP

Main config file:

* on RHEL/CentOS: it's `/etc/openldap/slapd.conf`.
* on Debian/Ubuntu: it's `/etc/ldap/slapd.conf`.
* on FreeBSD: it's `/usr/local/etc/openldap/slapd.conf`.
* on OpenBSD: it's `/etc/openldap/slapd.conf`.

Schema files are stored under `schema/` directory (same directory as `slapd.conf`).

OpenLDAP is configured to log to `/var/log/openldap.log` by default, if it's
empty, please check normal syslog log file `/var/log/messages` or
`/var/log/syslog` instead.

## MySQL, MariaDB

Main config file:

* on RHEL/CentOS: `/etc/my.cnf.
* on Debian/Ubuntu, it's `/etc/mysql/my.cnf`. If you're running MariaDB, it's
  `/etc/mysql/mariadb.conf.d/mysqld.cnf`.
* on FreeBSD: `/var/db/mysql/my.cnf`.
* on OpenBSD: `/etc/my.cnf.

## Amavisd

### Main config files

* on RHEL/CentOS: it's `/etc/amavisd/amavisd.conf`.
* on Debian/Ubuntu: it's `/etc/amavis/conf.d/50-user`.

    Debian/Ubuntu have some additional config files under `/etc/amavis/conf.d/`,
    but you can always override them in `/etc/amavis/conf.d/50-user`.
    When we mention `amavisd.conf` in other documents, it always means `50-user`
    on Debian/Ubuntu.

* on FreeBSD: it's `/usr/local/etc/amavisd.conf`.
* on OpenBSD: it's `/etc/amavisd.conf`.

### Log files

Amavisd is configured to log to [Postfix log file](#postfix) by iRedMail.

## Cluebringer

Main config file:

* RHEL/CentOS: `/etc/policyd/cluebringer.conf`, `/etc/policyd/webui.conf` (web admin panel).
* Debian/Ubuntu: `/etc/cluebringer/cluebringer.conf`, `/etc/cluebringer/cluebringer-webui.conf` (web admin panel).
* FreeBSD: `/usr/local/etc/cluebringer.conf`, `/usr/local/etc/apache24/cluebringer.conf` (web admin panel).
* OpenBSD: Not applicable, cluebringer is not available on OpenBSD.

Init script:

* RHEL/CentOS: `/etc/init.d/cbpolicyd`
* Debian/Ubuntu: `/etc/init.d/postfix-cluebringer`
* FreeBSD: `/usr/local/etc/rc.d/cluebringer`
* OpenBSD: N/A. we don't have Cluebringer installed on OpenBSD.

## Fail2ban

* Main config file is `/etc/fail2ban/jail.local`. All custom settings should be
  placed in `/etc/fail2ban/jail.local`, and don't touch `jail.conf`, so that
  upgrading Fail2ban binary package won't override your custom settings.

* All filter rules are defined in files under `/etc/fail2ban/filter.d/`.
* Actions are defined in files under `/etc/fail2ban/action.d/`.

FreeBSD system is `/usr/local/etc/fail2ban/`.

## Roundcube webmail

Roundcube webmail is installed under below directory by default:

* RHEL/CentOS: `/var/www/roundcubemail`. It's a symbol link to
  `/var/www/roundcubemail-x.y.z`.
* Debian/Ubuntu: `/usr/share/apache2/roundcubemail`. It's a symbol link of
  `/usr/share/apache2/roundcubemail-x.y.z/`.
* FreeBSD: `/usr/local/www/roundcube`.
* OpenBSD: `/var/www/roundcubemail`. It's a symbol link to
  `/var/www/roundcubemail-x.y.z/`.

Config files:

* Main config file is `config/config.inc.php` under Roundcube webmail
  directory.

    If you're running old Roundcube webmail (0.9.x and earlier
    releases), it has two separate config files: `config/db.inc.php` and
    `config/main.inc.php`.

* Config files of plugins are placed under plugin directory. for example,
  config file of `password` plugin is `plugins/password/config.inc.php`.

## SOGo Groupware

* Main config file is `/etc/sogo/sogo.conf`.
* Log file is `/var/log/sogo/sogo.log`.

## iRedAPD

Main config file is `/opt/iredapd/settings.py` on all Linux/BSD distributions.

## iRedAdmin

Main config file:

* on RHEL/CentOS, it's `/var/www/iredadmin/settings.py`.
* on Debian/Ubuntu, it's `/opt/www/iredadmin/settings.py` (in recent iRedMail
  releases) or `/usr/share/apache2/iredadmin/settings.py` (in old iRedMail
  releases).
* on FreeBSD, it's `/usr/local/www/iredadmin/settings.py`.
* on OpenBSD, it's `/var/www/iredadmin/settings.py`.

iRedAdmin is a web application, when debug mode is turned on, it will log error
message to [Apache ssl error log file](#apache), or uwsgi log file (if you're running
Nginx). uwsgi log file is under `/var/log/uwsgi/` on Linux/FreeBSD, and
`/var/www/logs/` on OpenBSD.

Note: If you modified any iRedAdmin files (not just config file), please restart
Apache or uwsgi service (if you're running Nginx) to reload modified files.
