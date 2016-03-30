# Upgrade iRedMail from 0.8.6 to 0.8.7

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](../support.html) and [contact us](../contact.html).

## ChangeLog

* 2014-05-18: Update SQL commands to sync value of removed columns to new column 'domain.settings'.
* 2014-05-14: Mention Roundcube setting change after you enable SMTP SASL authentication only over TLS in Postfix.
* 2014-05-13: iRedMail-0.8.7 has been released.
* 2014-05-06:
    * Allows SMTP SASL authentication ONLY over a TLS-encrypted smtp connection.
    * Fixed issue: Postfix cannot resolve client IP address to DNS name on RHEL/CentOS.
* 2014-04-18: [MySQL/PostgreSQL] Remove unused SQL columns in table `vmail.domain`.
* 2014-02-20:
    * Enable Dovecot LMTP service for local mail delivery.
    * [OpenLDAP] Add new value for existing mail users: enabledService=lmtp.
    * [MySQL/PostgreSQL] Create one additional SQL column in vmail database: mailbox.enablelmtp.
* 2014-02-19: Create additional SQL columns in vmail database: mailbox.settings, admin.settings, alias.islist.

## General (All backends should apply these steps)


### Update /etc/iredmail-release with iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
# File: /etc/iredmail-release

0.8.7
```

### Upgrade Roundcube webmail to the latest stable release

Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release immediately: [How to upgrade Roundcube](http://trac.roundcube.net/wiki/Howto_Upgrade)

### Upgrade iRedAPD (Postfix policy server) to the latest 1.4.3

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

### Upgrade iRedAdmin (open source edition) to the latest stable release

Please follow this tutorial to upgrade iRedAdmin open source edition to the
latest stable release: [Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html)

### Upgrade phpMyAdmin to the latest stable release

Please follow this short tutorial to upgrade phpMyAdmin to the latest stable
release: [http://docs.phpmyadmin.net/en/latest/setup.html#upgrading-from-an-older-version](http://docs.phpmyadmin.net/en/latest/setup.html#upgrading-from-an-older-version)

NOTE: Since phpMyAdmin-4.2.3.0, it  enforces the minimum PHP (5.3) and MySQL (5.5) versions.

### [OPTIONAL] Allows SMTP SASL authentication ONLY over a TLS-encrypted smtp connection

* This step is optional.
* WARNING: With this Postfix change, mail users must configure their mail
  client applications (Outlook, Thunderbird, etc) to enable TLS (port 25 or
  587) or SSL (port 465) for sending email.

To allow SMTP SASL authentication ONLY over a TLS-encrypted smtp connection,
just change value of parameter `smtpd_tls_auth_only` to `yes`, and reload
Postfix service.

```
# postconf -e smtpd_tls_auth_only='yes'
# postfix reload
```

After this change, you have to update Roundcube config file to use SMTP service
over TLS. For example:

* On RHEL/CentOS, it's `/var/www/roundcubemail/config/main.inc.php` (or `config.inc.php`)
* On Debian/Ubuntu, it's `/usr/share/apache2/roundcubemail/config/main.inc.php` (or `config.inc.php`)
* On FreeBSD, it's `/usr/local/www/roundcubemail/config/main.inc.php` (or `config.inc.php`)
* On OpenBSD, it's `/var/www/roundcubemail/config/main.inc.php` (or `config.inc.php`)

```
# Part of Roundcube config file: config.inc.php

// OLD settings
//$rcmail_config['smtp_server'] = '127.0.0.1';
//$rcmail_config['smtp_port'] = 25;

// NEW settings
$config['smtp_server'] = 'tls://127.0.0.1';                                
$config['smtp_port'] = 587;
```

### [OPTIONAL] Enable LMTP service in Dovecot-2.x

* This step is optional. We already have Dovecot LDA as local mail deliver
  agent, LMTP is just another choice. LDA and LMTP are enabled in
  iRedMail-0.8.7 by default.
* WARNING: This is for Dovecot-2.x, and NOT applicable to Dovecot-1.x. You can
  check Dovecot version with below command:

```
# dovecot --version
```

Before we go further, there're some questions we have to answer:

* __What's LMTP?__ LMTP is a mail deliver agent like Dovecot LDA.
* __Why use LMTP (instead of LDA)?__ Short answer: LMTP has better performance
  than LDA on a busy server and easier to config. The main difference between
  LMTP and LDA is that the LDA is a short-running process, started as a binary
  from command line, while LMTP is a long-running process started by Dovecot's
  master process. LMTP has better performance, "the performance gains comes
  mostly from avoiding the overhead of invoking an executable and spawning a
  new process for each delivery." If your mail system isn't stressed, It
  doesn't matter which one you use.

Search "dovecot lda vs lmtp" in Google will give you more detailed info and debate.

__NOTE__: On Debian or Ubuntu, you have to install one additional package before
we go further: `dovecot-lmtpd`.

```
# apt-get install dovecot-lmtpd
```

* To enable LMTP service, please APPEND service name `lmtp` in parameter
  `protocols` in Dovecot config file, it's `/etc/dovecot/dovecot.conf` (on
  Linux/OpenBSD), or `/usr/local/etc/dovecot/dovecot.conf` (on FreeBSD).

```
# Part of file: /etc/dovecot/dovecot.conf

