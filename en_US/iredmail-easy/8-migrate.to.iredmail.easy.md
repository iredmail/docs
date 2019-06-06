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

* `mysql_root_password`: the MySQL root password. This is required for OpenLDAP
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
* `vmail_db_password`: The password of SQL user `vmail`.
* `vmail_db_admin_password`: The password of SQL user `vmailadmin`.
* `amavisd_db_password`: The password of SQL user `amavisd`.
* `sa_bayes_db_password`: The password of SQL user `sa_bayes`.
* `iredadmin_db_password`: The password of SQL user `iredadmin`.
* `iredapd_db_password`: The password of SQL user `iredapd`.
* `iredapd_srs_secret`: The secret string used by iRedAPD to sign SRS.
* `sogo_db_password`: The password of SQL user `sogo`.
* `sogo_sieve_master_password`: The Dovecot master user used by SOGo. You can find it in `/etc/sogo/sieve.cred`.
* `roundcube_db_password`: The password of SQL user `roundcube`.
* `roundcube_des_key`: The DES key used by Roundcube to encrypt the session. You can find it in `/opt/www/roundcubemail/config/config.inc.php`, parameter `$config['des_key'] =`.
* `mlmmjadmin_api_token`: The token string used by iRedAdmin-Pro to communicate with mlmmjadmin. You can find it in `/opt/mlmmjadmin/settings.py`, parameter `api_auth_tokens =`.
* `netdata_db_password`: The password of SQL user `netdata`. You can find it in `/root/.my.cnf-netdata` or `/opt/netdata/etc/netdata/my.cnf`.
* `first_domain_admin_password`: The password of the first mail user created during iRedMail installation.

## Copy files to new locations

iRedMail Easy stores SSL cert/key files under `/opt/iredmail/ssl/`, you need to
either copy or (symbol) link existing ssl cert/key to this directory with
correct files names,

* `/opt/iredmail/ssl/key.pem`: private key
* `/opt/iredmail/ssl/cert.pem`: certificate
* `/opt/iredmail/ssl/combined.pem`: full chain

## Run the full deployment with iRedMail Easy platform

Please follow our tutorial [Getting start with iRedMail Easy](./iredmail-easy.getting.start.html)
to sign up, and add your mail server info, then perform the full deployment.

## Post-installation setup

iRedMail Easy will re-generate most config files, custom settings will be
loaded from files under `/opt/iredmail/custom/`, so if you have any
customizations, you may need to copy your custom settings to files under
`/opt/iredmail/custom/`.

### Postfix config files

iRedMail Easy will rewrite config files under `/etc/postfix/`, most importantly
`main.cf` and `master.cf`. If you have any changes in these 2 files, please
read the `[Best Practice](./iredmail-easy.best.practice.html)` document to
understand how to customize them with shell script
`/opt/iredmail/custom/postfix/custom.sh`.

For customizations you made in other files under `/etc/postfix/`, you must
move the customizations to files under `/opt/iredmail/custom/postfix/` which
have same file names.

For example, if you added some rules in `/etc/postfix/helo_access.pcre`, you
should copy these rules to file `/opt/iredmail/custom/postfix/helo_access.pcre`.
