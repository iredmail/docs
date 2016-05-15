# Upgrade iRedMail from 0.9.4 to 0.9.5

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](../support.html) and [contact us](../contact.html).

## ChangeLog

* May 3, 2016: Initial publish.

## General (All backends should apply these steps)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
0.9.5
```

### Upgrade iRedAPD (Postfix policy server) to the latest stable release (1.9.0)

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

Detailed release notes are available [here](./iredapd.releases.html).

### Upgrade iRedAdmin (open source edition) to the latest stable release (0.6.1)

Please follow this tutorial to upgrade iRedAdmin open source edition to the
latest stable release:
[Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html)

### Upgrade Roundcube webmail to the latest stable release (1.1.5)

Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release immediately: [How to upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).

Note: package `rsync` must be installed on your server before upgrading.

### [Linux] Fixed: not add ssh port number in Fail2ban config file (jail.local)

!!! attention

    If your `jail.local` uses `action = iptables-allports`, then you can skip
    this step.

iRedMail-0.9.4 doesn't list ssh port number in 2 Fail2ban jails: `sshd`,
`sshd-ddos`, this causes Fail2ban doesn't block bad client IP address for
ssh service.

* Please open Fail2ban config file `/etc/fail2ban/jail.local`, find lines below:

```
[sshd]
...
action      = iptables-multiport[name=sshd, port="http,https,smtp,submission,pop3,pop3s,imap,imaps,sieve", protocol=tcp]

[sshd-ddos]
...
action      = iptables-multiport[name=sshd-ddos, port="http,https,smtp,submission,pop3,pop3s,imap,imaps,sieve", protocol=tcp]
```

* Append your ssh service name `ssh` in the `port=` parameter like below. If
  you're running ssh service on different port number, please append the port
  number directly:

```
[sshd]
...
action      = iptables-multiport[name=sshd, port="http,https,smtp,submission,pop3,pop3s,imap,imaps,sieve,ssh", protocol=tcp]

[sshd-ddos]
...
action      = iptables-multiport[name=sshd-ddos, port="http,https,smtp,submission,pop3,pop3s,imap,imaps,sieve,ssh", protocol=tcp]
```

Restarting Fail2ban service is required.

### Fixed: Not perform banned file types checking on RHEL/CentOS/OpenBSD/FreeBSD

!!! attention

    This is __NOT__ applicable to Debian and Ubuntu.

There's a bug in iRedMail-0.9.3 and 0.9.4, it didn't comment out setting
`bypass_banned_checks_maps` in parameter `$policy_bank{'ORIGINATING'} = {}`,
this causes Amavisd won't perform banned file types checking for outgoing
emails sent through SMTP AUTH. Please follw steps below to fix it.

Open Amavisd config file, find parameter `$policy_bank{'ORIGINATING'} =` like
below:

* on RHEL/CentOS: it's `/etc/amavisd/amavisd.conf`
* on FreeBSD: it's `/usr/local/etc/amavisd.conf`
* on OpenBSD: it's `/etc/amavisd.conf`

```
$policy_bank{'ORIGINATING'} = {
    ...
    bypass_banned_checks_maps => [1],
    ...
};
```

Comment out line `bypass_banned_checks_maps` like below:

```
$policy_bank{'ORIGINATING'} = {
    ...
    #bypass_banned_checks_maps => [1],
    ...
};
```

Save the change. Restarting amavisd service is required.

### Fixed: not add alias for `virusalert` on RHEL/CentOS/OpenBSD/FreeBSD

!!! attention

    This is __NOT__ applicable to Debian and Ubuntu.

There's a bug in iRedMail-0.9.4, it adds alias `virusalert` on only Debian and
Ubuntu, but not other OSes. Please fix it with below commands:

* For Linux and OpenBSD:

```shell
perl -pi -e 's/(virusalert:.*)/#${1}/g' /etc/postfix/aliases
echo -e '\nvirusalert: root' >> /etc/postfix/aliases
postalias /etc/postfix/aliases
```

* For FreeBSD:

```shell
perl -pi -e 's/(virusalert:.*)/#${1}/g' /usr/local/etc/postfix/aliases
echo -e '\nvirusalert: root' >> /usr/local/etc/postfix/aliases
postalias /usr/local/etc/postfix/aliases
```

### Fixed: Improper Nginx proxy timeout setting for SOGo

!!! attention

    This is applicable to Nginx, not Apache (Apache has proper proxy timeout setting).

iRedMail-0.9.4 and early releases didn't set proper proxy timeout setting in
Nginx, this will cause error `client disconnected during delivery of response`
while SOGo trying to push mailbox changes. Below settings will fix this issue.

* Open Nginx config file `/etc/nginx/templates/sogo.tmpl`
    * If your iRedMail server was installed with iRedMail-0.9.4, it's
      `/etc/nginx/templates/sogo.tmpl` (Linux/OpenBSD) or
      `/usr/local/etc/nginx/templates/sogo.tmpl` (FreeBSD).
    * If your iRedMail server was installed with early release and upgraded to
      iRedMail-0.9.4, it's `/etc/nginx/conf.d/default.conf` (Linux/OpenBSD)
      or `/usr/local/etc/nginx/conf.d/default.conf` (FreeBSD).

* Find setting like below:

```
location ^~ /Microsoft-Server-ActiveSync {
    ...
}

