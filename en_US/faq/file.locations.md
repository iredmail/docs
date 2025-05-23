# Locations of configuration and log files of major components

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

## SSL certificate {: #ssl }

The self-signed SSL certificate generated during iRedMail installation:

* on RHEL/CentOS:

    * `/etc/pki/tls/certs/iRedMail.crt`
    * Private key: `/etc/pki/tls/private/iRedMail.key`

* on Debian/Ubuntu:

    * `/etc/ssl/certs/iRedMail.crt`
    * Private key: `/etc/ssl/private/iRedMail.key`

* on FreeBSD:

    * `/etc/ssl/certs/iRedMail.crt`
    * Private key: `/etc/ssl/private/iRedMail.key`

* on OpenBSD:

    * `/etc/ssl/iRedMail.crt`
    * Private key: `/etc/ssl/iRedMail.key`

## Postfix {: #postfix }

* on `Linux` and OpenBSD, Postfix config files are placed under `/etc/postfix/`.
* on FreeBSD, Postfix config files are placed under `/usr/local/etc/postfix/`.

### Main config files: {: #postfix-config }

* `main.cf`: contains most configurations.
* `master.cf`: contains transport related settings.
* `aliases`: aliases for system accounts.
* `helo_access.pcre`: PCRE regular expressions of HELO check rules.
* `ldap/*.cf`: used to query mail accounts. LDAP backends only.
* `mysql/*.cf`: used to query mail accounts. MySQL/MariaDB backends only.
* `pgsql/*.cf`: used to query mail accounts. PostgreSQL backend only.

### Log files {: #postfix-log }

* on RHEL/CentOS, FreeBSD, OpenBSD, it's `/var/log/maillog`.
* on Debian, Ubuntu, it's `/var/log/mail.log`.

## Dovecot {: #dovecot }

* on Linux and OpenBSD, Dovecot config files are placed under `/etc/dovecot/`.
* on FreeBSD, Dovecot config files are placed under `/usr/local/etc/dovecot/`.

### Config files {: #dovecot-config }

Main config file is `dovecot.conf`. It contains most configurations.

Additional config files under `/etc/dovecot/`:

* `dovecot-ldap.conf`: used to query mail users and passwords. LDAP backends only.
* `dovecot-mysql.conf`: used to query mail users and passwords. MySQL/MariaDB backends only.
* `dovecot-pgsql.conf`: used to query mail users and passwords. PostgreSQL backend only.
* `dovecot-used-quota.conf`: used to store and query real-time per-user mailbox quota.
* `dovecot-share-folder.conf`: used to store settings of shared IMAP mailboxes.
* `dovecot-master-users-password` or `dovecot-master-users`: used to store Dovecot master user accounts.

### Log files {: #dovecot-log }

* `/var/log/dovecot/*.log`: main log file after iRedMail-0.9.8.

Earlier releases log to `/var/log/dovecot.log` and `/var/log/dovecot-*.log`.

## Nginx {: #nginx }

* On `Linux` and OpenBSD:
    * Nginx config files are placed under `/etc/nginx/`
    * uWSGI config files are placed under `/etc/uwsgi/`
* On FreeBSD:
    * Nginx config files are placed under `/usr/local/etc/nginx`
    * Web applications are stored under `/usr/local/www`
    * uWSGI config files are placed under `/usr/local/etc/uwsgi/`

Main config files are `nginx.conf` and `default.conf`.

* On `Linux` and FreeBSD: log files are placed under `/var/log/nginx/`.
* On OpenBSD: log files are placed under `/var/www/logs/` (same as Apache).

## PHP {: #php }

Main config file:

* on RHEL/CentOS: it's `/etc/php.ini`
* on Debian/Ubuntu:
    * If you're running Apache as web server:
        * If you're running PHP-5: it's `/etc/php5/apache2/php.ini` (Debian 8, Ubuntu 14.04)
        * If you're running PHP-7: it's `/etc/php/7.0/cli/php.ini` (Ubuntu 16.04)
    * If you're running Nginx as web server: it's `/etc/php5/fpm/php.ini`.
        * If you're running PHP-5: it's `/etc/php5/fpm/php.ini` (Debian 8, Ubuntu 14.04)
        * If you're running PHP-7: it's `/etc/php/7.0/fpm/php.ini` (Ubuntu 16.04)
* on FreeBSD: it's `/usr/local/etc/php.ini`.
* on OpenBSD: it's `/etc/php-5.X.ini`

