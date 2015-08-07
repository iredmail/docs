# Upgrade iRedMail from 0.6.1 to 0.7.0

[TOC]

> We provide remote upgrade service, check [the price](../support.html) and [contact us](../contact.html).

## General (All backends should apply these steps)

* [Upgrade Dovecot 1.1.x to 1.2.x](./upgrade.dovecot.1.1.to.1.2.html)
* [Quarantining SPAM into MySQL with Amavisd](./quarantining.html)

### Update postfix setting `proxy_read_maps`

Execute below command as root user, it's used to append
`$smtpd_sender_restrictions` in setting postfix `proxy_read_maps` setting.

```
# postconf -e proxy_read_maps='$canonical_maps $lmtp_generic_maps $local_recipient_maps $mydestination $mynetworks $recipient_bcc_maps $recipient_canonical_maps $relay_domains $relay_recipient_maps $relocated_maps $sender_bcc_maps $sender_canonical_maps $smtp_generic_maps $smtpd_sender_login_maps $transport_maps $virtual_alias_domains $virtual_alias_maps $virtual_mailbox_domains $virtual_mailbox_maps $smtpd_sender_restrictions'
```

## OpenLDAP backend only

### Support alias domain in mail list/alias

* Edit `/etc/postfix/ldap_virtual_group_maps.cf`, remove `domainName=%d` in `search_base`:

```
# Part of file: /etc/postfix/ldap_virtual_group_maps.cf

# OLD SETTING
search_base     = domainName=%d,o=domains,dc=XXX

# NEW SETTING
search_base     = o=domains,dc=XXX
```

* Edit `/etc/postfix/ldap_catch_all_maps.cf`, update `query_filter` to:

```
# Part of file: /etc/postfix/ldap_catch_all_maps.cf

# NEW SETTING
query_filter     = (&(objectClass=mailUser)(accountStatus=active)(|(mail=@%d)(shadowAddress=@%d)))
```

### Support IMAP share folder in LDAP

Dovecot IMAP share folder doesn't work with default LDAP query, so we need to
change it.

* Edit `/etc/dovecot-ldap.conf` (RHEL/CentOS) or `/etc/dovecot/dovecot-ldap.conf`
  (Debian/Ubuntu/openSUSE) or `/usr/local/etc/dovecot-ldap.conf` (FreeBSD), set
  `user_attrs =` to below value:

```
# Part of file: dovecot-ldap.conf

# OLD setting
#user_attrs      = storageBaseDirectory=home,mailMessageStore=mail=maildir:~/%$/Maildir/,mailQuota=quota_rule=*:bytes=%$

# NEW setting
user_attrs      = homeDirectory=home,mailMessageStore=mail=maildir:/var/vmail/%$/Maildir/,mailQuota=quota_rule=*:bytes=%$
```

What we changed:

    * Replace `storageBaseDirectory=home` with `homeDirectory=home`.
    * Replace `mailMessageStore=mail=maildir:~/%$/Maildir/` with
      `mailMessageStore=mail=maildir:/var/vmail/%$/Maildir/`, with hard-coded
      `/var/vmail` instead of using `~` to replace `home` query. `/var/vmail`
      is value of postfix setting `virtual_mailbox_base`, you can get it with
      command `postconf virtual_mailbox_base`. Please make sure you have the
      correct one.

### Save date of password last change in Roundcube

Roundcube won't save date of password last change by default, please change
setting of its plugin `"password"` to make it work.

* Edit config file `/var/www/roundcubemail/plugins/password/config.inc.php`
  (RHEL/CentOS) or `/usr/share/apache2/roundcubemail/plugins/password/config.inc.php`
  (Debian/Ubuntu) or `/srv/www/roundcubemail/plugins/password/config.inc.php`
  (openSUSE) or `/usr/local/www/roundcubemail/plugins/password/config.inc.php`
  (FreeBSD), find setting `password_ldap_lchattr` and set its value to
  `shadowLastChange`:

```
# Part of file: roundcubemail/plugins/password/config.inc.php

$rcmail_config['password_ldap_lchattr'] = 'shadowLastChange';
```

Roundcube will now save date of password last change in attribute `shadowLastChange`.

### Add missing value for mail users

iRedMail-0.7.0 requires `enabledService=smtpsecured` for sending mail via SMTP
over SSL in Postfix. so we should add it if users doesn't have it.

