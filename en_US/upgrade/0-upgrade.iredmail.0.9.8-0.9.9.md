# Upgrade iRedMail from 0.9.8 to 0.9.9

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

* Dec 23, 2018, Fixed: Improper new dovecot ldap/sql queries which doesn't convert upper cases of maildir to lower cases.
* Dec 21, 2018, Fixed: SOGo backup script doesn't set correct permission on backup files.
* Dec 21, 2018, mention how to upgrade netdata.
* Dec 20, 2018, fix hard-coded mailbox folder name in `dovecot-mysql.conf`.
* Dec 19, 2018, add section for upgrading mlmmjadmin.
* Dec 17, 2018, initial release.

## General (All backends should apply these changes)

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

### Upgrade iRedAdmin (open source edition) to the latest stable release (0.9.3)

!!! attention

    In this release, iRedAdmin (and iRedAdmin-Pro) is running as a standalone
    service named "iredadmin", each time you modified its config file, please
    restart the service ("iredadmin").

Please follow this tutorial to upgrade iRedAdmin open source edition to the
latest stable release:
[Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html)

### Upgrade mlmmjadmin to the latest stable release (1.9)

Please follow below tutorial to upgrade mlmmjadmin to the latest stable release:
[Upgrade mlmmjadmin to the latest stable release](./upgrade.mlmmjadmin.html)

### Upgrade Roundcube webmail to the latest stable release (1.3.8)

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

### Upgrade netdata to the latest stable release (1.11.1)

If you have netdata installed, you can upgrade it by following this tutorial: [Upgrade netdata](./upgrade.netdata.html).

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
location ~ ^/mail/(bin|config|installer|logs|SQL|temp|vendor)($|/.*) { deny all; }
location ~ ^/mail/(CHANGELOG|composer.json|INSTALL|jsdeps.json|LICENSE|README|UPGRADING)($|.*) { deny all; }
location ~ ^/mail/plugins/.*/config.inc.php.* { deny all; }
location ~ ^/mail/plugins/enigma/home($|/.*) { deny all; }
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

### Improve mlmmj script used for appending footer text

Run commands below to create file `/usr/bin/mlmmj-amime-receive` (Linux) or
`/usr/local/bin/mlmmj-amime-receive` (FreeBSD/OpenBSD):

On Linux:

```
cd /usr/bin/
rm -f mlmmj-amime-receive
wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/mlmmj/mlmmj-amime-receive
chown mlmmj:mlmmj mlmmj-amime-receive
chmod 0550 mlmmj-amime-receive
```

On FreeBSD or OpenBSD:

```
cd /usr/local/bin/
rm -f mlmmj-amime-receive
wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/mlmmj/mlmmj-amime-receive
chown mlmmj:mlmmj mlmmj-amime-receive
chmod 0550 mlmmj-amime-receive
```

### Fix address mapping issue for mlmmj mailing list

