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

* `sql_user_root`: the MySQL root password. This is required for OpenLDAP
  and MySQL/MariaDB backends. You can find it in file `/root/.my.cnf` or `/root/.my.cnf-root`.
* `pgsql_root_password`: The PostgreSQL root password. This is required for
  PostgreSQL backend. You can find it in the `.pgpass` file under PostgreSQL
  data directory.
    - on CentOS, it's `/var/lib/pgsql/.pgpass`.
    - on Debian/Ubuntu, it's `/var/lib/postgresql/.pgpass`.
    - on OpenBSD, it's `/var/postgresql/.pgpass`.
* `ldap_root_password`: The password of OpenLDAP root dn (cn=Manager,dc=xx,dc=xx).
  This is required for OpenLDAP backend.
* `ldap_vmail_password`: The password of LDAP dn `cn=vmail,dc=xx,dc=xx`.
* `ldap_vmailadmin_password`: The password of LDAP dn `cn=vmailadmin,dc=xx,dc=xx`.
* `sql_user_vmail`: The password of SQL user `vmail`.
* `sql_user_vmailadmin`: The password of SQL user `vmailadmin`.
* `sql_user_amavisd`: The password of SQL user `amavisd`.
* `sql_user_sa_bayes`: The password of SQL user `sa_bayes`.
* `sql_user_iredadmin`: The password of SQL user `iredadmin`.
* `sql_user_iredapd`: The password of SQL user `iredapd`.
* `sql_user_sogo`: The password of SQL user `sogo`.
* `sql_user_netdata`: The password of SQL user `netdata`. You can find it in `/root/.my.cnf-netdata` or `/opt/netdata/etc/netdata/my.cnf`.
* `sql_user_roundcube`: The password of SQL user `roundcube`.
* `iredapd_srs_secret`: The secret string used by iRedAPD to sign SRS. You can find it in `/opt/iredapd/settings.py`, parameter `srs_secrets =`. if you don't have this parameter in file due to old iRedAPD release, it's ok to ignore it and let iRedMail Easy to generate one.
* `sogo_sieve_master_password`: The Dovecot master user used by SOGo. You can find it in `/etc/sogo/sieve.cred`.
* `roundcube_des_key`: The DES key used by Roundcube to encrypt the session. You can find it in `/opt/www/roundcubemail/config/config.inc.php`, parameter `$config['des_key'] =`.
* `mlmmjadmin_api_token`: The token string used by iRedAdmin-Pro to communicate with mlmmjadmin. You can find it in `/opt/mlmmjadmin/settings.py`, parameter `api_auth_tokens =`.
* `first_domain_admin_password`: The password of the first mail user created during iRedMail installation.

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

Copy custom settings from `/opt/www/roundcubemail/config/config.inc.php` to `/opt/iredmail/custom/roundcubemail/config/custom.inc.php`.

### iRedAPD

Copy custom settings from `/opt/iredapd/settings.py` to `/opt/iredmail/custom/iredapd/settings.py`.

### iRedAdmin(-Pro)

Copy custom settings from `/opt/www/iredadmin/settings.py` to `/opt/iredmail/custom/iredadmin/settings.py`.

## Run the full deployment with iRedMail Easy platform

Please follow our tutorial [Getting start with iRedMail Easy](./iredmail-easy.getting.start.html)
to sign up, and add your mail server info, then perform the full deployment.
