# Upgrade iRedMail from 1.7.1 to 1.7.2

!!! warning

    THIS IS A DRAFT DOCUMENT, DO NOT APPLY IT ON PRODUCTION SERVER.

!!! attention

	 Check out the on-premises, lightweight email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

- Nov XX, 2024: initial publish.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.7.2
```

### Upgrade Roundcube webmail to the latest stable release (1.6.9 or 1.5.9)

!!! warning "CentOS 7: please stick to Roundcube 1.5.2"

    __It's time to leave your comfort zone and upgrade this server to at least
    CentOS Stream 8 or [Rocky Linux 8](https://docs.rockylinux.org/guides/migrate2rocky/).__

    If you're running CentOS 7, please upgrade to Roundcube 1.5.2 instead.
    Roundcube 1.5.3 requires PHP-7, but CentOS 7 ships PHP-5.4 which is not
    supported by Roundcube 1.5.3 and later releases, including 1.6.x.

    __Unfortunately, Roundcube 1.5.2 does NOT contains multiple security fixes
    which shipped in Roundcube 1.5.6 and 1.6.5.__

!!! warning "Ubuntu 18.04: please stick to Roundcube 1.5.9"

    Ubuntu 18.04 runs old php version which is not supported by Roundcube 1.6.

* [Upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).

### Upgrade netdata to the latest stable release (1.47.5)

If you have netdata installed, you can upgrade it by following this tutorial:
[Upgrade netdata](./upgrade.netdata.html).

### Fixed: incorrect sql column name in Fail2ban script

Run command below to override existing one. That's all.

```
wget -O /usr/local/bin/fail2ban_banned_db \
    https://raw.githubusercontent.com/iredmail/iRedMail/1.7.2/samples/fail2ban/bin/fail2ban_banned_db
```

## For OpenLDAP backend

### Update LDAP schema file

New schema allows mail alias account to use 2 more attributes: `accessPolicy`,
`listModerator`.

Download the latest iRedMail LDAP schema file:

* On RHEL/CentOS:

```
wget -O /tmp/iredmail.schema https://github.com/iredmail/iRedMail/raw/1.7.2/samples/iredmail/iredmail.schema
mv /etc/openldap/schema/iredmail.schema{,.bak}
cp -f /tmp/iredmail.schema /etc/openldap/schema/
service slapd restart
```

* On Debian/Ubuntu:
```
wget -O /tmp/iredmail.schema https://github.com/iredmail/iRedMail/raw/1.7.2/samples/iredmail/iredmail.schema
mv /etc/ldap/schema/iredmail.schema{,.bak}
cp -f /tmp/iredmail.schema /etc/ldap/schema/
service slapd restart
```

* On FreeBSD:

```
wget -O /tmp/iredmail.schema https://github.com/iredmail/iRedMail/raw/1.7.2/samples/iredmail/iredmail.schema
mv /usr/local/etc/openldap/schema/iredmail.schema{,.bak}
cp -f /tmp/iredmail.schema /usr/local/etc/openldap/schema/
service slapd restart
```

* On OpenBSD:

    > Note: if you're running ldapd as LDAP server, the schema directory is
    > `/etc/ldap`, and service name is `ldapd`.

```
ftp -o /tmp/iredmail.schema https://github.com/iredmail/iRedMail/raw/1.7.2/samples/iredmail/iredmail.schema
mv /etc/openldap/schema/iredmail.schema{,.bak}
cp -f /tmp/iredmail.schema /etc/openldap/schema/
rcctl restart slapd
```

## For MariaDB backend

### Fixed: Not detect domain status while querying per-domain BCC

- Open file `/etc/postfix/mysql/recipient_bcc_maps_domain.cf`, replace the `query =` line by below one:

```
query       = SELECT recipient_bcc_domain.bcc_address FROM recipient_bcc_domain, domain WHERE recipient_bcc_domain.domain='%d' AND recipient_bcc_domain.domain=domain.domain AND domain.active=1
```

- Open file `/etc/postfix/mysql/sender_bcc_maps_domain.cf`, replace the `query =` line by below one:

```
query       = SELECT sender_bcc_domain.bcc_address FROM sender_bcc_domain, domain WHERE sender_bcc_domain.domain='%d' AND sender_bcc_domain.domain=domain.domain AND domain.active=1
```

## For PostgreSQL backend

### Fixed: Not detect domain status while querying per-domain BCC

- Open file `/etc/postfix/pgsql/recipient_bcc_maps_domain.cf`, replace the `query =` line by below one:

```
query       = SELECT recipient_bcc_domain.bcc_address FROM recipient_bcc_domain, domain WHERE recipient_bcc_domain.domain='%d' AND recipient_bcc_domain.domain=domain.domain AND domain.active=1
```

- Open file `/etc/postfix/pgsql/sender_bcc_maps_domain.cf`, replace the `query =` line by below one:

```
query       = SELECT sender_bcc_domain.bcc_address FROM sender_bcc_domain, domain WHERE sender_bcc_domain.domain='%d' AND sender_bcc_domain.domain=domain.domain AND domain.active=1
```
