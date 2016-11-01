# Upgrade iRedMail from 0.9.5-1 to 0.9.6

[TOC]

!!! warning

    This tutorial is still a __DRAFT__, do not apply it.

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](../support.html) and [contact us](../contact.html).

## TODO

* Update memcached config file to listen on 127.0.0.1.
* Separated SOGo address book for LDAP backend.

## ChangeLog

* Nov  1, 2016: Fixed: invalid default (datetime) value for some SQL columns in 'vmail' database.
* Oct 21, 2016: Fixed: [ldap] mail accounts (user, alias, list) are still active when domain is disabled.
* Sep  8, 2016: Fixed: HTTProxy vulnerability in Apache and Nginx.
* Jul  2, 2016: Fixed: SOGo-3.1.3 (and later releases) changed argument used by `sogo-tool` command.
* Jun 10, 2016: Fixed: Nginx doesn't forward real client IP address to SOGo.
* Jun  8, 2016: Set correct file owner for config file of Roundcube password plugin.
* Jun  8, 2016: Fixed: one incorrect HELO restriction rule in Postfix.
* May 27, 2016: Fixed: not enable opportunistic TLS support in Postfix.
* May 24, 2016: Initial __DRAFT__.

## General (All backends should apply these steps)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
0.9.6
```

### Upgrade iRedAPD (Postfix policy server) to the latest stable release (1.9.2)

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

Detailed release notes are available [here](./iredapd.releases.html).

### Upgrade iRedAdmin (open source edition) to the latest stable release (0.6.3)

Please follow this tutorial to upgrade iRedAdmin open source edition to the
latest stable release:
[Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html)

### Upgrade Roundcube webmail to the latest stable release (1.2.0)

Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release immediately: [How to upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).

Note: package `rsync` must be installed on your server before upgrading.

### Fixed: HTTProxy vulnerability in Apache and Nginx

For more details about HTTPROXY vulnerability, please read this website: <https://httpoxy.org/>

#### Apache

Please append setting below in Apache config file:

* on RHEL/CentOS, it's `/etc/httpd/conf/httpd.conf`.
* on Debian/Ubuntu, it's `/etc/apache2/apache2.conf`.
* on FreeBSD, it's `/usr/local/etc/apache2[X]/httpd.conf`. Please replace
  `apache2[X]` by the real Apache version number here.
* on OpenBSD: not applicable because iRedMail doesn't use Apache on OpenBSD.

```
RequestHeader unset Proxy early
```

Restarting Apache service is required.

#### Nginx

Please open all files under below directories which contains `fastcgi_pass`
parameter:

* On Linux/OpenBSD:
    * `/etc/nginx/templates/`
    * `/etc/nginx/conf.d/`
* On FreeBSD:
    * `/usr/local/etc/nginx/templates`
    * `/usr/local/etc/nginx/conf.d/`

If config file contains `fastcgi_pass` parameter, please append below one after
it:

```
fastcgi_param HTTP_PROXY '';
```

Restart Nginx service is required.

### Fixed: not enable opportunistic TLS support in Postfix

iRedMail-0.9.5 and iRedMail-0.9.5-1 didn't enable opportunistic TLS support in
Postfix, this causes other servers cannot transfer emails via TLS secure
connection. Please fix it with commands below.

```
postconf -e smtpd_tls_security_level='may'
postfix reload
```

### Fixed: one incorrect HELO restriction rule in Postfix

There's one incorrect HELO restriction rule file `helo_access.pcre`

* on Linux/OpenBSD, it's `/etc/postfix/helo_access.pcre`
* on FreeBSD, it's `/usr/local/etc/postfix/helo_access.pcre`

It will match HELO identity like `[192.168.1.1]` which is legal.
```
/(\d{1,3}[\.-]\d{1,3}[\.-]\d{1,3}[\.-]\d{1,3})/ REJECT ACCESS DENIED. Your email was rejected because the sending mail server appears to be on a dynamic IP address that should not be doing direct mail delivery (${1})
```

Please replace it by the correct one below (it matches the IP address with
`/^IP$/` strictly):
```
/^(\d{1,3}[\.-]\d{1,3}[\.-]\d{1,3}[\.-]\d{1,3})$/ REJECT ACCESS DENIED. Your email was rejected because the sending mail server appears to be on a dynamic IP address that should not be doing direct mail delivery (${1})
```

### Fixed: incorrect file owner and permission of config file of Roundcube password plugin

iRedMail-0.9.5-1 and earlier versions didn't correct set file owner and
permission of config file of Roundcube password plugin, other system users may
be able to see the SQL/LDAP username and password in the config file. Please
follow steps below to fix it.

* On RHEL/CentOS:

<h5>For Apache server:</h5>
```
chown apache:apache /var/www/roundcubemail/plugins/password/config.inc.php
chmod 0400 /var/www/roundcubemail/plugins/password/config.inc.php
```
<h5>For Nginx:</h5>
```
chown nginx:nginx /var/www/roundcubemail/plugins/password/config.inc.php
chmod 0400 /var/www/roundcubemail/plugins/password/config.inc.php
```

* On Debian/Ubuntu (Note: with old iRedMail release, Roundcube directory is
  `/usr/share/apache2/roundcubemail`):
```
chown www-data:www-data /opt/www/roundcubemail/plugins/password/config.inc.php
chmod 0400 /opt/www/roundcubemail/plugins/password/config.inc.php
```

* On FreeBSD:
```
chown www:www /usr/local/www/roundcubemail/plugins/password/config.inc.php
chmod 0400 /usr/local/www/roundcubemail/plugins/password/config.inc.php
```

* On FreeBSD:
```
chown www:www /var/www/roundcubemail/plugins/password/config.inc.php
chmod 0400 /var/www/roundcubemail/plugins/password/config.inc.php
```

### Fixed: Nginx doesn't forward real client IP address to SOGo

iRedMail-0.9.5-1 and earlier releases didn't correctly configure Nginx to
forward real client IP address to SOGo, this causes Fail2ban cannot catch
bad clients with failed authentication while logging to SOGo. Please try
steps below to fix it.

* Open file `/etc/nginx/templates/sogo.tmpl` (on Linux or OpenBSD) or
  `/usr/local/etc/nginx/templates/sogo.tmpl` (on FreeBSD), find 3 lines like
  below:

```
    #proxy_set_header X-Real-IP $remote_addr;
    #proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    #proxy_set_header Host $host;
