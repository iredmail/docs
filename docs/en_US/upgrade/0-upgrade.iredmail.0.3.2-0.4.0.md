# Upgrade iRedMail from 0.3.2 to 0.4.0

[TOC]

> We provide remote upgrade service, check [the price](../support.html) and [contact us](../contact.html).

## Fixed

* Fix error in root's cron job which used to punge expired mails. Thanks xcrossbow@gmail.

Execute command `crontab`:
```
# crontab -e -u root
```

Change `dovecot` to `/usr/sbin/dovecot` (absolute path):
```
1   5   *   *   *   /usr/sbin/dovecot --exec-mail ext /usr/libexec/dovecot/expire-tool
```

* Fix incorrect crontab job for vmail user. Thanks xcrossbow@gmail.
```
# crontab -e -u vmail

1   5   *   *   *   find /var/virusmails -ctime +30 | xargs rm -rf {}
```

* Replace incorrect parameter name `debug_level` by `debuglevel` in all
  LDAP query tables in Postfix.

```
# perl -pi -e 's#(.*)debug_level(.*)#${1}debuglevel${2}#' /etc/postfix/ldap_*
```

## Components Update and Migration
### Postfix

* Postfix was update to 2.5.6, please backup main config files before you
update it (we assume you backup them to /opt/backup/):

```
# cp -rfp /etc/postfix/ /opt/backup/
# yum update postfix
```

* Parameters changed (Restart postfix to make it work):

    * Set `maximal_queue_lifetime` and `bounce_queue_lifetime` to `1d`. Thanks muniao@gmail.
    * Reduce postfix queue run retry time to `300s`.
    * Disable the SMTP `VRFY` command. This stops some techniques used to harvest email addresses.

```
# postconf -e maximal_queue_lifetime='1d'
# postconf -e bounce_queue_lifetime='1d'

# postconf -e queue_run_delay='300s'
# postconf -e minimal_backoff_time='300s'
# postconf -e maximal_backoff_time='1800s'

# postconf -e disable_vrfy_command='yes'
```

* Reduce spam. Add one more pcre expression for smtpd helo restriction to
  block client which use dynamic ip address. Thanks muniao@gmail.

```
# Part of file: /etc/postfix/helo_access.pcre

/\d{1,3}-\d{1,3}-\d{1,3}-\d{1,3}/   REJECT Go away  (dynamic).
```

### OpenLDAP

In iRedMail 0.4.0+, LDAP schema was changed, several attributes were merged:

* enableMailService=yes -> enabledService=mail
* enableSMTP=yes -> enabledService=smtp
* enablePOP3=yes -> enabledService=pop3
* enableIMAP=yes -> enabledService=imap
* enableDELIVER=yes -> enabledService=deliver
* enableFTPService=yes -> enabledService: ftp. This attribute is not used yet.
* enableIMService=yes -> enabledService: im. This attribute is not used yet.

Step-by-Step migration tutorial:

* Dump/Export all virtual domains and users via `slapcat`:
```
# slapcat -b 'o=domains,dc=iredmail,dc=org' -a '(|(objectClass=mailUser)(objectClass=mailDomain))' > all.ldif
```

* Backup original copy:
```
# cp all.ldif all.ldif.orig
```

* Change attributes and values:
```
# perl -pi -e 's#enableMailService: yes#enabledService: mail#' all.ldif
# perl -pi -e 's#enableSMTP: yes#enabledService: smtp#' all.ldif
# perl -pi -e 's#enablePOP3: yes#enabledService: pop3#' all.ldif
# perl -pi -e 's#enableIMAP: yes#enabledService: imap#' all.ldif
# perl -pi -e 's#enableDELIVER: yes#enabledService: deliver#' all.ldif
# perl -pi -e 's#enableFTPService: yes#enabledService: ftp#' all.ldif
# perl -pi -e 's#enableIMService: yes#enabledService: im#' all.ldif
```

* Delete all entries:

```
# ldapsearch -x \
    -b 'o=domains,dc=iredmail,dc=org' \
    -s sub \
    -D 'cn=Manager,dc=iredmail,dc=org' \
    -W \
    "(|(objectClass=mailUser)(objectClass=mailDomain))" dn | \
    grep '^dn:' | awk '{print $2}' | grep -v '^domainName' | sort -r > dn.del.list

# ldapdelete -x -D 'cn=Manager,dc=iredmail,dc=org' -W -f dn.del.list
```

* Use schema file in iRedMail-0.4.0 (samples/iredmail.schema) to replace old file:
```
# cp -f iRedMail-0.4.0/samples/iredmail.schema /etc/openldap/schema/
```

* Restart ldap service:
```
# /etc/init.d/ldap restart
```

* Re-import LDIF data:
```
# ldapadd -x -D 'cn=Manager,dc=iredmail,dc=org' -W -f all.ldif
```    

* Change ldap search filter in all ldap enabled service:

    * Dovecot: /etc/dovecot-ldap.conf
```
user_filter     = (&(mail=%u)(objectClass=mailUser)(accountStatus=active)(enabledService=mail)(enabledService=%Ls))
```
    * Postfix:
        * /etc/postfix/ldap_virtual_mailbox_domains.cf
```
query_filter    = (&(objectClass=mailDomain)(domainName=%s)(domainStatus=active)(enabledService=mail))
```
        * /etc/postfix/ldap_sender_login_maps.cf