location ^~ /SOGo/Microsoft-Server-ActiveSync {
    ...
}
```

* Add 3 proxy timeout settings in both `location {}` blocks like below:

!!! warning

    The timeout value, `360` (seconds), used below must be same as the value of
    parameter `SOGoMaximumPingInterval =` in SOGo config file `/etc/sogo/sogo.conf`
    (Linux/OpenBSD) or `/usr/local/etc/sogo/sogo.conf`. if your `sogo.conf`
    doesn't have this setting, please add it manually (`SOGoMaximumPingInterval = 360;`).

```
location ^~ /Microsoft-Server-ActiveSync {
    ...
    proxy_connect_timeout 360;
    proxy_send_timeout 360;
    proxy_read_timeout 360;
}

location ^~ /SOGo/Microsoft-Server-ActiveSync {
    ...
    proxy_connect_timeout 360;
    proxy_send_timeout 360;
    proxy_read_timeout 360;
}
```

* Restarting Nginx service is required.

### [RHEL/CentOS] Fixed: Not enable cron job to update SpamAssassin rules

Note: this is applicable to only RHEL and CentOS.

In iRedMail-0.9.4 and earlier releases, iRedMail didn't enable cron job to
update SpamAssassin rules. Please run commands below to fix it.

```shell
perl -pi -e 's/^(SAUPDATE=yes)/#${1}/' /etc/sysconfig/sa-update
echo 'SAUPDATE=yes' >> /etc/sysconfig/sa-update
```

### [RHEL/CentOS] Fixed: Not create required directory used to store PHP session files

Note: this is applicable to only RHEL and CentOS if you're __running Nginx + php-fpm__.

In iRedMail-0.9.4 and earlier releases, iRedMail didn't create directory used
to store PHP session files, it will cause error when your PHP application tries
to create session file. Please fix it with commands below:

```shell
mkdir /var/lib/php/session
chown root:root /var/lib/php/session
chmod 0773 /var/lib/php/session
chmod o+t /var/lib/php/session
```

### [OpenBSD] Add script and daily cron job to backup ldapd database

!!! attention

    This is applicable to only OpenBSD with ldapd backend (not OpenLDAP, MySQL, PostgreSQL).

In iRedMail-0.9.4 and early releases, iRedMail incorrectly used script for
backing up OpenLDAP to backup ldapd, this causes empty backup. Please fix it with
steps below.

* Download script used to backup ldapd and copy it to `/var/vmail/backup` (this
  is default backup directory, it might be changed during iRedMail installation,
  so please copy to the correct directory on your server):

```
cd /var/vmail/backup/
wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/tools/backup_ldapd.sh
chown root:wheel backup_ldapd.sh
chmod 0500 backup_ldapd.sh
```

* Edit file `/var/vmail/backup/backup_ldapd.sh`, update parameters with proper
  values:

    * You should use LDAP suffix as value of `LDAP_BASE_DN` to backup whole
      LDAP tree.
    * You should use LDAP root dn and password as `LDAP_BIND_DN` and
      `LDAP_BIND_PASSWORD`, so that it has required privilege to query whole
      LDAP tree.
    * You can find all required values in `iRedMail.tips` file under iRedMail
      installation directory. for example, `/root/iRedMail-0.9.4/iRedMail.tips`.

```
# LDAP base dn, bind dn and password.
export LDAP_BASE_DN='dc=example,dc=com'
export LDAP_BIND_DN='cn=Manager,dc=example,dc=com'
export LDAP_BIND_PASSWORD='password'

