# Migrate from iRedMail to iRedMail Easy platform

[TOC]

!!! attention

    iRedMail Team can help migrate your iRedMail server, feel free to
    [Contact Us](https://www.iredmail.org/contact.html).

## Summary

iRedMail Easy platform offers deployment, one-click upgrade support and
technical support for your iRedMail servers, it's very easy to keep your
server up to date with the ease to use web UI, and get issues solved by
iRedMail Team quickly.

For more details about iRedMail Easy platform, please
[check our website](https://www.iredmail.org/easy.html).

## Requirements

- A working iRedMail server which was deployed with the downlodable installer
  `iRedMail-0.9.9`, or has been successfully upgraded to the latest
  iRedMail-0.9.9 release.
- Your iRedMail server must be running one of supported Linux/OpenBSD
  distribution releases:
    - Ubuntu 18.04 LTS
    - Debian 9
    - CentOS 7
    - OpenBSD 6.4, 6.5

Unfortunately, FreeBSD is not supported by iRedMail Easy platform.

## Backup first

Please backup all important data before preparing the migration, including but not limtied to:

- All SQL/LDAP databases.

    iRedMail Easy will use existing SQL/LDAP databases, no data corruption is expected.

- All config files under `/etc` directory.

    After moved to iRedMail Easy, you should place all your custom settings in files
    under `/opt/iredmail/custom/<software>/`.

## Create required files used by iRedMail Easy

iRedMail Easy doesn't store any SQL/LDAP passwords, instead it reads from files
under `/root/.iredmail/kv/` on your server to get them.

Please create these files under `/root/.iredmail/kv/` with correct passwords
manually, each file should contain only one line, passwords must be in plain
text, not the hashed one.

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
ALL | `sql_user_vmail` | Password of SQL user `vmail` | `/etc/postfix/mysql/*.cf` or `/etc/postfix/pgsql/*.cf`
ALL | `sql_user_vmailadmin` | Password of SQL user `vmailadmin` | `/opt/www/iredadmin/settings.py`
ALL | `sql_user_amavisd` | Password of SQL user `amavisd` | `/etc/amavisd/amavisd.conf` (Linux/OpenBSD)<br>`/etc/amavis/conf.d/50-user` (Debian/Ubuntu)
ALL | `sql_user_sa_bayes` | Password of SQL user `sa_bayes` | `/etc/mail/spamassassin/local.cf`
ALL | `sql_user_iredadmin` | Password of SQL user `iredadmin` | `/opt/www/iredadmin/settings.py`
ALL | `sql_user_iredapd` | Password of SQL user `iredapd` | `/opt/iredapd/settings.py`
ALL | `sql_user_roundcube` | Password of SQL user `roundcube` | `/root/.my.cnf-roundcube` or `/opt/www/roundcubemail/config/config.inc.php`
ALL | `sql_user_sogo` | Password of SQL user `sogo` | `/etc/sogo/sogo.conf`
ALL | `sql_user_netdata` | Password of SQL user `netdata` | `/root/.my.cnf-netdata` or `/opt/netdata/etc/netdata/my.cnf`
ALL | `iredapd_srs_secret` | The secret string used to sign SRS. | `/opt/iredapd/settings.py`, parameter `srs_secrets =`.
ALL | `sogo_sieve_master_password` | The Dovecot master user used by SOGo. | `/etc/sogo/sieve.cred`.
ALL | `roundcube_des_key` | The DES key used by Roundcube to encrypt the session. | `/opt/www/roundcubemail/config/config.inc.php`, parameter `$config['des_key'] =`.
ALL | `mlmmjadmin_api_token` | API token for authentication. | `/opt/mlmmjadmin/settings.py`, parameter `api_auth_tokens =`.
ALL | `first_domain_admin_password` | Password of the mail user `postmaster@<your-domain.com>`. | `your-domain.com` is the first mail domain name you (are going to) set in mail server profile page on iRedMail Easy platform, you can find it in mail server profile page, under tab `Settings`.

## Copy files to new locations

iRedMail Easy stores SSL cert/key files under `/opt/iredmail/ssl/`, you need to
either copy or (symbol) link existing ssl cert/key to this directory with
correct files names,

* `/opt/iredmail/ssl/key.pem`: private key
* `/opt/iredmail/ssl/cert.pem`: certificate
* `/opt/iredmail/ssl/combined.pem`: full chain

## Split custom settings

iRedMail Easy maintains the core config files, and each time you perform
full deployment or upgrade, these core config files will be re-generated, all
your custom config files will be lost. So it's very important to not touch
these core config files and just store your custom settings in pre-defined
files under `/opt/iredmail/custom/<software>/`.

### Postfix

* Files under `/etc/postfix/`:
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

    - From `/etc/postfix/body_checks.pcre` to `/opt/iredmail/custom/postfix/body_checks.pcre`.
    - From `/etc/postfix/command_filter.pcre` to `/opt/iredmail/custom/postfix/command_filter.pcre`.

    You need to create directory `/opt/iredmail/custom/postfix/` and the files
    if they don't exist, iRedMail Easy will set correct owner/group and
    permission for them while deployment.

    If you're lasy and don't want to check files one by one, it's ok to simply
    copy these files from `/etc/postfix/` to `/opt/iredmail/custom/postfix/`
    directly, and (optionally) remove non-custom settings later.

* `/etc/postfix/main.cf` and `/etc/postfix/master.cf`

    Postfix doesn't support `include` directive to load extra config files,
    so if you have custom settings in these 2 files, you have to create shell
    script file `/opt/iredmail/custom/postfix/custom.sh` to update them with
    `postconf` command during iRedMail Easy deployment or upgrade. For more
    details, please check our
    [Best Practice](./iredmail-easy.best.practice.html#postfix) tutorial.

### Roundcube Webmail

* Copy custom settings from `/opt/www/roundcubemail/config/config.inc.php` to `/opt/iredmail/custom/roundcube/config/custom.inc.php`.
* Copy third-party plugins from `/opt/www/roundcubemail/plugins/` to `/opt/iredmail/custom/roundcube/plugins/`. iRedMail Easy will create symbol link for them automatically.
* Copy third-party or custom skins from `/opt/www/roundcubemail/skins/` to `/opt/iredmail/custom/roundcube/skins/`. iRedMail Easy will create symbol link for them automatically.

### iRedAPD

Copy custom settings from `/opt/iredapd/settings.py` to `/opt/iredmail/custom/iredapd/settings.py`.

### iRedAdmin(-Pro)

Copy custom settings from `/opt/www/iredadmin/settings.py` to `/opt/iredmail/custom/iredadmin/settings.py`.

## Run the full deployment with iRedMail Easy platform

Please follow our tutorial [Getting start with iRedMail Easy](./iredmail-easy.getting.start.html)
to sign up, and add your mail server info, then perform the full deployment.

## Post-deployment tasks

### Remove duplicate cron jobs

iRedMail Easy will add required cron jobs for `root` and `sogo` users, but it
can not detect and remove old duplicate jobs, so you have to check cron jobs
manually and remove duplicate old ones and keep the ones added by iRedMail Easy.