## OpenLDAP {: #openldap }

Main config file:

* on RHEL/CentOS: it's `/etc/openldap/slapd.conf`.
* on Debian/Ubuntu: it's `/etc/ldap/slapd.conf`.
* on FreeBSD: it's `/usr/local/etc/openldap/slapd.conf`.
* on OpenBSD: it's `/etc/openldap/slapd.conf`.

Schema files are stored under `schema/` directory (same directory as `slapd.conf`).

OpenLDAP is configured to log to `/var/log/openldap.log` by default, if it's
empty, please check normal syslog log file `/var/log/messages` or
`/var/log/syslog` instead.

## MySQL, MariaDB {: #mysql }

Main config file:

* on RHEL/CentOS: `/etc/my.cnf`.
* on Debian/Ubuntu, it's `/etc/mysql/my.cnf`. If you're running MariaDB, it's
  `/etc/mysql/mariadb.conf.d/mysqld.cnf`.
* on FreeBSD: `/var/db/mysql/my.cnf`.
* on OpenBSD: `/etc/my.cnf`.

## Roundcube webmail {: #roundcube }

* Root Directory. Roundcube webmail is installed under below directory by default:

    * RHEL/CentOS: `/opt/www/roundcubemail`. It's a symbol link to `roundcubemail-x.y.z` under same directory.

        Note: with old iRedMail releases, it's `/var/www/roundcubemail`.

    * Debian/Ubuntu: `/opt/www/roundcubemail`. It's a symbol link to
      `/opt/www/roundcubemail-x.y.z`.

        Note: with old iRedMail releases, it's `/usr/share/apache2/roundcubemail`,
        it's a symbol link to `/usr/share/apache2/roundcubemail-x.y.z/`.

    * FreeBSD: `/usr/local/www/roundcube`.
    * OpenBSD: `/opt/www/roundcubemail`. It's a symbol link to `roundcubemail-x.y.z`
      under same directory.

        Note: with old iRedMail releases, it's `/var/www/roundcubemail`.

* Config files:

    * Main config file is `config/config.inc.php` under Roundcube webmail
      directory.

        If you're running old Roundcube webmail (0.9.x and earlier
        releases), it has two separate config files: `config/db.inc.php` and
        `config/main.inc.php`.

    * Config files of plugins are placed under plugin directory. for example,
      config file of `password` plugin is `plugins/password/config.inc.php`.