```

* Remove the leading `#` to uncomment them:

```
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $host;
```

* Restart Nginx service.

### Fixed: SOGo-3.1.3 (and later releases) changed argument used by `sogo-tool` command

SOGo-3.1.3 (and late releases) changed `sogo-tool` argument `expire-autoreply`
to `update-autoreply`, and it's used in a daily cron job. Please update SOGo
cron job to fix it.

* Edit SOGo deamon user's cron job with command.
    * On Linux: ```crontab -e -u sogo```
    * On FreeBSD: ```crontab -e -u sogod```
    * On OpenBSD: ```crontab -e -u _sogo```

* Replace the argument `expire-autoreply` by `update-autoreply`.

## OpenLDAP backend special

### Fixed: mail accounts (user, alias, list) are still active when domain is disabled

> This fix is applicable to OpenBSD ldapd backend also.

In iRedMail-0.9.5-1 and all earlier releases, if we disable a mail domain,
all mail accounts (mail users, aliases, lists) are still active and Postfix
will accept emails sent to them. Steps below fix the issue.

#### Update OpenLDAP config file to index new attribute name: `domainStatus`

* Please open OpenLDAP config file `slapd.conf`, find line below:
    * On RHEL/CentOS, it's `/etc/openldap/slapd.conf`
    * On Debian/Ubuntu, it's `/etc/ldap/slapd.conf`
    * On FreeBSD, it's `/usr/local/etc/openldap/slapd.conf`
    * On OpenBSD, it's `/etc/openldap/slapd.conf`. If you're running ldapd as
      LDAP server, please add a new line `index domainStats` in the `namespace
      xxx {}` block.

```
access to attrs="employeeNumber,mail,..."
```

* Add new attribute name `domainStatus` in this line (__WARNING__: don't leave
  any whitespace between attribute names and comma):

```
access to attrs="domainStatus,employeeNumber,mail,..."
```

#### Use the latest iRedMail LDAP schema file

* On RHEL/CentOS:

```
cd /tmp
wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/iredmail/iredmail.schema

cd /etc/openldap/schema/
cp iredmail.schema iredmail.schema.bak

cp -f /tmp/iredmail.schema /etc/openldap/schema/
service slapd restart
```

* On Debian/Ubuntu:
```
cd /tmp
wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/iredmail/iredmail.schema

cd /etc/ldap/schema/
cp iredmail.schema iredmail.schema.bak

cp -f /tmp/iredmail.schema /etc/ldap/schema/
service slapd restart
```

* On FreeBSD:

```
cd /tmp
wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/iredmail/iredmail.schema

cd /usr/local/etc/openldap/schema/
cp iredmail.schema iredmail.schema.bak

cp -f /tmp/iredmail.schema /usr/local/etc/openldap/schema/
service slapd restart
```

* On OpenBSD:

    > Note: if you're running ldapd as LDAP server, the schema directory is
    > `/etc/ldap`, and service name is `ldapd`.

```
cd /tmp
ftp https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/iredmail/iredmail.schema

cd /etc/openldap/schema/
cp iredmail.schema iredmail.schema.bak

cp -f /tmp/iredmail.schema /etc/openldap/schema/
rcctl restart slapd
```

#### Update Postfix/Dovecot LDAP lookup files