* Download python script used to adding missing values.
```
# cd /root/
# wget http://iredmail.googlecode.com/hg/extra/update/updateLDAPValues_061_to_070.py
```

* Open `updateLDAPValues_061_to_070.py`, config below parameters in file head:

```
# Part of file: updateLDAPValues_061_to_070.py

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
# python updateLDAPValues_061_to_070.py
```

## MySQL backend only

### Improve backup mx support

* Edit `/etc/postfix/mysql_domain_alias_maps.cf`, change `query =` to below new setting:

```
# Part of file: /etc/postfix/mysql_domain_alias_maps.cf

query       = SELECT alias.goto FROM alias,alias_domain,domain WHERE alias_domain.alias_domain='%d' AND alias.address=CONCAT('%u', '@',     alias_domain.target_domain) AND alias_domain.target_domain=domain.domain AND alias.active=1 AND alias_domain.active=1 AND domain.backupmx=0
```

### Check domain status in postfix and dovecot

* Edit postfix config file `/etc/postfix/mysql_virtual_mailbox_maps.cf`, change
  `query =` to below new setting:

```
# Part of file: mysql_virtual_mailbox_maps.cf

query       = SELECT CONCAT(mailbox.storagenode, '/', mailbox.maildir) FROM mailbox,domain WHERE mailbox.username='%s' AND mailbox.active='1' AND mailbox.enabledeliver='1' AND domain.domain = mailbox.domain AND domain.active='1'
```

__WARNING__: If you don't have column `storagenode` present in table
`vmail.mailbox`, please add it with below SQL command:
```
$ mysql -uroot -p
mysql> USE vmail;
mysql> ALTER TABLE mailbox ADD COLUMN storagenode VARCHAR(255) NOT NULL DEFAULT '';
```

* Edit postfix config file `/etc/postfix/mysql_virtual_alias_maps.cf`, change
  `query =` to below new setting:

```
# Part of file: mysql_virtual_alias_maps.cf

query       = SELECT alias.goto FROM alias,domain WHERE alias.address='%s' AND alias.domain='%d' AND alias.domain=domain.domain AND alias.active=1 AND domain.backupmx=0 AND domain.active=1
```

* Edit postfix config file `/etc/postfix/mysql_transport_maps_user.cf`, change
  `query =` to below new setting:

```
# Part of file: mysql_transport_maps_user.cf

query       = SELECT mailbox.transport FROM mailbox,domain WHERE mailbox.username='%s' AND mailbox.domain='%d' AND mailbox.domain=domain.domain AND mailbox.active=1 AND mailbox.enabledeliver=1 AND domain.backupmx=0 AND domain.active=1 AND mailbox.transport<>''
```

* Edit postfix config file `/etc/postfix/mysql_sender_login_maps.cf`, change
  `query =` to below new setting:

```
# Part of file: mysql_sender_login_maps.cf

query       = SELECT mailbox.username FROM mailbox,domain WHERE mailbox.username='%s' AND mailbox.domain='%d' AND mailbox.domain=domain.domain AND mailbox.enablesmtp=1 AND mailbox.active=1 AND domain.backupmx=0 AND domain.active=1
```

* Edit postfix config file `/etc/postfix/mysql_recipient_bcc_maps_user.cf`,
  change `query =` to below new setting:

```
# Part of file: mysql_recipient_bcc_maps_user.cf

query       = SELECT recipient_bcc_user.bcc_address FROM recipient_bcc_user,domain WHERE recipient_bcc_user.username='%s' AND recipient_bcc_user.domain='%d' AND recipient_bcc_user.domain=domain.domain AND domain.backupmx=0 AND domain.active=1 AND recipient_bcc_user.active=1
```

* Edit postfix config file `mysql_sender_bcc_maps_user.cf`, change `query =` to
  below new setting:

```
# Part of file: mysql_sender_bcc_maps_user.cf

query       = SELECT sender_bcc_user.bcc_address FROM sender_bcc_user,domain WHERE sender_bcc_user.username='%s' AND sender_bcc_user.domain='%d' AND sender_bcc_user.domain=domain.domain AND domain.backupmx=0 AND domain.active=1 AND sender_bcc_user.active=1
```

