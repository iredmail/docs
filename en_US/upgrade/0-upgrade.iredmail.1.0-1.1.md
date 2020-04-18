# Upgrade iRedMail from 1.0 to 1.1

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

* Feb 10, 2020: initial release.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.1
```

### Upgrade iRedAPD (Postfix policy server) to the latest stable release

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

### Upgrade iRedAdmin (open source edition) to the latest stable release

Please follow this tutorial to upgrade iRedAdmin open source edition to the
latest stable release:
[Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html)

### Upgrade mlmmjadmin to the latest stable release

Please follow below tutorial to upgrade mlmmjadmin to the latest stable release:
[Upgrade mlmmjadmin to the latest stable release](./upgrade.mlmmjadmin.html)

### Upgrade Roundcube webmail to the latest stable release

!!! warning "Roundcube 1.4"

    Since Roundcube 1.3, at least __PHP 5.4__ is required. If your server is
    running PHP 5.3 and cannot upgrade to 5.4, please upgrade Roundcube
    the latest 1.2 branch instead.

The latest Roundcube webmail 1.4.2 offers a shiny new web UI.
Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release (1.4.2):

* [How to upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).

### Upgrade netdata to the latest stable release

If you have netdata installed, you can upgrade it by following this tutorial:
[Upgrade netdata](./upgrade.netdata.html).

### Fixed: modular rsyslog config file is improper

!!! attention

    This is applicable to only CentOS 7.

On CentOS 7, the modular rsyslog config file
`/etc/rsyslog.d/1-iredmail-iredapd.conf` doesn't correctly filter iRedAPD log,
please replace the `if` line by below one and restart rsyslog service:

```
if $syslogfacility-text == 'local5' and ($syslogtag startswith 'iredapd' or $msg startswith 'iredapd ') then -/var/log/iredapd/iredapd.log
```

### Fixed: SOGo backup script doesn't relies on Python anymore

SOGo backup script `/var/vmail/backup/backup_sogo.sh` shipped in iRedMail-1.0
and earlier releases relies on Python to calculate the date of old backup for
removal, but not anymore in iRedMail-1.1. Please download the latest version
and override the one on your system:

```
cd /var/vmail/backup/
wget -O backup_sogo.sh https://github.com/iredmail/iRedMail/raw/1.1/tools/backup_sogo.sh
chown root backup_sogo.sh
chmod 0500 backup_sogo.sh
```

## For OpenLDAP backend

### Fixed: Backup MX doesn't work.

In iRedMail-1.0, the placeholder used by LDAP query for Backup MX domain is
incorrect, please run commands below to fix it.

```
perl -pi -e 's#%d#%s#g' /etc/postfix/ldap/relay_domains.cf
postfix reload
```

### Fixed: improper LDAP query filter

The LDAP query used in file `/etc/postfix/ldap/virtual_group_maps.cf`
(Linux/OpenBSD) or `/usr/local/etc/postfix/ldap/virtual_group_maps.cf`
(FreeBSD) is not accurate, it will cause missing external members of
(not-subscribeable) mailing list with alias domain.
Please follow steps below to fix it.

* Open file `/etc/postfix/ldap/virtual_group_maps.cf`
  (Linux/OpenBSD) or `/usr/local/etc/postfix/ldap/virtual_group_maps.cf`, replace
  the `query_filter =` line by below one:

```
query_filter    = (&(accountStatus=active)(!(domainStatus=disabled))(enabledService=mail)(enabledService=deliver)(|(&(|(memberOfGroup=%s)(shadowAddress=%s))(|(objectClass=mailUser)(objectClass=mailExternalUser)))(&(memberOfGroup=%s)(!(shadowAddress=%s))(|(objectClass=mailAlias)(&(objectClass=mailList)(!(enabledService=mlmmj)))))(&(objectClass=mailList)(enabledService=mlmmj)(|(mail=%s)(shadowAddress=%s)))))
```

* Save your change and restart or reload Postfix service.

### Improvement: OpenLDAP backup script doesn't relies on Python anymore

OpenLDAP backup scripts `/var/vmail/backup/backup_openldap.sh` and
`backup_mysql.sh` shipped in iRedMail-1.0 and earlier releases relies on Python
to calculate the date of old backup for removal, but not anymore in
iRedMail-1.1. Please download the latest version and override the one on your
system:

```
cd /var/vmail/backup/
wget -O backup_openldap.sh https://github.com/iredmail/iRedMail/raw/1.1/tools/backup_openldap.sh
wget -O backup_openldap.sh https://github.com/iredmail/iRedMail/raw/1.1/tools/backup_mysql.sh
chown root backup_openldap.sh backup_mysql.sh
chmod 0500 backup_openldap.sh backup_mysql.sh
```

## For MySQL/MariaDB backends

### Fixed: Backup MX doesn't work.

In iRedMail-1.0, the placeholder used by SQL query for Backup MX domain is
incorrect, please run commands below to fix it.

```
perl -pi -e 's#%d#%s#g' /etc/postfix/mysql/relay_domains.cf
postfix reload
```

### Fixed: MySQL backup script doesn't relies on Python anymore

Backup script `/var/vmail/backup/backup_mysql.sh` shipped in iRedMail-1.0
and earlier releases relies on Python to calculate the date of old backup for
removal, but not anymore in iRedMail-1.1. Please download the latest version
and override the one on your system:

```
cd /var/vmail/backup/
wget -O backup_mysql.sh https://github.com/iredmail/iRedMail/raw/1.1/tools/backup_mysql.sh
chown root backup_mysql.sh
chmod 0500 backup_mysql.sh
```

## For PostgreSQL backend

### Fixed: incorrect index on SQL table `vmail.sender_relayhost`

Column `sender_relayhost.account` should be unique index. Please follow steps below to fix it.

* Connect to PostgreSQL server as `postgres` user and connect to `vmail` database:
    * on Linux, it's `postgres` user
    * on FreeBSD, it's `pgsql` user
    * on OpenBSD, it's `_postgresql` user

```
su - postgres
psql -d vmail
```

* Run SQL commands below:

```
DROP INDEX idx_sender_relayhost_account;
CREATE UNIQUE INDEX idx_sender_relayhost_account ON sender_relayhost (account);
```

### Fixed: Backup MX doesn't work.

In iRedMail-1.0, the placeholder used by SQL query for Backup MX domain is
incorrect, please run commands below to fix it.

```
perl -pi -e 's#%d#%s#g' /etc/postfix/pgsql/relay_domains.cf
postfix reload
```

### Fixed: PostgreSQL backup script doesn't relies on Python anymore

Backup script `/var/vmail/backup/backup_pgsql.sh` shipped in iRedMail-1.0
and earlier releases relies on Python to calculate the date of old backup for
removal, but not anymore in iRedMail-1.1. Please download the latest version
and override the one on your system:

```
cd /var/vmail/backup/
wget -O backup_pgsql.sh https://github.com/iredmail/iRedMail/raw/1.1/tools/backup_pgsql.sh
chown root backup_pgsql.sh
chmod 0500 backup_pgsql.sh
```