* On Linux and OpenBSD, run commands:

```
cp -rf /etc/postfix/ldap /etc/postfix/ldap.$(date +%Y%m%d)
cd /etc/postfix/ldap/
perl -pi -e 's#\(accountStatus=active\)#(accountStatus=active)(!(domainStatus=disabled))#g' catchall_maps.cf recipient_bcc_maps_user.cf sender_bcc_maps_user.cf sender_dependent_relayhost_maps_user.cf sender_login_maps.cf transport_maps_user.cf virtual_alias_maps.cf virtual_group_maps.cf virtual_group_members_maps.cf virtual_mailbox_maps.cf

cp /etc/dovecot/dovecot-ldap.conf /etc/dovecot/dovecot-ldap.conf.$(date +%Y%m%d)
perl -pi -e 's#\(accountStatus=active\)#(accountStatus=active)(!(domainStatus=disabled))#g' /etc/dovecot/dovecot-ldap.conf
```

* On FreeBSD, run commands:

```
cp -rf /usr/local/etc/postfix/ldap /usr/local/etc/postfix/ldap.$(date +%Y%m%d)
cd /usr/local/etc/postfix/ldap/
perl -pi -e 's#\(accountStatus=active\)#(accountStatus=active)(!(domainStatus=disabled))#g' catchall_maps.cf recipient_bcc_maps_user.cf sender_bcc_maps_user.cf sender_dependent_relayhost_maps_user.cf sender_login_maps.cf transport_maps_user.cf virtual_alias_maps.cf virtual_group_maps.cf virtual_group_members_maps.cf virtual_mailbox_maps.cf

cp /usr/local/etc/dovecot/dovecot-ldap.conf /usr/local/etc/dovecot/dovecot-ldap.conf.$(date +%Y%m%d)
perl -pi -e 's#\(accountStatus=active\)#(accountStatus=active)(!(domainStatus=disabled))#g' /usr/local/etc/dovecot/dovecot-ldap.conf
```

* Restart both Postfix and Dovecot services:
    * on Linux: `service postfix restart; service dovecot restart`
    * on FreeBSD: `service postfix restart; service dovecot restart`
    * on OpenBSD: `rcctl restart postfix; rcctl restart dovecot`

#### Add required LDAP attribute/value for existing mail accounts under disabled domains

* Download script to update existing mail accounts:

```
cd /root/
wget https://bitbucket.org/zhb/iredmail/raw/default/extra/update/updateLDAPValues_095_1_to_096.py
```

* Open downloaded file `updateLDAPValues_095_1_to_096.py`, set LDAP server
  related settings in this file. For example:

```
# Part of file: updateLDAPValues_095_1_to_096.py

uri = 'ldap://127.0.0.1:389'
basedn = 'o=domains,dc=example,dc=com'
bind_dn = 'cn=vmailadmin,dc=example,dc=com'
bind_pw = 'passwd'
```

You can find required LDAP credential in iRedAdmin config file or
`iRedMail.tips` file under your iRedMail installation directory. Using either
`cn=Manager,dc=xx,dc=xx` or `cn=vmailadmin,dc=xx,dc=xx` as bind dn is ok, both
of them have read-write privilege to update mail accounts.

* Execute this script, it will add required data:

```
# python updateLDAPValues_095_1_to_096.py
```

## MySQL/MariaDB backend special

### Fix invalid default (datetime) value for some SQL columns in 'vmail' database

If you're going to upgrade MySQL/MariaDB to MySQL 5.7, or already upgraded,
please run SQL commands below as SQL root user to fix invalid default value
for some SQL columns in `vmail` database.

```
USE vmail;

ALTER TABLE admin \
	MODIFY passwordlastchange DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01', \
	MODIFY created DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01', \
	MODIFY modified DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01';

ALTER TABLE alias \
	MODIFY created DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01', \
	MODIFY modified DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01';

ALTER TABLE alias_domain \
	MODIFY created DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01', \
	MODIFY modified DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01';

ALTER TABLE domain \
	MODIFY created DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01', \
	MODIFY modified DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01';

ALTER TABLE domain_admins \
	MODIFY created DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01', \
	MODIFY modified DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01';

ALTER TABLE mailbox \
	MODIFY lastlogindate DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01', \
	MODIFY passwordlastchange DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01', \
	MODIFY created DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01', \
	MODIFY modified DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01';

ALTER TABLE recipient_bcc_domain \
	MODIFY created DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01', \
	MODIFY modified DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01';

ALTER TABLE recipient_bcc_user \
	MODIFY created DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01', \
	MODIFY modified DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01';

ALTER TABLE sender_bcc_domain \
	MODIFY created DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01', \
	MODIFY modified DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01';

ALTER TABLE sender_bcc_user \
	MODIFY created DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01', \
	MODIFY modified DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01';
```
