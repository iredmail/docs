# Upgrade iRedMail from 0.9.6 to 0.9.7

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

* Nov 12, 2017: Add Fail2ban jail `nginx-http-auth`.
* Jul  3, 2017: Mention how to upgrade uwsgi (OpenBSD only), iRedAdmin and iRedAPD.
* Jul  2, 2017: Mention Roundcube 1.3.0 requires PHP 5.4.
* Jul  1, 2017: Initial publish.

## General (All backends should apply these steps)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
0.9.7
```

### Upgrade iRedAPD (Postfix policy server) to the latest stable release (2.1)

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

### Upgrade iRedAdmin (open source edition) to the latest stable release (0.8)

Please follow this tutorial to upgrade iRedAdmin open source edition to the
latest stable release:
[Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html)

### Upgrade Roundcube webmail to the latest stable release (1.3.0)

!!! warning "Roundcube 1.3"

    * Roundcube 1.3 requires at least __PHP 5.4__. If your server is still running
      PHP 5.3 and cannot upgrade to 5.4, please upgrade Roundcube to the latest
      1.2 branch (1.2.5) instead.
    * Roundcube 1.3 no longer supports IE < 10 and old versions of Firefox,
      Chrome and Safari.
    * Roundcube 1.3 uses jQuery 3.2 and will not work with current jQuery
      mobile plugin. If you use any third-party plugin, please check its
      website to make sure it's compatible with Roundcube 1.3 before upgrading.

    With the release of Roundcube 1.3.0, the previous stable release branches
    1.2.x and 1.1.x will switch in to LTS low maintenance mode which means
    they will only receive important security updates but no longer any regular
    improvement updates.

> There're several security fixes in Roundcube 1.2.4 and 1.2.5, all users are
> encouraged to upgrade it as soon as possible. For more details about this
> release, please check Roundcube release notes:
>
> * [1.2.4](https://github.com/roundcube/roundcubemail/releases/tag/1.2.4)
> * [1.2.5](https://github.com/roundcube/roundcubemail/releases/tag/1.2.5)

Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release immediately:

* [How to upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).

### Fixed: improper order of Postfix HELO restriction rules.

iRedMail-0.9.6 and earlier releases didn't configure Postfix to apply custom
HELO restriction rule before FQDN helo hostname check and DNS verification,
this way you cannot whitelist some bad HELO hostnames. Please follow steps
below to fix it.

* Open file `/etc/postfix/main.cf` (Linux/OpenBSD) or
`/usr/local/etc/postfix/main.cf` (FreeBSD), find parameter
`smtpd_helo_restrictions` like below:

```
smtpd_helo_restrictions =
    permit_mynetworks
    permit_sasl_authenticated
    reject_non_fqdn_helo_hostname
    reject_unknown_helo_hostname
    check_helo_access pcre:/etc/postfix/helo_access.pcre
```

* Move the `check_helo_access` line after `permit_sasl_authenticated`:

```
smtpd_helo_restrictions =
    permit_mynetworks
    permit_sasl_authenticated
    check_helo_access pcre:/etc/postfix/helo_access.pcre
    reject_non_fqdn_helo_hostname
    reject_unknown_helo_hostname
```

* Reloading or restarting Postfix service is required.

### Fixed: incorrect owner and permission for rotated Dovecot log files

!!! attention

    This is applicable to Linux, not FreeBSD and OpenBSD.

iRedMail-0.9.6 and earlier releases have an incorrect logrotate setting for
Dovecot log file, it causes all Dovecot log files are empty due to no required
permission to open log files. Please follow steps below to fix it.

Please open file `/etc/logrotate.d/dovecot`, find line below:

```
    create 0600 vmail vmail
