# Upgrade iRedMail from 0.9.7 to 0.9.8

[TOC]

!!! warning "DO NOT APPLY THIS UPGRADE TUTORIAL"

    This document is still a __DRAFT__, do NOT apply it.

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

* [TODO] mlmmj & mlmmjadmin integration.
* Feb 11, 2018: OpenBSD: Upgrade uwsgi to the latest 2.0.16
* Jan 31, 2018: Fail2ban: new jail `postfix-pregreet`.
* Jan 21, 2018: [LDAP] Update SOGo config file for per-domain global address book.
* Jan 19, 2018: Update OpenLDAP config file to index new attributes and fix an ACL.
* Jan 19, 2018: Update iRedMail LDAP schema file
* Dec 18, 2017: Don't hard-code static file types in Nginx template for iRedAdmin.
* Nov 24, 2017: Amavisd: Add new SQL column `maddr.email_raw` to store mail address without address extension.
* Nov 17, 2017: Fixed: Improper Postfix SQL queries used to query per-user bcc address.
* Oct 6, 2017: Fixed: SOGo backup script contains 3 issues
* Oct 6, 2017: [OPTIONAL] Fix improper expected DNSBL filter for site `b.barracudacentral.org`
* Oct 6, 2017: [OPTIONAL] Log mail subject, sender, size in mail deliver log.

## General (All backends should apply these steps)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
0.9.7
```

### Upgrade iRedAPD (Postfix policy server) to the latest stable release (2.2)

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

### Fixed: SOGo backup script contains 3 issues

SOGo backup script `/var/vmail/backup/backup_sogo.sh` shipped in iRedMail-0.9.7
and earlier releases contains 3 issues:

- it cannot remove old backup files
- it doesn't set correct owner and permission on backup files
- it cannot find command `sogo-tool` on FreeBSD. This issue causes our script
  didn't backup any sogo data on FreeBSD at all.

To fix them, please download the latest version and override the one on your
system:

!!! attention

    Script `backup_sogo.sh` uses `/var/vmail/backup` to store backup files by
    default, if you use a different directory, please edit this file and modify
    parameter `BACKUP_ROOTDIR=` to use the correct one.

```
cd /var/vmail/backup/
wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/tools/backup_sogo.sh
chown root backup_sogo.sh
chmod 0400 backup_sogo.sh
```

### Fail2ban: new jail `postfix-pregreet`

!!! attention

    This is not applicable to OpenBSD because we don't have Fail2ban running on
    OpenBSD.

Quote from [Postfix website](http://www.postfix.org/POSTSCREEN_README.html#pregreet):

> The SMTP protocol is a classic example of a protocol where the server speaks
> before the client. postscreen(8) detects zombies that are in a hurry and that
> speak before their turn.

Many spammers are in a hurry to transfer message to your server, we'd
like to block them due to not follow RFC.

During mail server maintenance, we found many spammers from China mainland
cannot pass this pregreet test and all of them use `ylmf-pc` as HELO hostname.
it's very possible that they're running an illegal Windows XP system which were
installed with a malware Windows XP ISO image.

Steps to create this new Fail2ban jail:

* Create new file `/etc/fail2ban/filter.d/postfix-pregreet.conf` with content
  below:

```
[Definition]

# Block clients which cannot pass Postfix postscreen pregreet test.
# FYI: http://www.postfix.org/POSTSCREEN_README.html#pregreet
#
# The SMTP protocol is a classic example of a protocol where the server speaks
# before the client. postscreen(8) detects zombies that are in a hurry and that
# speak before their turn.
failregex = postscreen\[\d+\]: PREGREET .* from \[<HOST>\]:\d+:

