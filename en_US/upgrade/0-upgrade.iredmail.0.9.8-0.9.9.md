# Upgrade iRedMail from 0.9.8 to 0.9.9

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

## General (All backends should apply these steps)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
0.9.9
```

### Upgrade iRedAPD (Postfix policy server) to the latest stable release (2.3)

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

### Upgrade iRedAdmin (open source edition) to the latest stable release (1.0)

Please follow this tutorial to upgrade iRedAdmin open source edition to the
latest stable release:
[Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html)

### Upgrade Roundcube webmail to the latest stable release (1.3.6)

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

Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release immediately:

* [How to upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).

### Fix incorrect file owner/group of mlmmjadmin config file

Please run commands below to fix incorrect file owner/group and permission:

```
chown mlmmj:mlmmj /opt/mlmmjadmin/settings.py
chmod 0400 /opt/mlmmjadmin/settings.py
```

### Fix improper Nginx config files for Roundcube

Accurate Nginx url match helps avoid namespace conflicts, we need some fixes
for Roundcube to get accurate url match.

Please open file `/etc/nginx/templates/roundcube.tmpl`, find `location`
directives like below:

```
location ~ /mail/(bin|config|installer|logs|SQL|temp|vendor)($|/.*) { deny all; }
location ~ /mail/(CHANGELOG|composer.json|INSTALL|jsdeps.json|LICENSE|README|UPGRADING)($|.*) { deny all; }
location ~ /mail/plugins/.*/config.inc.php.* { deny all; }
location ~ /mail/plugins/enigma/home($|/.*) { deny all; }
```

Add a `^` symbol before url path, this will exactly match the url begins
with the path.

```
+location ~ ^/mail/(bin|config|installer|logs|SQL|temp|vendor)($|/.*) { deny all; }
+location ~ ^/mail/(CHANGELOG|composer.json|INSTALL|jsdeps.json|LICENSE|README|UPGRADING)($|.*) { deny all; }
+location ~ ^/mail/plugins/.*/config.inc.php.* { deny all; }
+location ~ ^/mail/plugins/enigma/home($|/.*) { deny all; }
```

Open file `/etc/nginx/templates/roundcube-subdomain.tmpl`, find `location`
directives like below:


```
location ~ /(bin|config|installer|logs|SQL|temp|vendor)($|/.*) { deny all; }
location ~ /(CHANGELOG|composer.json|INSTALL|jsdeps.json|LICENSE|README|UPGRADING)($|.*) { deny all; }
location ~ /plugins/.*/config.inc.php.* { deny all; }
location ~ /plugins/enigma/home($|/.*) { deny all; }
```

Add `^` symbol like below:

```
location ~ ^/(bin|config|installer|logs|SQL|temp|vendor)/.* { deny all; }
location ~ ^/(CHANGELOG|composer.json|INSTALL|jsdeps.json|LICENSE|README|UPGRADING)$ { deny all; }
location ~ ^/plugins/.*/config.inc.php.* { deny all; }
location ~ ^/plugins/enigma/home($|/.*) { deny all; }
```

## OpenLDAP special

### Update iRedMail LDAP schema file

iRedMail-0.9.9 introduces 2 new LDAP attributes for mail user account:

* `mailboxFormat`: used to store mailbox format. All formats supported by
  Dovecot are ok. for example, `maildir`, `mdbox`. For more details, please
  check Dovecot document here: <https://wiki2.dovecot.org/MailboxFormat>
* `mailboxFolder`: used to store the folder name which will be appended to
  maildir path. Defaults to `Maildir`.

With these 2 new attributes, it will be very easy to switch different mailbox
format.

!!! warning

    If you use different mailbox format, you need to set mailbox format to the
    one you're using.

Download the latest iRedMail LDAP schema file

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

### Dovecot: read mailbox format from LDAP

Please open file `/etc/dovecot/dovecot-ldap.conf` (Linux/OpenBSD) or
`/usr/local/etc/dovecot/dovecot-ldap.conf` (FreeBSD), find the `user_attrs =`
line like below:

```
user_attrs      = mail=master_user,mail=user,homeDirectory=home,=mail=maildir:~/Maildir/,mailQuota=quota_rule=*:bytes=%$
```

Please replace it by below one:

```
user_attrs      = mail=master_user,mail=user,homeDirectory=home,=mail=%{ldap:mailboxFormat:maildir}:~/%{ldap:mailboxFolder:Maildir}/,mailQuota=quota_rule=*:bytes=%$
```

If attribute `mailboxFormat` doesn't present in user object, Dovecot will use
string `maildir` as default value.

For more details about changing mailbox format, please check our tutorial:
[Change mailbox format](./change.mailbox.format.html).

## MySQL/MariaDB special

### SQL structure changes in `vmail` database

We've made some changes to `vmail` database:

* New SQL column `mailbox.mailboxformat`: used to store mailbox format.
  All formats supported by Dovecot are ok. for example, `maildir`, `mdbox`.
  __Default value is `maildir`.__
  For more details, please check Dovecot document here:
  <https://wiki2.dovecot.org/MailboxFormat>
* `mailboxfolder`: used to store the folder name which will be appended to
  maildir path. Defaults to `Maildir`.

With these 2 new columns, it will be very easy to migrate existing mailbox to
different mailbox format, or set different mailbox for new user.


!!! warning

    If you use different mailbox format, you need to set mailbox format to the
    one you're using.

Download SQL template file and import it:

```
cd /root/
wget https://bitbucket.org/zhb/iredmail/raw/default/extra/update/0.9.9/iredmail.mysql
mysql vmail < /root/iredmail.mysql
```

### Dovecot: read mailbox format from SQL

Please open file `/etc/dovecot/dovecot-mysql.conf` (Linux/OpenBSD) or
`/usr/local/etc/dovecot/dovecot-mysql.conf` (FreeBSD), find the `user_attrs =`
line like below:

```
user_query = SELECT \
            ...
            CONCAT(mailbox.storagebasedirectory, '/', mailbox.storagenode, '/', mailbox.maildir) AS home, \
            ...
