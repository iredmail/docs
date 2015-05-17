# Upgrade iRedMail from 0.5.1 to 0.6.0

[TOC]

## ChangeLog

> We provide remote upgrade service, check [the price](../support.html) and [contact us](../contact.html).

* 2010-06-19: Fixed: Add new column in MySQL database after upgarding PostfixAdmin.
* 2010-06-18: [OpenLDAP] New: Index missed LDAP attributes.
* 2010-06-03: Fixed: Forget to add new parameter to enable domain alias management in PostfixAdmin.
* 2010-06-02: Fixed: incorrect config file of phpLDAPadmin. Thanks billybons2006@forum.
* 2010-06-02: Fixed: incorrect PostfixAdmin config file. Thanks hata_ph@forum.

## General (All backends should apply these steps)

### Apply hotfix for iRedMail-0.5.1

* [Incorrect crontab job of vmail user](http://www.iredmail.org/forum/topic418-fixed-in-051-incorrect-crontab-job-of-vmail-user.html)
* [iRedAdmin-0.1.1 (shipped in iRedMail-0.5.1): not all arguments converted during string formatting](http://www.iredmail.org/forum/topic398-fixed-in-iredadmin011-not-all-arguments-converted.html)

### Add missing MySQL table (Debian/Ubuntu only)

__Note__: This step is applicable to only Debian/Ubuntu.

You should manually import another MySQL table if you are using below distributions:

* Debian 5
* Ubuntu 8.04
* Ubuntu 9.04

```
$ mysql -uroot -p postfixpolicyd
mysql> SOURCE /usr/share/dbconfig-common/data/postfix-policyd/upgrade/mysql/1.73-1;
mysql> GRANT SELECT,INSERT,UPDATE,DELETE ON postfixpolicyd.* TO postfix-policyd@localhost;
mysql> quit;
```

It will create a new table `postfixpolicyd.blacklist_dnsname`. Used to block
emails sent from `blacklist_dnsname` in Policyd,

### Upgrade Roundcube webmail to 0.3.1

Roundcube-0.3.1 brings new features and better performance, all users are encouraged to upgrade it.

To upgrade roundcube to 0.3.1, we should:
* Backup current roundcube installation.
* Download roundcube source tarball: roundcubemail-0.3.1.tar.gz, and uncompress it.
* Copy it to apache server root directory.
* Upgrade SQL database.
* Replace symbol link by new version.
* Create new config files and synchronize settings from old configuration files.
* Enable necessary plugins.
* Restart apache web server
* [Next Step] Configure plugin (`managesieve`) to allow user to customize mail filter rule.

Steps to upgrade it:

* Backup current roundcube installation.

    * We should backup roundcubemail database in MySQL. If upgrade failed, we can recovery it from this backup copy.
    * Backing up installation files is not required since we won't move or override them during upgrade procedure.

```
$ mysqldump -uroot -p --default-character-set=utf8 roundcubemail > /opt/roundcubemail-old.sql
```

File `/opt/roundcubemail-old.sql` is the backup copy of current roundcubemail database.

* Download Roundcube 0.3.1: http://sourceforge.net/projects/roundcubemail/files/ .
  we assume you downloaded it to /root/ directory.

```
# cd /root/
# tar zxf roundcubemail-0.3.1.tar.gz
```

* Copy it to apache server root directory:
```
#
# ---- On RHEL/CentOS ----
#
# cp -rf /root/roundcubemail-0.3.1 /var/www/

#
# ---- On Debian/Ubuntu ----
#
# cp -rf /root/roundcubemail-0.3.1 /usr/share/apache2/
```

* Remove old symbol link, and create a new one:
```
#
# ---- On RHEL/CentOS ----
#
# cd /var/www/
# rm -i roundcubemail        # Do not use command 'rm' with '-r' flag here.
# ln -s roundcubemail-0.3.1 roundcubemail

#
# ---- On Debian/Ubuntu ----
#
# cd /usr/share/apache2/
# rm -i roundcubemail
# ln -s roundcubemail-0.3.1 roundcubemail
```

* Upgrade SQL database.
```
#
# ---- On RHEL/CentOS ----
#
# mysql -uroot -p
mysql> USE roundcubemail;
mysql> SOURCE /var/www/roundcubemail/SQL/mysql.update.sql;
mysql> quit;

#
# ---- On Debian/Ubuntu ----
#
# mysql -uroot -p
mysql> USE roundcubemail;
mysql> SOURCE /usr/share/apache2/roundcubemail/SQL/mysql.update.sql;
mysql> quit;
```

* Create new config files and synchronize settings from old configuration files.

```
#
# ---- On RHEL/CentOS ----
#
# cd /var/www/roundcubemail/config/
# cp db.inc.php.dist db.inc.php        # Database config file.
# cp main.inc.php.dist main.inc.php        # Main config file.

#
# ---- On Debian/Ubuntu ----
#
# cd /usr/share/apache2/roundcubemail/config/
# cp db.inc.php.dist db.inc.php        # Database config file.
# cp main.inc.php.dist main.inc.php        # Main config file.
```

Sync database config file `db.inc.php` with below config parameters:

```
# Part of file:  roundcubemail/config/db.inc.php

$rcmail_config['db_dsnw'] =
```

Sync config parameters in main config file `main.inc.php`. Roundcube 0.3.1 has
some new config parameters in main config file `main.inc.php`, but you can use
most of them with default values. What we need to do is syncing config
parameters from old installation.

```
$rcmail_config['enable_installer'] = FALSE;
$rcmail_config['check_all_folders'] = TRUE;
$rcmail_config['default_host'] =
$rcmail_config['smtp_server'] =
$rcmail_config['smtp_user'] = "%u";
$rcmail_config['smtp_pass'] = "%p";
$rcmail_config['smtp_auth_type'] = "LOGIN";
$rcmail_config['username_domain'] =
$rcmail_config['language'] =
$rcmail_config['enable_spellcheck'] =
$rcmail_config['default_charset'] = "UTF-8";
$rcmail_config['useragent'] = "RoundCube WebMail";
$rcmail_config['create_default_folders'] = TRUE;
$rcmail_config['mime_param_folding'] = 1;
$rcmail_config['identities_level'] = 3;
$rcmail_config['preview_pane'] = TRUE;
$rcmail_config['quota_zero_as_unlimited'] = TRUE;
$rcmail_config['log_driver'] = "syslog";
$rcmail_config['syslog_id'] = "roundcube";
$rcmail_config['syslog_facility'] = LOG_MAIL;
$rcmail_config['log_logins'] = TRUE;
$rcmail_config['delete_always'] = TRUE;

#
# ---- Global LDAP Address Book ----
# You can simply copy from old config file.
#
$rcmail_config['ldap_public']
```

* Enable necessary plugins.

Roundcube 0.3.1 officially ships some plugins, currently, we need two plugins:
`password`, `managesieve`. List them in main config file: `main.inc.php`.

```
# Part of file: roundcubemail/config/main.inc.php

$rcmail_config['plugins'] = array("password", "managesieve",);
```

Plugin name is same as folder name under `roundcubemail/plugins/` directory,
and we have to config plugins separately.

* Restart apache web server.
```
#
# ---- On RHEL/CentOS ----
#
# /etc/init.d/httpd restart

#
# ---- On Debian/Ubuntu ----
#
# /etc/init.d/apache2 restart
```

* Apply two patches. About these two patches:

    * Refer to this forum topic for more detail about patch for CVE-2010-0464: [http://www.iredmail.org/forum/topic673-security-fix-in-roundcube-disable-dns-prefetching-cve20100464.html Security fix in Roundcube: Disable DNS prefetching. (CVE-2010-0464)]
    * Patch `managesieve_rule_width_on_safari.patch` is used to fix page width in filter plugin, for Safari web browser.

Steps to patch your roundcube 0.3.1:

* On RHEL/CentOS:
```
# cd /tmp/
# wget http://iredmail.googlecode.com/hg/tags/0.6.0/patches/roundcubemail/roundcube-CVE-2010-0464.patch
# wget http://iredmail.googlecode.com/hg/tags/0.6.0/patches/roundcubemail/managesieve_rule_width_on_safari.patch
# cd /var/www/roundcubemail/
# patch -p0 < /tmp/roundcube-CVE-2010-0464.patch
# patch -p0 < /tmp/managesieve_rule_width_on_safari.patch
```

* On Debian/Ubuntu:
```
# cd /tmp/
# wget http://iredmail.googlecode.com/hg/tags/0.6.0/patches/roundcubemail/roundcube-CVE-2010-0464.patch
# wget http://iredmail.googlecode.com/hg/tags/0.6.0/patches/roundcubemail/managesieve_rule_width_on_safari.patch
# cd /usr/share/apache2/roundcubemail/
# patch -p0 < /tmp/roundcube-CVE-2010-0464.patch
# patch -p0 < /tmp/managesieve_rule_width_on_safari.patch
```

#### Configure plugin for mail filter rules: managesieve 

Roundcube 0.3.1 officially ships a plugin to allow users to customize mail
filter rule: `managesieve`. To make it work, we should generate new config
file and config necessary parameters.

* Change current directory to plugin directory:
```
#
# ---- On RHEL/CentOS ----
#
# cd /var/www/roundcubemail/plugins/managesieve/
# cp config.inc.php.dist config.inc.php

#
# ---- On Debian/Ubuntu ----
#
# cd /usr/share/apache2/roundcubemail/plugins/managesieve/
# cp config.inc.php.dist config.inc.php
```

* Configure plugin in `config.inc.php`:

```
# Part of file: roundcubemail/plugins/managesieve/config.inc.php

$rcmail_config['managesieve_port'] = 2000; 
$rcmail_config['managesieve_host'] = "127.0.0.1";
$rcmail_config['managesieve_usetls'] = false;
$rcmail_config['managesieve_default'] = "/var/vmail/sieve/dovecot.sieve";
```

* Make sure this plugin is enabled/listed in roundcube main config file: `roundcubemail/config/main.inc.php`.

```
# Part of file: roundcubemail/config/main.inc.php

$rcmail_config['plugins'] = array("password", "managesieve",);
```

### Upgrade phpMyAdmin to 2.11.10

phpMyAdmin doesn't require additional config, you can simply download new version
and copy old config file into new version.

* Download new version and uncompress it:
```
# cd /root/
# wget http://iredmail.org/yum/misc/phpMyAdmin-2.11.10-all-languages.tar.bz2
# tar xjf phpMyAdmin-2.11.10-all-languages.tar.bz2
```

* Copy it to apache server root directory, remove old symbol link and create a
  new one, copy old config file into new version:

```
#
# ---- On RHEL/CentOS ----
#
# cp -rf /root/phpMyAdmin-2.11.10-all-languages /var/www/
# cd /var/www/
# rm -i phpmyadmin
# ln -s phpMyAdmin-2.11.10-all-languages phpmyadmin
# cp phpMyAdmin-OLD-VERSION/config.inc.php phpmyadmin/

#
# ---- On Debian/Ubuntu ----
#
# cp -rf /root/phpMyAdmin-2.11.10-all-languages /usr/share/apache2/
# cd /usr/share/apache2/
# rm -i phpmyadmin
# ln -s phpMyAdmin-2.11.10-all-languages phpmyadmin
# cp phpMyAdmin-OLD-VERSION/config.inc.php phpmyadmin/
```

* It's recommended to restart apache web server:
```
#
# ---- On RHEL/CentOS ----
#
# /etc/init.d/httpd restart

#
# ---- On Debian/Ubuntu ----
#
# /etc/init.d/apache2 restart
```

## OpenLDAP backend only

### Use newest schema file

NOTE: New LDAP schema provides several new attributes, but it's backwards
compatibility, it's __SAFE__ to replace the old one without additional operations.

To use the newest iRedMail ldap schem file, we have to:
* Download the newest iRedMail ldap schema file
* Copy old ldap schema file as a backup copy
* Replace the old one
* Restart OpenLDAP service.

Here we go:

* On RHEL/CentOS:
```
# cd /tmp
# wget http://iredmail.googlecode.com/hg/tags/0.6.0/samples/iredmail.schema

# cd /etc/openldap/schema/
# cp iredmail.schema iredmail.schema.bak

# mv -i /tmp/iredmail.schema /etc/openldap/schema/
# /etc/init.d/ldap restart
```

* On Debian/Ubuntu:
```
# cd /tmp
# wget http://iredmail.googlecode.com/hg/tags/0.6.0/samples/iredmail.schema

# cd /etc/ldap/schema/
# cp iredmail.schema iredmail.schema.bak

# mv -i /tmp/iredmail.schema /etc/ldap/schema/
# /etc/init.d/slapd restart
```

### Include Amavisd LDAP schema file in OpenLDAP

We're starting to provide better Amavisd integration in iRedMail, e.g.
per-user blacklist/whitelist, anti-spam and anti-virus settings.

Since Amavisd can read per-user settings which stored in LDAP, we have to
include Amavisd LDAP schema file in OpenLDAP.

NOTE: Amavisd LDAP schema file is installed in OpenLDAP schema directory during
installing Amavisd-new, so we don't need to copy/move it.

* On RHEL/CentOS, edit `/etc/openldap/slapd.conf` and append Amavisd schema
  file before `iredmail.schema`:

```
# Part of file: /etc/openldap/slapd.conf

# Integrate Amavisd-new.
include     /etc/openldap/schema/amavisd-new.schema
include     /etc/openldap/schema/iredmail.schema
```

Restart OpenLDAP service to make it work:
```
# /etc/init.d/ldap restart
```

* On Debian/Ubuntu, edit `/etc/ldap/slapd.conf` and append Amavisd schema file before `iredmail.schema`:

```
# part of file: /etc/ldap/slapd.conf

# Integrate Amavisd-new.
include     /etc/ldap/schema/amavis.schema
include     /etc/ldap/schema/iredmail.schema
```

Restart OpenLDAP service to make it work:
```
# /etc/init.d/slapd restart
```

### Index missed attributes 

We will search email address which stored in attribute `shadowAddress`, so make
sure you have `shadowAddress` indexed in OpenLDAP configure file like this:

```
# Part of file: slapd.conf

index shadowAddress eq,pres,sub
```

If `shadowAddress` already exists in `slapd.conf`, you don't need to do
additional operations. If you add them now, you have to initially index this
attribute manually now.

* Stop OpenLDAP service first.
```
#
# ---- On RHEL/CentOS ----
#
# /etc/init.d/ldap stop

#
# ---- On Debian/Ubuntu ----
#
# /etc/init.d/slapd stop
```

* Execute 'slapindex' to index all attributes:
```
#
# ---- On RHEL/CentOS ----
#
# slapindex -f /etc/openldap/slapd.conf

#
# ---- On Debian/Ubuntu ----
#
# slapindex -f /etc/ldap/slapd.conf
```

* Start OpenLDAP service now.
```
#
# ---- On RHEL/CentOS ----
#
# /etc/init.d/ldap start

#
# ---- On Debian/Ubuntu ----
#
# /etc/init.d/slapd start
```

### Add missing LDAP attribute/value

iRedMail-0.6.0 requires some more values of attribute `enabledService` and `objectClass`:

* enabledService=sieve
* enabledService=sievesecured
* enabledService=internal
* objectClass=amavisAccount

Both `enabledService=sieve` and `enabledService=sievesecured` are used in
Dovecot-1.2.x, for builtin managesieve service. `enabledService=internal` is
used for shared IMAP folder. `objectClass=amavisAccount` is used for
Amavisd-new integration, for example, per-user anti-spam settings, anti-virus
control.

Steps:

* Download python script used to adding missing values.
```
# cd /root/
# wget http://iredmail.googlecode.com/hg/extra/update/updateLDAPValues_051_to_060.py
```

* Open `updateLDAPValues_051_to_060.py`, config below parameters in file head:
```
# Part of file: updateLDAPValues_051_to_060.py

uri = 'ldap://127.0.0.1:389'
basedn = 'o=domains,dc=iredmail,dc=org'
bind_dn = 'cn=vmailadmin,dc=iredmail,dc=org'
bind_pw = 'passwd'
```

You can find required LDAP credential in iRedAdmin config file or `iRedMail.tips`
file under your iRedMail installation directory. Using either
`cn=Manager,dc=xx,dc=xx` or `cn=vmailadmin,dc=xx,dc=xx` as bind dn is ok.

* Execute this script, it will add missing values for mail accounts:
```
# python updateLDAPValues_051_to_060.py
```

### Add `shadowAddress` support for mail alias

* Update postfix mysql lookup file: `/etc/postfix/ldap_virtual_alias_maps.cf`:

```
# Part of file: /etc/postfix/ldap_virtual_alias_maps.cf

# OLD SETTING
query_filter = (&(mail=%s)(accountStatus=active)(enabledService=mail)(enabledService=deliver)(|(objectClass=mailList)(objectClass=mailAlias)(&(objectClass=mailUser)(enabledService=forward))))

# NEW SETTING.
# - Added: shadowAddress=%s
# - Removed: objectClass=mailList. It's impossible to add shadow address support for mail list.
query_filter = (&(|(mail=%s)(shadowAddress=%s))(accountStatus=active)(enabledService=mail)(enabledService=deliver)(|(objectClass=mailAlias)(&(objectClass=mailUser)(enabledService=forward))))
```

Note: We add `shadowAddress` support for mail alias here, and remove
`shadowAddress` support for mail list. Because mail list doesn't support this
feature.

### Add catch-all account support

NOTE: This is required by iRedAdmin-Pro-1.2.0.

* Change your postfix setting in `/etc/postfix/main.cf`:

```
# Part of file: /etc/postfix/main.cf

virtual_alias_maps =
    proxy:ldap:/etc/postfix/ldap_virtual_alias_maps.cf,
    proxy:ldap:/etc/postfix/ldap_virtual_group_maps.cf,
    proxy:ldap:/etc/postfix/ldap_sender_login_maps.cf,      # <-- Add this line.
    proxy:ldap:/etc/postfix/ldap_catch_all_maps.cf          # <-- Add this line.
```

* File `/etc/postfix/ldap_sender_login_maps.cf` already exists by default, so
  what you need to do is adding new file: `/etc/postfix/ldap_catch_all_maps.cf`.

```
# File: /etc/postfix/ldap_catch_all_maps.cf

#
# WARNING: Please REPLACE bind_dn, bind_pw, search_base below, you can find
#          them in /etc/postfix/ldap_*.cf.
#
server_host     = 127.0.0.1
server_port     = 389
version         = 3
bind            = yes
start_tls       = no
bind_dn         = cn=vmail,dc=iredmail,dc=org
bind_pw         = JnvF4UQheMdImdXYnRVEgKpsdCXJy3
search_base     = domainName=%d,o=domains,dc=iredmail,dc=org
scope           = sub
query_filter    = (&(objectClass=mailUser)(accountStatus=active)(mail=@%d))
result_attribute= mailForwardingAddress
debuglevel      = 0
```

* Restart postfix service to make it work.
```# /etc/init.d/postfix restart```

### Roundcube Webmail plugin: change password stored in OpenLDAP

Password plugin which officially shipped in Roundcubemail-0.3.1 requires php-pear and Net_LDAP2, so we have to:
* Generate a new config file and config necessary parameters.
* Force upgrade php-pear to support password plugin on RHEL/CentOS 5 (Not required on Debian/Ubuntu)
* Install php-mhash to provide hash algorithms such as MD5, SHA1, GOST, and many others. (Not required on Debian/Ubuntu)
* Install php pear package: Net_LDAP2.
* Restart Apache web service.

Steps:

* Generate a new config file:
```
#
# ---- On RHEL/CentOS ----
#
# cd /var/www/roundcubemail/plugins/password/
# cp config.inc.php.dist config.inc.php

#
# ---- On Debian/Ubuntu ----
#
# cd /usr/share/apache2/roundcubemail/plugins/password/
# cp config.inc.php.dist config.inc.php
```

* Config it:
```
# Part of file: roundcubemail/plugins/password/config.inc.php

$rcmail_config['password_driver'] = "ldap";
$rcmail_config['password_confirm_current'] = true;
$rcmail_config['password_minimum_length'] = 6;
$rcmail_config['password_require_nonalpha'] = false;

$rcmail_config['password_ldap_host'] = "127.0.0.1";
$rcmail_config['password_ldap_port'] = "389";
$rcmail_config['password_ldap_starttls'] = false;
$rcmail_config['password_ldap_version'] = "3";
$rcmail_config['password_ldap_basedn'] = "o=domains,dc=iredmail,dc=org";    # REPLACE THIS BY YOUR OWN BASE DN
$rcmail_config['password_ldap_method'] = "user";
$rcmail_config['password_ldap_adminDN'] = "null";
$rcmail_config['password_ldap_adminPW'] = "null";

#
# WARNING: REPLACE BASE DN BY YOUR OWN ONE
#
$rcmail_config['password_ldap_userDN_mask'] = "mail=%login,ou=Users,domainName=%domain,o=domains,dc=iredmail,dc=org";

$rcmail_config['password_ldap_encodage'] = "ssha";
$rcmail_config['password_ldap_pwattr'] = "userPassword";
$rcmail_config['password_ldap_force_replace'] = false;
```

* Upgrade php-pear and install pear package: Net_LDAP2.
```
#
# ---- On RHEL/CentOS ----
#
# pear upgrade --force pear
# pear install Net_LDAP2
# yum install php-mhash           # Please make sure you have iRedMail yum repository enabled.
# /etc/init.d/httpd restart       # Restart Apache web service.

#
# ---- On Debian/Ubuntu ----
#
# pear install Net_LDAP2
# /etc/init.d/apache2 restart       # Restart Apache web service.
```

### Upgrade phpLDAPadmin to 1.2.0.5

phpLDAPadmin doesn't require additional config, you can simply download new
version and copy sample config file to make it work.

* Download new version and uncompress it:
```
# cd /root/
# wget http://iredmail.org/yum/misc/phpldapadmin-1.2.0.5.tgz
# tar zxf phpldapadmin-1.2.0.5.tgz
```

* Copy it to apache server root directory, remove old symbol link and create
  a new one, copy old config file into new version:

```
#
# ---- On RHEL/CentOS ----
#
# cp -rf /root/phpldapadmin-1.2.0.5 /var/www/
# cd /var/www/
# rm -i phpldapadmin
# ln -s phpldapadmin-1.2.0.5 phpldapadmin
# cd phpldapadmin/config/
# cp config.php.example config.php

#
# ---- On Debian/Ubuntu ----
#
# cp -rf /root/phpldapadmin-1.2.0.5 /usr/share/apache2/
# cd /usr/share/apache2/
# rm -i phpldapadmin
# ln -s phpldapadmin-1.2.0.5 phpldapadmin
# cd phpldapadmin/config/
# cp config.php.example config.php
```

* Edit config file to hide template warning messages: `phpldapadmin/config/config.php`.
```
# Part of file: phpldapadmin/config/config.php

#
# Search 'hide_template_warning' in config file, uncomment below line, and change value to 'true'.
#
$config->custom->appearance['hide_template_warning'] = true;
```

* It's recommended to restart apache web server:
```
#
# ---- On RHEL/CentOS ----
#
# /etc/init.d/httpd restart

#
# ---- On Debian/Ubuntu ----
#
# /etc/init.d/apache2 restart
```

## MySQL backend only

### Add missing SQL columns in `vmail.mailbox`

iRedMail-0.6.0 adds a new SQL column in `vmail.mailbox` table: `enableinternal`.
This is used in Dovecot, e.g. shared IMAP folders, etc.

```
$ mysql -uroot -p
mysql> USE vmail;
mysql> ALTER TABLE mailbox ADD COLUMN enableinternal TINYINT(1) NOT NULL DEFAULT '1';
mysql> quit;
```

### Domain alias support

Note: You can use PostfixAdmin-2.3 to manage domain alias. iRedAdmin-Pro for
MySQL backend will support this feature later.

* Save below lines in temporary file: `/tmp/upgrade_iredmail.sql`:
```
CREATE TABLE IF NOT EXISTS `alias_domain` (
    `alias_domain` varchar(255) NOT NULL,
    `target_domain` varchar(255) NOT NULL,
    `created` datetime NOT NULL default '0000-00-00 00:00:00',
    `modified` datetime NOT NULL default '0000-00-00 00:00:00',
    `active` tinyint(1) NOT NULL default '1',
    PRIMARY KEY  (`alias_domain`),
    KEY `active` (`active`),
    KEY `target_domain` (`target_domain`)
) ENGINE=MyISAM;
```

* Import missing MySQL table in `vmail` database with above temporary file:
```
# mysql -uroot -p
mysql> USE vmail;
mysql> SOURCE /tmp/upgrade_iredmail.sql;
```

* Update postfix config in `/etc/postfix/main.cf`.

```
# Part of file: /etc/postfix/main.cf

# ---- OLD SETTING ----
virtual_alias_maps = proxy:mysql:/etc/postfix/mysql_virtual_alias_maps.cf

# ---- NEW SETTING ----
virtual_alias_maps =
    proxy:mysql:/etc/postfix/mysql_virtual_alias_maps.cf,
    proxy:mysql:/etc/postfix/mysql_domain_alias_maps.cf
```

* Add new file: `/etc/postfix/mysql_domain_alias_maps.cf`.
```
# File: /etc/postfix/mysql_domain_alias_maps.cf

#
# WARNING: REPLACE password below. You can find it in /etc/postfix/mysql_*.cf.
#
user        = vmail
password    = YOUR_MYSQL_BIND_PW
hosts       = localhost
port        = 3306
dbname      = vmail
query       = SELECT goto FROM alias,alias_domain WHERE alias_domain.alias_domain = '%d' and alias.address = CONCAT('%u', '@', alias_domain.target_domain) AND alias.active = 1 AND alias_domain.active='1'
```

### Roundcube Webmail plugin: change password

* Generate a new config file:
```
#
# ---- On RHEL/CentOS ----
#
# cd /var/www/roundcubemail/plugins/password/
# cp config.inc.php.dist config.inc.php

#
# ---- On Debian/Ubuntu ----
#
# cd /usr/share/apache2/roundcubemail/plugins/password/
# cp config.inc.php.dist config.inc.php
```

* Config it:

```
# Part of file: roundcubemail/plugins/password/config.inc.php

$rcmail_config['password_driver'] = "sql";
$rcmail_config['password_confirm_current'] = true;
$rcmail_config['password_minimum_length'] = 6;
$rcmail_config['password_require_nonalpha'] = false;

$rcmail_config['password_db_dsn'] = 'mysqli://roundcube:REPLACE_YOUR_PASSWORD_HERE@localhost/vmail';
$rcmail_config['password_query'] = 'UPDATE vmail.mailbox SET password=%c,modified=NOW() WHERE username=%u LIMIT 1';
$rcmail_config['password_hash_algorithm'] = 'md5crypt';
$rcmail_config['password_hash_base64'] = false;
```

### Upgrade PostfixAdmin to 2.3

To upgrade PostfixAdmin to 2.3, we should:

* Download and uncompress new version.
* Copy new version to apache server root directory.
* Copy config file from old version.
* Add new column in MySQL database.
* Restart apache web server. (Optional, but is recommended.)

Steps:

* Download and uncompress new version:
```
# cd /root/
# wget http://iredmail.org/yum/misc/postfixadmin_2.3.tar.gz
# tar zxf postfixadmin_2.3.tar.gz
```

* Copy new version to apache server root directory, create new symbol link and copy old config file:
```
#
# ---- On RHEL/CentOS ----
#
# cp -rf /root/postfixadmin-2.3 /var/www/
# cd /var/www/
# cp postfixadmin/config.local.php postfixadmin-2.3/
# rm -i postfixadmin
# ln -s postfixadmin-2.3 postfixadmin

#
# ---- On Debian/Ubuntu ----
#
# cp -rf /root/postfixadmin-2.3 /usr/share/apache2/
# cd /usr/share/apache2/
# cp postfixadmin/config.local.php postfixadmin-2.3/
# rm -i postfixadmin
# ln -s postfixadmin-2.3 postfixadmin
```

* Add one more parameter in `postfixadmin/config.local.php` to enable domain alias management:

```
# Part of file: postfixadmin/config.local.php

$CONF['alias_domain'] = 'YES';
```

* Add new column in MySQL database.
```
# mysql -uroot -p
mysql> USE vmail;
mysql> ALTER TABLE mailbox ADD local_part VARCHAR(255) NOT NULL DEFAULT '';
mysql> UPDATE mailbox SET local_part = substring_index(username, '@', 1);
```

* Restart apache web server.
```
#
# ---- On RHEL/CentOS ----
#
# /etc/init.d/httpd restart

#
# ---- On Debian/Ubuntu ----
#
# /etc/init.d/apache2 restart
```