```

Remove above line and save the change.

### Fixed: incorrect session.save_path in php-fpm pool config file on RHEL/CentOS

!!! attention

    This is applicable to RHEL/CentOS system, and Nginx web server.

iRedMail-0.9.6 doesn't set path for `session.save_path` parameter in php-fpm
pool config file `/etc/php-fpm.d/www.conf`, please fix it with steps below:

* Open file `/etc/php-fpm.d/www.conf`, find line:

```
php_value[session.save_path] = "/var/lib/php/session"
```

* The directory name should be `sessions` (ends with `s`), not `session`. So
  please change it to:

```
php_value[session.save_path] = "/var/lib/php/sessions"
```

* Restarting php-fpm service is required:

```
service php-fpm restart
```

### Fixed: incorrect freshclam setting `UpdateLogFile`

!!! attention

    This is applicable to RHEL/CentOS system.

With iRedMail-0.9.6, freshclam program cannot update ClamAV signatures due to
improper log file permission, please open its config file `/etc/freshclam.conf`
or `/etc/clamav/freshclam.conf`, comment out setting `UpdateLogFile` to use
syslog for logging.

```
#UpdateLogFile ...          # <- Comment out this parameter
LogSyslog true              # <- Make sure you have this line. If not present, please add it manually.
```

### Fail2ban: fixes an improper filter and add new filter rule

iRedMail-0.9.7 fixes an improper filter for Dovecot log file which may cause
incorrect ban, and adds a new filter for Roundcube log file to help ban bad
client while Roundcube is running behind a proxy server.

* On Linux:

```
cd /etc/fail2ban/filter.d/
rm -f dovecot.iredmail.conf	roundcube.iredmail.conf
wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/fail2ban/filter.d/dovecot.iredmail.conf
wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/fail2ban/filter.d/roundcube.iredmail.conf
```

Restarting Fail2ban service is required.

### Fail2ban: Add new jail for Nginx

!!! attention

    This is applicable if you run Nginx as web server.

Let's add a new jail to stop bad clients which tried to perform http basic auth 
but failed.

Create file `/etc/fail2ban/jail.d/nginx-http-auth.local` with content below:

!!! attention

    If directory `/etc/fail2ban/jail.d/` doesn't exist, you can append content
    below in file `/etc/fail2ban/jail.local` instead.

```
[nginx-http-auth]
enabled     = true
filter      = nginx-http-auth
action      = iptables-multiport[name=nginx, port="80,443", protocol=tcp]
logpath     = /var/log/nginx/error.log
```

Restarting Fail2ban service is required.

### NEW: New backup script for SOGo

!!! attention

    This is not applicable to SOGo-2.x because it doesn't support backing up
    all users' data with command `sogo-tool backup /path/to/backup/dir ALL`.

iRedMail has script `/var/vmail/backup/backup_mysql.sh` (or `backup_pgsql.sh`)
to backup SOGo database by dumping whole database to a plain SQL file as
backup. It's not ideal because:

* it's hard to restore single user's data with a plain SQL file.
* if SOGo changes some SQL structure, it's hard to restore all data.

This new script does backup with `sogo-tool backup` command to avoid issues
mentioned above, you can restore a single user's data or all users data with
`sogo-tool restore`.

Please follow steps below to setup this daily cron job.

* Download backup script. We store it under `/var/vmail/backup`, if you prefer
  a different directory, feel free to change the directory name used in commands
  below:

```
cd /var/vmail/backup/
wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/tools/backup_sogo.sh
chmod 0400 backup_sogo.sh
```

* This script will create new directory under `/var/vmail/backup` like below
  to store backup files:

```
/var/vmail/backup
            |- sogo/
                |- 2017/                # <- year
                    |- 03/              # <- month
                        |- 22.tar.bz2   # <- day (file name is: <day>.tar.bz2)