# while setting up new account, Thunderbird doesn't wait for server connection
# greeting/banner, this causes Thunderbird cannot pass the Postfix pregreet
# test and caught by `failregex` rules listed above (the rule contains
# 'PREGREET' line).
# FYI: https://bugzilla.mozilla.org/show_bug.cgi?id=538809#c41
ignoreregex = postscreen\[\d+\]: PREGREET .* from \[<HOST>\]:\d+: (EHLO|HELO) we-guess.mozilla.org
```

* Create new file `/etc/fail2ban/jail.d/postfix-pregreet.local` with content
  below:

    !!! attention

        Please make sure you're using correct Postfix log file in `logpath =`
        parameter. On RHEL/CentOS/FreeBSD, it's `/var/log/maillog`. On
        Debian/Ubuntu, it's `/var/log/mail.log`.

```
[postfix-pregreet-iredmail]
enabled     = true
filter      = postfix-pregreet.iredmail
logpath     = /var/log/maillog
maxretry    = 1
action      = iptables-multiports[name=postfix, port="25", protocol=tcp]
```

* Restarting Fail2ban service is required.

### Fixed: Nginx snippet file hard-codes static file types for iRedAdmin

!!! attention

    This is only applicable to Nginx.

With default iRedMail settings, Nginx snippet file `/etc/nginx/templates/iredadmin.tmpl`
(on Linux/OpenBSD) or `/usr/local/etc/nginx/templates/iredadmin.tmpl` (on FreeBSD)
hard-codes static file types like below:

```
location ~ ^/iredadmin/static/(.*)\.(png|jpg|gif|css|js) {
    alias /var/www/iredadmin/static/$1.$2;
}
```

Note: The path in `alias` directive is different on different Linux/BSD distributions.

Please replace it by:

```
location ~ ^/iredadmin/static/(.*) {            # Remove file types
    alias /var/www/iredadmin/static/$1;         # Remove '.$2'
}
```

Reloading or restarting Nginx service is required.

### Fix unexpected DNSBL query result for site `b.barracudacentral.org`

Postfix config file generated by iRedMail enables DNSBL service for postscreen
service like below:

```
postscreen_dnsbl_sites =
    zen.spamhaus.org=127.0.0.[2..11]*3
    b.barracudacentral.org=127.0.0.[2..11]*2
```

but site `b.barracudacentral.org` returns only domain `127.0.0.2` (instead of
a range from `127.0.0.2` to `127.0.0.11`), so we should change the
`b.barracudacentral.org=127.0.0.[2..11]*2` line to:

```
postscreen_dnsbl_sites =
    zen.spamhaus.org=127.0.0.[2..11]*3
    b.barracudacentral.org=127.0.0.2*2
```

Reloading or restarting Postfix is required.

### OpenBSD: Upgrade uwsgi to the latest 2.0.16

uwsgi is the interface between Nginx and iRedAdmin, so if you're running
iRedAdmin, it's recommended to upgrade uwsgi to the latest version, 2.0.16.

Steps: Download the latest uwsgi, compile it, then restart uwsgi service.

```
cd /root/
ftp https://projects.unbit.it/downloads/uwsgi-2.0.16.tar.gz
tar zxf uwsgi-2.0.16.tar.gz
cd uwsgi-2.0.16
python setup.py install
```

uwsgi should be succesfully installed, then restart uwsgi service:

```
rcctl restart uwsgi
```

### [OPTIONAL] Log mail subject, sender, size in mail deliver log

If you may need to get more info of (locally) delivered mail messages,
Dovecot setting `deliver_log_format` can log extra mail subject, sender, and
message size in mail deliver log. Please append this setting in Dovecot config
file `dovecot.conf`, then restart or reload Dovecot service.
* On Linux/OpenBSD, it's `/etc/dovecot/dovecot.conf`
* On FreeBSD, it's `/usr/local/etc/dovecot/dovecot.conf`

```
deliver_log_format = from=%{from}, envelope_sender=%{from_envelope}, subject=%{subject}, msgid=%m, size=%{size}, %$
```

## OpenLDAP backend

### Update OpenLDAP config file to index new attributes and fix an ACL

* Please open OpenLDAP config file `slapd.conf`:
    * On RHEL/CentOS, it's `/etc/openldap/slapd.conf`
    * On Debian/Ubuntu, it's `/etc/ldap/slapd.conf`
    * On FreeBSD, it's `/usr/local/etc/openldap/slapd.conf`
    * On OpenBSD:
        * if you're running OpenLDAP, it's `/etc/openldap/slapd.conf`.
        * if you're running `ldapd(8)` as LDAP server, no need to fix ACL
          issue (`access to dn.subtree=`), but still need to index new
          attributes.

* find lines below:
```
access to dn.subtree="o=domains,dc=xxx,dc=xxx"
    by anonymous                    auth
    by self                         write
    by dn.exact="cn=vmail,dc=xxx,dc=xxx"    read
    by dn.exact="cn=vmailadmin,dc=xxx,dc=xxx"  write
    by users                        none
