# Upgrade iRedMail from 0.7.2 to 0.7.3

[TOC]

## ChangeLog

> We provide remote upgrade service, check [the price](../support.html) and [contact us](../contact.html).

* 2011-08-23: Add upgrade tutorial or links for iRedAdmin (open source edition), phpMyAdmin, Roundcube.
* 2011-08-17: initial public.

## General (All backends should apply these upgrade steps)

* Please follow phpMyAdmin official tutorial to upgrade phpMyAdmin: http://www.phpmyadmin.net/documentation/#upgrading
* Please follow Roundcube official tutorial to upgrade Roundcube Webmail: http://trac.roundcube.net/wiki/Howto_Upgrade

## OpenLDAP backend special

### Add `enabledService=lda`, required by Dovecot 2.x.

__Note__: If you're running dovecot-1.1.x, or 1.2.x, then please stay on that
version, but it's still recommended to add this missing value for existing
users. It won't impact current mail services.

__Note__: Dovecot-2.x is the default version on RHEL/CentOS/Scieitnfic Linux 6.x.

Dovecot-2.x requires `enabledService=enablelda` for receiving email for virtual
mail users, so we should add it if users doesn't have it.

* Download python script used to adding missing values.

```
# cd /root/
# wget http://iredmail.googlecode.com/hg/extra/update/updateLDAPValues_072_to_073.py
```

* Open `updateLDAPValues_072_to_073.py`, config LDAP server related settings in file head. e.g.

```
# Part of file: updateLDAPValues_072_to_073.py

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
# python updateLDAPValues_072_to_073.py
```

## MySQL backend special

* Add new column: `mailbox.enablelda`, required by Dovecot 2.x, used to replace
  `mailbox.enabledeliver`.

```
$ mysql -uroot -p
mysql> USE vmail;
mysql> ALTER TABLE mailbox ADD COLUMN enablelda TINYINT(1) NOT NULL DEFAULT 1;
mysql> ALTER TABLE mailbox ADD INDEX enablelda (enablelda);
```
