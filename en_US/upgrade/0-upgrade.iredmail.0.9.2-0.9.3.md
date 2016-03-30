# Upgrade iRedMail from 0.9.2 to 0.9.3

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](../support.html) and [contact us](../contact.html).

## ChangeLog

* 2016-01-21: Fix incorrect permission on new sql table `amavisd.outbound_wblist`.
* 2016-01-14: Mention updating backup script to backup iRedAPD SQL database.
* 2015-12-23: Run `a2enmod headers` on Debian/Ubuntu to make sure required Apache module is enabled.
* 2015-12-16: Mention how to enable greylisting in iRedAPD.
* 2015-12-14: New section: `Upgrade iRedAdmin (open source edition) to the latest stable release`.
* 2015-12-14: New section: `Migrate from Cluebringer to iRedAPD`.
* 2015-12-14: Fix duplicate folder name in section `Dovecot-2.2: Add more special folders as alias folders`.
----
* 2015-12-14: Initial release.

## General (All backends should apply these steps)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
# File: /etc/iredmail-release

0.9.3
```

### Upgrade iRedAPD (Postfix policy server) to the latest 1.7.0

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

__Notes__:

* iRedAPD-1.7.0 doesn't enable greylisting by default, please enable
   plugin `greylisting` in iRedAPD config file (`/opt/iredapd/settings.py`),
   then execute SQL command below to enable server-wide greylisting:

```
sql> USE iredapd;
sql> INSERT INTO greylisting (account, priority, sender, sender_priority, active) VALUES ('@.', 0, '@.', 0, 1);
```

* iRedAPD-1.7.0 creates a new SQL database `iredapd`, please update your
   backup script to backup this database. The backup script was set up by
   iRedMail during installation, default path is
   `/var/vmail/backup/backup_mysql.sh` (For OpenLDAP and MySQL/MariaDB
   backends) or `/var/vmail/backup/backup_pgsql.sh` (For PostgreSQL backend).
   For example:

```
DATABASES='... iredapd'
```

Detailed release notes are available [here](./iredapd.releases.html).

### Migrate from Cluebringer to iRedAPD

> NOTE: If your server doesn't have Cluebringer installed, please ignore this step.

In iRedMail-0.9.3, Cluebringer has been removed and replaced by iRedAPD.
Cluebringer is not under active development and no new release since 2013 (the
latest stable release doesn't support IPv6). iRedAPD offers greylisting and
throttling supports, please follow tutorial below to migrate greylisting and
throttling settings from Cluebringer to iRedAPD:

* [Migrate from Cluebringer to iRedAPD](./cluebringer.to.iredapd.html)

> Note: We also plan to completely remove code of Policyd/Cluebringer support
> in next iRedAdmin-Pro release.

### Upgrade iRedAdmin (open source edition) to the latest stable release

Please follow this tutorial to upgrade iRedAdmin open source edition to the
latest stable release:
[Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html)

### Upgrade Roundcube webmail to the latest stable release

Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release immediately: [How to upgrade Roundcube](http://trac.roundcube.net/wiki/Howto_Upgrade)

Note: package `rsync` must be installed on your server before upgrading.

### Postfix: Add additional aliases

ClamAV may detect virus in email, notification will be sent to system account
`virusalert`.

Steps to add alias accounts:

* For Linux and OpenBSD: please open file `/etc/postfix/aliases`, if you
  already have line `virusalert: root`, please ignore this step. if not, please
  run commands below to add it.

```shell
perl -pi -e 's/(virusalert:.*)/#${1}/g' /etc/postfix/aliases
echo -e '\nvirusalert: root' >> /etc/postfix/aliases
postalias /etc/postfix/aliases
```

* For FreeBSD: please open file `/usr/local/etc/postfix/aliases`, if you
  already have line `virusalert: root`, please ignore this step. if not, please
  run commands below to add it.

```shell
perl -pi -e 's/(virusalert:.*)/#${1}/g' /etc/postfix/aliases
echo -e '\nvirusalert: root' >> /usr/local/etc/postfix/aliases
postalias /usr/local/etc/postfix/aliases
```

### Amavisd: Fix incorrect setting which treats external sender as internal user

In iRedMail-0.9.2 and earlier releases, Amavisd was incorrectly configured
which causes it treats external sender as internal user, and it (incorrectly)
signs DKIM on inbound message. This is wrong. Please follow steps below to fix it.

With below changes, Amavisd will apply policy bank 'ORIGINATING' to emails
submitted through submission (port 587) by smtp authenticated user. This way
we clearly separate emails submitted by authenticated users and inbound message
sent by others, and Amavisd won't sign DKIM on inbound message anymore.

* Open Amavisd config file, make sure you have below settings. If they don't
  exist, please add them or update them.

    * on RHEL/CentOS: it's `/etc/amavisd/amavisd.conf`.
    * on Debian/Ubuntu: it's `/etc/amavis/conf.d/50-user`.
    * on FreeBSD: it's `/usr/local/etc/amavisd.conf`.
    * on OpenBSD: it's `/etc/amavisd.conf`.

```
$inet_socket_port = [10024, 10026, 9998];
$interface_policy{'10026'} = 'ORIGINATING';
```

We will configure Postfix to pipe email submitted by authenticated user through
port 10026, others through port 10024. And port 9998 is used to manage
quarantined mails.

* Find `$policy_bank{'ORIGINATING'} = {` block, comment out `forward_method`
  line in the block:

```
  #forward_method => 'smtp:[127.0.0.1]:10027',
```

* Comment out below line in Amavisd config file:

> WARNING:
>
> There're several `$originating =1;` in amavisd config file, but there's only
> one of them is __NOT__ defined inside any `$policy_bank = {}` block, and this
> is the one we need to comment out.

```
$originating = 1;
```

* Comment out the whole `$policy_bank{'MYUSERS'}` block:

```
#$policy_blank{'MYUSERS'} = {
#   ...
#}
```

* Restart Amavisd service.

* Open Postfix config file `/etc/postfix/master.cf` (Linux/OpenBSD) or
  `/usr/local/etc/postfix/master.cf` (FreeBSD), update transport `submission`
  to uncomment `content_filter=smtp-amavis:[127.0.0.1]:10026` line, so that we
  can use Amavisd with policy bank `ORIGINATING` as content filter. like below:

```
submission inet n       -       n       -       -       smtpd
  ... [omit other settings here] ...
  -o content_filter=smtp-amavis:[127.0.0.1]:10026
```

* Restart Postfix service.

### Dovecot: Fix incorrect quota warning priorities

iRedMail configures Dovecot to send warning message to local user when the
mailbox quota is 85%, 90% or 95% full, but the priorities is wrong. Please
fix it with steps below.

* Find below setting in Dovecot config file `/etc/dovecot/dovecot.conf`
  (Linux/OpenBSD) or `/usr/local/etc/dovecot/dovecot.conf` (FreeBSD):

```
    quota_warning = storage=85%% quota-warning 85 %u
    quota_warning2 = storage=90%% quota-warning 90 %u
    quota_warning3 = storage=95%% quota-warning 95 %u
```

`quota_warning` has the highest priority, `quota_warning3` has the lowest
priority. Only the command for the first exceeded limit is executed, so we must
configure the highest limit first.

With above setting, when the mailbox quota goes from 70% to 98% directly, it
sends warning message to notify user that the quota is 85% full, this is wrong,
it's expected to be warned as 95% full instead.

* Update them to below ones to fix it. Please pay close attention to the percent
  numbers:

```
    quota_warning = storage=95%% quota-warning 95 %u
    quota_warning2 = storage=90%% quota-warning 90 %u
    quota_warning3 = storage=85%% quota-warning 85 %u
```

Restart Dovecot service is required.

For more details, please read Dovecot document:
[Quota Configuration](http://wiki2.dovecot.org/Quota/Configuration)

### Dovecot-2.2: Add more special folders as alias folders

Note: This is applicable to Dovecot-2.2.x. if you're running Dovecot-2.1.x or
earlier versions, please skip this step.

Check Dovecot version number with below command first:

```bash
# dovecot --version
```

Open Dovecot config file `/etc/dovecot/dovecot.conf` (Linux/OpenBSD) or
`/usr/local/etc/dovecot/dovecot.conf` (FreeBSD), find below setting:

```
namespace {
    type = private
    ...
    inbox = yes
    ...
}
```

Add below alias folders inside the same `namespace {}` block:

```
    mailbox "Sent Items" {
        auto = no
        special_use = \Sent
    }

    mailbox "Deleted Messages" {
        auto = no
        special_use = \Trash
    }

    mailbox "Deleted Items" {
        auto = no
        special_use = \Trash
    }

    # Archive
    mailbox Archive {
        auto = no
        special_use = \Archive
    }
    mailbox Archives {
        auto = no
        special_use = \Archive
    }
```

Restart Dovecot service is required.

### Roundcube webmail: Add daily cron job to cleanup Roundcube SQL database

It's recommended to setup a daily cron job to keep Roundcube SQL database slick
and clean, it removes all records that are marked as deleted.

Please edit `root`'s cron job with command below:
```
# crontab -e -u root
```

Then add cron job below:

* RHEL/CentOS:

```
# Cleanup Roundcube SQL database.
2   2   *   *   *   php /var/www/roundcubemail/bin/cleandb.sh >/dev/null
```

* Debian/Ubuntu:

```
# Cleanup Roundcube SQL database.
2   2   *   *   *   php /opt/www/roundcubemail/bin/cleandb.sh >/dev/null
```

__WARNING__: with old iRedMail release, Roundcube directory is
`/usr/share/apache2/roundcubemail`, please make sure you're using the correct
one on your server.

* FreeBSD:

```
# Cleanup Roundcube SQL database.
2   2   *   *   *   php /usr/local/www/roundcube/bin/cleandb.sh >/dev/null
```

* OpenBSD:

```
# Cleanup Roundcube SQL database.
2   2   *   *   *   php /var/www/roundcubemail/bin/cleandb.sh >/dev/null
```

### Web server: Enable HSTS (HTTP Strict Transport Security) support

HTTP Strict Transport Security (often abbreviated as HSTS) is a security
feature that lets a web site tell browsers that it should only be communicated
with using HTTPS, instead of using HTTP.

For more details, please read this article:
[HTTP Strict Transport Security](https://developer.mozilla.org/en-US/docs/Web/Security/HTTP_strict_transport_security)

<h4>Apache</h4>

For Apache, please edit its config file which manages SSL related settings,
and append below settings right after `SSLEngine on` line:

* On RHEL/CentOS, it's `/etc/httpd/conf.d/ssl.conf`.
* On Debian/Ubuntu, it's `/etc/apache2/sites-enabled/default-ssl` or `default-ssl.conf`.
* On FreeBSD: it's `/usr/local/etc/apache24/extra/httpd-ssl.conf`.

```
# Use HTTP Strict Transport Security to force client to use secure connections only.
# Reference:
# https://developer.mozilla.org/en-US/docs/Web/Security/HTTP_strict_transport_security
# Module mod_headers is required. 15768000 seconds = 6 months.
Header always set Strict-Transport-Security "max-age=15768000"
```

On Debian 8 and Ubuntu, run command below to make sure Apache module `headers`
is enabled:

```
a2enmod headers
service apache2 restart
```

<h4>Nginx</h4>

For Nginx, please edit its config file which manages SSL related settings,
and append below settings right after `ssl on` line:

* On Linux and OpenBSD, it's `/etc/nginx/conf.d/default.conf`.
* On FreeBSD, it's `/usr/local/etc/nginx/conf.d/default.conf`.

```
# Use HTTP Strict Transport Security to force client to use secure connections only.
# Reference:
# https://developer.mozilla.org/en-US/docs/Web/Security/HTTP_strict_transport_security
add_header Strict-Transport-Security "max-age=15768000"
```

### SOGo: Fix improper settings in Apache/Nginx config file

iRedMail-0.9.2 has improper settings in Apache/Nginx config files:

* when you try to view attachment in email, it will redirect the URL to
  `https://127.0.0.1/...`.
* iOS mobile devices will try to access web url
  `https://.../.well-known/carddav`, but it's not defined in Apache/Nginx
  config files.

<h4>Apache</h4>

<h5>1: Comment out incorrect settings</h5>

For Apache: Please make sure below settings are commented out in Apache
config file, then restart Apache service.

* On RHEL/CentOS, it's `/etc/httpd/conf.d/SOGo.conf`.
* On Debian/Ubuntu, it's `/etc/apache2/conf-available/SOGo.conf`.
* FreeBSD: iRedMail-0.9.2 and earlier releases doesn't support SOGo
  on FreeBSD, so it's not appliable on FreeBSD.

```
#RequestHeader set "x-webobjects-server-port" "443"
#RequestHeader set "x-webobjects-server-name" "yourhostname"
#RequestHeader set "x-webobjects-server-url" "https://yourhostname"
```

<h5>2: Redirect /.well-known/carddav access to SOGo</h5>

Find below line in `SOGo.conf`:

```
  RewriteRule ^/.well-known/caldav/?$ /SOGo/dav [R=301]
```

Add a new line right after above line:

```
  RewriteRule ^/.well-known/caldav/?$ /SOGo/dav [R=301]
  RewriteRule ^/.well-known/carddav/?$ /SOGo/dav [R=301]
```

Restarting Apache service is required.

<h4>Nginx</h4>

<h5>1: Comment out incorrect settings</h5>

For Nginx: Please make sure below settings are commented out in Nginx config
file, then restart or reload Nginx service.

* On Linux and OpenBSD, it's `/etc/nginx/conf.d/default.conf`.
* On FreeBSD, it's `/usr/local/etc/nginx/conf.d/default.conf`.

```
#proxy_set_header x-webobjects-remote-host 127.0.0.1;
#proxy_set_header x-webobjects-server-name $server_name;
#proxy_set_header x-webobjects-server-url $scheme://$host;
```

<h5>2: Redirect /.well-known/carddav access to SOGo</h5>

iRedMail doesn't have `/.well-known` redirection in Nginx by default, so
please add lines below in the `server { listen 443; ...}` block,
in file `default.conf`:

```
rewrite ^/.well-known/caldav    /SOGo/dav permanent;
rewrite ^/.well-known/carddav   /SOGo/dav permanent;
```

Restarting Nginx service is required.

### SOGo: The Dovecot Master User used by SOGo doesn't work due to incorrect username.

Note: you can skip this step if you don't run SOGo groupware, and iRedMail
doesn't install SOGo on FreeBSD due to missing required ports in official ports
tree.

The Dovecot Master User created by iRedMail and used by SOGo doesn't contain
a mail domain name, this will cause login failure.

If you don't append a (non-exist) mail domain name in Dovecot Master User
account, Dovecot will use the domain name of your login username. For example,
if your real user is `myuser@mydomain.com`, when you try to access this user's
mailbox as Dovecot Master User `myuser@mydomain.com*my_master_user`, it will
trigger Dovecot to verify user `my_master_user@mydomain.com` which doesn't
exist on your server, then this login attempt fails.

Please follow steps below to fix it.

* Open file `/etc/dovecot/dovecot-master-users` (Linux/OpenBSD),
  find the account used by SOGo:

```
sogo_sieve_master:...
```

* Append any mail domain name which is not hosted on your server to this
  account, save your change. for example:

```
sogo_sieve_master@not-exist.com:...
```

* Open file `/etc/sogo/sieve.cred`, append the same mail domain name for the
  sieve account:

```
sogo_sieve_master@not-exist.com:...
```

That's all.

### SOGo: cron jobs which run every minute must be grouped in one job.

Note: this is applicable to iRedMail server which has SOGo groupware installed
and running.

iRedMail sets up 3 cron jobs for SOGo, 2 of them are running every minute. You
can check the cron jobs with command below. Note:

* SOGo daemon user is `sogo` on all Linux distributions.
* SOGo daemon user is `_sogo` on OpenBSD.
* with iRedMail-0.9.2 and earlier releases, there's no SOGo support on FreeBSD.

```
# crontab -u sogo -l

*   *   *   *   *   /usr/sbin/sogo-tool expire-sessions 30
*   *   *   *   *   /usr/sbin/sogo-ealarms-notify
```

It always complains with error message like below:

> sogo-tool[27443] Failed to create lock directory '/var/lib/sogo/GNUstep/Defaults/.lck/.GNUstepDefaults.lck'

> sogo-ealarms-notify[27790] Warning ... someone broke our lock (/var/lib/sogo/GNUstep/Defaults/.lck/.GNUstepDefaults.lck) ... and may have interfered with updating defaults data in file.

According to
[SOGo mailing list](http://marc.info/?l=sogo-users&m=144307619805703&w=2),
replied by SOGo developer __Christian Mack__, `This is a known problem, but
harmless, as the lock is not really needed here. The work around is to use one
cron entry only for both (jobs).`

Please edit the cron job with command below:

```
# crontab -u sogo -e
```

Then group those 2 jobs into one cron job like below (note, use semicolon `;`
to separate jobs):

```
*   *   *   *   *   /usr/sbin/sogo-tool expire-sessions 30; /usr/sbin/sogo-ealarms-notify
```

That's all.

### SOGo: Use correct sieve folder encoding

SOGo uses `UTF-7` as sieve folder encoding by default, this is improper, we
must use `UTF-8` instead, otherwise mail folder names with non-ASCII characters
cannot be correctly created or displayed.

To fix this, please add below setting in SOGo config file `/etc/sogo/sogo.conf`
(Linux/OpenBSD) or `/usr/local/etc/sogo/sogo.conf` (FreeBSD):

```
    SOGoSieveFolderEncoding = UTF-8;
```

Restarting SOGo service is required.

### [RHEL/CentOS 7] Remove `daemonze =` line in `/etc/uwsgi.ini`

NOTE: this is required by RHEL/CentOS 7, and not applicable to other Linux/BSD
distributions.

`daemonze =` line set in `/etc/uwsgi.ini` is required by RHEL/CentOS 6, but
not RHEL/CentOS 7, and it will cause `uwsgi` service fail. Please __remove or
comment out this line__ and restart `uwsgi` service.

### [RHEL/CentOS 7] Fix incorrect default firewall zone name

NOTE: this is required by RHEL/CentOS 7, and not applicable to other Linux/BSD
distributions.

iRedMail-0.9.2 and earlier versions won't set default firewall zone if you
didn't choose to restart firewall immediately, so after iRedMail installation,
you must set the default firewall zone manually with steps below.

* Open file `/etc/firewalld/firewalld.conf`, find parameter `DefaultZone=`. If
  it's not set by iRedMail installer, it will be `DefaultZone=public`:

```
DefaultZone=public
```

* Please replace `public` by `iredmail`, it will open ports required by ssh and
  mail services. The zone file is `/etc/firewalld/zones/iredmail.xml`, please
  make sure you have correct ssh port number in this file.

```
DefaultZone=iredmail
```

* Reload firewall rules with command below:

```
firewall-cmd --complete-reload
```

### [OPTIONAL] Fixed: Not preserve the case of `${extension}` while delivering message to mailbox

With iRedMail-0.9.2 and earlier releases, email sent to user
`username+Ext@domain.com` (upper case `E`) will be delivered to folder
`ext` (lower case `e`) of `username@domain.com`'s mailbox. This fix will
preserve the case of address extension.

* Open file `/etc/postfix/master.cf` (Linux/OpenBSD) or
  `/usr/local/etc/postfix/master.cf` (FreeBSD), find below lines:

```
# Use dovecot deliver program as LDA.
dovecot unix    -       n       n       -       -      pipe
    flags=DRhu ...
```

* Replace `flags=DRhu` by `flags=DRh` (remove `u`) in the third line:

```
    flags=DRh ...
```

### [OPTIONAL] Fail2ban: Update regular expression to catch postscreen log

We added one new regular expression to catch postscreen log to help reduce
spam, please follow steps below to add it.

Open file `/etc/fail2ban/filter.d/postfix.iredmail.conf` or
`/usr/local/etc/fail2ban/filter.d/postfix.iredmail.conf` (on FreeBSD), append
below line under `[Definition]` section:

```
            reject: RCPT from (.*)\[<HOST>\]:([0-9]{4,5}:)? 550
```

Restarting Fail2ban service is required.

### [OPTIONAL] Postfix: Remove one non-spam HELO identity in helo restriction

iRedMail ships a Postfix HELO rule file, `/etc/postfix/helo_access.pcre`, it
contains some HELO identities which were treated as spammers by analizing
Postfix log files, and one of them, `bezeqint.net` is not spammer and we should
remove it.

Please find below line in `/etc/postfix/helo_access.pcre` (Linux and OpenBSD)
or `/usr/local/etc/postfix/helo_access.pcre` (FreeBSD), and remove it.

```
/(bezeqint\.net)$/ REJECT ACCESS DENIED. Your email was rejected because the sending mail server does not identify itself correctly (${1})
```

### [OPTIONAL] Postfix: add some more restriction methods

> Note: this is an optional operation, not required but recommended.

If you need flexible rules to restrict senders, this change will be helpful.
for example, reject spammer whom sends emails with different domain names.

Please open Postfix config file `main.cf`, add below 2 settings:

* On Linux and OpenBSD, it's `/etc/postfix/main.cf`.
* On FreeBSD, it's `/usr/local/etc/postfix/main.cf`. WARNING: in below settings,
  all new files must be placed under `/usr/local/etc/postfix/`.

```
header_checks = pcre:/etc/postfix/header_checks
body_checks = pcre:/etc/postfix/body_checks.pcre
```

* In `main.cf`, find parameter `smtpd_sender_restrictions =`, add a new setting
  `check_sender_access pcre:/etc/postfix/sender_access.pcre` right after
  `permit_sasl_authenticated` like below:

```
smtpd_sender_restrictions =
    ...
    permit_sasl_authenticated
    check_sender_access pcre:/etc/postfix/sender_access.pcre
    ...
```

* Create required files:

```
# touch /etc/postfix/{header_checks,body_checks.pcre,sender_access.pcre}
```

* Reloading or restarting Postfix service is required.

Note: each time you changed the pcre file, you should reload (not restart)
Postfix service so that Postfix can read the changes.

## OpenLDAP backend special

### Fixed: improper ACL control

With default OpenLDAP ACL control set by iRedMail, every mail user has
permission to query the whole LDAP tree (although cannot query sensitive info
like password), we'd better remove this ACL control due to security concern.

* Please open OpenLDAP config file `slapd.conf`, and find below lines:

    * on RHEL/CentOS: it's `/etc/openldap/slapd.conf`.
    * on Debian/Ubuntu: it's `/etc/ldap/slapd.conf`.
    * on FreeBSD: it's `/usr/local/etc/openldap/slapd.conf`.
    * on OpenBSD: it's `/etc/openldap/slapd.conf`.

```
access to dn.subtree="o=domains,dc=example,dc=com"
    by anonymous                    auth
    by self                         write
    by dn.exact="cn=vmail,dc=example,dc=com"   read
    by dn.exact="cn=vmailadmin,dc=example,dc=com"  write
    by dn.regex="mail=[^,]+,ou=Users,domainName=$1,o=domains,dc=example,dc=com$" read
    by users                        read
```

The LDAP suffix `dc=example,dc=com` might be different on your server.

* Remove the 6th line (`by dn.regex="mail=..."`), and replace the line `by users read`
  by `by users none`.

```
access to dn.subtree="o=domains,dc=example,dc=com"
    by anonymous                    auth
    by self                         write
    by dn.exact="cn=vmail,dc=example,dc=com"   read
    by dn.exact="cn=vmailadmin,dc=example,dc=com"  write
    by users                        none
```

* Save your change and restart OpenLDAP service.

### Fixed: Dovecot Master User doesn't work with ACL plugin

iRedMail has both Dovecot Master User and Dovecot `acl` plugin enabled by
default, if `acl` plugin is enabled, the Master User is still subject to ACLs
just like any other user, which means that by default the Master User has no
access to any mailboxes of the user. Please fix this issue by following steps
below.

* Open file `/etc/dovecot/dovecot-ldap.conf` (Linux/OpenBSD) or
  `/usr/local/etc/dovecot/dovecot-ldap.conf` (FreeBSD), find below line:

```
user_attrs      = mail=user, ...
```

* Add new setting `mail=master_user` in `user_attrs` like below:

```
user_attrs      = mail=master_user,mail=user, ...
```

* Restart Dovecot service.

### Add new SQL table `outbound_wblist` in `amavisd` database

We need a new SQL table `outbound_wblist` in `amavisd` database, it's used
to store white/blacklists for outbound message, required by iRedAPD plugin
`amavisd_wblist`.

Please connect to MySQL server as MySQL root user, create new table:

```
$ mysql -uroot -p
mysql> USE amavisd;
mysql> CREATE TABLE outbound_wblist (rid integer unsigned NOT NULL, sid integer unsigned NOT NULL, wb varchar(10) NOT NULL, PRIMARY KEY (rid,sid));
```

After table created, please restart iRedAPD service.

### Add new column `delete_date` in SQL table `iredadmin.deleted_mailboxes`

We need a SQL column to store the date we schedule to delete the mailbox after
removing mail account. This new column might be used by iRedAdmin and other
scripts used to delete mailboxes.

Please connect to MySQL server as MySQL root user, create new table:

```
$ mysql -uroot -p
sql> USE iredadmin;
sql> ALTER TABLE deleted_mailboxes ADD COLUMN delete_date DATE DEFAULT NULL;
sql> CREATE INDEX idx_delete_date ON deleted_mailboxes (delete_date);
```

That's it.

## MySQL/MariaDB backend special

### Add new SQL columns in `vmail` database: `alias.is_alias`, `alias.alias_to`

iRedMail-0.9.3 offers per-user alias address support, that means mail user
`john.smith@domain.com` can have additional email addresses like
`john@domain.com`, `js@domain.com` and more, all emails sent to these addresses
will be delivered to same mailbox. With per-user alias address support, you
don't need to create many mail alias accounts anymore.

Per-user alias address requires 2 new SQL columns:

* `alias.is_alias`: this column marks a SQL record is a per-user alias account.
* `alias.alias_to`: this column stores the target address (it's
  `john.smith@domain.com` as described above). Its value is same as `alias.goto`
  when this sql record is a per-user alias, but `alias.goto` is not good for
  indexed searching, so we create `alias.alias_to` as an alternative.

Please follow steps below to create required SQL columns:

```
$ mysql -uroot -p
sql> USE vmail;
sql> ALTER TABLE alias ADD COLUMN is_alias TINYINT(1) NOT NULL DEFAULT 0;
sql> ALTER TABLE alias ADD COLUMN alias_to VARCHAR(255) NOT NULL DEFAULT '';
sql> ALTER TABLE alias ADD INDEX (is_alias);
sql> ALTER TABLE alias ADD INDEX (alias_to);
```

> __Sample usage__: add additional email addresses `extra@domain.com` for
> existing user `user@domain.com`:
> 
```
sql> USE vmail;
sql> INSERT INTO alias (address, goto, is_alias, alias_to, domain)
                VALUES ('extra@domain.com', 'user@domain.com', 1, 'user@domain.com', 'domain.com');
```
> 
> Notes:
> 
> * Values of column `alias.goto` and `alias.alias_to` are the same.
> * You can add as many additional email addresses as you want.
> * In above sample, `extra@domain.com` can be an email address belong to your alias domain.

### Add new SQL table `outbound_wblist` in `amavisd` database

We need a new SQL table `outbound_wblist` in `amavisd` database, it's used
to store white/blacklists for outbound message, required by iRedAPD plugin
`amavisd_wblist`.

Please connect to MySQL server as MySQL root user, create new table:

```
$ mysql -uroot -p
mysql> USE amavisd;
mysql> CREATE TABLE outbound_wblist (rid integer unsigned NOT NULL, sid integer unsigned NOT NULL, wb varchar(10) NOT NULL, PRIMARY KEY (rid,sid));
```

After table created, please restart iRedAPD service.

### Add new column `delete_date` in SQL table `vmail.deleted_mailboxes`

We need a SQL column to store the date we schedule to delete the mailbox after
removing mail account. This new column might be used by iRedAdmin and other
scripts used to delete mailboxes.

Please connect to MySQL server as MySQL root user, create new table:

```
$ mysql -uroot -p
sql> USE vmail;
sql> ALTER TABLE deleted_mailboxes ADD COLUMN delete_date DATE DEFAULT NULL;
sql> CREATE INDEX idx_delete_date ON deleted_mailboxes (delete_date);
```

### [OPTIONAL] SOGo: enable isolated per-domain global address book

iRedMail doesn't enable global address book by default, this step will help
you enable isolated per-domain global address book.

iRedMail creates a SQL VIEW `sogo.users` in SOGo SQL database, but it doesn't
contain a `domain` column, if you enable global address book, every user is
able to search ALL mail accounts hosted on iRedMail server, so we need to drop
existing SQL VIEW, then re-create it with `domain` column for isolated
per-domain global address book.

Now connect to MySQL server as `root` user, drop existing SQL VIEW
`sogo.users`, then re-create it:

```
$ mysql -uroot -p
sql> USE sogo;
sql> DROP VIEW users;
sql> CREATE VIEW sogo.users (c_uid, c_name, c_password, c_cn, mail, domain) AS SELECT username, username, password, name, username, domain FROM vmail.mailbox WHERE active=1;
```

Open SOGo config file `/etc/sogo/sogo.conf` (Linux, OpenBSD) or
`/usr/local/etc/sogo/sogo.conf` (FreeBSD), find the `SOGoUserSources` block
defined for SQL backend. for example:

```
    // Authentication using SQL
    SOGoUserSources = (
        {
            ...

            //isAddressBook = YES;
            //displayName = "Global Address Book";
        }
    );
```

Uncomment `isAddressBook` and `displayName` lines, and add two new parameters
like below:

```
            isAddressBook = YES;
            displayName = "Global Address Book";
            SOGoEnableDomainBasedUID = YES;
            DomainFieldName = "domain";
```

Restart SOGo service is required.

## PostgreSQL backend special

### Add new SQL columns in `vmail` database: `alias.is_alias`, `alias.alias_to`

iRedMail-0.9.3 offers per-user alias address support, that means mail user
`john.smith@domain.com` can have additional email addresses like
`john@domain.com`, `js@domain.com` and more, all emails sent to these addresses
will be delivered to same mailbox. With per-user alias address support, you
don't need to create many mail alias accounts anymore.

Per-user alias address requires 2 new SQL columns:

* `alias.is_alias`: this column marks a SQL record is a per-user alias account.
* `alias.alias_to`: this column stores the target address (it's
  `john.smith@domain.com` as described above). Its value is same as `alias.goto`
  when this sql record is a per-user alias, but `alias.goto` is not good for
  indexed searching, so we create `alias.alias_to` as an alternative.

Please follow steps below to create required SQL columns:

```
# su - postgres
$ psql -d vmail
sql> ALTER TABLE alias ADD COLUMN is_alias INT2 NOT NULL DEFAULT 0;
sql> ALTER TABLE alias ADD COLUMN alias_to VARCHAR(255) NOT NULL DEFAULT '';
sql> CREATE INDEX idx_alias_is_alias ON alias (is_alias);
sql> CREATE INDEX idx_alias_alias_to ON alias (alias_to);
```

> __Sample usage__: add additional email addresses `extra@domain.com` for
> existing user `user@domain.com`:
> 
```
sql> USE vmail;
sql> INSERT INTO alias (address, goto, is_alias, alias_to, domain)
                VALUES ('extra@domain.com', 'user@domain.com', 1, 'user@domain.com', 'domain.com');
```
> 
> Notes:
> 
> * Values of column `alias.goto` and `alias.alias_to` are the same.
> * You can add as many additional email addresses as you want.
> * In above sample, `extra@domain.com` can be an email address belong to your alias domain.

### Add new SQL table `outbound_wblist` in `amavisd` database

We need a new SQL table `outbound_wblist` in `amavisd` database, it's used
to store white/blacklists for outbound message, required by iRedAPD plugin
`amavisd_wblist`.

Please switch to PostgreSQL daemon user, then execute SQL commands to import it:

* On Linux, PostgreSQL daemon user is `postgres`.
* On FreeBSD, PostgreSQL daemon user is `pgsql`.
* On OpenBSD, PostgreSQL daemon user is `_postgresql`.

```
# su - postgres
$ psql -d amavisd
sql> CREATE TABLE outbound_wblist (rid integer NOT NULL CHECK (rid >= 0), sid integer NOT NULL CHECK (sid >= 0), wb varchar(10) NOT NULL, PRIMARY KEY (rid,sid));
sql> ALTER TABLE outbound_wblist OWNER TO 'amavisd';
```

After table created, please restart iRedAPD service.

### Add new column `delete_date` in SQL table `vmail.deleted_mailboxes`

We need a SQL column to store the date we schedule to delete the mailbox after
removing mail account. This new column might be used by iRedAdmin and other
scripts used to delete mailboxes.

Please switch to PostgreSQL daemon user, then execute SQL commands to import it:

* On Linux, PostgreSQL daemon user is `postgres`.
* On FreeBSD, PostgreSQL daemon user is `pgsql`.
* On OpenBSD, PostgreSQL daemon user is `_postgresql`.

```
# su - postgres
$ psql -d vmail
sql> ALTER TABLE deleted_mailboxes ADD COLUMN delete_date DATE DEFAULT NULL;
sql> CREATE INDEX idx_delete_date ON deleted_mailboxes (delete_date);
```

That's it.
### [OPTIONAL] SOGo: enable isolated per-domain global address book

iRedMail doesn't enable global address book by default, this step will help
you enable isolated per-domain global address book.

iRedMail creates a SQL VIEW `sogo.users` in SOGo SQL database, but it doesn't
contain a `domain` column, if you enable global address book, every user is
able to search ALL mail accounts hosted on iRedMail server, so we need to drop
existing SQL VIEW, then re-create it with `domain` column for isolated
per-domain global address book.

Before we go further, we must find the SQL username/password used to query
`vmail` SQL database in `/etc/postfix/pgsql/*.cf` (on FreeBSD, it's
`/usr/local/etc/postfix/pgsql/*.cf`). for example:

```
hosts       = 127.0.0.1
port        = 3306
user        = vmail
password    = NGtLm0jFiwwOH5AeQtTsSAkScUMdFc
dbname      = vmail
```

We need SQL server address, port, user, password and database name.

Now connect to PostgreSQL server as admin user, drop existing SQL VIEW
`sogo.users`, and re-create it.

> __WARNING__: You must replace the `vmail` database username and password by
> the real ones found in `/etc/postfix/pgsql/*.cf`.

```
# su - postgres
$ psql -d sogo
sql> DROP TABLE users;
sql> CREATE VIEW users AS SELECT * FROM dblink('host=127.0.0.1 port=5432 user=vmail password=NGtLm0jFiwwOH5AeQtTsSAkScUMdFc dbname=vmail', 'SELECT username AS c_uid, username AS c_name, password AS c_password, name AS c_cn, username AS mail, domain AS domain FROM mailbox WHERE active=1') AS users (c_uid VARCHAR(255), c_name VARCHAR(255), c_password VARCHAR(255), c_cn VARCHAR(255), mail VARCHAR(255), domain VARCHAR(255));
sql> ALTER TABLE users OWNER TO sogo;
```

Open SOGo config file `/etc/sogo/sogo.conf` (Linux, OpenBSD) or
`/usr/local/etc/sogo/sogo.conf` (FreeBSD), find the `SOGoUserSources` block
defined for SQL backend. for example:

```
    // Authentication using SQL
    SOGoUserSources = (
        {
            ...

            //isAddressBook = YES;
            //displayName = "Global Address Book";
        }
    );
```

Uncomment `isAddressBook` and `displayName` lines, and add two new parameters
like below:

```
            isAddressBook = YES;
            displayName = "Global Address Book";
            SOGoEnableDomainBasedUID = YES;
            DomainFieldName = "domain";
```

Restart SOGo service is required.
