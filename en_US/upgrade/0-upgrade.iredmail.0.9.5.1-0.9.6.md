# Upgrade iRedMail from 0.9.5-1 to 0.9.6

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! note "Remote Upgrade Assistance"

    Check out our [remote upgrade support](https://www.iredmail.org/support.html) if you need assistance.

## ChangeLog

* Jan 23, 2016: Initial publish.

## General (All backends should apply these steps)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
0.9.6
```

### Upgrade iRedAPD (Postfix policy server) to the latest stable release (2.0)

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

Detailed release notes are available [here](./iredapd.releases.html).

### Upgrade iRedAdmin (open source edition) to the latest stable release (0.7)

Please follow this tutorial to upgrade iRedAdmin open source edition to the
latest stable release:
[Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html)

### Upgrade Roundcube webmail to the latest stable release (1.2.3)

Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release immediately: [How to upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).

Note: package `rsync` must be installed on your server before upgrading.

### Fixed: HTTProxy vulnerability in Apache and Nginx

For more details about HTTPROXY vulnerability, please read this website: <https://httpoxy.org/>

#### Apache

Please append setting below in Apache config file:

* on RHEL/CentOS, it's `/etc/httpd/conf/httpd.conf`.
* on Debian/Ubuntu, it's `/etc/apache2/apache2.conf`.
* on FreeBSD, it's `/usr/local/etc/apache2[X]/httpd.conf`. Please replace
  `apache2[X]` by the real Apache version number here.
* on OpenBSD: not applicable because iRedMail doesn't use Apache on OpenBSD.

```
RequestHeader unset Proxy early
```

* On Debian/Ubuntu, please make sure Apache module `headers` are enabled:

```
a2enmod headers
```

Restarting Apache service is required.

#### Nginx

Please open all files under below directories which contains `fastcgi_pass`
parameter:

* On Linux/OpenBSD:
    * `/etc/nginx/templates/`
    * `/etc/nginx/conf.d/`
* On FreeBSD:
    * `/usr/local/etc/nginx/templates`
    * `/usr/local/etc/nginx/conf.d/`

If config file contains `fastcgi_pass` parameter, please append below one after
it:

```
fastcgi_param HTTP_PROXY '';
```

Restart Nginx service is required.

### Fixed: not allow access to '/.well-known/' in Nginx

It's popular to use Let's Encrypt ssl cert nowadays, but default Nginx config
file will return a "403 Forbidden" error if you're trying to request new SSL
cert from Let's Encrypt. Step below will allow access to `/.well-known/` and
fix this issue.

Open Nginx template file `misc.tmpl`, find lines below:

* If your iRedMail server was installed with iRedMail-0.9.4, it's
  `/etc/nginx/templates/misc.tmpl` (Linux/OpenBSD) or
  `/usr/local/etc/nginx/templates/misc.tmpl` (FreeBSD).
* If your iRedMail server was installed with early release and upgraded to
  iRedMail-0.9.4, it's `/etc/nginx/conf.d/default.conf` (Linux/OpenBSD)
  or `/usr/local/etc/nginx/conf.d/default.conf` (FreeBSD).

```
# Deny all attempts to access hidden files such as .htaccess.
location ~ /\. { deny all; }
```

Add lines below ABOVE lines found above:

```
# Allow access to '^/.well-known/'
location ~ ^/.well-known/ {
    allow all;
    access_log off;
    log_not_found off;
    autoindex off;
}
```

Save your change and reload Nginx service.

### Fixed: Postfix allows email sent through port 587 without smtp authentication from trusted clients

iRedMail-0.9.5 and iRedMail-0.9.5-1 allows trusted clients (listed in parameter
`mynetworks=`) to send email through port 587 without smtp authentication, this
is not strict enough and may be used by spammers. All users should be forced
to send email through port 587 with smtp authentication. Please follow steps
below to fix it.

* Open Postfix config file `master.cf`, find the transport `submission` like
  below:
    * on Linux and OpenBSD, it's `/etc/postfix/master.cf`
    * on FreeBSD, it's `/usr/local/etc/postfix/master.cf`

```
submission ...
    ...
    -o smtpd_client_restrictions=permit_mynetworks,permit_sasl_authenticated,reject
```

* Remove `permit_mynetworks,` and save your change. After modification, it's:

```
submission ...
    ...
    -o smtpd_client_restrictions=permit_sasl_authenticated,reject
```

* Restart Postfix service is required to load the changed config file.

### Fixed: not enable opportunistic TLS support in Postfix

iRedMail-0.9.5 and iRedMail-0.9.5-1 didn't enable opportunistic TLS support in
Postfix, this causes other servers cannot transfer emails via TLS secure
connection. Please fix it with commands below. If you already have this
setting in `/etc/postfix/main.cf`, it's safe to ignore this step.

```
postconf -e smtpd_tls_security_level='may'
postfix reload
```

### Fixed: one incorrect HELO restriction rule in Postfix

There's one incorrect HELO restriction rule file `helo_access.pcre`

* on Linux/OpenBSD, it's `/etc/postfix/helo_access.pcre`
* on FreeBSD, it's `/usr/local/etc/postfix/helo_access.pcre`

It will match HELO identity like `[192.168.1.1]` which is legal.
```
/(\d{1,3}[\.-]\d{1,3}[\.-]\d{1,3}[\.-]\d{1,3})/ REJECT ACCESS DENIED. Your email was rejected because the sending mail server appears to be on a dynamic IP address that should not be doing direct mail delivery (${1})
```

Please replace it by the correct one below (it matches the IP address with
`/^IP$/` strictly):
```
/^(\d{1,3}[\.-]\d{1,3}[\.-]\d{1,3}[\.-]\d{1,3})$/ REJECT ACCESS DENIED. Your email was rejected because the sending mail server appears to be on a dynamic IP address that should not be doing direct mail delivery (${1})
```

### Fixed: incorrect file owner and permission of config file of Roundcube password plugin

iRedMail-0.9.5-1 and earlier versions didn't correct set file owner and
permission of config file of Roundcube password plugin, other system users may
be able to see the SQL/LDAP username and password in the config file. Please
follow steps below to fix it.

* On RHEL/CentOS:

<h5>For Apache server:</h5>
```
chown apache:apache /var/www/roundcubemail/plugins/password/config.inc.php
chmod 0400 /var/www/roundcubemail/plugins/password/config.inc.php
```
<h5>For Nginx:</h5>
```
chown nginx:nginx /var/www/roundcubemail/plugins/password/config.inc.php
chmod 0400 /var/www/roundcubemail/plugins/password/config.inc.php
```

* On Debian/Ubuntu (Note: with old iRedMail release, Roundcube directory is
  `/usr/share/apache2/roundcubemail`):
```
chown www-data:www-data /opt/www/roundcubemail/plugins/password/config.inc.php
chmod 0400 /opt/www/roundcubemail/plugins/password/config.inc.php
```

* On FreeBSD:
```
chown www:www /usr/local/www/roundcube/plugins/password/config.inc.php
chmod 0400 /usr/local/www/roundcube/plugins/password/config.inc.php
```

* On OpenBSD:
```
chown www:www /var/www/roundcubemail/plugins/password/config.inc.php
chmod 0400 /var/www/roundcubemail/plugins/password/config.inc.php
```

### Fixed: missing cron job used to clean up old Roundcube temporary files

iRedMail didn't run script `roundcubemail/bin/gc.sh` to clean up old files
under `roundcubemail/temp/` directory regularly, this directory will grow
larger and larger with temporary files.

Please edit `root`'s cron job with command below:

```
# crontab -e -u root
```

Then add cron job like below:

* RHEL/CentOS:

```
# Roundcube: Cleanup old temp files.
# Defaults to keep for 2 days, controlled by Roundcube parameter $config['temp_dir_ttl'].
2   2   *   *   *   php /var/www/roundcubemail/bin/gc.sh >/dev/null
```

* Debian/Ubuntu:

    > __WARNING__: with old iRedMail release, Roundcube directory is
    > `/usr/share/apache2/roundcubemail`, please make sure you're using the
    > correct one on your server.

```
# Roundcube: Cleanup old temp files.
# Defaults to keep for 2 days, controlled by Roundcube parameter $config['temp_dir_ttl'].
2   2   *   *   *   php /opt/www/roundcubemail/bin/gc.sh >/dev/null
```

* FreeBSD:

```
# Roundcube: Cleanup old temp files.
# Defaults to keep for 2 days, controlled by Roundcube parameter $config['temp_dir_ttl'].
2   2   *   *   *   /usr/local/bin/php /usr/local/www/roundcube/bin/gc.sh >/dev/null
```

* OpenBSD:

```
# Roundcube: Cleanup old temp files.
# Defaults to keep for 2 days, controlled by Roundcube parameter $config['temp_dir_ttl'].
2   2   *   *   *   php /var/www/roundcubemail/bin/gc.sh >/dev/null
```

### Fixed: Nginx doesn't forward real client IP address to SOGo

iRedMail-0.9.5-1 and earlier releases didn't correctly configure Nginx to
forward real client IP address to SOGo, this causes Fail2ban cannot catch
bad clients with failed authentication while logging to SOGo. Please try
steps below to fix it.

* Open file `/etc/nginx/templates/sogo.tmpl` (on Linux or OpenBSD) or
  `/usr/local/etc/nginx/templates/sogo.tmpl` (on FreeBSD), find 3 lines like
  below:

```
    #proxy_set_header X-Real-IP $remote_addr;
    #proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    #proxy_set_header Host $host;
```

* Remove the leading `#` to uncomment them:

```
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $host;
```

* Restart Nginx service.

### Fixed: SOGo-3.1.3 (and later releases) changed argument used by `sogo-tool` command

SOGo-3.1.3 (and late releases) changed `sogo-tool` argument `expire-autoreply`
to `update-autoreply`, and it's used in a daily cron job. Please update SOGo
cron job to fix it.

* Edit SOGo deamon user's cron job with command.
    * On Linux: ```crontab -e -u sogo```
    * On FreeBSD: ```crontab -e -u sogod```
    * On OpenBSD: ```crontab -e -u _sogo```

* Replace the argument `expire-autoreply` by `update-autoreply`.

### Fixed: Memcached listens on all available IP addresses instead of `127.0.0.1`

> This step is only applicable when you have SOGo installed, otherwise
> memcached was not installed and running on your server.

[Memcached](http://memcached.org) is an open-source distributed memory object caching system
which is generic in nature but often used for speeding up dynamic web
applications. Memcached does not support any forms of authorization.
Thus, anyone who can connect to the memcached server has unrestricted
access to the data stored in it. This allows attackers e.g. to steal
sensitive data like login credentials for web applications or any other
kind of content stored with memcached.

iRedMail-0.9.5-1 and earlier releases didn't configure Memcached to listen on
only `127.0.0.1`, steps below fix this issue.

* On RHEL/CentOS, please open file `/etc/sysconfig/memcached` and update
  parameter `OPTIONS=` with `-l 127.0.0.1` option like below:

```
OPTIONS="-l 127.0.0.1"
```

Then restart memcached service:

```
service memcached restart
```

* On Debian/Ubuntu, please make sure you have setting below in config file
  `/etc/memcached.conf`

```
-l 127.0.0.1
```

Then restart memcached service:

```
service memcached restart
```

* On FreeBSD, please append line below in `/etc/rc.conf`:

    !!! note

        If you're updating a jailed FreeBSD system, please change `127.0.0.1`
        to the IP address of your jail.

```
memcached_flags='-l 127.0.0.1'
```

Then restart memcached service:

```
service memcached restart
```

* On OpenBSD, please append line below in `/etc/rc.conf.local`:

```
memcached_flags='-u _memcached -l 127.0.0.1'
```

Then restart memcached service:

```
rcctl restart memcached
```

### Fixed: Awstats is world-accessible with Apache

> This is not applicable on OpenBSD system, because we don't have Apache nor Awstats installed.

With iRedMail-0.9.5-1 and earlier release, Awstats was incorrectly configured
and accessible without authentication. Please follow steps below to fix it.

* Open Awstats config file for Apache, find below lines:
    * On RHEL/CentOS, it's `/etc/httpd/conf.d/awstats.conf`
    * On Debian/Ubuntu, it's `/etc/apache2/conf-available/awstats.conf`
    * On FreeBSD, it's `/usr/local/etc/apache2?/Includes/awstats.conf`

```
   Require all granted
   Require valid-user
```

* Remove `Require all granted`, keep `Require valid-user`.
* Restart Apache service.

### Improve Fail2ban filter regular expression to catch more POP3/IMAP spams

> This step is applicable to Linux system.

We have one new Fail2ban filter regular expression to catch unauth clients
which generates log like below:

> Dec 11 16:49:41 imap-login: Info: Disconnected (auth failed, 1 attempts in
> 2 secs): user=<admin@example.net>, method=PLAIN, rip=212.8.246.222,
> lip=10.11.12.13, TLS: Disconnected, session=<xxfH9mhDwgDUCPbe>

Steps:

* On Linux:

```
cd /etc/fail2ban/filter.d/
rm -f dovecot.iredmail.conf
wget https://github.com/iredmail/iRedMail/raw/1.0/samples/fail2ban/filter.d/dovecot.iredmail.conf
service fail2ban reload
```

* On FreeBSD and OpenBSD, we don't have Fail2ban configured, so not applicable.

### Add more banned file types/extensions in Amavisd.

> Note: this is applicable to all Linux/BSD distributions.

We extended banned attachment file types and file name extensions to help
catch more dangerous email attachments. Please follow steps below to update
your Amavisd config file.

* Open Amavisd config file:
    * on RHEL/CentOS: it's `/etc/amavisd/amavisd.conf`
    * on Debian/Ubuntu: it's `/etc/amavis/conf.d/50-user`
    * on FreeBSD: it's `/usr/local/etc/amavisd.conf`
    * on OpenBSD: it's `/etc/amavisd.conf`

* If you already have parameter `$banned_namepath_re` in Amavisd config file,
  please replace it by below one. If you don't have it, please add it before
  the last line (`1;  # insure a defined return`) in Amavisd config file.

```
$banned_namepath_re = new_RE(
    #[qr'T=(rar|arc|arj|zoo|gz|bz2)(,|\t)'xmi => 'DISCARD'],     # Compressed file types
    [qr'T=x-(msdownload|msdos-program|msmetafile)(,|\t)'xmi => 'DISCARD'],
    [qr'T=(hta)(,|\t)'xmi => 'DISCARD'],

    # Dangerous mime types
    [qr'T=(9|386|LeChiffre|aaa|abc|aepl|ani|aru|atm|aut|b64|bat|bhx|bkd|blf|bll|bmw|boo|bps|bqf|breaking_bad|buk|bup|bxz|cc|ccc|ce0|ceo|cfxxe|chm|cih|cla|class|cmd|com|cpl|crinf|crjoker|crypt|cryptolocker|cryptowall|ctbl|cxq|cyw|dbd|delf|dev|dlb|dli|dll|dllx|dom|drv|dx|dxz|dyv|dyz|ecc|exe|exe-ms|exe1|exe_renamed|exx|ezt|ezz|fag|fjl|fnr|fuj|good|gzquar|hlp|hlw|hqx|hsq|hts|iva|iws|jar|js|kcd|keybtc@inbox_com|let|lik|lkh|lnk|locky|lok|lol!|lpaq5|magic|mfu|micro|mim|mjg|mjz|nls|oar|ocx|osa|ozd|pcx|pgm|php2|php3|pid|pif|plc|pr|pzdc|qit|qrn|r5a|rhk|rna|rsc_tmp|s7p|scr|shs|ska|smm|smtmp|sop|spam|ssy|swf|sys|tko|tps|tsa|tti|ttt|txs|upa|uu|uue|uzy|vb|vba|vbe|vbs|vbx|vexe|vxd|vzr|wlpginstall|ws|wsc|wsf|wsh|wss|xdu|xir|xlm|xlv|xnt|xnxx|xtbl|xxe|xxx|xyz|zix|zvz|zzz)(,|\t)'xmi => 'DISCARD'],

    # Dangerous file name extensions
    [qr'N=.*\.(9|386|LeChiffre|aaa|abc|aepl|ani|aru|atm|aut|b64|bat|bhx|bkd|blf|bll|bmw|boo|bps|bqf|breaking_bad|buk|bup|bxz|cc|ccc|ce0|ceo|cfxxe|chm|cih|cla|class|cmd|com|cpl|crinf|crjoker|crypt|cryptolocker|cryptowall|ctbl|cxq|cyw|dbd|delf|dev|dlb|dli|dll|dllx|dom|drv|dx|dxz|dyv|dyz|ecc|exe|exe-ms|exe1|exe_renamed|exx|ezt|ezz|fag|fjl|fnr|fuj|good|gzquar|hlp|hlw|hqx|hsq|hts|iva|iws|jar|js|kcd|keybtc@inbox_com|let|lik|lkh|lnk|locky|lok|lol!|lpaq5|magic|mfu|micro|mim|mjg|mjz|nls|oar|ocx|osa|ozd|pcx|pgm|php2|php3|pid|pif|plc|pr|pzdc|qit|qrn|r5a|rhk|rna|rsc_tmp|s7p|scr|shs|ska|smm|smtmp|sop|spam|ssy|swf|sys|tko|tps|tsa|tti|ttt|txs|upa|uu|uue|uzy|vb|vba|vbe|vbs|vbx|vexe|vxd|vzr|wlpginstall|ws|wsc|wsf|wsh|wss|xdu|xir|xlm|xlv|xnt|xnxx|xtbl|xxe|xxx|xyz|zix|zvz|zzz)$'xmi => 'DISCARD'],
);
```

* Restart Amavisd service is required.

## OpenLDAP backend special

### Use the latest iRedMail LDAP schema file

iRedMail-0.9.6 introduces 2 new LDAP attributes:

* `domainPendingAliasName`: used by mail domain account, to store new alias
  domain names which is pending for domain ownership verification. Required by
  iRedAdmin-Pro.
* `domainStatus`: used by mail user/alias/list accounts, to indicate domain
  status.

#### Update OpenLDAP config file to index new attributes

* Please open OpenLDAP config file `slapd.conf`:
    * On RHEL/CentOS, it's `/etc/openldap/slapd.conf`
    * On Debian/Ubuntu, it's `/etc/ldap/slapd.conf`
    * On FreeBSD, it's `/usr/local/etc/openldap/slapd.conf`
    * On OpenBSD:
        * if you're running OpenLDAP, it's `/etc/openldap/slapd.conf`.
        * if you're running ldapd(8) LDAP server, please add a new line
          `index domainStats` in the `namespace xxx {}` block.

* for new attribute `domainPendingAliasName`, please find line below:

```
access to attrs="objectclass,domainName,mtaTransport,..."
```

Add new attribute name `domainPendingAliasName` in this line (__WARNING__:
don't leave any whitespace between attribute names and comma):

```
access to attrs="domainPendingAliasName,objectclass,domainName,mtaTransport,..."
```

* for new attribute `domainStatus`, please find line below:

```
access to attrs="employeeNumber,mail,..."
```

Add new attribute name `domainStatus` in this line (__WARNING__: don't leave
any whitespace between attribute names and comma):

```
access to attrs="domainStatus,employeeNumber,mail,..."
```
#### Download the latest iRedMail LDAP schema file

* On RHEL/CentOS:

```
cd /tmp
wget https://github.com/iredmail/iRedMail/raw/1.0/samples/iredmail/iredmail.schema

cd /etc/openldap/schema/
cp iredmail.schema iredmail.schema.bak

cp -f /tmp/iredmail.schema /etc/openldap/schema/
service slapd restart
```

* On Debian/Ubuntu:
```
cd /tmp
wget https://github.com/iredmail/iRedMail/raw/1.0/samples/iredmail/iredmail.schema

cd /etc/ldap/schema/
cp iredmail.schema iredmail.schema.bak

cp -f /tmp/iredmail.schema /etc/ldap/schema/
service slapd restart
```

* On FreeBSD:

```
cd /tmp
wget https://github.com/iredmail/iRedMail/raw/1.0/samples/iredmail/iredmail.schema

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
ftp https://github.com/iredmail/iRedMail/raw/1.0/samples/iredmail/iredmail.schema

cd /etc/openldap/schema/
cp iredmail.schema iredmail.schema.bak

cp -f /tmp/iredmail.schema /etc/openldap/schema/
rcctl restart slapd
```

### Fixed: mail accounts (user, alias, list) are still active when domain is disabled

> This fix is applicable to OpenBSD ldapd backend also.

In iRedMail-0.9.5-1 and all earlier releases, if we disable a mail domain,
all mail accounts (mail users, aliases, lists) are still active and Postfix
will accept emails sent to them. Steps below fix the issue.

#### Update Postfix/Dovecot LDAP lookup files

* On Linux and OpenBSD, run commands:

```
cp -rf /etc/postfix/ldap /etc/postfix/ldap.bak
cd /etc/postfix/ldap/
perl -pi -e 's#\(accountStatus=active\)#(accountStatus=active)(!(domainStatus=disabled))#g' catchall_maps.cf recipient_bcc_maps_user.cf sender_bcc_maps_user.cf sender_dependent_relayhost_maps_user.cf sender_login_maps.cf transport_maps_user.cf virtual_alias_maps.cf virtual_group_maps.cf virtual_group_members_maps.cf virtual_mailbox_maps.cf

cp /etc/dovecot/dovecot-ldap.conf /etc/dovecot/dovecot-ldap.conf.$(date +%Y%m%d)
perl -pi -e 's#\(accountStatus=active\)#(accountStatus=active)(!(domainStatus=disabled))#g' /etc/dovecot/dovecot-ldap.conf
```

* On FreeBSD, run commands:

```
cp -rf /usr/local/etc/postfix/ldap /usr/local/etc/postfix/ldap.bak
cd /usr/local/etc/postfix/ldap/
perl -pi -e 's#\(accountStatus=active\)#(accountStatus=active)(!(domainStatus=disabled))#g' catchall_maps.cf recipient_bcc_maps_user.cf sender_bcc_maps_user.cf sender_dependent_relayhost_maps_user.cf sender_login_maps.cf transport_maps_user.cf virtual_alias_maps.cf virtual_group_maps.cf virtual_group_members_maps.cf virtual_mailbox_maps.cf

cp /usr/local/etc/dovecot/dovecot-ldap.conf /usr/local/etc/dovecot/dovecot-ldap.conf.$(date +%Y%m%d)
perl -pi -e 's#\(accountStatus=active\)#(accountStatus=active)(!(domainStatus=disabled))#g' /usr/local/etc/dovecot/dovecot-ldap.conf
```

* Restart both Postfix and Dovecot services:
    * on Linux: `service postfix restart; service dovecot restart`
    * on FreeBSD: `service postfix restart; service dovecot restart`
    * on OpenBSD: `rcctl restart postfix; rcctl restart dovecot`

#### Add required LDAP attribute/value for existing mail accounts under disabled domains

* Download script to update existing mail accounts:

```
cd /root/
wget https://github.com/iredmail/iRedMail/raw/1.0/update/ldap/updateLDAPValues_095_1_to_096.py
```

* Open downloaded file `updateLDAPValues_095_1_to_096.py`, set LDAP server
  related settings in this file. For example:

```
# Part of file: updateLDAPValues_095_1_to_096.py

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
# python updateLDAPValues_095_1_to_096.py
```

## MySQL/MariaDB backend special

### Fix invalid default (datetime) value for some SQL columns in 'vmail' database

Default value of some SQL columns in `vmail` database will become invalid (an error)
in MySQL 5.7, no matter which version of MySQL you're running, please run SQL
commands below as SQL root user to fix them.

```
USE vmail;

ALTER TABLE admin \
	MODIFY passwordlastchange DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01', \
	MODIFY created DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01', \
	MODIFY modified DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01';

ALTER TABLE alias \
	MODIFY created DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01', \
	MODIFY modified DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01';

ALTER TABLE alias_domain \
	MODIFY created DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01', \
	MODIFY modified DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01';

ALTER TABLE domain \
	MODIFY created DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01', \
	MODIFY modified DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01';

ALTER TABLE domain_admins \
	MODIFY created DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01', \
	MODIFY modified DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01';

ALTER TABLE mailbox \
	MODIFY lastlogindate DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01', \
	MODIFY passwordlastchange DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01', \
	MODIFY created DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01', \
	MODIFY modified DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01';

ALTER TABLE recipient_bcc_domain \
	MODIFY created DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01', \
	MODIFY modified DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01';

ALTER TABLE recipient_bcc_user \
	MODIFY created DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01', \
	MODIFY modified DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01';

ALTER TABLE sender_bcc_domain \
	MODIFY created DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01', \
	MODIFY modified DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01';

ALTER TABLE sender_bcc_user \
	MODIFY created DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01', \
	MODIFY modified DATETIME NOT NULL DEFAULT '1970-01-01 01:01:01';

UPDATE admin SET passwordlastchange='1970-01-01 01:01:01' WHERE passwordlastchange < '1970-01-01 01:01:01';
UPDATE admin SET created='1970-01-01 01:01:01' WHERE created < '1970-01-01 01:01:01';
UPDATE admin SET modified='1970-01-01 01:01:01' WHERE modified < '1970-01-01 01:01:01';

UPDATE alias SET created='1970-01-01 01:01:01' WHERE created < '1970-01-01 01:01:01';
UPDATE alias SET modified='1970-01-01 01:01:01' WHERE modified < '1970-01-01 01:01:01';

UPDATE alias_domain SET created='1970-01-01 01:01:01' WHERE created < '1970-01-01 01:01:01';
UPDATE alias_domain SET modified='1970-01-01 01:01:01' WHERE modified < '1970-01-01 01:01:01';

UPDATE domain SET created='1970-01-01 01:01:01' WHERE created < '1970-01-01 01:01:01';
UPDATE domain SET modified='1970-01-01 01:01:01' WHERE modified < '1970-01-01 01:01:01';

UPDATE domain_admins SET created='1970-01-01 01:01:01' WHERE created < '1970-01-01 01:01:01';
UPDATE domain_admins SET modified='1970-01-01 01:01:01' WHERE modified < '1970-01-01 01:01:01';

UPDATE mailbox SET lastlogindate='1970-01-01 01:01:01' WHERE lastlogindate < '1970-01-01 01:01:01';
UPDATE mailbox SET passwordlastchange='1970-01-01 01:01:01' WHERE passwordlastchange < '1970-01-01 01:01:01';
UPDATE mailbox SET created='1970-01-01 01:01:01' WHERE created < '1970-01-01 01:01:01';
UPDATE mailbox SET modified='1970-01-01 01:01:01' WHERE modified < '1970-01-01 01:01:01';

UPDATE recipient_bcc_domain SET created='1970-01-01 01:01:01' WHERE created < '1970-01-01 01:01:01';
UPDATE recipient_bcc_domain SET modified='1970-01-01 01:01:01' WHERE modified < '1970-01-01 01:01:01';

UPDATE recipient_bcc_user SET created='1970-01-01 01:01:01' WHERE created < '1970-01-01 01:01:01';
UPDATE recipient_bcc_user SET modified='1970-01-01 01:01:01' WHERE modified < '1970-01-01 01:01:01';

UPDATE sender_bcc_domain SET created='1970-01-01 01:01:01' WHERE created < '1970-01-01 01:01:01';
UPDATE sender_bcc_domain SET modified='1970-01-01 01:01:01' WHERE modified < '1970-01-01 01:01:01';

UPDATE sender_bcc_user SET created='1970-01-01 01:01:01' WHERE created < '1970-01-01 01:01:01';
UPDATE sender_bcc_user SET modified='1970-01-01 01:01:01' WHERE modified < '1970-01-01 01:01:01';
```