With default settings of iRedMail-0.9.8, if you use a per-user alias address
as member of a mailing list, Postfix doesn't not expand it to the final
recipient. For more details of this bug, please check this 
[forum post](https://forum.iredmail.org/topic14841-mlmmj-subscription-emails-missing.html).
Please follow steps below to fix it.

* Open Amavisd config file, find the policy bank named `MLMMJ` like below:
    * on RHEL/CentOS, it's `/etc/amavisd/amavisd.conf`
    * on Debian/Ubuntu, it's `/etc/amavis/conf.d/50-user`
    * on FreeBSD, it's `/usr/local/etc/amavisd.conf`
    * on OpenBSD, it's `/etc/amavisd.conf`

```
$policy_bank{'MLMMJ'} = {
    ...
};
```

Add a new line inside the {} block:

```
$policy_bank{'MLMMJ'} = {
    ...
    forward_method => 'smtp:[127.0.0.1]:10028',
};
```

Here we use a new smtp port 10028.

* Append new lines to file `/etc/postfix/master.cf` (Linux/OpenBSD) or
  `/usr/local/etc/postfix/master.cf` (FreeBSD):

```
127.0.0.1:10028 inet n  -   n   -   -  smtpd
    -o syslog_name=postfix/10028
    -o content_filter=
    -o mynetworks_style=host
    -o mynetworks=127.0.0.1
    -o local_recipient_maps=
    -o relay_recipient_maps=
    -o strict_rfc821_envelopes=yes
    -o smtp_tls_security_level=none
    -o smtpd_tls_security_level=none
    -o smtpd_restriction_classes=
    -o smtpd_delay_reject=no
    -o smtpd_client_restrictions=permit_mynetworks,reject
    -o smtpd_helo_restrictions=
    -o smtpd_sender_restrictions=
    -o smtpd_recipient_restrictions=permit_mynetworks,reject
    -o smtpd_end_of_data_restrictions=
    -o smtpd_error_sleep_time=0
    -o smtpd_soft_error_limit=1001
    -o smtpd_hard_error_limit=1000
    -o smtpd_client_connection_count_limit=0
    -o smtpd_client_connection_rate_limit=0
    -o receive_override_options=no_header_body_checks,no_unknown_recipient_checks
```

It's very similar to existing transport '10025', but without option `no_address_mappings`.
Port 10025 is used __BEFORE__ content filter, but 10028 is used __AFTER__
content filter.

* Restart both postfix and amavisd services.

### Fixed: SOGo backup script doesn't set correct permission on backup files

SOGo backup script `/var/vmail/backup/backup_sogo.sh` shipped in iRedMail-0.9.8
and earlier releases doesn't set correct permission on backup files, please
download the latest version and override the one on your system:

!!! attention

    Script `backup_sogo.sh` uses `/var/vmail/backup` to store backup files by
    default, if you use a different directory, please edit this file and modify
    parameter `BACKUP_ROOTDIR=` to use the correct one.

```
cd /var/vmail/backup/
rm -f backup_sogo.sh
wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/tools/backup_sogo.sh
chown root backup_sogo.sh
chmod 0400 backup_sogo.sh
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
user_attrs      = mail=master_user,mail=user,=home=%L{ldap:homeDirectory},=mail=%{ldap:mailboxFormat:maildir}:~/%{ldap:mailboxFolder:Maildir}/,mailQuota=quota_rule=*:bytes=%$
```

If attribute `mailboxFormat` doesn't present in user object, Dovecot will use
string `maildir` as default value.

For more details about changing mailbox format, please check our tutorial:
[Change mailbox format](./change.mailbox.format.html).

Restarting Dovecot service is required.

### [OPTIONAL] Monitoring OpenLDAP with netdata

netdata-1.11.1 (released on 23 Nov 2018) supports monitoring OpenLDAP through its `monitor` backend.
Please follow this tutorial to upgrade netdata and configure both OpenLDAP and netdata for monitoring.

* On Linux:
    * [Upgrade netdata](./integration.netdata.linux.html#update-netdata)
    * [Monitor OpenLDAP](./integration.netdata.linux.html#monitor-openldap)
* On FreeBSD:
    * Please update netdata with ports tree first, make sure you're running
      netdata-1.11.1 or later release.?
    * [Monitor OpenLDAP](./integration.netdata.freebsd.html#monitor-openldap)

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
`/usr/local/etc/dovecot/dovecot-mysql.conf` (FreeBSD), find the `user_query =`
line like below:

```
user_query = SELECT \
            ...
            CONCAT(mailbox.storagebasedirectory, '/', mailbox.storagenode, '/', mailbox.maildir) AS home, \
            ...
```

Update above line and also add a new `CONCAT` line after it:

```
user_query = SELECT \
            ...
            LOWER(CONCAT(mailbox.storagebasedirectory, '/', mailbox.storagenode, '/', mailbox.maildir)) AS home, \
            CONCAT(mailbox.mailboxformat, ':~/', mailbox.mailboxfolder, '/') AS mail, \
            ...
```

Restarting Dovecot service is required.

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
cd /tmp/
wget https://bitbucket.org/zhb/iredmail/raw/default/extra/update/0.9.9/iredmail.pgsql
```

* Run shell commands as root user below to connect to PostgreSQL server:

```
# su - postgres
$ psql -d vmail
sql> \i /tmp/iredmail.pgsql
```

### Dovecot: read mailbox format from SQL

Please open file `/etc/dovecot/dovecot-pgsql.conf` (Linux/OpenBSD) or
`/usr/local/etc/dovecot/dovecot-pgsql.conf` (FreeBSD), then

#### PostgreSQL 8.x

If you're running __PostgreSQL 8.x__, you can find the `user_query =` line like
below:

```
user_query = SELECT \
    mailbox.storagebasedirectory || '/' || mailbox.storagenode || '/' || mailbox.maildir AS home, \
    ...
```

Update above line and also add a new `CONCAT` line after it:

```
user_query = SELECT \
    LOWER(mailbox.storagebasedirectory || '/' || mailbox.storagenode || '/' || mailbox.maildir) AS home, \
    LOWER(mailbox.mailboxformat || ':~/' || mailbox.mailboxfolder || '/') AS mail, \
    ...
```

Restart Dovecot service is required.

For more details about changing mailbox format, please check our tutorial:
[Change mailbox format](./change.mailbox.format.html).

#### PostgreSQL 9.x and later releases

If you're running __PostgreSQL 9.x__ and later releases, you can find the
`user_query =` line like below:

```
user_query = SELECT \
            ...
            CONCAT(mailbox.storagebasedirectory, '/', mailbox.storagenode, '/', mailbox.maildir) AS home, \
            ...
```

Update above line and also add a new `CONCAT` line after it:

```
user_query = SELECT \
            ...
            LOWER(CONCAT(mailbox.storagebasedirectory, '/', mailbox.storagenode, '/', mailbox.maildir)) AS home, \
            CONCAT(mailbox.mailboxformat, ':~/', mailbox.mailboxfolder, '/') AS mail, \
            ...
```

Restart Dovecot service is required.

For more details about changing mailbox format, please check our tutorial:
[Change mailbox format](./change.mailbox.format.html).