```

Replace the last line `by users none` by:

```
   by users read
```

* Append lines below to the end of OpenLDAP config file `slapd.conf`:

```
index member,uniqueMember eq,pres
index mailingListID eq
```

!!! attention

    For OpenBSD `ldapd(8)` server, please add lines below inside the
    `namespace xxx {}` block:

    <pre>
    index member
    index uniqueMember
    index mailingListID
    </pre>

### Update iRedMail LDAP schema file

iRedMail-0.9.8 introduces 1 new LDAP attribute for mailing list account:

* `mailingListID`: used to store a server-wide unique id, currently is used
  for mailing list subscription/unsubscription (a.k.a. newsletter).

Download the latest iRedMail LDAP schema file

* On RHEL/CentOS:

```
cd /tmp
wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/iredmail/iredmail.schema

cd /etc/openldap/schema/
cp iredmail.schema iredmail.schema.bak

cp -f /tmp/iredmail.schema /etc/openldap/schema/
```

* On Debian/Ubuntu:
```
cd /tmp
wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/iredmail/iredmail.schema

cd /etc/ldap/schema/
cp iredmail.schema iredmail.schema.bak

cp -f /tmp/iredmail.schema /etc/ldap/schema/
```

* On FreeBSD:

```
cd /tmp
wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/iredmail/iredmail.schema

cd /usr/local/etc/openldap/schema/
cp iredmail.schema iredmail.schema.bak

