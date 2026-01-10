# iRedMail Enterprise Edition (EE): Best Practice

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

## How the fearless upgrade works

iRedMail Enterprise Edition ("EE" for short) splits software config files
to 2 parts: core configuration and custom settings.

EE generates and maintains core config files to make sure everything works by
default with our best practice, but we understand that you may need to tune
some settings to match your own requirements, so EE offers several ways to
allow you to archive this goal.

Please follow some simple rules to store your custom settings, and do not
modify the core config files manually maintained by EE.

### Including config files

Many software supports loading settings from extra config files with directives
like `include` (Nginx, Dovecot), `include_try` (Dovecot), `require_once`
(PHP applications). In this case, it will be configured to load extra config
files under `/opt/iredmail/custom/<software-name>/`. We use Dovecot for
example to explain the details.

Dovecot's main config file is `/etc/dovecot/dovecot.conf`, we have directives
at the bottom of `dovecot.conf` like this:

```
!include_try /etc/dovecot/conf-enabled/*.conf
!include_try /opt/iredmail/custom/dovecot/conf-enabled/*.conf
```

It will try to load all files ends with `.conf` under
`/etc/dovecot/conf-enabled/` first, then
`/opt/iredmail/custom/dovecot/conf-enabled/`. Earlier settings with same
parameter name will be overridden by the latter one.

`/etc/dovecot/dovecot.conf` and all files under `/etc/dovecot/conf-enabled/`
are generated and maintained by EE based on the settings you done on EE web UI
(especially the `Server Settings` page). If
you want to override some settings, please create a file ends with
`.conf` under `/opt/iredmail/custom/dovecot/conf-enabled/` with your custom
settings. for example, Dovecot is configured to enable services like below by
iRedMail EE:

```
protocols = pop3 imap sieve lmtp
```

What can you do to disable `pop3` service without modify files under
`/etc/dovecot/`? Easy, just create a file, e.g. `custom.conf`, under
`/opt/iredmail/custom/dovecot/conf-enabled/` with content below (note: service
name `pop3` is removed in this setting), then restart Dovecot service:

```
protocols = imap sieve lmtp
```

### Modify config files in-place

If software does not support loading settings from extra config files,
you may need to apply your own settings by running commands to modify its
config files under `/etc/`. For example, Postfix.

Postfix doesn't support directive like `include` to load extra config files,
so if you modifying Postfix config files (e.g. `/etc/postfix/main.cf`) manually,
your modifications will be lost after next time you perform deployment (update,
upgrade, etc) on EE web UI, because EE always re-generates the files it maintains
during deployment.

Fortunately, EE supports executing a (bash) shell script during each deployment,
the script is `/opt/iredmail/custom/<COMPONENT>/custom.sh`. For Postfix, it's
`/opt/iredmail/custom/postfix/custom.sh`.

Let's say you want to add IP address `192.168.1.1` to Postfix parameter
`mynetworks`, instead of modifying `/etc/postfix/main.cf` directly, you can
write shell commands in `/opt/iredmail/custom/postfix/custom.sh` like below:

```
postconf -e mynetworks='127.0.0.1 192.168.1.1'
```

Again, this `custom.sh` will be executed by EE during deployment, if you
want to apply the changes immediately, please execute it manually:

```
cd /opt/iredmail/custom/postfix/
bash custom.sh
```

## SSL cert

