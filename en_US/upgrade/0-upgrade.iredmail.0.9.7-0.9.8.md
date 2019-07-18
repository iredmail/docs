# Upgrade iRedMail from 0.9.7 to 0.9.8

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

* Jun 19, Improve Nginx config file to handle mailing list subscription/unsubscription
* Mar 12, Add new ldap attribute/value pairs required by Dovecot-2.3.
* Mar 4, Upgrade SOGo from v3 to v4.
* Mar 4, Upgrade Roundcube webmail to the latet version - 1.3.6.
* Mar 1, SQL structure changes in `vmail` database.
* Feb 14, 2018: [SECURITY] Fixed: Nginx snippet file doesn't block access to Roundcube sensitive files.
* Feb 11, 2018: netdata integration.
* Feb 11, 2018: mlmmj & mlmmjadmin integration.
* Feb 11, 2018: OpenBSD: Upgrade uwsgi to the latest 2.0.16
* Jan 31, 2018: Fail2ban: new jail `postfix-pregreet`.
* Jan 21, 2018: [LDAP] Update SOGo config file for per-domain global address book.
* Jan 19, 2018: Update OpenLDAP config file to index new attributes and fix an ACL.
* Jan 19, 2018: Update iRedMail LDAP schema file
* Dec 18, 2017: Don't hard-code static file types in Nginx template for iRedAdmin.
* Nov 24, 2017: Amavisd: Add new SQL column `maddr.email_raw` to store mail address without address extension.
* Oct 6, 2017: Fixed: SOGo backup script contains 3 issues
* Oct 6, 2017: [OPTIONAL] Fix improper expected DNSBL filter for site `b.barracudacentral.org`
* Oct 6, 2017: [OPTIONAL] Log mail subject, sender, size in mail deliver log.

## General (All backends should apply these steps)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
0.9.8
```

### Upgrade iRedAPD (Postfix policy server) to the latest stable release (2.2)

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

### Upgrade iRedAdmin (open source edition) to the latest stable release (0.9)

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

### Upgrade SOGo from v3 to v4

SOGo v4 was released on Mar 7, 2018 by the SOGo team (<https://sogo.nu>), it
will become the main branch with most active development.

If you're satisfied with SOGo v3, you're free to continue running v3. but if
you want to try v4, please follow our tutorial below to upgrade it.

* [Upgrade SOGo from v3 to v4](./upgrade.sogo.3.to.4.html)

### Upgrade Dovecot from 2.2 to 2.3

!!! attention

    This is only applicable to FreeBSD.

Currently only FreeBSD offers Dovecot 2.3 by the ports tree, other Linux/BSD
distributions still offers Dovecot 2.2, you should stick to Dovecot 2.2 if your
Linux/BSD vendor doesn't offer 2.3 yet.

Please follow our tutorial below to upgrade Dovecot:

* [Upgrade Dovecot from 2.2.x to 2.3.x](./upgrade.dovecot.2.2-2.3.html)

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
rm -f backup_sogo.sh
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

* Download filter rule:

```
cd /etc/fail2ban/filter.d/
wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/fail2ban/filter.d/postfix-pregreet.iredmail.conf
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
action      = iptables-multiport[name=postfix, port="25", protocol=tcp]
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
location ~ ^/iredadmin/static/(.*) {
    alias /var/www/iredadmin/static/$1;
}
```

Reloading or restarting Nginx service is required.

### Improve Nginx config file to handle mailing list subscription/unsubscription

iRedMail integrates mlmmj as mailing list manager (integration tutorial
mentioned later in this tutorial), it supports subscription and unsubscription
from web page. To hide the application handle the subscription/unsubscription
behind it, iRedMail requires a new URL `https://<server>/newsletter/` for this
purpose.

Please append lines below to file `/etc/nginx/templates/iredadmin.tmpl`
(on Linux/OpenBSD) or `/usr/local/etc/nginx/templates/iredadmin.tmpl` (on
FreeBSD)

```
# Handle newsletter-style subscription/unsubscription supported in iRedAdmin-Pro.
location ~ ^/newsletter/ {
    rewrite /newsletter/(.*) /iredadmin/newsletter/$1 last;
}
```

Reloading or restarting Nginx service is required.

### [SECURITY] Fixed: Nginx snippet file doesn't block access to Roundcube sensitive files

!!! attention

    This is only applicable to Nginx.

With default iRedMail settings, Nginx doesn't block access to Roundcube
sensitive files and `.htaccess` file, this may leak users' PGP keys.
Please follow steps below to fix it.

Please open file `/etc/nginx/templates/roundcube.tmpl` (Linux/OpenBSD) or
`/usr/local/etc/nginx/templates/roundcube.tmpl` (FreeBSD), add lines below
__ABOVE__ any existing lines:

