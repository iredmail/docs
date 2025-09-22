# Migrate from iRedMail to iRedMail Enterprise Edition

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! attention

    iRedMail Team can help migrate your iRedMail server, feel free to
    [Contact Us](https://www.iredmail.org/contact.html).

## Introduction

iRedMail Enterprise Edition ("EE" for short) offers deployment, one-click upgrade and
technical support for your iRedMail servers, it's very easy to keep your
server up to date with the ease to use web UI, and get issues solved by
iRedMail Team quickly.

For more details about EE, please
[check our website](https://www.iredmail.org/ee.html).

## Summary

Migrating from iRedMail to EE is like a fresh installation. EE detects
SQL/LDAP credentials from files under `/root/.iredmail/kv/`, then use them
directly, so all SQL/LDAP databases will be well kept.

It also generates config files for all involved software, so it's very
important to split the customizations you made in software config files to
files under `/opt/iredmail/custom/` manually. EE maintains the core config
files, and you override them.

## Requirements

- A working iRedMail server which was deployed with or upgraded to the latest
  iRedMail release.

    If you're not running the latest iRedMail release, please follow our
    tutorials to [upgrade iRedMail](./iredmail.releases.html).

- Your iRedMail server must be running one of supported Linux/OpenBSD
  distribution releases:

    !!! warning

        WARNING: Old Linux/BSD distribution releases are still supported but will be
        dropped shortly, it's __NOT__ recommended to deploy new iRedMail server
        with old Linux/BSD distribution releases.

    - Ubuntu 20.04 LTS, 22.04 LTS, 24.04 LTS
    - Debian 10, 11, 12 (recommended)
    - CentOS 7, 8 (NOT RECOMMENDED FOR NEW SERVER), 9 (recommended)
    - CentOS Stream 8, 9 (recommended)
    - Rocky Linux 8, 9 (recommended)
    - AlmaLinux 8, 9 (recommended)
    - OpenBSD 7.5, 7.6

Unfortunately, FreeBSD is not supported by EE.

## Backup first

Please backup all important data before preparing the migration, including
but not limtied to:

- All SQL/LDAP databases.

    EE will use existing SQL/LDAP databases, no data corruption is expected.

- All config files under `/etc` directory.

    After moved to EE, you should place all your
    custom settings in files under `/opt/iredmail/custom/<software>/`.

## MySQL backend: Remove MySQL (not MariaDB) packages

!!! attention

    * This is not necessary if you're running MariaDB backend.
    * If you're replacing MySQL by MariaDB on Ubuntu 18.04, please disable
      `apparmor` service before removing MySQL packages. Check
      [this tutorial](https://mariadb.com/kb/en/the-community-mariadb-troubles-only-running-after-reboot-times-out-when-try/) for known issue and solutions. Also related bug report in
      [Ubuntu LaunchPad](https://bugs.launchpad.net/ubuntu/+source/mariadb-10.1/+bug/1806263).

EE installs MariaDB instead of MySQL, if you're
running MySQL instead of MariaDB, you need to:

- Backup all databases
- Remove mysql packages
- Restore all backup SQL files except the one for database named `mysql` after
  EE installation

## Create required files used by EE

EE stores SQL/LDAP passwords under `/root/.iredmail/kv/`
on your server. Please create required files under `/root/.iredmail/kv/` with
correct passwords manually, each file should contain only one line, passwords
must be in plain text, not the hashed one.

!!! attention

    You can find all info in the `iRedMail.tips` file under iRedMail
    installation directory, for example, `/root/iRedMail-0.9.9/iRedMail.tips`.
    If you don't have this file anymore, you can still find them in other
    config files.

Backend | File Name | Comment | Value could be found in file
---|---|---|---
LDAP, MySQL | `sql_user_root` | MySQL root password. | `/root/.my.cnf`
PostgreSQL | `sql_user_postgres` (Linux)<br/>`sql_user__postgresql` (OpenBSD) | PostgreSQL root password. | `/var/lib/pgsql/.pgpass` (CentOS), or `/var/lib/postgresql/.pgpass` (Debian/Ubuntu), `/var/postgresql/.pgpass` (OpenBSD)
LDAP | `ldap_root_password` | Password of LDAP root dn (cn=Manager,dc=xx,dc=xx) |
LDAP | `ldap_vmail_password` | Password of LDAP dn `cn=vmail,dc=xx,dc=xx` | `/etc/postfix/ldap/*.cf`
LDAP | `ldap_vmailadmin_password` | Password of LDAP dn `cn=vmailadmin,dc=xx,dc=xx` | `/opt/www/iredadmin/settings.py`
MySQL, PostgreSQL | `sql_user_vmail` | Password of SQL user `vmail` | `/etc/postfix/mysql/*.cf` or `/etc/postfix/pgsql/*.cf`
MySQL, PostgreSQL | `sql_user_vmailadmin` | Password of SQL user `vmailadmin` | `/opt/www/iredadmin/settings.py`
ALL | `sql_user_amavisd` | Password of SQL user `amavisd` | `/etc/amavisd/amavisd.conf` (Linux/OpenBSD)<br>`/etc/amavis/conf.d/50-user` (Debian/Ubuntu)
ALL | `sql_user_sa_bayes` | Password of SQL user `sa_bayes`. If you didn't integrate SpamAssassin with SQL database, it's ok to not create this file. | `/etc/mail/spamassassin/local.cf`
ALL | `sql_user_iredapd` | Password of SQL user `iredapd` | `/opt/iredapd/settings.py`
ALL | `sql_user_roundcube` | Password of SQL user `roundcube` | `/root/.my.cnf-roundcube` or `/opt/www/roundcubemail/config/config.inc.php`
ALL | `sql_user_sogo` | Password of SQL user `sogo`. If you didn't install SOGo, it's ok to not create this file. | `/etc/sogo/sogo.conf`
ALL | `sql_user_netdata` | Password of SQL user `netdata`. If you didn't install netdata, it's ok to not create this file. | `/root/.my.cnf-netdata` or `/opt/netdata/etc/netdata/my.cnf`
ALL | `sql_user_fail2ban` | Password of SQL user `fail2ban`. If you didn't integrate Fail2ban with SQL server, it's ok to not create this file. | `/root/.my.cnf-fail2ban` (OpenLDAP or MariaDB backends), or `/var/lib/pgsql/.pgpass` (CentOS), or `/var/lib/postgresql/.pgpass` (Debian/Ubuntu), `/var/postgresql/.pgpass` (OpenBSD)
ALL | `iredapd_srs_secret` | The secret string used to sign SRS. It's ok if not present. | `/opt/iredapd/settings.py`, parameter `srs_secrets =`.
ALL | `sogo_sieve_master_password` | The Dovecot master user used by SOGo. It's ok if not present. | `/etc/sogo/sieve.cred`.
ALL | `roundcube_des_key` | The DES key used by Roundcube to encrypt the session. | `/opt/www/roundcubemail/config/config.inc.php`, parameter `$config['des_key'] =`.
ALL | `mlmmjadmin_api_token` | API token for authentication. | `/opt/mlmmjadmin/settings.py`, parameter `api_auth_tokens =`.
ALL | `first_domain_admin_password` | Password of the mail user `postmaster@<your-domain.com>`. | `your-domain.com` is the first mail domain name you (are going to) set in mail server profile page on EE, you can find it in mail server profile page, under tab `Settings`.

## Copy files to new locations

EE stores SSL cert/key files under `/opt/iredmail/ssl/`,
you need to either copy or (symbol) link existing ssl cert/key to this
directory with correct file names:

* `/opt/iredmail/ssl/key.pem`: private key
* `/opt/iredmail/ssl/cert.pem`: certificate
* `/opt/iredmail/ssl/combined.pem`: full chain

## Split custom settings

EE maintains the core config files, and each time you
perform full deployment or upgrade, these core config files will be
re-generated, all your custom config files will be lost. So it's very important
to not touch these core config files and just store your custom settings in
pre-defined files under `/opt/iredmail/custom/<software>/`.

### Postfix

Postfix doesn't support loading main settings (`/etc/postfix/main.cf` and
`/etc/postfix/master.cf`) from multiple files, so EE uses alternative
solution to split core and custom settings.

* Files under `/etc/postfix/`:
    * `aliases`
    * `body_checks.pcre`
    * `command_filter.pcre`
    * `header_checks.pcre`
    * `helo_access.pcre`
    * `postscreen_access.cidr`
    * `postscreen_dnsbl_reply.texthash`
    * `rdns_access.pcre`
    * `sender_access.pcre`
    * `smtp_tls_policy`
    * `transport`

    Please copy your custom settings from above files to the files with same
    names under `/opt/iredmail/custom/postfix/`. For example:

    - From `/etc/postfix/aliases` to `/opt/iredmail/custom/postfix/aliases`.
    - From `/etc/postfix/body_checks.pcre` to `/opt/iredmail/custom/postfix/body_checks.pcre`.
    - From `/etc/postfix/command_filter.pcre` to `/opt/iredmail/custom/postfix/command_filter.pcre`.

    You need to create directory `/opt/iredmail/custom/postfix/` and the files
    if they don't exist, EE will set correct
    owner/group and permission for them during deployment.

    If you're lazy and don't want to check files one by one, it's ok to simply
    copy these files from `/etc/postfix/` to `/opt/iredmail/custom/postfix/`
    directly, and (optionally) remove non-custom settings later.

* `/etc/postfix/main.cf` and `/etc/postfix/master.cf`

    - Write your new custom settings for `/etc/postfix/main.cf`
      in file `/opt/iredmail/custom/postfix/append_main.cf`. EE will append all
      content in this file to the end of `/etc/postfix/main.cf` each time you
      perform upgrade, re-perform full deployment, or re-deploy Postfix.
    - Write your new custom settings for `/etc/postfix/master.cf`
      in file `/opt/iredmail/custom/postfix/append_master.cf`. EE will append all
      content in this file to the end of `/etc/postfix/master.cf` each time you
      perform upgrade, re-perform full deployment, or re-deploy Postfix.
    - [__NOT RECOMMENDED__] If you need to modify settings generated by EE, you
      can maintain your own copy of `main.cf` and `master.cf` under
      `/opt/iredmail/custom/postfix/` directory, but this is __NOT RECOMMENDED__
      because EE may add or remove settings in main.cf and master.cf, other
      software will be updated at the same time to match Postfix settings, but
      if your own copy doesn't update together, other software may not work
      which causes mail flow broken.
        - If file `/opt/iredmail/custom/postfix/main.cf` exists, EE will
          create `/etc/postfix/main.cf` as symbol link to this file.
        - If file `/opt/iredmail/custom/postfix/master.cf` exists, EE
          will create `/etc/postfix/master.cf` as symbol link to this file.
    - There's also a (Bash) shell script for flexible customization:
      `/opt/iredmail/custom/postfix/custom.sh`. It will be ran each time you perform
      deployment or upgrade.

        For example, to set value of parameter `enable_original_recipient` to `yes`
        (defaults to `no` set in `/etc/postfix/main.cf`), you can write command in
        `/opt/iredmail/custom/postfix/custom.sh` like below:

        ```
        postconf -e enable_original_recipient=yes
        ```

### Amavisd

- Copy DKIM keys from `/var/lib/dkim/` to `/opt/iredmail/custom/amavisd/dkim/`.
- Move all `dkim_key(...)` parameters from Amavisd config file to
  `/opt/iredmail/custom/amavisd/amavisd.conf`, __EXCEPT__ the one for your first
  email domain name which was created during initial iRedMail installation.
    - RHEL/CentOS: `/etc/amavisd/amavisd.conf`
    - Debian/Ubuntu: `/etc/amavis/conf.d/50-user`
    - OpenBSD: `/etc/amavisd.conf`
    - FreeBSD: `/usr/local/etc/amavisd.conf`

    !!! attention

        Please make sure no duplicate `dkim_key(...)` parameters, otherwise
        Amavisd will fail to start.

### SpamAssassin

Split custom settings from `/etc/mail/spamassassin/local.cf` to
`/opt/iredmail/custom/spamassassin/custom.cf`.

If you have whitelisted IP addresses/networks listed in Postfix config file
`/etc/postfix/main.cf`, parameter `mynetworks =`, you may want to whitelist
them to avoid spam/virus scanning in `/opt/iredmail/custom/spamassassin/custom.cf`
too. For example:

```
trusted_networks 192.168.0.1 172.16.0.0/8
```

### Roundcube Webmail

* Copy custom settings from `/opt/www/roundcubemail/config/config.inc.php` to `/opt/iredmail/custom/roundcube/custom.inc.php`.
* Copy third-party plugins from `/opt/www/roundcubemail/plugins/` to `/opt/iredmail/custom/roundcube/plugins/`. EE will create symbol link for them automatically.
* Copy third-party or custom skins from `/opt/www/roundcubemail/skins/` to `/opt/iredmail/custom/roundcube/skins/`. EE will create symbol link for them automatically.

### iRedAPD

Copy custom settings from `/opt/iredapd/settings.py` to
`/opt/iredmail/custom/iredapd/settings.py` (this file will be linked back to
`/opt/iredapd/custom_settings.py`).

If you have whitelisted IP addresses/networks listed in Postfix config file
`/etc/postfix/main.cf`, parameter `mynetworks =`, you may want to whitelist
them to avoid greylisting or other access control in
`/opt/iredmail/custom/iredapd/settings.py` too. For example:

```
MYNEWTORKS = ['192.168.0.1', '172.16.0.0/8']
```

### iRedAdmin(-Pro)

There's no iRedAdmin(-Pro) with EE since it offers
same (actually, more) features as iRedAdmin(-Pro).

### SOGo Groupware

- SOGo doesn't support loading config from multiple files, so if file
  `/opt/iredmail/custom/sogo/sogo.conf` exists, EE will create `/etc/sogo/sogo.conf`
  as symbol link to this file.

    It's strongly recommended to customize SOGo settings on EE web UI, so
    you'd better check the features offered on EE web UI, then tune SOGo on
    web UI and remove `/opt/iredmail/custom/sogo/sogo.conf`.

- EE rewrites prefork child processes in `/etc/sysconfig/sogo` (RedHat-family OS)
  and `/etc/default/sogo` (Debian-family OS), please tune it on EE web UI
  (`Server Settings` -> `SOGo Groupware` -> `Max prefork processes`) after
  migrated to EE.

## Run the full deployment as migration

Please follow our tutorial [Install iRedMail Enterprise Edition](./install.ee.html)
to install it.

## Post-migration tasks

### Remove duplicate cron jobs

There might be duplicate cron jobs for `root` and `sogo` users, please check
cron jobs manually and remove old duplicate ones.