```

Add a new `CONCAT` line after above `CONCAT()` line:

```
user_query = SELECT \
            ...
            CONCAT(mailbox.storagebasedirectory, '/', mailbox.storagenode, '/', mailbox.maildir) AS home, \
            CONCAT(mailbox.mailboxformat, ':', mailbox.storagebasedirectory, '/', mailbox.storagenode, '/', mailbox.maildir, '/Maildir') AS mail, \
            ...
```

For more details about changing mailbox format, please check our tutorial:
[Change mailbox format](./change.mailbox.format.html).

## PostgreSQL special

### SQL structure changes in `vmail` database

We've made some changes to `vmail` database:

* New SQL column `mailbox.mailboxformat`: used to store mailbox format.
  All formats supported by Dovecot are ok. for example, `maildir`, `mdbox`.
  __Default value is `maildir`.__
  For more details, please check Dovecot document here:
  <https://wiki2.dovecot.org/MailboxFormat>
* `mailboxfolder`: used to store the folder name which will be appended to
  maildir path. Defaults to `Maildir`.

With these 2 new columns, it will be very easy to migrate existing mailbox to
different mailbox format, or set different mailbox for new user.

!!! warning

    If you use different mailbox format, you need to set mailbox format to the
    one you're using.

Download SQL template file used to update SQL database:

```
cd /root/
wget https://bitbucket.org/zhb/iredmail/raw/default/extra/update/0.9.9/iredmail.mysql
```

* Run shell commands as root user below to connect to PostgreSQL server:

```
# su - postgres
$ psql -d vmail
sql> \i /tmp/mysql.pgsql
```

### Dovecot: read mailbox format from SQL

Please open file `/etc/dovecot/dovecot-pgsql.conf` (Linux/OpenBSD) or
`/usr/local/etc/dovecot/dovecot-pgsql.conf` (FreeBSD), then

#### PostgreSQL 8.x

If you're running __PostgreSQL 8.x__, you can find the `user_attrs =` line like
below:

```
user_query = SELECT \
    mailbox.storagebasedirectory || '/' || mailbox.storagenode || '/' || mailbox.maildir AS home, \
    ...
```

Please Add a line after above line:

```
user_query = SELECT \
    mailbox.storagebasedirectory || '/' || mailbox.storagenode || '/' || mailbox.maildir AS home, \
    mailbox.mailboxformat || ':' || mailbox.storagebasedirectory || '/' || mailbox.storagenode || '/' || mailbox.maildir || '/' || mailbox.mailboxfolder || '/' AS mail, \
    ...
```

Restart Dovecot service is required.

For more details about changing mailbox format, please check our tutorial:
[Change mailbox format](./change.mailbox.format.html).

#### PostgreSQL 9.x and later releases

If you're running __PostgreSQL 9.x__ and later releases, you can find the
`user_attrs =` line like below:

```
user_query = SELECT \
            ...
            CONCAT(mailbox.storagebasedirectory, '/', mailbox.storagenode, '/', mailbox.maildir) AS home, \
            ...
```

Add a new `CONCAT` line after above `CONCAT()` line:

```
user_query = SELECT \
            ...
            CONCAT(mailbox.storagebasedirectory, '/', mailbox.storagenode, '/', mailbox.maildir) AS home, \
            CONCAT(mailbox.mailboxformat, ':', mailbox.storagebasedirectory, '/', mailbox.storagenode, '/', mailbox.maildir, '/', mailbox.mailboxfolder, '/') AS mail, \
            ...
```

Restart Dovecot service is required.

For more details about changing mailbox format, please check our tutorial:
[Change mailbox format](./change.mailbox.format.html).