protocols = ... lmtp
```

* Then append below settings in Dovecot config file `dovecot.conf`:

```
# Part of file: /etc/dovecot/dovecot.conf

service lmtp {
    user = vmail

    # For higher volume sites, it may be desirable to increase the number of
    # active listener processes. A range of 5 to 20 is probably good for most
    # sites.
    #process_min_avail = 5

    # Logging
    executable = lmtp -L

    # Listening LMTP service on socket file and TCP
    unix_listener /var/spool/postfix/private/dovecot-lmtp {
        user = postfix
        group = postfix
        mode = 0600
    }

    inet_listener lmtp {
        #address = 192.168.0.24 127.0.0.1 ::1
        port = 24
    }
}

protocol lmtp {
    # Plugins
    mail_plugins = quota sieve
    postmaster_address = postmaster

    lmtp_save_to_detail_mailbox = yes
    recipient_delimiter = +

    # Log file
    info_log_path = /var/log/dovecot-lmtp.log
}
```

__NOTE__: For OpenBSD users, please replace `user = postfix` by
`user = _postfix`, and replace `group = postfix` by `group = _postfix`.

* Create log file for LMTP service:

```
# touch /var/log/dovecot-lmtp.log
# chown vmail:vmail /var/log/dovecot-lmtp.log
# chmod 0600 /var/log/dovecot-lmtp.log
```

* Enable logrotate service for this newly created log file:

    * on Linux, please append this new log file name in `/etc/logrotate.d/dovecot` like below:

```
# Part of file: /etc/logrotate.d/dovecot