cp -f /tmp/iredmail.schema /usr/local/etc/openldap/schema/
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
```

### Amavisd: Add new SQL column `maddr.email_raw` to store mail address without address extension

Many sender/recipient addresses contain address extension like
`user+extension@domain.com`, this is annoying if we try to get top 10
senders/recipients from Amavisd SQL database, because address
`user+ext1@domain.com` and `user+ext2@domain.com` are considered as different
user. To avoid this issue, we create a SQL trigger to store email address
without address extension in a new column `maddr.email_raw`. Please follow
steps below to apply the SQL structure change.

* Download SQL template file used to update SQL database:

```
cd /tmp/
wget https://bitbucket.org/zhb/iredmail/raw/default/extra/update/0.9.8/amavisd.mysql
```

* Connect to MySQL server as MySQL root user, and execute SQL commands:

```
$ mysql amavisd
mysql> SOURCE /tmp/amavisd.mysql;
```

### Update SOGo config file for per-domain global address book

!!! attention

    With this change, user can only see other users in same domain. If this is
    __NOT__ what you expect, you should __NOT__ apply this change.

SOGo is configured by iRedMail to query all users on server while performing
account search (e.g. global address book, meeting attendees), this may be not
what you expect if you host multiple mail domains and they should not see
others on same server. Please follow steps below to fix it.

* Open SOGo config file `/etc/sogo/sogo.conf` (Linux/OpenBSD) or
  `/usr/local/etc/sogo/sogo.conf` (FreeBSD), find lines like below:

```
        {
            // Used for global address book
            type = ldap;
            id = global_addressbook;
            canAuthenticate = NO;
            isAddressBook = YES;
            displayName = "Global Address Book";
```

* Add one line after the `displayName =` line:

```
            bindAsCurrentUser = YES;
```

* Restarting SOGo service is required to apply this change.

## MySQL/MariaDB backends

### Fixed: User under disabled domain is able to send email with smtp protocol

Dovecot is IMAP/POP3/Managesieve server, also a SASL auth server for Postfix.
If mail domain is disabled, users under this domain are not able to use
IMAP/POP3/Managesieve services, but there's a bug in Dovecot SQL query
configured by iRedMail, it doesn't check domain status while performing smtp
sasl auth. Please follow steps below to fix it.

* Open file `/etc/dovecot/dovecot-mysql.conf` (Linux/OpenBSD) or
  `/usr/local/etc/dovecot/dovecot-mysql.conf` (FreeBSD), find the
  `password_query` line like below:

```
password_query = SELECT password, allow_nets FROM mailbox WHERE username='%u' AND enable%Ls%Lc=1 AND active=1
```

* Replace it by lines below:

```
password_query = SELECT mailbox.password, mailbox.allow_nets \
        FROM mailbox,domain \
       WHERE mailbox.username='%u' \
             AND mailbox.`enable%Ls%Lc`=1 \
             AND mailbox.active=1 \
             AND mailbox.domain=domain.domain \
             AND domain.backupmx=0 \
             AND domain.active=1
```

* Save your change and restart Dovecot service.

### Fixed: Improper Postfix SQL queries used to query per-user bcc address.

There're 2 Postfix SQL queries configured by iRedMail are improper, they won't
return per-user bcc address. Please follow steps below to fix it:

* Open file `/etc/postfix/mysql/recipient_bcc_maps_user.cf` (Linux/OpenBSD) or
  `/usr/local/etc/postfix/mysql/recipient_bcc_maps_user.cf` (FreeBSD),
  __REPLACE__ the `query =` line by lines below:

```
query       = SELECT recipient_bcc_user.bcc_address
                FROM recipient_bcc_user,domain,alias_domain
               WHERE recipient_bcc_user.username='%s'
                     AND recipient_bcc_user.domain='%d'
                     AND ((recipient_bcc_user.domain=domain.domain)
                          OR (recipient_bcc_user.domain=alias_domain.alias_domain AND domain.domain = alias_domain.target_domain))
                     AND domain.backupmx=0
                     AND domain.active=1
                     AND recipient_bcc_user.active=1
```

* Open file `/etc/postfix/mysql/sender_bcc_maps_user.cf` (Linux/OpenBSD) or
  `/usr/local/etc/postfix/mysql/sender_bcc_maps_user.cf` (FreeBSD),
  __REPLACE__ the `query =` line by lines below:

```
query       = SELECT sender_bcc_user.bcc_address
                FROM sender_bcc_user,domain,alias_domain
               WHERE sender_bcc_user.username='%s'
                     AND sender_bcc_user.domain='%d'
                     AND ((sender_bcc_user.domain=domain.domain)
                          OR (sender_bcc_user.domain=alias_domain.alias_domain AND domain.domain = alias_domain.target_domain))
                     AND domain.backupmx=0
                     AND domain.active=1
                     AND sender_bcc_user.active=1
```

* Save your changes and restart Postfix service.

### Amavisd: Add new SQL column `maddr.email_raw` to store mail address without address extension

Many sender/recipient addresses contain address extension like
`user+extension@domain.com`, this is annoying if we try to get top 10
senders/recipients from Amavisd SQL database, because address
`user+ext1@domain.com` and `user+ext2@domain.com` should be considered as same
user, but it's not. To avoid this issue, we create a SQL trigger to store email
address without address extension in a new column `maddr.email_raw`. Steps:

* Download SQL template file used to update SQL database:

```
cd /tmp/
wget https://bitbucket.org/zhb/iredmail/raw/default/extra/update/0.9.8/amavisd.mysql
```

* Connect to MySQL server as MySQL root user, and execute SQL commands:

```
# mysql amavisd
sql> SOURCE /tmp/amavisd.mysql;
```

## PostgreSQL backend

### Fixed: User under disabled domain is able to send email with smtp protocol

Dovecot is IMAP/POP3/Managesieve server, also a SASL auth server for Postfix.
If mail domain is disabled, users under this domain are not able to use
IMAP/POP3/Managesieve services, but there's a bug in Dovecot SQL query
configured by iRedMail, it doesn't check domain status while performing smtp
sasl auth. Please follow steps below to fix it.

* Open file `/etc/dovecot/dovecot-pgsql.conf` (Linux/OpenBSD) or
  `/usr/local/etc/dovecot/dovecot-pgsql.conf` (FreeBSD), find the
  `password_query` line like below:

```
password_query = SELECT password, allow_nets FROM mailbox WHERE username='%u' AND enable%Ls%Lc=1 AND active=1
```

* Replace it by lines below:

```
password_query = SELECT mailbox.password, mailbox.allow_nets \
        FROM mailbox,domain \
       WHERE mailbox.username='%u' \
             AND mailbox."enable%Ls%Lc"=1 \
             AND mailbox.active=1 \
             AND mailbox.domain=domain.domain \
             AND domain.backupmx=0 \
             AND domain.active=1
```

* Save your change and restart Dovecot service.

### Fixed: Improper Postfix SQL queries used to query per-user bcc address.

There're 2 Postfix SQL queries configured by iRedMail are improper, they won't
return per-user bcc address. Please follow steps below to fix it:

* Open file `/etc/postfix/pgsql/recipient_bcc_maps_user.cf` (Linux/OpenBSD) or
  `/usr/local/etc/postfix/pgsql/recipient_bcc_maps_user.cf` (FreeBSD),
  __REPLACE__ the `query =` line by lines below:

```
query       = SELECT recipient_bcc_user.bcc_address
                FROM recipient_bcc_user,domain,alias_domain
               WHERE recipient_bcc_user.username='%s'
                     AND recipient_bcc_user.domain='%d'
                     AND ((recipient_bcc_user.domain=domain.domain)
                          OR (recipient_bcc_user.domain=alias_domain.alias_domain AND domain.domain = alias_domain.target_domain))
                     AND domain.backupmx=0
                     AND domain.active=1
                     AND recipient_bcc_user.active=1
```

* Open file `/etc/postfix/pgsql/sender_bcc_maps_user.cf`, REPLACE the
  `query =` line by lines below:

```
query       = SELECT sender_bcc_user.bcc_address
                FROM sender_bcc_user,domain,alias_domain
               WHERE sender_bcc_user.username='%s'
                     AND sender_bcc_user.domain='%d'
                     AND ((sender_bcc_user.domain=domain.domain)
                          OR (sender_bcc_user.domain=alias_domain.alias_domain AND domain.domain = alias_domain.target_domain))
                     AND domain.backupmx=0
                     AND domain.active=1
                     AND sender_bcc_user.active=1
```

* Save your changes and restart Postfix service.

### Amavisd: Add new SQL column `maddr.email_raw` to store mail address without address extension

Many sender/recipient addresses contain address extension like
`user+extension@domain.com`, this is annoying if we try to get top 10
senders/recipients from Amavisd SQL database, because address
`user+ext1@domain.com` and `user+ext2@domain.com` should be considered as same
user, but it's not. To avoid this issue, we create a SQL trigger to store email
address without address extension in a new column `maddr.email_raw`. Steps:

* Download SQL template file used to update SQL database:

```
cd /tmp/
wget https://bitbucket.org/zhb/iredmail/raw/default/extra/update/0.9.8/amavisd.pgsql
```

* Run shell commands as root user below to connect to PostgreSQL server:

```
# su - postgres
$ psql -U amavisd -d vmail
sql> \i /tmp/amavisd.pgsql
```
