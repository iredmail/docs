# Upgrade iRedMail from 1.4.1 to 1.4.2

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

* Sep 13, 2021: Initial release.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.4.2
```

## For OpenLDAP backend

### Remove unused LDAP attributes

Few LDAP attributes in `iredmail.schema` file are not used since day one, it's
time to remove them:

- `lastLoginDate`
- `lastLoginIP`
- `lastLoginProtocol`

Download the latest iRedMail LDAP schema file

* On RHEL/CentOS:

```
wget -O /tmp/iredmail.schema https://github.com/iredmail/iRedMail/raw/1.4.2/samples/iredmail/iredmail.schema
mv /etc/openldap/schema/iredmail.schema{,.bak}
cp -f /tmp/iredmail.schema /etc/openldap/schema/
service slapd restart
```

* On Debian/Ubuntu:
```
wget -O /tmp/iredmail.schema https://github.com/iredmail/iRedMail/raw/1.4.2/samples/iredmail/iredmail.schema
mv /etc/ldap/schema/iredmail.schema{,.bak}
cp -f /tmp/iredmail.schema /etc/ldap/schema/
service slapd restart
```

* On FreeBSD:

```
wget -O /tmp/iredmail.schema https://github.com/iredmail/iRedMail/raw/1.4.2/samples/iredmail/iredmail.schema
mv /usr/local/etc/openldap/schema/iredmail.schema{,.bak}
cp -f /tmp/iredmail.schema /usr/local/etc/openldap/schema/
service slapd restart
```

* On OpenBSD:

    > Note: if you're running ldapd as LDAP server, the schema directory is
    > `/etc/ldap`, and service name is `ldapd`.

```
cd /tmp
ftp https://github.com/iredmail/iRedMail/raw/1.4.2/samples/iredmail/iredmail.schema
mv /etc/openldap/schema/iredmail.schema{,.bak}
cp -f /tmp/iredmail.schema /etc/openldap/schema/
rcctl restart slapd
```

## For MySQL and MariaDB backends

### Fix incorrect SQL column types and remove unused columns in `vmail.mailbox` tables

iRedMail-1.4.1 introduced 3 new columns used to enable or disable per-user
SOGo webmail, calendar and activesync services, but they were set to improper
column `CHAR(1)` because SOGo doesn't support it, we will change them to
`VARCHAR(1)`:

- `enablesogowebmail`
- `enablesogocalendar`
- `enablesogoactivesync`

3 columns are not used at all:

- `lastlogindate`
- `lastloginipv4`
- `lastloginprotocol`

Please download plain SQL file used to update SQL table, then import it as
MySQL root user (Please run commands below as `root` user):

```
wget -O /tmp/iredmail.mysql https://github.com/iredmail/iRedMail/raw/1.4.2/update/1.4.2/iredmail.mysql
mysql vmail < /tmp/iredmail.mysql
rm -f /tmp/iredmail.mysql
```

## For PostgreSQL backend

### Fix incorrect SQL column types and remove unused columns in `vmail.mailbox` tables

iRedMail-1.4.1 introduced 3 new columns used to enable or disable per-user
SOGo webmail, calendar and activesync services, but they were set to improper
column `CHAR(1)` because SOGo doesn't support it, we will change them to
`VARCHAR(1)`:

- `enablesogowebmail`
- `enablesogocalendar`
- `enablesogoactivesync`

3 columns are not used at all:

- `lastlogindate`
- `lastloginipv4`
- `lastloginprotocol`

Download plain SQL file used to update SQL table:

```
wget -O /tmp/iredmail.pgsql https://github.com/iredmail/iRedMail/raw/1.4.2/update/1.4.2/iredmail.pgsql
chmod +r /tmp/iredmail.pgsql
```

* Connect to PostgreSQL server as `postgres` user and import the SQL file:
    * on Linux, it's `postgres` user
    * on FreeBSD, it's `pgsql` user
    * on OpenBSD, it's `_postgresql` user

```
su - postgres
psql -d vmail < /tmp/iredmail.pgsql
```

* Remove downloaded file:

```
rm -f /tmp/iredmail.pgsql
```

### SOGo: Re-create SQL VIEW and update config file

Download plain SQL file used to update SQL table:

```
wget -O /tmp/sogo.pgsql https://github.com/iredmail/iRedMail/raw/1.4.2/update/1.4.2/sogo.pgsql
chmod +r /tmp/sogo.pgsql
```

!!! warning

    Please open downloaded file `/tmp/sogo.pgsql`, replace placeholder
    `VMAIL_DB_BIND_PASSWD` by the real password of SQL user `vmail`.
    You can find the password in any file under `/etc/postfix/pgsql/`.

After updated `/tmp/sogo.pgsql`, please connect to PostgreSQL server as
`postgres` user and import the SQL file:

* on Linux, it's `postgres` user
* on FreeBSD, it's `pgsql` user
* on OpenBSD, it's `_postgresql` user

```
su - postgres
psql -d sogo < /tmp/sogo.pgsql
```

* Remove downloaded file:

```
rm -f /tmp/sogo.pgsql
```