* Edit dovecot config file `/etc/dovecot-mysql.conf` (RHEL/CentOS) or
  `/etc/dovecot/dovecot-mysql.conf` (Debian/Ubuntu/openSUSE) or
  `/usr/local/etc/dovecot-mysql.conf` (FreeBSD):

```
# Part of file: dovecot-mysql.conf

user_query = SELECT CONCAT(mailbox.storagebasedirectory, '/', mailbox.storagenode, '/', mailbox.maildir) AS home, CONCAT('*:bytes=', mailbox.quota*1048576) AS quota_rule FROM mailbox,domain WHERE mailbox.username='%u' AND mailbox.domain='%d' AND mailbox.enable%Ls%Lc=1 AND mailbox.domain=domain.domain AND mailbox.active=1 AND domain.backupmx=0 AND domain.active=1
```

It will now check domain status, so if this domain is disabled, all users and
aliases will be disabled too.

Restart postfix and dovecot services to make it work.

### Make catch-all account work as expected

To make catch-all account work as expected, we need two more SQL lookup files:

    * `/etc/postfix/catchall_maps.cf`: Catch-all support for exist domains.
    * /etc/postfix/domain_alias_catchall_maps.cf: Catch-all support for alias domains.

Now edit postfix config file `/etc/postfix/main.cf` (Linux) or
`/usr/local/etc/postfix/main.cf` (FreeBSD), append these two lookup files in
`virtual_alias_maps` setting:

```
# Part of file: main.cf

virtual_alias_maps =
    proxy:mysql:/etc/postfix/mysql/virtual_alias_maps.cf,
    proxy:mysql:/etc/postfix/mysql/domain_alias_maps.cf,
    proxy:mysql:/etc/postfix/catchall_maps.cf,                      # <- Add this line
    proxy:mysql:/etc/postfix/domain_alias_catchall_maps.cf        # <- Add this line.
```

Now create these two new files (Note: You can create them based on exist mysql
lookup files, copy "`user`, `password`, `hosts`, `port`, `dbname`" to new files):

* `/etc/postfix/catchall_maps.cf`:

```
# File: catchall_maps.cf
user        = vmail
password    = PASSWORD_OF_VMAIL
hosts       = 127.0.0.1
port        = 3306
dbname      = vmail
query       = SELECT alias.goto FROM alias,domain WHERE alias.address='%d' AND alias.address=domain.domain AND alias.active=1 AND domain.active=1 AND domain.backupmx=0
```

* `/etc/postfix/domain_alias_catchall_maps.cf`:

```
# File: domain_alias_catchall_maps.cf

user        = vmail
password    = PASSWORD_OF_VMAIL
hosts       = 127.0.0.1
port        = 3306
dbname      = vmail
query       = SELECT alias.goto FROM alias,alias_domain,domain WHERE alias_domain.alias_domain='%d' AND alias.address=alias_domain.target_domain AND alias_domain.target_domain=domain.domain AND alias.active=1 AND alias_domain.active=1
```

Restart postfix to make it work.

### Update SQL structure of `vmail` database

* Add some more columns:
```
$ mysql -uroot -p
USE vmail;

-- enablesmtpsecured: Used for SMTP over SSL support in Postfix + Dovecot.
ALTER TABLE mailbox ADD COLUMN enablesmtpsecured TINYINT(1) NOT NULL DEFAULT '1';

-- name: Used to store common name of admin and alias account.
ALTER TABLE admin ADD COLUMN name VARCHAR(255) DEFAULT '' COLLATE utf8_general_ci;
ALTER TABLE alias ADD COLUMN name VARCHAR(255) DEFAULT '' COLLATE utf8_general_ci;

-- passwordlastchange: Store date of password last change.
ALTER TABLE admin ADD COLUMN passwordlastchange DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00';
ALTER TABLE mailbox ADD COLUMN passwordlastchange DATETIME NOT NULL DEFAULT '0000-00-00 00:00:00';

-- local_part: Used for PostfixAdmin compatible.
ALTER TABLE mailbox ADD COLUMN local_part VARCHAR(255) NOT NULL DEFAULT '';

-- defaultuseraliases: Assign new user to these aliases
ALTER TABLE domain ADD COLUMN defaultuseraliases TEXT NOT NULL DEFAULT '';

-- defaultpasswordscheme: Per-domain password scheme support.
ALTER TABLE domain ADD COLUMN defaultpasswordscheme VARCHAR(10) NOT NULL DEFAULT '';
```

