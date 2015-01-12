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
    * Log files are placed under `/var/www/apache2/`.

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

Additional config files:

* `dovecot-ldap.conf`: used to query mail users and passwords. LDAP backends only.
* `dovecot-mysql.conf`: used to query mail users and passwords. MySQL/MariaDB backends only.
* `dovecot-pgsql.conf`: used to query mail users and passwords. PostgreSQL backend only.
* `dovecot-used-quota.conf`: used to store and query real-time per-user mailbox quota.
* `dovecot-share-folder.conf`: used to store settings of shared IMAP mailboxes.
* `dovecot-master-users-password` or `dovecot-master-users`: used to store Dovecot master user accounts.

### Log files

* `/var/log/dovecot.log`: main log file.
* `/var/log/dovecot-sieve.log`: sieve related log. NOTE: on old iRedMail
  releases, it's `/var/log/sieve.log`.
* `/var/log/dovecot-lmtp.log`: LMTP related log.

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

## iRedAPD

Main config file is `/opt/iredapd/settings.py` on all Linux/BSD distributions.

## iRedAdmin

Main config file:

* on RHEL/CentOS, it's `/var/www/iredadmin/settings.py`.
* on Debian/Ubuntu, it's `/usr/share/apache2/iredadmin/settings.py`.
* on FreeBSD, it's `/usr/local/www/iredadmin/settings.py`.
* on OpenBSD, it's `/var/www/iredadmin/settings.py`.

iRedAdmin is a web application, when debug mode is turned on, it will log error
message to Apache/Nginx ssl error log file.

Note: If you modified any iRedAdmin files (not just config file), please restart
Apache or uwsgi service (if you're running Nginx) to reload modified files.
