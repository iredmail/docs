# Upgrade iRedMail from 0.4.0 to 0.5.0

[TOC]

> We provide remote upgrade service, check [the price](../support.html) and [contact us](../contact.html).

__NOTE__: Horde webmail was removed. Users want to migrate to Roundcube webmail
please go to our [online support forum](http://www.iredmail.org/forum/) for help.

## Issues Fixed & Notify


### LDAP backend only: Remove unnecessary ldap lookup in postfix (2009.07.26):

Remove `ldap_virtual_mailbox_maps.cf` in Postfix `virtual_mailbox_maps`.

```
# OLD setting
#virtual_mailbox_maps = ldap:/etc/postfix/ldap_accounts.cf, ldap:/etc/postfix/ldap_virtual_mailbox_maps.cf

# NEW setting
virtual_mailbox_maps = ldap:/etc/postfix/ldap_accounts.cf
```

### Fixed: incorrect file permission on sa-update cron job

```
# chmod 0644 /etc/cron.d/sa-update
```

### Fixed: different timezone in log file

Copy `/etc/localtime` to `/var/spool/postfix/etc/` solves this issue:
```
# cp /etc/localtime /var/spool/postfix/etc/
```

Reference: [Confusing timestamp in /var/log/secure (UTC time instead of localtime)](https://bugzilla.redhat.com/show_bug.cgi?id=193184)


### OpenLDAP backend only: Use the latest iRedMail LDAP schema file

#### `userPassword` and `accountStatus` are optional for objectclass `mailAdmin` (2008.03.25).

Please use the newest schema file to replace the old one:

* Backup old schema file (we assume you backup it to /opt/backup/ directory):
```
# cp /etc/openldap/schema/iredmail.schema /opt/backup/
```

* Use new version to replace the old one:

```
# cd /tmp/
# wget http://iredmail.googlecode.com/svn/trunk/iRedMail/samples/iredmail.schema
# rm -f /etc/openldap/schema/iredmail.schema
# mv /tmp/iredmail.schema /etc/openldap/schema/
# /etc/init.d/ldap restart
```

#### attribute `domainStatus` is deprecated.

* Add new attribute `accountStatus` for each mail domain with phpLDAPadmin or other LDAP admin tool.
* Change below files to use `accountStatus` instead.

    * /etc/postfix/ldap_virtual_mailbox_domains.cf
    * /etc/postfix/ldap_relay_domains.cf
    * /etc/postfix/ldap_transport_maps.cf
    * /etc/postfix/ldap_recipient_bcc_maps_domain.cf
    * /etc/postfix/ldap_sender_bcc_maps_domain.cf

* Send mail to exist mail user and make sure `accountStatus` works for you.
* Delete attribute `domainStatus` in each domain.

### Fixed incorrect OpenLDAP ACL (2009.03.23)

Edit `/etc/openldap/slapd.conf`, add several lines like below:

```
#
# Allow users to access their own domain subtree.
#
access to dn.regex="domainName=([^,]+),o=domains,dc=iredmail,dc=org$"
    by anonymous                    auth
    by self                         write
    by dn.exact="cn=vmail,dc=iredmail,dc=org"   read
    by dn.exact="cn=vmailadmin,dc=iredmail,dc=org"  write
    by dn.regex="mail=[^,]+,ou=Users,domainName=$1,o=domains,dc=iredmail,dc=org$" read
    by dn.regex="mail=[^,]+@$1,o=domainAdmins,dc=iredmail,dc=org$" read     # <-- Add this line.
    by users                        none

#
# Enable vmail/vmailadmin. 
#
access to dn.subtree="o=domains,dc=iredmail,dc=org"
    by anonymous                    auth
    by self                         write
    by dn.exact="cn=vmail,dc=iredmail,dc=org"   read
    by dn.exact="cn=vmailadmin,dc=iredmail,dc=org"  write
    by dn.regex="mail=[^,]+,domainName=$1,o=domains,dc=iredmail,dc=org$" read
    by users                        read

########################################################
################# Add below lines ######################
########################################################
access to dn.subtree="o=domainAdmins,dc=iredmail,dc=org"
    by anonymous                    auth
    by self                         write
    by dn.exact="cn=vmail,dc=iredmail,dc=org"  read
    by dn.exact="cn=vmailadmin,dc=iredmail,dc=org"  write
    by users                        none
```

### Fixed incorrect pysieved config file ownership. 2009.03.18

```
# chown vmail:vmail /etc/pysieved.ini
# /etc/init.d/pysieved restart
```

## Improvements and Updates
### Apache

* Add `/var/www/html/robots.txt` file to disallow search engines. Content:

```
User-agent: *
Disallow: /mail
Disallow: /webmail
Disallow: /roundcube
Disallow: /phpldapadmin
Disallow: /ldap
Disallow: /mysql
Disallow: /phpmyadmin
Disallow: /awstats
```

### PHP

* Set disable_functions in `/etc/php.ini`. Thanks david(at)knapp(dot)org.

```
disable_functions = show_source, system, shell_exec, passthru, exec, phpinfo, proc_open
```

### MySQL backend special

* Add column to set mail storage base directory. Warning: Please replace
  `/home/vmail` below to fit your environment.

```
# mysql -uroot -p vmail
mysql> ALTER TABLE mailbox ADD COLUMN storagebasedirectory VARCHAR(255) DEFAULT '/home/vmail';
```

* Alter `vmail.enablesieve` to vmail.enablemanagesieve:

```
# mysql -uroot -p vmail
mysql> ALTER TABLE mailbox CHANGE COLUMN enablesieve enablemanagesieve TINYINT(1);
```

* Due to this change, you have to add one more parameter in `/etc/pysieved.ini`:

```
[Dovecot]
service = managesieve
```

* Add new columns in `vmail.mailbox` table:

```
# mysql -uroot -p vmail
mysql> ALTER TABLE mailbox ADD COLUMN employeeid VARCHAR(255) DEFAULT NULL;
mysql> ALTER TABLE mailbox ADD COLUMN lastlogindate DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00';
mysql> ALTER TABLE mailbox ADD COLUMN lastloginprotocol CHAR(255) NOT NULL DEFAULT '';
```

### OpenLDAP backend special

* Add one `enabledService=forward` in mail forwarding address lookup:
  `/etc/postfix/ldap_virtual_alias_maps.cf`.

```
query_filter    = (&(mail=%s)(objectClass=mailUser)(accountStatus=active)(enabledService=mail)(enabledService=forward))
```

* Index more LDAP attributes in `/etc/openldap/slapd.conf`:

```
index domainAdmin,domainGlobalAdmin,domainBackupMX    eq,pres
index listAllowedUser,accessPolicy eq,pres
index memberOfGroup eq,pres
```

After added above line, please stop openldap and run `slapindex` in database directory:

```
# /etc/init.d/ldap stop
# cd /var/lib/ldap/iredmail.org/
# slapindex
# chown ldap:ldap *
# /etc/init.d/ldap start
```    

### Postfix

* LDAP backend only: Mail group/list implemented of LDAP is changed.

    * objectClass `mailUser` has a new attribute: `memberOfGroup`, used to store
      group name (a valid email address).
    * Mail group lookup maps in postfix must be changed too. modify your `/etc/postfix/main.cf`:

```
virtual_alias_maps =
    ldap:/etc/postfix/ldap_virtual_alias_maps.cf,
    ldap:/etc/postfix/ldap_virtual_group_maps.cf    # Add this lookup file.
```

Create /etc/postfix/ldap_virtual_group_maps.cf:

```
server_host     = 127.0.0.1
server_port     = 389
version         = 3
bind            = yes
start_tls       = no
bind_dn         = cn=vmail,dc=iredmail,dc=org
bind_pw         = KrxIkebDaRWb81yHdetBPt0UXC6NVZ
search_base     = domainName=%d,o=domains,dc=iredmail,dc=org
scope           = sub
query_filter    = (&(memberOfGroup=%s)(objectClass=mailUser)(accountStatus=active)(enabledService=mail)(enabledService=deliver))
result_attribute= mail
debuglevel      = 0
```

Remove `(objectClass=mailList)` in query_filter line in `/etc/postfix/ldap_virtual_alias_maps.cf`:

```
#query_filter    = (&(mail=%s)(accountStatus=active)(enabledService=mail)(enabledService=deliver)(|(objectClass=mailList)(objectClass=mailAlias)(&(objectClass=mailUser)(enabledService=forward))))
query_filter    = (&(mail=%s)(accountStatus=active)(enabledService=mail)(enabledService=deliver)(|(objectClass=mailAlias)(&(objectClass=mailUser)(enabledService=forward))))
```

* LDAP backend only: Add bcc control in bcc lookup. Warning: Do __NOT__ forget
  to add `enabledService=senderbcc` and `enabledService=recipientbcc` for all
  domains/users allowed bcc feature.

File: `/etc/postfix/ldap_sender_bcc_maps_domain.cf`.
```
query_filter    = (&(domainName=%d)(objectClass=mailDomain)(domainStatus=active)(enabledService=mail)(enabledService=senderbcc))
```

File: `/etc/postfix/ldap_recipient_bcc_maps_domain.cf`.
```
query_filter    = (&(domainName=%d)(objectClass=mailDomain)(domainStatus=active)(enabledService=mail)(enabledService=recipientbcc))
```

File: `/etc/postfix/ldap_sender_bcc_maps_user.cf`.

```
query_filter    = (&(mail=%s)(objectClass=mailUser)(accountStatus=active)(enabledService=mail)(enabledService=senderbcc))
```

File: `/etc/postfix/ldap_recipient_bcc_maps_user.cf`.

```
query_filter    = (&(mail=%s)(objectClass=mailUser)(accountStatus=active)(enabledService=mail)(enabledService=recipientbcc))
```

* Add backup mx control in domain lookup file:

    * For MySQL backend: /etc/postfix/mysql_virtual_mailbox_domains.cf
```
query       = SELECT domain FROM domain WHERE domain='%s' AND backupmx='0' AND active='1' AND expired >= NOW()
```

    * For OpenLDAP backend: /etc/postfix/ldap_virtual_mailbox_domains.cf
```
query_filter    = (&(objectClass=mailDomain)(domainName=%s)(!(domainBackupMX=yes))(domainStatus=active)(enabledService=mail))
```

    * LDAP backend only: Add group mail and alias support for openldap backend, you have to change virtual alias lookup file: /etc/postfix/ldap_virtual_alias_maps.cf.
```
search_base     = domainName=%d,o=domains,dc=iredmail,dc=org
scope           = sub
query_filter    = (&(mail=%s)(accountStatus=active)(enabledService=mail)(enabledService=deliver)(|(objectClass=mailList)(objectClass=mailAlias)(&(objectClass=mailUser)(enabledService=forward))))
result_attribute= mailForwardingAddress
```

### Dovecot

* mail_location setting changed in file: /etc/dovecot.conf.

```
mail_location = maildir:/%Lh/:INDEX=/%Lh/
```

and dovecot-mysql.conf (if you use MySQL as backend) should be changed too:
```
user_query = SELECT CONCAT(storagebasedirectory, '/', maildir) AS home, \
```

and dovecot-ldap.conf (if you use OpenLDAP as backend) should be changed too:
```
user_attrs      = =sieve_dir=/home/vmail/sieve/%Ld/%Ln/,storageBaseDirectory=home,mailMessageStore=mail=maildir:~/%$/Maildir/,mailQuota=quota_rule=*:bytes=%$
```

### Roundcube webmail

* Change global ldap address book filter in /var/www/roundcubemail-x.y.z/config/main.inc.php. It will search mail user/group/alias for you while typing mail address in recipient field.

```
    'filter'        => "(&(accountStatus=active)(enabledService=mail)(enabledService=deliver)(|(&(objectClass=mailList)(hasMember=yes))(objectClass=mailAlias)(objectClass=mailUser)))", // Search mail users, lists, aliases.
```

* New settings in /var/www/roundcubemail-x.y.z/config/main.inc.php:

* log_driver syslog
* syslog_id roundcube
syslog_facility LOG_MAIL
mime_param_folding 1
identities_level 3
quota_zero_as_unlimited TRUE

* LDAP backend only: Replace 'gn' by 'givenName' in global LDAP address book. (2009.03.15)
```
# File: /var/www/roundcubemail-x.y.z-stable/config/main.inc.php

    'search_fields' => array('mail', 'cn', 'givenName', 'sn'),  // fields to search in
    'firstname_field' => 'givenName',  // this field represents the contact's first name
```

### Disclaimer

iRedMail-0.5.0 supports automatically adding a disclaimer to all outgoing
emails with Amavisd-new + alterMIME.

* Install altermime from iRedMail yum repository:

    * For i386:
```
# yum install altermime.i386
```

    * For x86_64:
```
# yum install altermime.x86_64
```

* Create directory to store disclaimer files if not exist:
```
# mkdir -p /etc/postfix/disclaimer/
```

* In /etc/amavisd.conf, add `allow_disclaimers` in `$policy_bank{'MYNET'}`:
```
$policy_bank{'MYNETS'} = {   # mail originating from @mynetworks
  [ ... skip other settings here ...]
  allow_disclaimers => 1,  # enables disclaimer insertion if available
};
```

* Add disclaimer settings before the last line:
```
# ------------ Disclaimer Setting ---------------
$altermime = '/usr/bin/altermime';
$defang_maps_by_ccat{+CC_CATCHALL} = [ 'disclaimer' ];
 
# Disclaimer in plain text formart.
@altermime_args_disclaimer = qw(--disclaimer=/etc/postfix/disclaimer/_OPTION_.txt);

@disclaimer_options_bysender_maps = ({
    # Per-domain disclaimer setting: /etc/postfix/disclaimer/host1.iredmail.org.txt
    #'host1.iredmail.org' => 'host1.iredmail.org',

    # Sub-domain disclaimer setting: /etc/postfix/disclaimer/iredmail.org.txt
    #'.iredmail.org'      => 'iredmail.org',

    # Per-user disclaimer setting: /etc/postfix/disclaimer/boss.iredmail.org.txt
    #'boss@iredmail.org'  => 'boss.iredmail.org',

    # Catch-all disclaimer setting: /etc/postfix/disclaimer/default.txt
    '.' => 'default',
},);
# ------------ End Disclaimer Setting ---------------
```

* Create an testing disclaimer file:
```
# echo 'Testing disclaimer.' > /etc/postfix/disclaimer/default.txt
```

* Restart amavisd and send mail from your webmail or Outlook/Thunderbird:
```
# /etc/init.d/amavisd restart
```
