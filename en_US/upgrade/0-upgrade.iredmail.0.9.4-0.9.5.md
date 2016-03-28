# Upgrade iRedMail from 0.9.4 to 0.9.5

[TOC]

!!! warning

    __THIS IS STILL A DRAFT DOCUMENT, DO NOT APPLY IT.__

## ChangeLog

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](../support.html) and [contact us](../contact.html).

* 2016-03-23: [NEW] Able to enable/disable SOGo access for a single user.
* 2016-03-08: [NEW] Supports Postfix `sender_dependent_relayhost_maps`.
* 2016-02-25:
    * [RHEL/CentOS] Fixed: Not create required directory used to store PHP session files
    * [RHEL/CentOS] Fixed: Not enable cron job to update SpamAssassin rules
    * Fixed: not add alias for `virusalert` on non-Debian/Ubuntu OSes

## General (All backends should apply these steps)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
# File: /etc/iredmail-release

0.9.5
```

### Upgrade iRedAPD (Postfix policy server) to the latest 1.9.0

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

Detailed release notes are available [here](./iredapd.releases.html).

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

### Fixed: not add alias for `virusalert` on non-Debian/Ubuntu OSes

Note: this is __NOT__ applicable to Debian and Ubuntu.

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

* On RHEL/CentOS, OpenBSD:

```
cd /tmp
wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/iredmail.schema

cd /etc/openldap/schema/
cp iredmail.schema iredmail.schema.bak

cp -f /tmp/iredmail.schema /etc/openldap/schema/
/etc/init.d/slapd restart     # Use '/etc/rc.d/slapd restart' on OpenBSD
```

* On Debian/Ubuntu:
```
cd /tmp
wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/iredmail.schema

cd /etc/ldap/schema/
cp iredmail.schema iredmail.schema.bak

cp -f /tmp/iredmail.schema /etc/ldap/schema/
/etc/init.d/slapd restart
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
postconf -e proxy_read_maps ='$canonical_maps $lmtp_generic_maps $local_recipient_maps $mydestination $mynetworks $recipient_bcc_maps $recipient_canonical_maps $relay_domains $relay_recipient_maps $relocated_maps $sender_bcc_maps $sender_canonical_maps $smtp_generic_maps $smtpd_sender_login_maps $transport_maps $virtual_alias_domains $virtual_alias_maps $virtual_mailbox_domains $virtual_mailbox_maps $smtpd_sender_restrictions $sender_dependent_relayhost_maps'

postconf -e sender_dependent_relayhost_maps='proxy:ldap:/etc/postfix/ldap/sender_dependent_relayhost_maps_domain.cf, proxy:ldap:/etc/postfix/ldap/sender_dependent_relayhost_maps_user.cf'
```

* On __FreeBSD__, please run 2 commands below to update Postfix settings:

```
postconf -e proxy_read_maps ='$canonical_maps $lmtp_generic_maps $local_recipient_maps $mydestination $mynetworks $recipient_bcc_maps $recipient_canonical_maps $relay_domains $relay_recipient_maps $relocated_maps $sender_bcc_maps $sender_canonical_maps $smtp_generic_maps $smtpd_sender_login_maps $transport_maps $virtual_alias_domains $virtual_alias_maps $virtual_mailbox_domains $virtual_mailbox_maps $smtpd_sender_restrictions $sender_dependent_relayhost_maps'

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
# cd /root/
# wget https://bitbucket.org/zhb/iredmail/raw/default/extra/update/updateLDAPValues_094_to_095.py
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
postconf -e proxy_read_maps ='$canonical_maps $lmtp_generic_maps $local_recipient_maps $mydestination $mynetworks $recipient_bcc_maps $recipient_canonical_maps $relay_domains $relay_recipient_maps $relocated_maps $sender_bcc_maps $sender_canonical_maps $smtp_generic_maps $smtpd_sender_login_maps $transport_maps $virtual_alias_domains $virtual_alias_maps $virtual_mailbox_domains $virtual_mailbox_maps $smtpd_sender_restrictions $sender_dependent_relayhost_maps'

postconf -e sender_dependent_relayhost_maps='proxy:mysql:/etc/postfix/mysql/sender_dependent_relayhost_maps.cf'
```

* On __FreeBSD__, please run 2 commands below to update Postfix settings:

```
postconf -e proxy_read_maps ='$canonical_maps $lmtp_generic_maps $local_recipient_maps $mydestination $mynetworks $recipient_bcc_maps $recipient_canonical_maps $relay_domains $relay_recipient_maps $relocated_maps $sender_bcc_maps $sender_canonical_maps $smtp_generic_maps $smtpd_sender_login_maps $transport_maps $virtual_alias_domains $virtual_alias_maps $virtual_mailbox_domains $virtual_mailbox_maps $smtpd_sender_restrictions $sender_dependent_relayhost_maps'

postconf -e sender_dependent_relayhost_maps='proxy:mysql:/usr/local/etc/postfix/mysql/sender_dependent_relayhost_maps.cf'
```

Reload or restart Postfix service is required.

### NEW: Able to enable/disable SOGo access for a single user

With steps below, system admin is able to control which users can access SOGo
Groupware (webmail, calendar, contacts, ActiveSync).

To accomplish this, we need to add a new SQL column `enablesogo` in SQL table
`vmail.mailbox`, then re-create SQL VIEW `sogo.users`.

Before we go further, please find the SQL password for SQL user `vmail`
in Postfix config file `/etc/postfix/mysql/*.cf` (on Linux/OpenBSD) or
`/usr/local/etc/postfix/mysql/*.cf` (on FreeBSD), we need this while
(re-)creating SQL VIEW `sogo.users`.

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
sql> DROP TABLE users;
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
postconf -e proxy_read_maps ='$canonical_maps $lmtp_generic_maps $local_recipient_maps $mydestination $mynetworks $recipient_bcc_maps $recipient_canonical_maps $relay_domains $relay_recipient_maps $relocated_maps $sender_bcc_maps $sender_canonical_maps $smtp_generic_maps $smtpd_sender_login_maps $transport_maps $virtual_alias_domains $virtual_alias_maps $virtual_mailbox_domains $virtual_mailbox_maps $smtpd_sender_restrictions $sender_dependent_relayhost_maps'

postconf -e sender_dependent_relayhost_maps='proxy:pgsql:/etc/postfix/pgsql/sender_dependent_relayhost_maps.cf'
```

* On __FreeBSD__, please run 2 commands below to update Postfix settings:

```
postconf -e proxy_read_maps ='$canonical_maps $lmtp_generic_maps $local_recipient_maps $mydestination $mynetworks $recipient_bcc_maps $recipient_canonical_maps $relay_domains $relay_recipient_maps $relocated_maps $sender_bcc_maps $sender_canonical_maps $smtp_generic_maps $smtpd_sender_login_maps $transport_maps $virtual_alias_domains $virtual_alias_maps $virtual_mailbox_domains $virtual_mailbox_maps $smtpd_sender_restrictions $sender_dependent_relayhost_maps'

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