EE generates self-signed ssl cert during initial setup, but you can [request
free cert from Let's Encrypt](./ee.cert.html) after initial setup.

Cert files are stored under `/opt/iredmail/ssl/`:

* `key.pem`: private key
* `cert.pem`: certificate
* `combined.pem`: full chain

## Passwords

* EE generates random and strong passwords and stores them under
  `/root/.iredmail/kv/` during initial setup, but if files exist before or
  after initial setup, EE reads from these files directly instead of generating
  new ones.
* All files under `/root/.iredmail/kv/` should contain only one line.
* If you changed some password manually, e.g. change mysql root password, please
  update file under `/root/.iredmail/kv/` immediately, so that EE can get
  correct password and updating config files to use it when you perform a deployment.


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
ALL | `sql_user_fail2ban` | Password of SQL user `fail2ban` | `/root/.my.cnf-fail2ban`
ALL | `iredapd_srs_secret` | The secret string used to sign SRS. | `/opt/iredapd/settings.py`, parameter `srs_secrets =`.
ALL | `sogo_sieve_master_password` | The Dovecot master user used by SOGo. | `/etc/sogo/sieve.cred`.
ALL | `roundcube_des_key` | The DES key used by Roundcube to encrypt the session. | `/opt/www/roundcubemail/config/config.inc.php`, parameter `$config['des_key'] =`.
ALL | `mlmmjadmin_api_token` | API token for authentication. | `/opt/mlmmjadmin/settings.py`, parameter `api_auth_tokens =`.
ALL | `first_domain_admin_password` | Password of the mail user `postmaster@<your-domain.com>`. | `your-domain.com` is the first mail domain name you (are going to) set during iRedMail installation.

## Custom settings used by software

### MariaDB

- `/opt/iredmail/custom/mysql/`:
    - All files end with `.cnf` will be loaded by MariaDB.
    - It will override existing settings defined in files under `/etc/mysql/`.
      For example, add file `/opt/iredmail/custom/mysql/custom.conf` with
      content below, it will set value of parameter `max_connections` to `1024`:

```
[mysqld]
max_connections     = 1024
```

### OpenLDAP

- `/opt/iredmail/custom/openldap/schema/`

    Extra LDAP schema files must be stored in this directory, owned by OpenLDAP
    daemon user and group with permission 0640. Note: schema files will __NOT__
    be loaded by OpenLDAP automatically, you must update `global.conf` mentioned
    below to load them.

- `/opt/iredmail/custom/openldap/conf.d/global.conf`

    Extra global settings should be stored in this file. For example, you can
    load extra LDAP schema file by adding line below:

    ```
    include /opt/iredmail/custom/openldap/schema/custom.schema
    ```

- `/opt/iredmail/custom/openldap/conf.d/databases.conf`

    OpenLDAP is configured to run one database for mail domains and accounts,
    if you want to run extra databases, please add [database related settings](https://openldap.org/doc/admin26/slapdconfig.html#General%20Database%20Directives)
    in this file. For example:

```
database    mdb
suffix      dc=my-ldap-suffix,dc=com
directory   /var/lib/ldap/my-ldap-suffix.com

rootdn      cn=Manager,dc=my-ldap-suffix,dc=com
rootpw      {SSHA}...

sizelimit   unlimited
maxsize     2147483648
checkpoint  128 3
mode        0700

index attr_1,attr_2,attr_3  eq,pres
index attr_4,attr_5,attr_6  eq,pres
```

### Nginx

- `/opt/iredmail/custom/nginx/custom.sh`: a (bash) shell script for advanced
  customization. This file will be executed every time iRedMail EE deploys /
  upgrades the Nginx.

      For example, Nginx doesn't support override existing settings by loading
      same parameter from another config file, in this case you can run command
      like `sed`, `perl` to modify the config file generated by EE in place.

- `/opt/iredmail/custom/nginx/conf-enabled/`

    All files ends with `.conf` under this directory will be loaded by Nginx
    inside the `http {}` block (check `/etc/nginx/nginx.conf` for more details).

    If you want to override a parameter which is already defined in files under
    `/etc/nginx/conf-enabled/`, please update the value with command like
    `sed`, `perl` in `/opt/iredmail/custom/nginx/custom.sh`.

- `/opt/iredmail/custom/nginx/sites-conf.d/default-ssl/`: additional settings
  for default https website (inside the `server {}` block).
- `/opt/iredmail/custom/nginx/sites-enabled/`: additional virtual web hosts.
- `/opt/iredmail/custom/nginx/webapps/`: additional settings for certain web
  applications, usually used to add ACL for the web applications. Including:

    - `adminer.conf`: loaded in file `/etc/nginx/template/adminer.tmpl`.
    - `iredadmin.conf`: loaded in file `/etc/nginx/template/iredadmin.tmpl`.
    - `netdata.conf`: loaded in file `/etc/nginx/template/netdata.tmpl`.
    - `roundcube.conf`: it will be loaded in file `/etc/nginx/templates/roundcube*.tmpl`.
    - `sogo.conf`: loaded in file `/etc/nginx/template/sogo.tmpl`.
    - `php_fpm_status.conf`: loaded in file `/etc/nginx/template/php_fpm_status.tmpl`.
    - `stub_status.conf`: loaded in file `/etc/nginx/template/stub_status.tmpl`.

iRedMail uses the directory structure recommended by Debian/Ubuntu:

```
/etc/nginx/                         # all config files

        |- conf-available/          # store settings used inside Nginx `http {}` block.
                                    # Note: files under this directory are NOT
                                    #       loaded by Nginx directly.

        |- conf-enabled/            # symbol links to files under `conf-available/`.
                                    # Note: files under this directory are
                                    #       loaded by Nginx directly.

        |- sites-available/         # store virtual web host config files.
                                    # Note: files under this directory are NOT
                                    #       loaded by Nginx directly.

        |- sites-enabled/           # symbol links to files under `sites-available/`.
                                    # Note: files under this directory are
                                    #       loaded by Nginx directly.

        |- sites-conf.d/
                |- default-ssl/     # modular config files used by default
                                    # virtual web host.

/opt/iredmail/custom/nginx/         # all custom config files.
                        |- conf-available/
                        |- conf-enabled/
                        |- sites-available/
                        |- sites-enabled/
                        |- webapps/         # config snippets for certain web applications.
                        |- custom.sh        # (bash) shell script used for advanced customization
```

### Postfix

Postfix doesn't support loading main settings (`/etc/postfix/main.cf` and
`/etc/postfix/master.cf`) from multiple files, so iRedMail EE uses alternative
solution to split core and custom settings.

- Write your custom settings for `/etc/postfix/main.cf`
  in file `/opt/iredmail/custom/postfix/append_main.cf`. EE will append all
  content of `append_main.cf` to the end of `/etc/postfix/main.cf` during each
  deployment.
- Write your new custom settings for `/etc/postfix/master.cf`
  in file `/opt/iredmail/custom/postfix/append_master.cf`. EE will append all
  content of `append_master.cf` to the end of `/etc/postfix/master.cf` during
  each deployment.
  perform upgrade, re-perform full deployment, or re-deploy Postfix.
- [__NOT RECOMMENDED__] <del>You can also maintain your own copy of full
  `main.cf` and `master.cf` under `/opt/iredmail/custom/postfix/` directory,
  but this is __NOT RECOMMENDED__ because EE may add or remove settings in
  those 2 files in future releases, if your own copy doesn't update at the
  same time, SMTP service may be broken.
    - If file `/opt/iredmail/custom/postfix/main.cf` exists, iRedMail EE will
      create `/etc/postfix/main.cf` as symbol link to this file.
    - If file `/opt/iredmail/custom/postfix/master.cf` exists, iRedMail EE
      will create `/etc/postfix/master.cf` as symbol link to this file.</del>

For other settings, Postfix is configured to load files under
`/opt/iredmail/custom/postfix/` first (they store custom settings and
maintained by you), then another one from `/etc/postfix/` (maintained by
iRedMail EE and you should __NOT__ modify them). If rule defined in custom files
matches, Postfix will skip the second file.

For example, Postfix is configured to load 2 files for HELO access check:

```
smtpd_helo_restrictions =
    ...
    check_helo_access pcre:/opt/iredmail/custom/postfix/helo_access.pcre
    check_helo_access pcre:/etc/postfix/helo_access.pcre
    ...
```

- The first one, `/opt/iredmail/custom/postfix/helo_access.pcre`, is used to
  store your cusotm HELO access rules. If rule in this file matches,
  Postfix will ignore other rules defined later in same file, also the second
  file `/etc/postfix/helo_access.pcre`. So you can write rule in first file
  for new HELO access, or write same rule with different action to override the
  one defined in `/etc/postfix/helo_access.pcre`.
- `/etc/postfix/helo_access.pcre`: This file is maintained by iRedMail EE,
  do NOT modify it.

You can find some other files for customization under
`/opt/iredmail/custom/postfix/`. For example:

- `body_checks.pcre`
- `header_checks.pcre`
- `command_filter.pcre`
- `postscreen_access.cidr`
- ...

There's also a (Bash) shell script for flexible customization:
`/opt/iredmail/custom/postfix/custom.sh`. It will be ran each time you perform
deployment or upgrade.

For example, to set value of parameter `enable_original_recipient` to `yes`
(defaults to `no` set in `/etc/postfix/main.cf`), you can write command in
`/opt/iredmail/custom/postfix/custom.sh` like below:

```
postconf -e enable_original_recipient=yes
```

To add new or update existing transport settings in `/etc/postfix/master.cf`,
you can run `postconf -M` and `postconf -P` (requires Postfix-2.11 or later
releases). For example, create new transport `465` for
[SMTPS (SMTP over SSL)](./enable.smtps.html):

```
postconf -M 465/inet="465 inet n - n - - smtpd"
postconf -P "465/inet/syslog_name=postfix/smtps"
postconf -P "465/inet/smtpd_tls_wrappermode=yes"
postconf -P "465/inet/smtpd_sasl_auth_enable=yes"
postconf -P "465/inet/smtpd_client_restrictions=permit_sasl_authenticated,reject"
postconf -P "465/inet/content_filter=smtp-amavis:[127.0.0.1]:10026"
```

It will generate new lines in `/etc/postfix/master.cf` like below:

```
465 inet n - n - - smtpd
  -o syslog_name=postfix/smtps
  -o smtpd_tls_wrappermode=yes
  -o smtpd_sasl_auth_enable=yes
  -o smtpd_client_restrictions=permit_sasl_authenticated,reject
  -o content_filter=smtp-amavis:[127.0.0.1]:10026
```

For more details about `postconf` command, please check its manual page:
[postconf(1)](http://www.postfix.org/postconf.1.html).

Updating configuration with `postconf` is not that user-friendly, use
`append_main.cf` and `append_master.cf` if possible.

### Dovecot

Dovecot supports loading from mulitple config files, and settings will be
overrode by the last one.

- `/opt/iredmail/custom/dovecot/conf-enabled/`: store custom Dovecot settings.
- `/opt/iredmail/custom/dovecot/custom.sh`: a (bash) shell script used for advanced customization
- `/opt/iredmail/custom/dovecot/dovecot.sieve`: custom global sieve rule file.

    If this file exists, iRedMail EE will link it to
    `/var/vmail/sieve/dovecot.sieve` as global sieve rule file.

### Roundcube

#### Custom global settings

All your custom settings should be placed in
__`/opt/iredmail/custom/roundcube/custom.inc.php`__, and do __NOT__
touch main config file `/opt/www/roundcubemail/config/config.inc.php`.

#### Third-party or custom plugins

All third-party or custom plugins should be placed under __`/opt/iredmail/custom/roundcube/plugins/`__.

Plugins will be linked to `/opt/www/roundcubemail/plugins/` automatically
during iRedMail EE deployment, but you need to create the symbol
link manually if you don't want to run another deployment.

Don't forget to enable the plugin(s) in `/opt/iredmail/custom/roundcube/custom.inc.php`.
For example:

```
$config['plugins'] = array('managesieve', 'password', 'markasjunk', 'YOUR-PLUGIN-1', 'YOUR-PLUGIN-2');
```

#### Third-party or custom skins

All third-party or custom skins should be placed under __`/opt/iredmail/custom/roundcube/skins/`__.

Skins will be linked to `/opt/www/roundcubemail/skins/` automatically
during iRedMail EE deployment, but you need to create the symbol link
manually if you don't want to run another deployment.

To use some third-party skin as the default one for all users, append a line
in `/opt/iredmail/custom/roundcube/custom.inc.php` like below:

```
$config['skin'] = 'YOUR-SKIN-NAME';
```

#### Custom settings for official plugins

iRedMail EE enables 3 official plugins by default:

- `password`: used by end users to change their own passwords.
- `managesieve`: used by end users to custom mail filter rules.
- `markasjunk`: used by end users to report spam or ham.

If you have custom settings for plugins enabled by iRedMail EE, please
put the custom settings in file
`/opt/iredmail/custom/roundcube/config_<plugin_name>.inc.php`.

For example:

- For `password` plugin: `/opt/iredmail/custom/roundcube/config_password.inc.php`
- For `managesieve` plugin: `/opt/iredmail/custom/roundcube/config_managesieve.inc.php`
- For `markasjunk` plugin: `/opt/iredmail/custom/roundcube/config_markasjunk.inc.php`

#### Custom settings for official plugins but not enabled by iRedMail

If you need to enable some Roundcube official plugin which is not enabled by
iRedMail EE:

* Add shell commands like below in `/opt/iredmail/custom/roundcube/custom.sh`
(Note: replace `<plugin>` by the real plugin name):

```
cd /opt/www/roundcubemail/plugins/<plugin>/
cp config.inc.php.dist config.inc.php
echo 'require_once "/opt/iredmail/custom/roundcube/config_<plugin>.inc.php";' >> config.inc.php
```

* Create file `/opt/iredmail/custom/roundcube/config_<plugin>.inc.php` and
  store all your custom settings in this file. __WARNING__: this file must be a
  valid php file.

This way if iRedMail EE enables this plugin in the future, it will
successfully load your own custom settings and not mess it up.

For example, if you have custom settings for official plugin `enigma`, you
should add shell commands like below in `/opt/iredmail/custom/roundcube/custom.sh`

```
cd /opt/www/roundcubemail/plugins/engima/
cp config.inc.php.dist config.inc.php
echo 'require_once "/opt/iredmail/custom/roundcube/config_enigma.inc.php";' >> config.inc.php
```

Then put all custom settings for plugin `enigma` to
`/opt/iredmail/custom/roundcube/config_enigma.inc.php`.

### SOGo

SOGo doesn’t support directive like `include` to load extra settings
from multiple files, so you have to either maintain your own SOGo config
file (`/opt/iredmail/custom/sogo/sogo.conf`) or use the `custom.sh`
(bash) shell script to do some customization based on the config file generated by
iRedMail EE.

- [__NOT RECOMMENDED__] <del>File `/opt/iredmail/custom/sogo/sogo.conf`</del>

    <del>If this file exists, `/etc/sogo/sogo.conf` will be created as a symbol
    link to this file during iRedMail EE deployment.</del>

    <del>WARNING: SOGo may introduce new parameters in future release, or EE may
    add new parameters too, if you didn't update your own copy of `sogo.conf`
    at the same time, SOGo may not work as expected.</del>

- Shell script `/opt/iredmail/custom/sogo/custom.sh`

    A bash shell script for advanced customization, you can customize SOGo
    config file with shell commands organized in this file.

    This file will be ran by iRedMail EE deployment each time it deploys
    or upgrade SOGo component.

### iRedAPD

- File `/opt/iredmail/custom/iredapd/settings.py`

    All custom settings must be stored in this file.
    It will be linked to `/opt/www/iredapd/custom_settings.py` during iRedMail
    EE deployment or upgrade.

### Amavisd

- Store custom settings in `/opt/iredmail/custom/amavisd/amavisd.conf`.
- Store all DKIM keys under `/opt/iredmail/custom/amavisd/dkim/`.
    - Note: iRedMail EE maintains DKIM key for primary domain, please do not
      add duplicate dkim key for primary domain in `/opt/iredmail/custom/amavisd/amavisd.conf`.

### SpamAssassin

Store custom rules in `/opt/iredmail/custom/spamassassin/custom.cf`.

### Fail2ban

- `/opt/iredmail/custom/fail2ban/jail.local`: used to override settings in
  `[DEFAULT]` section of main fail2ban config file. For example, `maxretry`, `findtime`, `bantime`,
  `ignoreip`.
- `/opt/iredmail/custom/fail2ban/custom.sh`: used for advanced customization.
  for example, if you have some new jails, you can write jail config files under
  `/opt/iredmail/custom/fail2ban/` too (you're free to create sub-folder to
  store the jail config files), then use `custom.sh` to create symbol link
  of jails you want to enable under `/etc/fail2ban/jail.d/`.

## Backup

- iRedMail EE generates daily cron jobs to backup mail accounts and SQL/LDAP
  databases (stored under `/var/vmail/backup/` by default), but not mailboxes, you
  need to backup mailboxes yourself.
- Files under `/opt/iredmail/custom/` contain all your custom settings.
  If you need to restore an iRedMail EE server to another one, please copy
  `/opt/iredmail/custom/` to new server first, then perform the iRedMail EE
  deployment, EE will set correct owner/group/permission for them during deployment.

## FAQ

### DKIM signature is now signed by the new milter program

!!! attention

    If you migrated from iRedMail open source edition or iRedMail Easy,
    existing DKIM keys were migrated by EE automatically during migration.

- DKIM signature is signed by the milter program (`/usr/local/bin/milter*`) developed by iRedMail team.
- DKIM keys are stored in SQL table `vmail.dkim`.
- After login to EE as global admin, you can click the `DNS` badge on domain
  list page to check DNS records of the email domain, including DKIM key.
- Feel free to generate DKIM key for each domain, then publish the public key on DNS.
