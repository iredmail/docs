# Upgrade iRedMail from 0.9.4 to 0.9.5

[TOC]

## TODO

* Upgrade yum/apt repositories to switch to SOGo v3.
* Support 'enabledService=sogo' (LDAP) and 'mailbox.enablesogo=1' (SQL).

## ChangeLog

> We offer remote upgrade service, check [the price](../support.html) and [contact us](../contact.html).

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