```

If you want to use another directory to store backup files, please open file
`backup_sogo.sh`, update variable `BACKUP_ROOTDIR` with the new directory.

* Run command `crontab -e -u root` to setup root user's cron job. Add content
  below as new job:

```
# SOGo: backup all users' data at 3:05AM everyday.
5   3   *   *   *   bash /var/vmail/backup/backup_sogo.sh
```

### OpenBSD: Upgrade uwsgi to the latest 2.0.15

uwsgi is the interface between Nginx and iRedAdmin, so if you're running
iRedAdmin, it's recommended to upgrade uwsgi to the latest version, 2.0.15.

Steps: Download the latest uwsgi, compile it, then restart uwsgi service.

```
cd /root/
ftp https://projects.unbit.it/downloads/uwsgi-2.0.15.tar.gz
tar zxf uwsgi-2.0.15.tar.gz
cd uwsgi-2.0.15
python setup.py install
```

uwsgi should be succesfully installed, then restart uwsgi service:

```
rcctl restart uwsgi
```

## OpenLDAP backend special

### Fixed: Avoid possible backdooring mysqldump backups

For more details about this backdooring mysqldump backup issue, please read
blog post:

* [[CVE-2016-5483] Backdooring mysqldump backups](https://blog.tarq.io/cve-2016-5483-backdooring-mysqldump-backups/).

Steps to fix it:

* Open the daily MySQL backup script, it's `/var/vmail/backup/backup_mysql.sh`
  by default. if you use different storage directory during iRedMail
  installation, you can find the base directory with command `postconf virtual_mailbox_base`.

* Find variable name `CMD_MYSQLDUMP` like below:

```
export CMD_MYSQLDUMP="mysqldump ..."
```

* Make sure it has argument `--skip-comments` like below:

```
export CMD_MYSQLDUMP="mysqldump ... --skip-comments"
```

* Save your change. That's it.

## MySQL/MariaDB backend special

### SQL structure change in `vmail.alias` SQL table

We've made some changes to `vmail.alias` SQL table for easier account
management, you can find details about this change here:
[SQL structure changes in `vmail.alias` table](https://bitbucket.org/zhb/iredmail/issues/101/sql-structure-changes-in-vmailalias-table).

This change introduces 2 new SQL tables (`forwardings`, `alias_moderators`),
and (optionally) dropped few columns in `vmail.alias` table.

iRedAPD and iRedAdmin (and iRedAdmin-Pro) have been upgraded to use this new
SQL structure.

!!! warning

    Please backup SQL database `vmail` before you run any SQL commands below.

#### Create required new SQL tables

Please connect to MySQL server as MySQL root user, and execute SQL commands
below to create required new tables:

```
USE vmail;

CREATE TABLE IF NOT EXISTS alias_moderators (
    id BIGINT(20) UNSIGNED AUTO_INCREMENT,
    address VARCHAR(255) NOT NULL DEFAULT '',
    moderator VARCHAR(255) NOT NULL DEFAULT '',
    domain VARCHAR(255) NOT NULL DEFAULT '',
    dest_domain VARCHAR(255) NOT NULL DEFAULT '',
    PRIMARY KEY (id),
    UNIQUE INDEX (address, moderator),
    INDEX (domain),
    INDEX (dest_domain)
) ENGINE=InnoDB;

-- Forwardings. it contains
--  - members of mail alias account
--  - per-account alias addresses
--  - per-user mail forwarding addresses
CREATE TABLE IF NOT EXISTS forwardings (
    id BIGINT(20) UNSIGNED AUTO_INCREMENT,
    address VARCHAR(255) NOT NULL DEFAULT '',
    forwarding VARCHAR(255) NOT NULL DEFAULT '',
    domain VARCHAR(255) NOT NULL DEFAULT '',
    dest_domain VARCHAR(255) NOT NULL DEFAULT '',
    -- defines whether it's a standalone mail alias account. 0=no, 1=yes.
    is_list TINYINT(1) NOT NULL DEFAULT 0,
    -- defines whether it's a mail forwarding address of mail user. 0=no, 1=yes.
    is_forwarding TINYINT(1) NOT NULL DEFAULT 0,
    -- defines whether it's a per-account alias address. 0=no, 1=yes.
    is_alias TINYINT(1) NOT NULL DEFAULT 0,
    active TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (id),
    UNIQUE INDEX (address, forwarding),
    INDEX (domain),
    INDEX (dest_domain),
    INDEX (is_list),
    INDEX (is_alias)
) ENGINE=InnoDB;
```

#### Migrate mail accounts

Please download script used to migrate mail accounts, and run it directly:

```
cd /root/
wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/tools/migrate_sql_alias_table.py
python migrate_sql_alias_table.py
```

Note: It will try to read iRedAdmin config file from one of paths below, and
connects to SQL server as user `vmailadmin`:

* /opt/www/iredadmin/settings.py (Debian/Ubuntu)
* /var/www/iredadmin/settings.py (CentOS/OpenBSD)
* /usr/share/apache2/iredadmin/settings.py (Debian/Ubuntu with old iRedMail releases)
* /usr/local/www/iredadmin/settings.py (FreeBSD)

#### Update Postfix config files

Please run shell commands below to tell Postfix to use new SQL tables.

Notes: on FreeBSD, the path is `/usr/local/etc/postfix/mysql`.

```
cd /etc/postfix/mysql/
perl -pi -e 's#alias\.address#forwardings.address#g' *.cf
perl -pi -e 's#alias\.goto#forwardings.forwarding#g' *.cf
perl -pi -e 's#alias\.active#forwardings.active#g' *.cf
perl -pi -e 's#alias\.domain#forwardings.domain#g' *.cf
perl -pi -e 's#alias,#forwardings,#g' *.cf
```

Restarting Postfix service is required.

#### Drop unused SQL columns and records in `vmail.alias` table

!!! warning

    * Make sure you have a backup of SQL database `vmail`.
    * Please also upgrade iRedAPD and iRedAdmin-Pro, they need the new SQL
      structure too.

After migration, `vmail.alias` table contains few sql columns we will never
use, also old records (accounts) will cause ghost accounts if we don't remove
them.

Please connect to MySQL server as MySQL root user, then execute SQL commands
below:

```
USE vmail;