* Create indexes of some columns for better performance.
```
$ mysql -uroot -p
USE vmail;

-- Table: admin
ALTER TABLE  admin ADD INDEX (passwordlastchange);
ALTER TABLE  admin ADD INDEX (expired);
ALTER TABLE  admin ADD INDEX (active);

-- Table: alias
ALTER TABLE  alias ADD INDEX (domain);
ALTER TABLE  alias ADD INDEX (expired);
ALTER TABLE  alias ADD INDEX (active);

-- Table: domain
ALTER TABLE  domain ADD INDEX (backupmx);
ALTER TABLE  domain ADD INDEX (expired);
ALTER TABLE  domain ADD INDEX (active);

-- Table: domain_admins
ALTER TABLE  domain_admins ADD INDEX (username);
ALTER TABLE  domain_admins ADD INDEX (domain);
ALTER TABLE  domain_admins ADD INDEX (active);

-- Table: mailbox
ALTER TABLE  mailbox ADD INDEX (domain);
ALTER TABLE  mailbox ADD INDEX (department);
ALTER TABLE  mailbox ADD INDEX (employeeid);
ALTER TABLE  mailbox ADD INDEX (enablesmtp);
ALTER TABLE  mailbox ADD INDEX (enablesmtpsecured);
ALTER TABLE  mailbox ADD INDEX (enablepop3);
ALTER TABLE  mailbox ADD INDEX (enablepop3secured);
ALTER TABLE  mailbox ADD INDEX (enableimap);
ALTER TABLE  mailbox ADD INDEX (enableimapsecured);
ALTER TABLE  mailbox ADD INDEX (enablemanagesieve);
ALTER TABLE  mailbox ADD INDEX (enablemanagesievesecured);
ALTER TABLE  mailbox ADD INDEX (enablesieve);
ALTER TABLE  mailbox ADD INDEX (enablesievesecured);
ALTER TABLE  mailbox ADD INDEX (enableinternal);
ALTER TABLE  mailbox ADD INDEX (passwordlastchange);
ALTER TABLE  mailbox ADD INDEX (expired);
ALTER TABLE  mailbox ADD INDEX (active);

-- Table: sender_bcc_domain
ALTER TABLE  sender_bcc_domain ADD INDEX (bcc_address);
ALTER TABLE  sender_bcc_domain ADD INDEX (expired);
ALTER TABLE  sender_bcc_domain ADD INDEX (active);

-- Table: sender_bcc_user
ALTER TABLE  sender_bcc_user ADD INDEX (bcc_address);
ALTER TABLE  sender_bcc_user ADD INDEX (expired);
ALTER TABLE  sender_bcc_user ADD INDEX (active);

-- Table: recipient_bcc_domain
ALTER TABLE  recipient_bcc_domain ADD INDEX (bcc_address);
ALTER TABLE  recipient_bcc_domain ADD INDEX (expired);
ALTER TABLE  recipient_bcc_domain ADD INDEX (active);

-- Table: recipient_bcc_user
ALTER TABLE  recipient_bcc_user ADD INDEX (bcc_address);
ALTER TABLE  recipient_bcc_user ADD INDEX (expired);
ALTER TABLE  recipient_bcc_user ADD INDEX (active);
```

### Save date of password last change in Roundcube

Roundcube won't save date of password last change by default, please change
setting of its plugin `password` to make it work.

* Edit config file `/var/www/roundcubemail/plugins/password/config.inc.php`
  (RHEL/CentOS) or `/usr/share/apache2/roundcubemail/plugins/password/config.inc.php`
  (Debian/Ubuntu) or `/srv/www/roundcubemail/plugins/password/config.inc.php`
  (openSUSE) or `/usr/local/www/roundcubemail/plugins/password/config.inc.php`
  (FreeBSD), change `password_query`, add `passwordlastchange=NOW()` in SQL command:

```
# Part of file: roundcubemail/plugins/password/config.inc.php

$rcmail_config['password_query'] = "UPDATE vmail.mailbox SET password=%c,passwordlastchange=NOW() WHERE username=%u LIMIT 1";
```

Roundcube will now save date of password last change in column `passwordlastchange`.

Note: If you want to force users to change their passwords in 90 days, please
refer to this tutorial: [Force users to change password in 90 days](./force.user.to.change.password.html).