```
query_filter    = (&(mail=%s)(objectClass=mailUser)(accountStatus=active)(enabledService=mail)(enabledService=smtp))
```
        * /etc/postfix/ldap_accounts.cf
```
query_filter    = (&(objectClass=mailUser)(mail=%s)(accountStatus=active)(enabledService=mail))
```
        * /etc/postfix/ldap_virtual_mailbox_maps.cf
```
query_filter    = (&(objectClass=mailUser)(mail=%s)(accountStatus=active)(enabledService=mail)(enabledService=deliver))
```
        * /etc/postfix/ldap_sender_bcc_maps_user.cf
```
query_filter    = (&(mail=%s)(objectClass=mailUser)(accountStatus=active)(enabledService=mail))
```
        * /etc/postfix/ldap_sender_bcc_maps_domain.cf
```
query_filter    = (&(domainName=%d)(objectClass=mailDomain)(domainStatus=active)(enabledService=mail))
```
        * /etc/postfix/ldap_virtual_alias_maps.cf
```
query_filter    = (&(mail=%s)(objectClass=mailUser)(accountStatus=active)(enabledService=mail))
```
        * /etc/postfix/ldap_recipient_bcc_maps_user.cf
```
query_filter    = (&(mail=%s)(objectClass=mailUser)(accountStatus=active)(enabledService=mail))
```
        * /etc/postfix/ldap_recipient_bcc_maps_domain.cf
```
query_filter    = (&(domainName=%d)(objectClass=mailDomain)(domainStatus=active)(enabledService=mail))
```
        * /etc/postfix/ldap_recipient_bcc_maps_user.cf
```
query_filter    = (&(mail=%s)(objectClass=mailUser)(accountStatus=active)(enabledService=mail))
```
    * Roundcube global ldap address book: /var/www/roundcubemail-x.y.z/config/main.inc.php
```
    'filter'        => "(&(objectClass=mailUser)(accountStatus=active)(enabledService=mail)(enabledService=deliver))",
```
    * Change ldap password plugin in SquirrelMail: /var/www/squirrelmail-x.y.z/plugins/change_ldappass/config.php
```
$ldap_filter = "(&(objectClass=mailUser)(accountStatus=active)(enabledService=mail))";
```

### Apache

* Add Directory container to disable autoindex feature in webmail directory.
* Make web-based admin consoles access via https only.

    * File: /etc/httpd/conf.d/horde.conf
```
# Add '-Indexes' after 'FollowSymLinks'.
<Directory /var/www/html/horde>
    Options +FollowSymLinks -Indexes
```

    * File: /etc/httpd/conf.d/phpldapadmin.conf
```
# Comment below lines, make it can't access via http://.
#Alias /phpldapadmin "/var/www/phpldapadmin-1.1.0.6/"
#Alias /ldap "/var/www/phpldapadmin-1.1.0.6/"

# Add below lines.
<Directory "/var/www/phpldapadmin-1.1.0.6/">
    Options -Indexes
</Directory>
```
    * File: /etc/httpd/conf.d/phpmyadmin.conf
```
# Comment below lines, make it can't access via http://.
#Alias /phpmyadmin "/var/www/phpMyAdmin-2.11.9.4-all-languages/"

# Add below lines.
<Directory "/var/www/phpMyAdmin-2.11.9.4-all-languages/">
    Options -Indexes
</Directory>
```
    * File: /etc/httpd/conf.d/postfixadmin.conf
```
# Comment below lines, make it can't access via http://.
#Alias /postfixadmin "/var/www/postfixadmin-2.2.1.1/"
```
    * File: /etc/httpd/conf.d/roundcubemail.conf
```
# Add below lines.
<Directory "/var/www/roundcubemail-0.2-stable/">
    Options -Indexes
</Directory>
```
    * File: /etc/httpd/conf.d/roundcubemail.conf
```
# Add below lines.
<Directory "/var/www/squirrelmail-1.4.17/">
    Options -Indexes
</Directory>
```
    * File: /etc/httpd/conf.d/ssl.conf
```
# Add below lines before '</VirtualHost>' mark, make all web-based
# programs can access via https://.

Alias /squirrelmail /var/www/squirrelmail-1.4.17/
Alias /squirrel /var/www/squirrelmail-1.4.17/
Alias /mail /var/www/roundcubemail-0.2-stable/
Alias /webmail /var/www/roundcubemail-0.2-stable/
Alias /roundcube /var/www/roundcubemail-0.2-stable/
Alias /phpldapadmin /var/www/phpldapadmin-1.1.0.6/
Alias /ldap /var/www/phpldapadmin-1.1.0.6/
Alias /phpmyadmin /var/www/phpMyAdmin-2.11.9.4-all-languages/
```

### Update phpLDAPadmin to 1.1.0.6.

* Backup old version (we assume you backup it to /opt/backup/).
```
# cp -rfp /var/www/phpldapadmin-1.1.0.5/ /opt/backup/
```

* Extract new version to /var/www/:
```
# tar zxf phpldapadmin-1.1.0.6.tar.gz -C /var/www/
```

* Set file permission:
```
# chown -R root:root /var/www/phpldapadmin-1.1.0.6/
# chmod -R 0755 /var/www/phpldapadmin-1.1.0.6/
```

* Update /etc/httpd/conf.d/ssl.conf, replace the version number:
```
Alias /phpldapadmin "/var/www/phpldapadmin-1.1.0.6/"
Alias /ldap "/var/www/phpldapadmin-1.1.0.6/"
```
* Restart Apache:
```
# /etc/init.d/httpd restart
```