-- Remove non-mail-alias account
DELETE FROM alias WHERE islist <> 1;

-- Remove per-domain catch-all account
DELETE FROM alias WHERE address=domain;

-- Drop unused columns
ALTER TABLE alias DROP COLUMN goto;
ALTER TABLE alias DROP COLUMN moderators;
ALTER TABLE alias DROP COLUMN islist;
ALTER TABLE alias DROP COLUMN is_alias;
ALTER TABLE alias DROP COLUMN alias_to;
```
### Fixed: Avoid possible backdooring mysqldump backups

For more details about this backdooring mysqldump backup issue, please read
blog post:

* [[CVE-2016-5483] Backdooring mysqldump backups](https://blog.tarq.io/cve-2016-5483-backdooring-mysqldump-backups/).

Steps to fix it:

* Open the daily MySQL backup script, it's `/var/vmail/backup/backup_mysql.sh`
  by default. if you use different storage directory during iRedMail
  installation, you can find the base directory with command `postconf virtual_mailbox_base`.

* Find variable name `CMD_MYSQLDUMP` like below:

```
export CMD_MYSQLDUMP="mysqldump ..."
```

* Make sure it has argument `--skip-comments` like below:

```
export CMD_MYSQLDUMP="mysqldump ... --skip-comments"
```

* Save your change. That's it.

## PostgreSQL backend specific

### SQL structure change in `vmail.alias` SQL table

We've made some changes to `vmail.alias` SQL table for easier account
management, you can find details about this change here:
[SQL structure changes in `vmail.alias` table](https://bitbucket.org/zhb/iredmail/issues/101/sql-structure-changes-in-vmailalias-table).

This change introduces 2 new SQL tables (`forwardings`, `alias_moderators`),
and (optionally) dropped few columns in `vmail.alias` table.

iRedAPD and iRedAdmin (and iRedAdmin-Pro) have been upgraded to use this new
SQL structure.

!!! warning

    Please backup SQL database `vmail` before you run any SQL commands below.

#### Create required new SQL tables

Please run shell commands below to connect to PostgreSQL server as
`vmailadmin` user first:

```
su - postgres
psql -U vmailadmin -d vmail
```

Then execute SQL commands below to create required new tables:

```
CREATE TABLE alias_moderators (
    id SERIAL PRIMARY KEY,
    address VARCHAR(255) NOT NULL DEFAULT '',
    moderator VARCHAR(255) NOT NULL DEFAULT '',
    domain VARCHAR(255) NOT NULL DEFAULT '',
    dest_domain VARCHAR(255) NOT NULL DEFAULT ''
);