/var/log/dovecot.log /var/log/dovecot-lmtp.log {
```

* on FreeBSD, please append below line in file `/etc/newsyslog.conf`:

```
# Part of file: /etc/newsyslog.conf
/var/log/dovecot-lmtp.log    vmail:vmail   600  7     *    24    Z    /var/run/dovecot/master.pid
```

* on OpenBSD, please append below line in file `/etc/newsyslog.conf`:

```
# Part of file: /etc/newsyslog.conf

/var/log/dovecot-lmtp.log    vmail:vmail   600  7     *    24    Z "/usr/local/bin/doveadm log reopen"
```

* Restarting Dovecot service is required.

```
# ---- On Linux ----
# /etc/init.d/dovecot restart

# ---- On FreeBSD ----
# /usr/local/etc/rc.d/dovecot restart

# ---- On OpenBSD ----
# /etc/rc.d/dovecot restart
```

That's all. You can now check whether Dovecot is listening on port 24 and
created socket file `/var/spool/postfix/private/dovecot-lmtp` for LMTP service.

```
# ---- On Linux ----
# netstat -ntlp | grep ':24'
# ls -l /var/spool/postfix/private/dovecot-lmtp
```

To use LMTP as local mail delivery agent, you can use either
`lmtp:unix:private/dovecot-lmtp` (local socket) or `lmtp:inet:127.0.0.1:24`
(network listener). Currently, default mail delivery agent is `dovecot`
(Dovecot LDA). For example:

* For OpenLDAP backend, you can set domain transport to LMTP in domain object
  with this attribute/value: `mtaTransport=lmtp:unix:private/dovecot-lmtp`
* For MySQL and PostgreSQL backends, you can set with this SQL command:

```
mysql> USE vmail;
mysql> UPDATE domain SET transport='lmtp:unix:private/dovecot-lmtp' WHERE domain='abc.com';
```

!!! note

    It requires new LDAP value or SQL column for mail users mentioned later in
    this tutorial (LDAP: `enabledService=lmtp`, SQL: `mailbox.enablelmtp=1`),
    so please finish this upgrade tutorial first, then you're safe to use LMTP.

### [OPTIONAL] Fixed issue: Postfix cannot resolve client IP address to DNS name on RHEL/CentOS

This is optional.

On RHEL/CentOS, Postfix is running under chroot, it logs client IP address in
log file, but cannot resolve IP to DNS name. You can fix it with below steps:

```
# ---- For i386 ----
# mkdir /var/spool/postfix/lib/
# cp /lib/*nss* /lib/*reso* /var/spool/postfix/lib/
# postfix reload

# ---- For x86_64 ----
# mkdir /var/spool/postfix/lib64/
# cp /lib64/*nss* /lib64/*reso* /var/spool/postfix/lib64/
# postfix reload
```

## OpenLDAP backend special

### Add new LDAP values for existing mail users

We will add one new LDAP attribute/value pair for existing mail users:
`enabledService=lmtp`. It's used by Dovecot LMTP server.

* Download below python script to adding new values for existing mail users.

```
# cd /root/
# wget https://bitbucket.org/zhb/iredmail/raw/default/extra/update/updateLDAPValues_086_to_087.py
```

* Open downloaded file `updateLDAPValues_086_to_087.py`, set LDAP server
related settings in file head. for example:

```
# Part of file: updateLDAPValues_086_to_087.py

uri = 'ldap://127.0.0.1:389'
basedn = 'o=domains,dc=example,dc=com'
bind_dn = 'cn=vmailadmin,dc=example,dc=com'
bind_pw = 'passwd'
```

You can find required LDAP credential in iRedAdmin config file or `iRedMail.tips`
file under your iRedMail installation directory. Using either
`cn=Manager,dc=xx,dc=xx` or `cn=vmailadmin,dc=xx,dc=xx` as bind dn is ok.

* Execute this script, it will add required data:

```
# python updateLDAPValues_086_to_087.py
```

That's all.

## MySQL backend special

### Add and remove SQL columns in `vmail` database

We need 5 new SQL columns in `vmail` database:

* `mailbox.enablelmtp`: used by Dovecot LMTP server.
* `mailbox.settings`: used to store additional per-user settings, default value is empty. Used in iRedAdmin-Pro.
* `domain.settings`: used to store per-domain settings, default is empty. Used in iRedAdmin-Pro.
* `admin.settings`: used to store additional per-admin settings, default value is empty. Used in iRedAdmin-Pro.
* `alias.islist`: used to mark a sql record is a mail list account, default value is `0` (means not a mail list account). This helps avoid complex SQL queries.

Some existing columns in table `vmail.domain` are not needed anymore, they will
be merged into our new column: `domain.settings`.

Now connect to SQL server as root user, create new columns, add required
indexes for new column `alias.islist`, and update value of `alias.islist` for
existing accounts:

```
$ mysql -uroot -p
mysql> USE vmail;
mysql> ALTER TABLE mailbox ADD COLUMN enablelmtp TINYINT(1) NOT NULL DEFAULT 1;
mysql> ALTER TABLE mailbox ADD INDEX (enablelmtp);

mysql> ALTER TABLE mailbox ADD COLUMN settings TEXT;
mysql> ALTER TABLE domain ADD COLUMN settings TEXT;
mysql> ALTER TABLE admin ADD COLUMN settings TEXT;

mysql> ALTER TABLE alias ADD COLUMN islist TINYINT(1) NOT NULL DEFAULT 0;
mysql> ALTER TABLE alias ADD INDEX (islist);
mysql> UPDATE alias SET islist=1 WHERE address NOT IN (SELECT username FROM mailbox);
mysql> UPDATE alias SET islist=0 WHERE address=domain;    -- domain catch-all account

-- Remove old columns and store their value into new column: domain.settings
mysql> UPDATE domain SET settings='';
mysql> UPDATE domain SET settings=CONCAT(settings, IF(defaultlanguage IS NULL OR defaultlanguage='', '', CONCAT('default_language:', defaultlanguage, ';')));
mysql> UPDATE domain SET settings=CONCAT(settings, IF(defaultuserquota IS NULL OR defaultuserquota=0, '', CONCAT('default_user_quota:', defaultuserquota, ';')));
mysql> UPDATE domain SET settings=CONCAT(settings, IF(defaultuseraliases IS NULL OR defaultuseraliases='', '', CONCAT('default_groups:', defaultuseraliases, ';')));
mysql> UPDATE domain SET settings=CONCAT(settings, IF(minpasswordlength IS NULL OR minpasswordlength=0, '', CONCAT('min_passwd_length:', minpasswordlength, ';')));
mysql> UPDATE domain SET settings=CONCAT(settings, IF(maxpasswordlength IS NULL OR maxpasswordlength=0, '', CONCAT('max_passwd_length:', maxpasswordlength, ';')));
mysql> UPDATE domain SET settings=CONCAT(settings, IF(disableddomainprofiles IS NULL OR disableddomainprofiles='', '', CONCAT('disabled_domain_profiles:', disableddomainprofiles, ';')));
mysql> UPDATE domain SET settings=CONCAT(settings, IF(disableduserprofiles IS NULL OR disableduserprofiles='', '', CONCAT('disabled_user_profiles:', disableduserprofiles, ';')));

mysql> ALTER TABLE domain DROP defaultlanguage;
mysql> ALTER TABLE domain DROP defaultuserquota;
mysql> ALTER TABLE domain DROP defaultuseraliases;
mysql> ALTER TABLE domain DROP minpasswordlength;
mysql> ALTER TABLE domain DROP maxpasswordlength;
mysql> ALTER TABLE domain DROP disableddomainprofiles;
mysql> ALTER TABLE domain DROP disableduserprofiles;
```

## PostgreSQL backend special

### Add and remove SQL columns in `vmail` database

We need 5 new SQL columns in `vmail` database:

* `mailbox.enablelmtp`: used by Dovecot LMTP server.
* `mailbox.settings`: used to store additional per-user settings, default value is empty. Used in iRedAdmin-Pro.
* `domain.settings`: used to store per-domain settings, default is empty. Used in iRedAdmin-Pro.
* `admin.settings`: used to store additional per-admin settings, default value is empty. Used in iRedAdmin-Pro.
* `alias.islist`: used to mark a sql record is a mail list account, default value is `0` (means not a mail list account). This helps avoid complex SQL queries.

Some existing columns in table `vmail.domain` are not needed anymore, they will
be merged into our new column: `domain.settings`.

Now connect to SQL server as PostgreSQL administrator user, create new columns,
add required indexes for new column `alias.islist`, and update value of
`alias.islist` for existing accounts:

```
# su - postgres
$ psql -d vmail
sql> ALTER TABLE mailbox ADD COLUMN enablelmtp INT2 NOT NULL DEFAULT 1;
sql> CREATE INDEX idx_mailbox_enablelmtp ON mailbox (enablelmtp);

sql> ALTER TABLE mailbox ADD COLUMN settings TEXT NOT NULL DEFAULT '';
sql> ALTER TABLE domain ADD COLUMN settings TEXT NOT NULL DEFAULT '';
sql> ALTER TABLE admin ADD COLUMN settings TEXT NOT NULL DEFAULT '';

sql> ALTER TABLE alias ADD COLUMN islist INT2 NOT NULL DEFAULT 0;
sql> CREATE INDEX idx_alias_islist ON alias (islist);
sql> UPDATE alias SET islist=1 WHERE address NOT IN (SELECT username FROM mailbox);
sql> UPDATE alias SET islist=0 WHERE address=domain;    -- domain catch-all account

-- Remove old columns and store their value into new column: domain.settings
sql> UPDATE domain SET settings='';
sql> UPDATE domain SET settings=settings || 'default_language:' || defaultlanguage || ';';
sql> UPDATE domain SET settings=settings || 'default_user_quota:' || defaultuserquota || ';';
sql> UPDATE domain SET settings=settings || 'default_groups:' || defaultuseraliases || ';';
sql> UPDATE domain SET settings=settings || 'min_passwd_length:' || minpasswordlength || ';';
sql> UPDATE domain SET settings=settings || 'max_passwd_length:' || maxpasswordlength || ';';
sql> UPDATE domain SET settings=settings || 'disabled_domain_profiles:' || disableddomainprofiles || ';';
sql> UPDATE domain SET settings=settings || 'disabled_user_profiles:' || disableduserprofiles || ';';

sql> ALTER TABLE domain DROP defaultlanguage;
sql> ALTER TABLE domain DROP defaultuserquota;
sql> ALTER TABLE domain DROP defaultuseraliases;
sql> ALTER TABLE domain DROP minpasswordlength;
sql> ALTER TABLE domain DROP maxpasswordlength;
sql> ALTER TABLE domain DROP disableddomainprofiles;
sql> ALTER TABLE domain DROP disableduserprofiles;
```
