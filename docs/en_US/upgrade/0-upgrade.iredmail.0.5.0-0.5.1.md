# Upgrade iRedMail from 0.5.0 to 0.5.1

[TOC]

## ChangeLog

> We provide remote upgrade service, check [the price](../support.html) and [contact us](../contact.html).

* 2009-11-03: Explain why we need extra SQL columns. Thanks Rashef@forum.
* 2009-11-03: Fix file name of LDAP schema. Thanks Bronkoo@twitter.
* 2009-11-02: Use python script to update LDAP data. ldapsearch will wrap long line, it breaks dn value. Thanks yangbajing@bbs for report this issue.
* 2009-11-02: Fix typo error. Thanks sdaniel@bbs.
* 2009-11-02: Add domain alias support.

## General (All backends should apply these steps)

### Apply hotfixes

* 2009-10-28: [Missing syslog setting. (Ubuntu 8.04 + LDAP backend only)](http://www.iredmail.org/forum/topic373-fixed-in-050-missed-syslog-setting-ubuntu-804-ldap-only.html)
* 2009-09-10: [Maill forwarding and bcc are invalid](http://www.iredmail.org/forum/topic236-fixed-in-050-maill-forwarding-and-bcc-are-invalid.html)
* 2009-08-21: [per-user mail filter setting](http://www.iredmail.org/forum/topic182-fixed-in-050-peruser-mail-filter-setting.html)

### Enable `proxymap` in SQL/LDAP query maps

Set `proxy_read_maps` in postfix, so that we can use `proxymap(8)` daemon which
is part of postfix to reduce the number of connections to MySQL/LDAP and
greatly reduces system load.

```
# postconf -e proxy_read_maps='$canonical_maps $lmtp_generic_maps $local_recipient_maps $mydestination $mynetworks $recipient_bcc_maps $recipient_canonical_maps $relay_domains $relay_recipient_maps $relocated_maps $sender_bcc_maps $sender_canonical_maps $smtp_generic_maps $smtpd_sender_login_maps $transport_maps $virtual_alias_domains $virtual_alias_maps $virtual_mailbox_domains $virtual_mailbox_maps'
```

### Add `@mynetworks` in `/etc/amavis/conf.d/50-user` (Debian/Ubuntu only)

```
# Part of file: /etc/amavis/conf.d/50-user

@mynetworks = qw( 127.0.0.0/8 [::1] [FE80::]/10 [FEC0::]/10
                10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 );
```

NOTE: They are trusted subnets (amavisd-new default setting), mail sent from
these subnets will be bypassed for anti-spam and anti-virus.

### Convert SQL columns from latin to utf8 in policyd database

Convert some columns of policyd database from latin to utf8, so that we can
add non-ascii characters in `description` column.

```
$ mysql -uroot -p policyd
mysql> ALTER TABLE blacklist MODIFY COLUMN _description CHAR(60) CHARACTER SET utf8;
mysql> ALTER TABLE blacklist_sender MODIFY COLUMN _description CHAR(60) CHARACTER SET utf8;
mysql> ALTER TABLE whitelist MODIFY COLUMN _description CHAR(60) CHARACTER SET utf8;
mysql> ALTER TABLE whitelist_dnsname MODIFY COLUMN _description CHAR(60) CHARACTER SET utf8;
mysql> ALTER TABLE whitelist_sender MODIFY COLUMN _description CHAR(60) CHARACTER SET utf8;
```

NOTE: Policyd database name is `policyd` (on RHEL/CentOS) or `postfixpolicyd`
(on Debian/Ubuntu).

## OpenLDAP backend only

### Replace old LDAP schema file with the new one shipped in iRedMail-0.5.1.

```
# --- BELOW ARE SHELL COMMANDS ----
# cd /etc/openldap/schema/      # Note: On Debian/Ubuntu, path is /etc/ldap/schema/
# cp iredmail.schema iredmail.schema.bak
# cd /root
# wget http://iredmail.googlecode.com/hg/tags/0.5.1/samples/iredmail.schema
# mv -i /root/iredmail.schema /etc/openldap/schema/
# /etc/init.d/ldap restart      # Note: On Debian/Ubuntu, path is /etc/init.d/slapd
```

NOTE: New LDAP schema provides several new attributes, but it's backwards
compatibility, it's __SAFE__ to replace the old one without additional operations.

### Use proxymap to improve performance and reliability under high load.

Prepend `proxy:` to the beginnning of all LDAP lookup table definitions in
postfix configuration file: `/etc/postfix/main.cf`. For example:

```
# Part of file: /etc/postfix/main.cf

# Old setting:
#virtual_alias_maps = ldap:/etc/postfix/ldap_virtual_alias_maps.cf

# New setting. Add 'proxy:'.
virtual_alias_maps = proxy:ldap:/etc/postfix/ldap_virtual_alias_maps.cf
```

### Restrict POP3S/IMAPS service in Dovecot

Update dovecot settings to restrict POP3S & IMAPS in `/etc/dovecot-ldap.conf`
(on RHEL/CentOS) or `/etc/dovecot/dovecot-ldap.conf` (on Debian/Ubuntu),
support domain alias and user shadow address.

```
# Part of file: dovecot-ldap.conf

# Old setting:
#base            = ou=Users,domainName=%d,o=domains,dc=iredmail,dc=org
#user_filter     = (&(mail=%u)(objectClass=mailUser)(accountStatus=active)(enabledService=mail)(enabledService=%Ls))
#pass_filter     = (mail=%u)

# New setting (user_filter is same as pass_filter):
base            = o=domains,dc=iredmail,dc=org
user_filter     = (&(objectClass=mailUser)(accountStatus=active)(enabledService=mail)(enabledService=%Ls%Lc)(|(mail=%u)(&(enabledService=shadowaddress)(shadowAddress=%u))))
pass_filter     = (&(objectClass=mailUser)(accountStatus=active)(enabledService=mail)(enabledService=%Ls%Lc)(|(mail=%u)(&(enabledService=shadowaddress)(shadowAddress=%u))))
```

Restarting Dovecot service is required.

### Enable POP3S/IMAPS services for all mail users

* Make sure you have python-ldap module installed.

```
# python
>>> import ldap
```

If it raises error message `ImportError: No module named ldap`, you have to
install python-ldap module first.

```
# easy_install python-ldap==2.3.8
```

* Download script tool to update LDAP values.

```
# wget http://iredmail.googlecode.com/hg/extra/update/updateLDAPValues_050_to_051.py
```

* Open downloaded file, set correct LDAP base dn, bind dn, and bind password.
  Example:

```
# Part of file: updateLDAPValues_050_to_051.py

uri = 'ldap://127.0.0.1:389'
basedn = 'o=domains,dc=iredmail,dc=org'
bind_dn = 'cn=Manager,dc=iredmail,dc=org'
bind_pw = 'passwd'
```

* Execute the script to update LDAP data

```
# python updateLDAPValues_050_to_051.py
```

### Add domain alias support

Add domain alias support in postfix ldap lookup table file: `/etc/postfix/ldap_virtual_mailbox_domains.cf`.

```
# Part of file: /etc/postfix/ldap_virtual_mailbox_domains.cf

# ---- Old setting ----
query_filter    = (&(objectClass=mailDomain)(domainName=%s)(!(domainBackupMX=yes))(accountStatus=active)(enabledService=mail))

# ---- New setting ----
query_filter    = (&(objectClass=mailDomain)(|(domainName=%s)(&(enabledService=domainalias)(domainAliasName=%s)))(!(domainBackupMX=yes))(accountStatus=active)(enabledService=mail))
```

### Add missing service control in Postfix LDAP lookup table

Add missing service control in postfix ldap lookup table file: `/etc/postfix/ldap_virtual_mailbox_maps.cf`:

```
# Part of file: /etc/postfix/ldap_virtual_mailbox_maps.cf

# OLD setting
#query_filter    = (&(objectClass=mailUser)(mail=%s)(accountStatus=active)(enabledService=mail))

# NEW setting
query_filter    = (&(objectClass=mailUser)(mail=%s)(accountStatus=active)(enabledService=mail)(enabledService=deliver))
```

### Add missing attributes in LDAP ACL and index control
Add `shadowAddress` and `employeeNumber` attribute names in
`/etc/openldap/slapd.conf` (RHEL/CentOS) or `/etc/ldap/slapd.conf`
(Debian/Ubuntu) for access control and index.

```
# Part of file: slapd.conf

# OLD setting
#access to attrs="homeDirectory,mailMessageStore,mail,..."

# NEW setting
access to attrs="shadowAddress,employeeNumber,homeDirectory,mailMessageStore,mail,..."


# OLD setting
#index homeDirectory,mailMessageStore,mailForwardingAddress   eq,pres

# NEW setting
index homeDirectory,mailMessageStore,mailForwardingAddress,shadowAddress,employeeNumber   eq,pres
```

## MySQL backend only

### Add new columns

Add columns used for service control: pop3s, imaps, managesieve:
```
# mysql -uroot -p vmail
mysql> ALTER TABLE mailbox ADD COLUMN enableimapsecured TINYINT(1) NOT NULL DEFAULT '1';
mysql> ALTER TABLE mailbox ADD COLUMN enablepop3secured TINYINT(1) NOT NULL DEFAULT '1';
mysql> ALTER TABLE mailbox ADD COLUMN enablemanagesievesecured TINYINT(1) NOT NULL DEFAULT '1';
```

Add columns used to store default user quota size, per-domain default password
length control. Will be used in iRedAdmin.

```
# mysql -uroot -p vmail
mysql> ALTER TABLE domain ADD COLUMN defaultuserquota BIGINT(20) NOT NULL DEFAULT '1024';
mysql> ALTER TABLE domain ADD COLUMN minpasswordlength INT(10) NOT NULL DEFAULT '0';
mysql> ALTER TABLE domain ADD COLUMN maxpasswordlength INT(10) NOT NULL DEFAULT '0';
```

### Use `proxymap` to improve performance and reliability under high load in Postfix

Prepend `proxy:` to the beginnning of all MySQL lookup table definitions in
postfix configuration file: `/etc/postfix/main.cf`. For example:

```
# Part of file: /etc/postfix/main.cf

# Old setting:
#virtual_alias_maps = mysql:/etc/postfix/mysql_virtual_alias_maps.cf

# New setting. Add 'proxy:'.
virtual_alias_domains = proxy:mysql:/etc/postfix/mysql_virtual_alias_maps.cf
```

### Restrict POP3S/IMAPS services in Dovecot

Update dovecot settings in `/etc/dovecot-mysql.conf` (RHEL/CentOS) or
`/etc/dovecot/dovecot-mysql.conf` (Debian/Ubuntu) to restrict POP3S/IMAPS
services.

```
# Part of file: dovecot-mysql.conf

# Old setting:
AND active='1' AND enable%Ls='1' AND expired >= NOW()

# New setting (Add '%Lc'):
AND active='1' AND enable%Ls%Lc='1' AND expired >= NOW()
```