# Where to store backup copies.
export BACKUP_ROOTDIR='/var/vmail/backup'

# Keep backup for how many days. Default is 90 days.
export KEEP_DAYS='90'
```

If you want to store backup status in SQL database `iredadmin` (so that you
can check backup status in iRedAdmin), please set correct SQL username and
password in parameters `MYSQL_USER` and `MYSQL_PASSWD` in
file `/var/vmail/backup/backup_ldapd.sh`:

```
# MySQL user and password, used to log backup status to sql table `iredadmin.log`.
# You can find password of SQL user 'iredadmin' in iRedAdmin config file 'settings.py'.
export MYSQL_USER='iredadmin'
export MYSQL_PASSWD='passwd'
```

* Run this script manually to backup ldapd immediately, check whether or not
  it works: make sure the backup file contains valid/correct LDIF data, and
  SQL table `iredadmin.log` contains a record of this backup.

```
bash backup_ldapd.sh
```

* Edit root's cron job with command:

```
crontab -e -u root
```

* Find the daily cron job used to run script `backup_openldap.sh` like below:

```
0   3   *   *   *   /usr/local/bin/bash /var/vmail/backup/backup_openldap.sh
```

* Rename `backup_openldap.sh` to `backup_ldapd.sh`, and make sure the absolute
  path of this script is correct:

```
0   3   *   *   *   /usr/local/bin/bash /var/vmail/backup/backup_ldapd.sh
```

* Save your changes.

### [OPTIONAL] Add custom Amavisd log template to always log SpamAssassin testing result

!!! attention

    Note: This step is totally optional.

It's helpful if you can see SpamAssassin testing result in log file at Amavisd
log_level 0.

Open Amavisd config file `amavisd.conf`, add below lines in BEFORE the last line `1;  # insure a defined return value`:

* on RHEL/CentOS: it's `/etc/amavisd/amavisd.conf`.
* on Debian/Ubuntu: it's `/etc/amavis/conf.d/50-user`.
* on FreeBSD: it's `/usr/local/etc/amavisd.conf`.
* on OpenBSD: it's `/etc/amavisd.conf`.

```
# Custom short log template (at log_level 0), add SpamAssassin testing result (Tests: [xxx])
#
# Note: You can find the original log template at the bottom of
#       /usr/sbin/amavisd-new.
$log_templ = '
[?%#D|#|Passed #
[? [:ccat|major] |#
OTHER|CLEAN|MTA-BLOCKED|OVERSIZED|BAD-HEADER-[:ccat|minor]|SPAMMY|SPAM|\
UNCHECKED[?[:ccat|minor]||-ENCRYPTED|]|BANNED (%F)|INFECTED (%V)]#
 {[:actions_performed]}#
,[?%p|| %p][?%a||[?%l|| LOCAL] [:client_addr_port]][?%e|| \[%e\]] [:mail_addr_decode_octets|%s] -> [%D|[:mail_addr_decode_octets|%D]|,]#
[? %q ||, quarantine: %q]#
[? %Q ||, Queue-ID: %Q]#
[? %m ||, Message-ID: [:mail_addr_decode_octets|%m]]#
[? %r ||, Resent-Message-ID: [:mail_addr_decode_octets|%r]]#
[? %i ||, mail_id: %i]#
, Hits: [:SCORE]#
, size: %z#
[? [:partition_tag] ||, pt: [:partition_tag]]#
[~[:remote_mta_smtp_response]|["^$"]||[", queued_as: "]]\
[remote_mta_smtp_response|[~%x|["queued as ([0-9A-Za-z]+)$"]|["%1"]|["%0"]]|/]#
#, Subject: [:dquote|[:mime2utf8|[:header_field_octets|Subject]|100|1]]#
#, From: [:uquote|[:mail_addr_decode_octets|[:rfc2822_from]]]#
[? [:dkim|sig_sd]    ||, dkim_sd=[:dkim|sig_sd]]#
[? [:dkim|newsig_sd] ||, dkim_new=[:dkim|newsig_sd]]#
, %y ms#
[? %#T ||, Tests: \[[%T|,]\]]#
]
[?%#O|#|Blocked #
[? [:ccat|major|blocking] |#
OTHER|CLEAN|MTA-BLOCKED|OVERSIZED|BAD-HEADER-[:ccat|minor]|SPAMMY|SPAM|\
UNCHECKED[?[:ccat|minor]||-ENCRYPTED|]|BANNED (%F)|INFECTED (%V)]#
 {[:actions_performed]}#
,[?%p|| %p][?%a||[?%l|| LOCAL] [:client_addr_port]][?%e|| \[%e\]] [:mail_addr_decode_octets|%s] -> [%O|[:mail_addr_decode_octets|%O]|,]#
[? %q ||, quarantine: %q]#
[? %Q ||, Queue-ID: %Q]#
[? %m ||, Message-ID: [:mail_addr_decode_octets|%m]]#
[? %r ||, Resent-Message-ID: [:mail_addr_decode_octets|%r]]#
[? %i ||, mail_id: %i]#
, Hits: [:SCORE]#
, size: %z#
[? [:partition_tag] ||, pt: [:partition_tag]]#
#, Subject: [:dquote|[:mime2utf8|[:header_field_octets|Subject]|100|1]]#
#, From: [:uquote|[:mail_addr_decode_octets|[:rfc2822_from]]]#
[? [:dkim|sig_sd]    ||, dkim_sd=[:dkim|sig_sd]]#
[? [:dkim|newsig_sd] ||, dkim_new=[:dkim|newsig_sd]]#
, %y ms#
[? %#T ||, Tests: \[[%T|,]\]]#
]';
```