* Log file. Roundcube is configured to log to [Postfix log](#postfix) file by default.
  {: #roundcube-log }

!!! warning

    Roundcube stores all default settings in `config/defaults.inc.php`, please do
    not modify it, instead, you should copy the settings you want to modify from
    `config/defaults.inc.php` to `config/config.inc.php`, then modify the one in
    `config/config.inc.php`.

* Nginx config snippet:
    * `/etc/nginx/templates/roundcube.tmpl`
    * `/etc/nginx/templates/roundcube-subdomain.tmpl`

## Amavisd {: #amavisd }

### Main config files {: #amavisd-config }

* on RHEL/CentOS: it's `/etc/amavisd/amavisd.conf`.
* on Debian/Ubuntu: it's `/etc/amavis/conf.d/50-user`.

    Debian/Ubuntu have some additional config files under `/etc/amavis/conf.d/`,
    but you can always override them in `/etc/amavis/conf.d/50-user`.
    When we mention `amavisd.conf` in other documents, it always means `50-user`
    on Debian/Ubuntu.

* on FreeBSD: it's `/usr/local/etc/amavisd.conf`.
* on OpenBSD: it's `/etc/amavisd.conf`.

### Log files {: #amavisd-log }

Amavisd is configured to log to [Postfix log file](#postfix) by iRedMail.

## SpamAssassin {: #spamassassin }

!!! attention

    With default iRedMail settings, SpamAssassin is called by Amavisd, not run as a daemon.

Main config file:
{: #spamassassin-config }

* On Linux/OpenBSD, it's `/etc/mail/spamassassin/local.cf`.
* On FreeBSD, it's `/usr/local/etc/mail/spamassassin/local.cf`.

SpamAssassin doesn't have a separated log file, to debug SpamAssassin, please
set `$sa_debug = 1;` in Amavisd config file, then restart Amavisd service.
{: #spamassassin-log }

## Fail2ban {: #fail2ban }

Main config file:
{: #fail2ban-config }

* On Linux/OpenBSD, it's `/etc/fail2ban/jail.local`.
* On FreeBSD, it's `/usr/local/etc/fail2ban/jail.local`.

!!! warning

    All custom settings should be placed in `jail.local`, and don't touch
    `jail.conf`, so that upgrading Fail2ban binary package won't lose/override
    your custom settings.

Filters:

* On Linux/OpenBSD, all filters are defined in files under `/etc/fail2ban/filter.d/`.
* On FreeBSD, all filters are defined in files under `/usr/local/etc/fail2ban/filter.d/`.

Ban/Unban actions:

* On Linux/OpenBSD, all actions are defined in files under `/etc/fail2ban/action.d/`.
* On FreeBSD, all filters are defined in files under `/usr/local/etc/fail2ban/action.d/`.

Log file: Fail2ban logs to default syslog log file.
{: #fail2ban-log }

* on RHEL/CentOS/OpenBSD/FreeBSD, it's `/var/log/messages`.
* on Debian/Ubuntu, it's `/var/log/syslog`.

## SOGo Groupware {: #sogo }

* Main config file is
    * on Linux/OpenBSD: `/etc/sogo/sogo.conf`
    * on FreeBSD: `/usr/local/etc/sogo/sogo.conf`
* Log file is `/var/log/sogo/sogo.log`.

## mlmmjadmin {: #mlmmjadmin }

* Config file: `/opt/mlmmjadmin/settings.py` (same on all Linux/BSD distributions)
* Log file: `/var/log/mlmmjadmin/mlmmjadmin.log`
* Data directories:
    * All active mailing lists: `/var/vmail/mlmmj`. Including archive.
    * Removed and archived mailing lists: `/var/vmail/mlmmj-archive`

## iRedAPD {: #iredapd }

* Main config file is `/opt/iredapd/settings.py` on all Linux/BSD distributions.
* Log file:

    * With iRedAPD-1.7.0 and later releases, log file is `/var/log/iredapd/iredapd.log`.
    * With iRedAPD-1.6.0 and older releases, log file is `/var/log/iredapd.log`.

## iRedAdmin {: #iredadmin }

Main config file: `/opt/www/iredadmin/settings.py`.

iRedAdmin is a web application, when debug mode is turned on, it will log error
message to:

* Debian/Ubuntu: `/var/log/uwsgi/app/iredadmin.log`.
* RHEL/CentOS: `/var/log/messages`.
* OpenBSD: `/var/www/logs/uwsgi.log`.
* FreeBSD: `/var/log/uwsgi-iredadmin.log`.

Note: If you modified any iRedAdmin source files (not just config file),
don't forget to restart `iredadmin` service to load modified files.

## <strike>Apache</strike> {: #apache }

!!! warning

    Apache was dropped since iRedMail-0.9.8.

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
      document root is `/usr/local/www/apacheXX/data/`.
    * Log files are placed under `/var/log/`, main log files are
      `/var/log/httpd-access.log` and `/var/log/httpd-error.log`.

* On OpenBSD: Apache (the one shipped in OpenBSD base system) config files
  are placed under `/var/www/conf`.

    * Main config file is `/var/www/conf/httpd.conf`.
    * Module config files are placed under `/var/www/conf/modules/`.
    * Root directory used to store web applications is `/var/www/`,
      document root is `/var/www/htdocs/`.
    * Log files are placed under `/var/www/logs/`.

## <strike>Cluebringer</strike>

!!! warning

    Policyd/Cluebringer were removed since iRedMail-0.9.3.

Main config file:

* RHEL/CentOS: `/etc/policyd/cluebringer.conf`, `/etc/policyd/webui.conf` (web admin panel).
* Debian/Ubuntu: `/etc/cluebringer/cluebringer.conf`, `/etc/cluebringer/cluebringer-webui.conf` (web admin panel).
* FreeBSD: `/usr/local/etc/cluebringer.conf`, `/usr/local/etc/apache24/cluebringer.conf` (web admin panel).
* OpenBSD: Not applicable, cluebringer is not available on OpenBSD.

Init script:

* RHEL/CentOS: `/etc/init.d/cbpolicyd`
* Debian/Ubuntu: `/etc/init.d/postfix-cluebringer`
* FreeBSD: `/usr/local/etc/rc.d/policyd2`
* OpenBSD: N/A. we don't have Cluebringer installed on OpenBSD.