```
# Block access to default directories and files under these directories
location ~ ^/mail/(bin|config|installer|logs|SQL|temp|vendor)($|/.*) { deny all; }

# Block access to default files under top-directory and files start with same name.
location ~ ^/mail/(CHANGELOG|composer.json|INSTALL|jsdeps.json|LICENSE|README|UPGRADING)($|.*) { deny all; }

# Block plugin config files and sample config files.
location ~ ^/mail/plugins/.*/config.inc.php.* { deny all; }

# Block access to plugin data
location ~ ^/mail/plugins/enigma/home($|/.*) { deny all; }
```

Please open file `/etc/nginx/templates/roundcube-subdomain.tmpl`
(Linux/OpenBSD) or `/usr/local/etc/nginx/templates/roundcube-subdomain.tmpl`
(FreeBSD), add lines below __ABOVE__ any existing lines:

```
# Block access to default directories and files under these directories
location ~ ^/(bin|config|installer|logs|SQL|temp|vendor)($|/.*) { deny all; }

# Block access to default files under top-directory and files start with same name.
location ~ ^/(CHANGELOG|composer.json|INSTALL|jsdeps.json|LICENSE|README|UPGRADING)($|.*) { deny all; }

# Block plugin config files and sample config files.
location ~ ^/plugins/.*/config.inc.php.* { deny all; }

# Block access to plugin data
location ~ ^/plugins/enigma/home($|/.*) { deny all; }
```

Open file `/etc/nginx/sites-available/00-default.conf` AND `00-default-ssl.conf`,
make sure template file `misc.tmpl` is loaded before other template files.
For example, your existing config file may look like this:

```
server {
    ...
    include /etc/nginx/templates/...;
    include /etc/nginx/templates/...;
    include /etc/nginx/templates/misc.tmpl;
}
```

Please move the `misc.tmpl` line __ABOVE__ any other `include` directive.
Final setting should look like this:

```
server {
    ...
    include /etc/nginx/templates/misc.tmpl;
    include /etc/nginx/templates/...;
    include /etc/nginx/templates/...;
}
```

Note: Nginx in iRedMail-0.9.7 loads modular config files from
`/etc/nginx/sites-conf.d/default/` and `/etc/nginx/sites-conf.d/default-ssl/`
instead of storing all configurations for default web hosts in one file, in
this case you need to:

* rename file `/etc/nginx/sites-conf.d/default/99-include-tmpl-misc.conf` to
  `/etc/nginx/sites-conf.d/default/1-include-tmpl-misc.conf`.
* rename file `/etc/nginx/sites-conf.d/default-ssl/99-include-tmpl-misc.conf` to
  `/etc/nginx/sites-conf.d/default-ssl/1-include-tmpl-misc.conf`.

Restarting Nginx service is required.

### Fix unexpected DNSBL query result for site `b.barracudacentral.org`

Postfix config file (`/etc/postfix/main.cf` on Linux/OpenBSD, or
`/usr/local/etc/postfix/main.cf` on FreeBSD) generated by iRedMail enables
DNSBL service for postscreen service like below:

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

### OpenBSD: Upgrade uwsgi to the latest 2.0.17

uwsgi is the interface between Nginx and iRedAdmin, so if you're running
iRedAdmin, it's recommended to upgrade uwsgi to the latest version, 2.0.17.

Steps: Download the latest uwsgi, compile it, then restart uwsgi service.

```
cd /root/
ftp https://projects.unbit.it/downloads/uwsgi-2.0.17.tar.gz
tar zxf uwsgi-2.0.17.tar.gz
cd uwsgi-2.0.17
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

### [OPTIONAL] integrate netdata - fancy system monitor

iRedMail-0.9.8 integrates netdata as an optional component, it's a fancy system
monitor to help you understand how your iRedMail server runs.

To integrate netdata, please follow our tutorial below:

* [Integrate netdata monitor on Linux server](./integration.netdata.linux.html)
* [Integrate netdata monitor on FreeBSD server](./integration.netdata.freebsd.html)

Unfortunately, netdata doesn't work on OpenBSD.

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

### Add new ldap attribute/value pairs required by Dovecot-2.3.

Dovecot-2.3 has an internal change which impacts mail accounts created by
iRedMail, it requires 2 new ldap attribute/value pairs for all mail users:

* enabledService=imaptls
* enabledService=pop3tls

Please follow steps below to add them.

* Download script used to update existing mail users:

```
cd /root/
wget https://bitbucket.org/zhb/iredmail/raw/default/extra/update/update-ldap-dovecot-2.3.py
```

* Open downloaded file `update-ldap-dovecot-2.3.py`, set LDAP server
  related settings in this file. For example:

```
# Part of file: update-ldap-dovecot-2.3.py