Restarting Amavisd service is required.

## OpenLDAP backend special

### NEW: Support Postfix `sender_dependent_relayhost_maps`

#### Summary

Postfix setting `relayhost` allows Postfix to relay outbound emails to
specified mail server instead of connecting recipient server directly. Sender
dependent relayhost (controlled by parameter `sender_dependent_relayhost_maps`)
allows you to define per-user or per-domain relayhost, it
overrides the global `relayhost` parameter setting. Specified query tables are
searched by the envelope sender address (`user@domain.com`) and domain name
(`@domain.com`). For more details, please read Postfix document:

* Postfix parameter: [`sender_dependent_relayhost_maps`](http://www.postfix.org/postconf.5.html#sender_dependent_relayhost_maps)
* Postfix manual page: [transport(5)](http://www.postfix.org/transport.5.html)

To support `sender_dependent_relayhost_maps`, we need some modification on
iRedMail server:

* one updated iRedMail OpenLDAP schema file with new attribute: `senderRelayHost`
* two new LDAP lookup files:
    * `/etc/postfix/ldap/sender_dependent_relayhost_maps_domain.cf`
    * `/etc/postfix/ldap/sender_dependent_relayhost_maps_user.cf`
* one new Postfix parameter: `sender_dependent_relayhost_maps`

#### Use the latest iRedMail LDAP schema file

* On RHEL/CentOS:

```
cd /tmp
wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/iredmail.schema

cd /etc/openldap/schema/
cp iredmail.schema iredmail.schema.bak

cp -f /tmp/iredmail.schema /etc/openldap/schema/
service slapd restart
```

* On Debian/Ubuntu:
```
cd /tmp
wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/iredmail.schema

cd /etc/ldap/schema/
cp iredmail.schema iredmail.schema.bak

cp -f /tmp/iredmail.schema /etc/ldap/schema/
service slapd restart
```

* On FreeBSD:

```
cd /tmp
wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/iredmail.schema

cd /usr/local/etc/ldap/schema/
cp iredmail.schema iredmail.schema.bak

cp -f /tmp/iredmail.schema /usr/local/etc/openldap/schema/
service slapd restart
```

* On OpenBSD:

```
cd /tmp
ftp https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/iredmail.schema

cd /etc/openldap/schema/
cp iredmail.schema iredmail.schema.bak

cp -f /tmp/iredmail.schema /etc/openldap/schema/
rcctl restart ldapd
```

#### Create LDAP lookup files

* On Linux/OpenBSD:

```
cd /etc/postfix/ldap/
cp -p transport_maps_domain.cf sender_dependent_relayhost_maps_domain.cf
cp -p transport_maps_user.cf sender_dependent_relayhost_maps_user.cf
perl -pi -e 's#%s#%d#g' sender_dependent_relayhost_maps_domain.cf
perl -pi -e 's#mtaTransport#senderRelayHost#g' sender_dependent_relayhost_maps*.cf
```

* On FreeBSD:

```
cd /usr/local/etc/postfix/ldap/
cp -p transport_maps_domain.cf sender_dependent_relayhost_maps_domain.cf
cp -p transport_maps_user.cf sender_dependent_relayhost_maps_user.cf
perl -pi -e 's#%s#%d#g' sender_dependent_relayhost_maps_domain.cf
perl -pi -e 's#mtaTransport#senderRelayHost#g' sender_dependent_relayhost_maps*.cf
```

#### Update Postfix settings in `/etc/postfix/main.cf`

We need to update 2 parameters in Postfix config file: `proxy_read_maps`,
`sender_dependent_relayhost_maps`.

* On __Linux/OpenBSD__, please run 2 commands below to update Postfix settings:

```
postconf -e proxy_read_maps='$canonical_maps $lmtp_generic_maps $local_recipient_maps $mydestination $mynetworks $recipient_bcc_maps $recipient_canonical_maps $relay_domains $relay_recipient_maps $relocated_maps $sender_bcc_maps $sender_canonical_maps $smtp_generic_maps $smtpd_sender_login_maps $transport_maps $virtual_alias_domains $virtual_alias_maps $virtual_mailbox_domains $virtual_mailbox_maps $smtpd_sender_restrictions $sender_dependent_relayhost_maps'

postconf -e sender_dependent_relayhost_maps='proxy:ldap:/etc/postfix/ldap/sender_dependent_relayhost_maps_domain.cf, proxy:ldap:/etc/postfix/ldap/sender_dependent_relayhost_maps_user.cf'
```

* On __FreeBSD__, please run 2 commands below to update Postfix settings:

```
postconf -e proxy_read_maps='$canonical_maps $lmtp_generic_maps $local_recipient_maps $mydestination $mynetworks $recipient_bcc_maps $recipient_canonical_maps $relay_domains $relay_recipient_maps $relocated_maps $sender_bcc_maps $sender_canonical_maps $smtp_generic_maps $smtpd_sender_login_maps $transport_maps $virtual_alias_domains $virtual_alias_maps $virtual_mailbox_domains $virtual_mailbox_maps $smtpd_sender_restrictions $sender_dependent_relayhost_maps'

postconf -e sender_dependent_relayhost_maps='proxy:ldap:/usr/local/etc/postfix/ldap/sender_dependent_relayhost_maps_domain.cf, proxy:ldap:/usr/local/etc/postfix/ldap/sender_dependent_relayhost_maps_user.cf'
```

Reload or restart Postfix service is required.

### NEW: Able to enable/disable SOGo access for a single user

With steps below, system admin is able to control which users can access SOGo
Groupware (webmail, calendar, contacts, ActiveSync).

To accomplish this, we need to add a new LDAP attribute/value pair
`enabledService=sogo` for existing mail users, then update SOGo config file to
use this condition while querying user accounts.

#### Add required LDAP attribute/value for existing mail users

* Download below script to update existing mail users:

```
cd /root/
wget https://bitbucket.org/zhb/iredmail/raw/default/extra/update/updateLDAPValues_094_to_095.py
```

* Open downloaded file `updateLDAPValues_094_to_095.py`, set LDAP server
  related settings in this file. For example:

```
# Part of file: updateLDAPValues_094_to_095.py

uri = 'ldap://127.0.0.1:389'
basedn = 'o=domains,dc=example,dc=com'
bind_dn = 'cn=vmailadmin,dc=example,dc=com'
bind_pw = 'passwd'
```

You can find required LDAP credential in iRedAdmin config file or
`iRedMail.tips` file under your iRedMail installation directory. Using either
`cn=Manager,dc=xx,dc=xx` or `cn=vmailadmin,dc=xx,dc=xx` as bind dn is ok, both
of them have read-write privilege to update mail accounts.

* Execute this script, it will add required data:

```
# python updateLDAPValues_094_to_095.py
```

#### Update SOGo config file

* On Linux/OpenBSD, please update file `/etc/sogo/sogo.conf`.
* On FreeBSD, please update file /usr/local/etc/sogo/sogo.conf`.

Open SOGo config file `sogo.conf`, find below line:

```
filter = "objectClass=mailUser AND accountStatus=active AND enabledService=mail";
```

Add new condition `AND enabledService=sogo` in `filter =` setting, the final
setting is:

```
filter = "objectClass=mailUser AND accountStatus=active AND enabledService=mail AND enabledService=sogo";
```

Save your change and restart SOGo service.

It's now able to enable or disable SOGo access for a single user by adding or
removing `enabledService=sogo` for this user.

## MySQL/MariaDB backend special

### NEW: Support Postfix `sender_dependent_relayhost_maps`

#### Summary

Postfix setting `relayhost` allows Postfix to relay outbound emails to
specified mail server instead of connecting recipient server directly. Sender
dependent relayhost (controlled by parameter `sender_dependent_relayhost_maps`)
allows you to define per-user or per-domain relayhost, it
overrides the global `relayhost` parameter setting. Specified query tables are
searched by the envelope sender address (`user@domain.com`) and domain name
(`@domain.com`). For more details, please read Postfix document:

* Postfix parameter: [`sender_dependent_relayhost_maps`](http://www.postfix.org/postconf.5.html#sender_dependent_relayhost_maps)
* Postfix manual page: [transport(5)](http://www.postfix.org/transport.5.html)

To support `sender_dependent_relayhost_maps`, we need some modification on
iRedMail server:

* a new SQL table: `vmail.sender_relayhost`
* a new SQL lookup file: `/etc/postfix/mysql/sender_dependent_relayhost_maps.cf`
* a new Postfix parameter: `sender_dependent_relayhost_maps`

#### Create SQL table `vmail.sender_relayhost`

Please connect to MySQL server as MySQL root user, and execute SQL commands
below to create this new table:

```
# mysql -uroot -p
sql> USE vmail;
sql> CREATE TABLE IF NOT EXISTS sender_relayhost (
    id BIGINT(20) UNSIGNED AUTO_INCREMENT,
    account VARCHAR(255) NOT NULL DEFAULT '',
    relayhost VARCHAR(255) NOT NULL DEFAULT '',
    PRIMARY KEY (id),
    UNIQUE INDEX (account)
) ENGINE=InnoDB;
```

#### Create SQL lookup file: `sender_dependent_relayhost_maps.cf`

Create sql lookup file by copying an existing file:

* On Linux/OpenBSD:

```
cd /etc/postfix/mysql/
cp -p catchall_maps.cf sender_dependent_relayhost_maps.cf
```

* On FreeBSD:

```
cd /usr/local/etc/postfix/mysql/
cp -p catchall_maps.cf sender_dependent_relayhost_maps.cf
```

Open file `sender_dependent_relayhost_maps.cf`, __REPLACE__ the `query =` line
by below one:

```
query       = SELECT relayhost FROM sender_relayhost WHERE account='%s' LIMIT 1
```

#### Update Postfix settings in `/etc/postfix/main.cf`

We need to update 2 parameters in Postfix config file: `proxy_read_maps`,
`sender_dependent_relayhost_maps`.

* On __Linux/OpenBSD__, please run 2 commands below to update Postfix settings:

```
postconf -e proxy_read_maps='$canonical_maps $lmtp_generic_maps $local_recipient_maps $mydestination $mynetworks $recipient_bcc_maps $recipient_canonical_maps $relay_domains $relay_recipient_maps $relocated_maps $sender_bcc_maps $sender_canonical_maps $smtp_generic_maps $smtpd_sender_login_maps $transport_maps $virtual_alias_domains $virtual_alias_maps $virtual_mailbox_domains $virtual_mailbox_maps $smtpd_sender_restrictions $sender_dependent_relayhost_maps'

postconf -e sender_dependent_relayhost_maps='proxy:mysql:/etc/postfix/mysql/sender_dependent_relayhost_maps.cf'
```

* On __FreeBSD__, please run 2 commands below to update Postfix settings:

```
postconf -e proxy_read_maps='$canonical_maps $lmtp_generic_maps $local_recipient_maps $mydestination $mynetworks $recipient_bcc_maps $recipient_canonical_maps $relay_domains $relay_recipient_maps $relocated_maps $sender_bcc_maps $sender_canonical_maps $smtp_generic_maps $smtpd_sender_login_maps $transport_maps $virtual_alias_domains $virtual_alias_maps $virtual_mailbox_domains $virtual_mailbox_maps $smtpd_sender_restrictions $sender_dependent_relayhost_maps'

postconf -e sender_dependent_relayhost_maps='proxy:mysql:/usr/local/etc/postfix/mysql/sender_dependent_relayhost_maps.cf'
```

Reload or restart Postfix service is required.

### NEW: Able to enable/disable SOGo access for a single user

With steps below, system admin is able to control which users can access SOGo
Groupware (webmail, calendar, contacts, ActiveSync).

To accomplish this, we need to add a new SQL column `enablesogo` in SQL table
`vmail.mailbox`, then re-create SQL VIEW `sogo.users`.

Please login to MySQL/MariaDB as SQL root user first:

```
# mysql -uroot -p
```

Then execute SQL commands below to add required new SQL column and re-create
SQL VIEW `sogo.users`:

```
sql> USE vmail;
sql> ALTER TABLE mailbox ADD COLUMN enablesogo TINYINT(1) NOT NULL DEFAULT 1;
sql> ALTER TABLE mailbox ADD INDEX (enablesogo);

sql> USE sogo;
sql> DROP VIEW users;
sql> CREATE VIEW sogo.users (c_uid, c_name, c_password, c_cn, mail, domain) AS SELECT username, username, password, name, username, domain FROM vmail.mailbox WHERE enablesogo=1 AND active=1;
```

It's now able to enable SOGo access for a single user by setting
`mailbox.enablesogo=1`, or disable the access with `mailbox.enablesogo=0`.

## PostgreSQL backend special

### NEW: Support Postfix `sender_dependent_relayhost_maps`

#### Summary

Postfix setting `relayhost` allows Postfix to relay outbound emails to
specified mail server instead of connecting recipient server directly. Sender
dependent relayhost (controlled by parameter `sender_dependent_relayhost_maps`)
allows you to define per-user or per-domain relayhost, it
overrides the global `relayhost` parameter setting. Specified query tables are
searched by the envelope sender address (`user@domain.com`) and domain name
(`@domain.com`). For more details, please read Postfix document:

* Postfix parameter: [`sender_dependent_relayhost_maps`](http://www.postfix.org/postconf.5.html#sender_dependent_relayhost_maps)
* Postfix manual page: [transport(5)](http://www.postfix.org/transport.5.html)

To support `sender_dependent_relayhost_maps`, we need some modification on
iRedMail server:

* a new SQL table: `vmail.sender_relayhost`
* a new SQL lookup file: `/etc/postfix/mysql/sender_dependent_relayhost_maps.cf`
* a new Postfix parameter: `sender_dependent_relayhost_maps`

#### Create SQL table `vmail.sender_relayhost`

Please follow steps below to create this new table:

```
# su - postgres
$ psql -d vmail
sql> CREATE TABLE sender_relayhost (
    id SERIAL PRIMARY KEY,
    account VARCHAR(255) NOT NULL DEFAULT '',
    relayhost VARCHAR(255) NOT NULL DEFAULT ''
);

sql> CREATE INDEX idx_sender_relayhost_account ON sender_relayhost (account);
sql> ALTER TABLE sender_relayhost OWNER TO vmailadmin;
sql> GRANT SELECT ON sender_relayhost TO vmail;
```

#### Create SQL lookup file: `sender_dependent_relayhost_maps.cf`

Create sql lookup file by copying an existing file:

* On Linux/OpenBSD:

```
cd /etc/postfix/pgsql/
cp -p catchall_maps.cf sender_dependent_relayhost_maps.cf
```

* On FreeBSD:

```
cd /usr/local/etc/postfix/pgsql/
cp -p catchall_maps.cf sender_dependent_relayhost_maps.cf
```

Open file `sender_dependent_relayhost_maps.cf`, __REPLACE__ the `query =` line
by below one:

```
query       = SELECT relayhost FROM sender_relayhost WHERE account='%s' LIMIT 1
```

#### Update Postfix settings in `/etc/postfix/main.cf`

We need to update 2 parameters in Postfix config file: `proxy_read_maps`,
`sender_dependent_relayhost_maps`.

* On __Linux/OpenBSD__, please run 2 commands below to update Postfix settings:

```
postconf -e proxy_read_maps='$canonical_maps $lmtp_generic_maps $local_recipient_maps $mydestination $mynetworks $recipient_bcc_maps $recipient_canonical_maps $relay_domains $relay_recipient_maps $relocated_maps $sender_bcc_maps $sender_canonical_maps $smtp_generic_maps $smtpd_sender_login_maps $transport_maps $virtual_alias_domains $virtual_alias_maps $virtual_mailbox_domains $virtual_mailbox_maps $smtpd_sender_restrictions $sender_dependent_relayhost_maps'

postconf -e sender_dependent_relayhost_maps='proxy:pgsql:/etc/postfix/pgsql/sender_dependent_relayhost_maps.cf'
```

* On __FreeBSD__, please run 2 commands below to update Postfix settings:

```
postconf -e proxy_read_maps='$canonical_maps $lmtp_generic_maps $local_recipient_maps $mydestination $mynetworks $recipient_bcc_maps $recipient_canonical_maps $relay_domains $relay_recipient_maps $relocated_maps $sender_bcc_maps $sender_canonical_maps $smtp_generic_maps $smtpd_sender_login_maps $transport_maps $virtual_alias_domains $virtual_alias_maps $virtual_mailbox_domains $virtual_mailbox_maps $smtpd_sender_restrictions $sender_dependent_relayhost_maps'

postconf -e sender_dependent_relayhost_maps='proxy:mysql:/usr/local/etc/postfix/mysql/sender_dependent_relayhost_maps.cf'
```

Reload or restart Postfix service is required.

### NEW: Able to enable/disable SOGo access for a single user

With steps below, system admin is able to control which users can access SOGo
Groupware (webmail, calendar, contacts, ActiveSync).

To accomplish this, we need to add a new SQL column `enablesogo` in SQL table
`vmail.mailbox`, then re-create SQL VIEW `sogo.users`.

Before we go further, please find the SQL password for SQL user `vmail`
in Postfix config file `/etc/postfix/pgsql/*.cf` (on Linux/OpenBSD) or
`/usr/local/etc/postfix/pgsql/*.cf` (on FreeBSD), we need this while
(re-)creating SQL VIEW `sogo.users`.

Please login to PostgreSQL database as SQL root user first:

* on Linux, the root user name is `postgres`
* on FreeBSD, the root user name is `pgsql`
* on OpenBSD, the root user name is `_postgresql`

```
# su - postgres
$ psql -d vmail
```

Then execute SQL commands below to add required new SQL column and re-create
SQL VIEW `sogo.users`:

```sql
sql> \c vmail;
sql> ALTER TABLE mailbox ADD COLUMN enablesogo INT2 NOT NULL DEFAULT 1;
sql> CREATE INDEX idx_mailbox_enablesogo ON mailbox (enablesogo);

sql> \c sogo;
sql> DROP VIEW users;
```

Be careful, you must replace string `VMAIL_PASSWORD` in SQL command below
by the real password of SQL user `vmail`:

```sql
sql> CREATE VIEW users
              AS SELECT * FROM dblink('host=127.0.0.1
                                       port=5432
                                       dbname=vmail
                                       user=vmail
                                       password=VMAIL_PASSWORD',
                                       'SELECT username AS c_uid,
                                               username AS c_name,
                                               password AS c_password,
                                               name AS c_cn,
                                               username AS mail,
                                               domain AS domain
                                          FROM mailbox
                                         WHERE enablesogo=1 AND active=1')
              AS users (c_uid VARCHAR(255),
                        c_name VARCHAR(255),
                        c_password VARCHAR(255),
                        c_cn VARCHAR(255),
                        mail VARCHAR(255),
                        domain VARCHAR(255));

sql> ALTER TABLE users OWNER TO sogo;
sql> EXIT;
```

It's now able to enable SOGo access for a single user by setting
`mailbox.enablesogo=1`, or disable the access with `mailbox.enablesogo=0`.