CREATE INDEX idx_alias_moderators_address ON alias_moderators (address);
CREATE INDEX idx_alias_moderators_moderator ON alias_moderators (moderator);
CREATE UNIQUE INDEX idx_alias_moderators_address_moderator ON alias_moderators (address, moderator);
CREATE INDEX idx_alias_moderators_domain ON alias_moderators (domain);
CREATE INDEX idx_alias_moderators_dest_domain ON alias_moderators (dest_domain);

CREATE TABLE forwardings (
    id SERIAL PRIMARY KEY,
    address VARCHAR(255) NOT NULL DEFAULT '',
    forwarding VARCHAR(255) NOT NULL DEFAULT '',
    domain VARCHAR(255) NOT NULL DEFAULT '',
    dest_domain VARCHAR(255) NOT NULL DEFAULT '',
    -- defines whether it's a standalone mail alias account. 0=no, 1=yes.
    is_list INT2 NOT NULL DEFAULT 0,
    -- defines whether it's a mail forwarding address of mail user. 0=no, 1=yes.
    is_forwarding INT2 NOT NULL DEFAULT 0,
    -- defines whether it's a per-account alias address. 0=no, 1=yes.
    is_alias INT2 NOT NULL DEFAULT 0,
    active INT2 NOT NULL DEFAULT 1
);
CREATE INDEX idx_forwardings_address ON forwardings (address);
CREATE INDEX idx_forwardings_forwarding ON forwardings (forwarding);
CREATE UNIQUE INDEX idx_forwardings_address_forwarding ON forwardings (address, forwarding);
CREATE INDEX idx_forwardings_domain ON forwardings (domain);
CREATE INDEX idx_forwardings_dest_domain ON forwardings (dest_domain);
CREATE INDEX idx_forwardings_is_list ON forwardings (is_list);
CREATE INDEX idx_forwardings_is_forwarding ON forwardings (is_forwarding);
CREATE INDEX idx_forwardings_is_alias ON forwardings (is_alias);

-- Grant required privilege to vmail user
GRANT SELECT ON TABLE forwardings to vmail;
GRANT SELECT ON TABLE alias_moderators to vmail;
```

#### Migrate mail accounts

Please download script used to migrate mail accounts, and run it directly:

```
cd /root/
wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/tools/migrate_sql_alias_table.py
python migrate_sql_alias_table.py
```

Note: It will try to read iRedAdmin config file from one of paths below, and
connects to SQL server as user `vmailadmin`:

* /opt/www/iredadmin/settings.py (Debian/Ubuntu)
* /var/www/iredadmin/settings.py (CentOS/OpenBSD)
* /usr/share/apache2/iredadmin/settings.py (Debian/Ubuntu with old iRedMail releases)
* /usr/local/www/iredadmin/settings.py (FreeBSD)

#### Update Postfix config files

Please run shell commands below to tell Postfix to use new SQL tables.

Notes: on FreeBSD, the path is `/usr/local/etc/postfix/pgsql`.

```
cd /etc/postfix/pgsql/
perl -pi -e 's#alias\.address#forwardings.address#g' *.cf
perl -pi -e 's#alias\.goto#forwardings.forwarding#g' *.cf
perl -pi -e 's#alias\.active#forwardings.active#g' *.cf
perl -pi -e 's#alias\.domain#forwardings.domain#g' *.cf
perl -pi -e 's#alias,#forwardings,#g' *.cf
```

Restarting Postfix service is required.

#### Drop unused SQL columns in `vmail.alias` table

!!! warning

    * Make sure you have a backup of SQL database `vmail`.
    * Please also upgrade iRedAPD and iRedAdmin-Pro, they need the new SQL
      structure too.

After migration, few columns in `vmail.alias` table are not used anymore, it's
ok to drop them. But it's strongly recommended to keep them for few more days
until you can confirm all features are working as expected.

```
su - postgres
psql -d vmail

-- Remove non-mail-alias account
DELETE FROM alias WHERE islist <> 1;

-- per-domain catch-all account
DELETE FROM alias WHERE address=domain;

-- Drop unused columns
ALTER TABLE alias DROP COLUMN goto;
ALTER TABLE alias DROP COLUMN moderators;
ALTER TABLE alias DROP COLUMN islist;
ALTER TABLE alias DROP COLUMN is_alias;
ALTER TABLE alias DROP COLUMN alias_to;
```