uri = 'ldap://127.0.0.1:389'
basedn = 'o=domains,dc=example,dc=com'
bind_dn = 'cn=vmailadmin,dc=example,dc=com'
bind_pw = 'password'
```

You can find required LDAP credential in iRedAdmin config file or
`iRedMail.tips` file under your iRedMail installation directory. Using either
`cn=Manager,dc=xx,dc=xx` or `cn=vmailadmin,dc=xx,dc=xx` as bind dn is ok, both
of them have read-write privilege to update mail accounts.

* Execute this script, it will add required data:

```
# python update-ldap-dovecot-2.3.py
```

### mlmmj (mailing list manager) integration

iRedMail-0.9.8 integrates mlmmj as mailing list manager, please follow our
document below to integrate it:

* [Integrate mlmmj mailing list manager](./integration.mlmmj.ldap.html)

!!! attention

    mlmmj is a core component since iRedMail-0.9.8.

### Amavisd: Add new SQL column `maddr.email_raw` to store mail address without address extension

Many sender/recipient addresses contain address extension like
`user+extension@domain.com`, this is annoying if we try to get top 10
senders/recipients from Amavisd SQL database, because address
`user+ext1@domain.com` and `user+ext2@domain.com` are considered as different
user. To avoid this issue, we create a SQL trigger to store email address
without address extension in a new column `maddr.email_raw`. Please follow
steps below to apply the SQL structure change.

* Download and import SQL template file used to update SQL database:

```
cd /tmp/
wget https://bitbucket.org/zhb/iredmail/raw/default/extra/update/0.9.8/amavisd.mysql
mysql amavisd < amavisd.mysql
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

### SQL structure changes in `vmail` database

We've made some changes to `vmail` database:

* Drop sql column `mailbox.local_part`. This column was inherited from
  PostfixAdmin, but iRedMail didn't use it at all.
* Rename table `alias_moderators` to `moderators`. Used to store moderators of
  both mail alias accounts and mailing lists.
* Add new column `domain.maillists`. Used to store per-domain limit of mailing
  list accounts. Note: this is majorly used by iRedAdmin-Pro.
* Add new column `forwardings.is_maillist`.
* Add new column `mailbox.enableimaptls`. Required by Dovecot-2.3.
* Add new table `maillists`, used by our new mailing list manager software - mlmmj.

!!! warning

    Please backup SQL database `vmail` before you run any SQL commands below.

    ```bash /var/vmail/backup/backup_mysql.sh```

Download SQL template file used to update SQL database:

```
cd /root/
wget -O iredmail.mysql https://bitbucket.org/zhb/iredmail/raw/default/extra/update/0.9.8/iredmail.mysql
```

Connect to MySQL server as MySQL root user, and execute SQL commands:

```
mysql vmail < /root/iredmail.mysql
```

### Amavisd: Add new SQL column `maddr.email_raw` to store mail address without address extension

Many sender/recipient addresses contain address extension like
`user+extension@domain.com`, this is annoying if we try to get top 10
senders/recipients from Amavisd SQL database, because address
`user+ext1@domain.com` and `user+ext2@domain.com` should be considered as same
user, but it's not. To avoid this issue, we create a SQL trigger to store email
address without address extension in a new column `maddr.email_raw`. Steps:

* Download and import SQL template file used to update SQL database:

```
cd /tmp/
wget https://bitbucket.org/zhb/iredmail/raw/default/extra/update/0.9.8/amavisd.mysql
mysql amavisd < amavisd.mysql
```

### mlmmj (mailing list manager) integration

iRedMail-0.9.8 integrates mlmmj as mailing list manager, please follow our
document below to integrate it:

* [Integrate mlmmj mailing list manager](./integration.mlmmj.mysql.html)

!!! attention

    mlmmj is a core component since iRedMail-0.9.8.

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

### SQL structure changes in `vmail` database

We've made some changes to `vmail` database:

* Drop sql column `mailbox.local_part`. This column was inherited from
  PostfixAdmin, but iRedMail didn't use it at all.
* Rename table `alias_moderators` to `moderators`. Used to store moderators of
  both mail alias accounts and mailing lists.
* Add new column `domain.maillists`. Used to store per-domain limit of mailing
  list accounts. Note: this is majorly used by iRedAdmin-Pro.
* Add new column `forwardings.is_maillist`.
* Add new column `mailbox.enableimaptls`. Required by Dovecot-2.3.
* Add new table `maillists`, used by our new mailing list manager software - mlmmj.

!!! warning

    Please backup SQL database `vmail` before you run any SQL commands below.

    ```bash /var/vmail/backup/backup_pgsql.sh```

* Download SQL template file used to update SQL database:

```
cd /tmp/
wget https://bitbucket.org/zhb/iredmail/raw/default/extra/update/0.9.8/iredmail.pgsql
```

* Connect to PostgreSQL server as `postgres` user and import the SQL file:
    * on Linux, it's `postgres` user
    * on FreeBSD, it's `pgsql` user
    * on OpenBSD, it's `_postgresql` user

```
su - postgres
psql -d vmail < /tmp/iredmail.pgsql
```

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
$ psql -U amavisd -d amavisd
sql> \i /tmp/amavisd.pgsql
```

### mlmmj (mailing list manager) integration

iRedMail-0.9.8 integrates mlmmj as mailing list manager, please follow our
document below to integrate it:

* [Integrate mlmmj mailing list manager](./integration.mlmmj.pgsql.html)

!!! attention

    mlmmj is a core component since iRedMail-0.9.8.
