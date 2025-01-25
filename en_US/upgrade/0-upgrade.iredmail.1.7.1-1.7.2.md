# Upgrade iRedMail from 1.7.1 to 1.7.2

!!! attention

	 Check out the on-premises, lightweight email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! note "Remote Upgrade Assistance"

    Check out our [remote upgrade support](https://www.iredmail.org/support.html) if you need assistance.

## ChangeLog

- Jan 24, 2025: initial publish.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.7.2
```

### Upgrade iRedAPD (Postfix policy server) to the latest stable release (5.8.1)

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

### Upgrade mlmmjadmin to the latest stable release (3.3.0)

Please follow below tutorial to upgrade mlmmjadmin to the latest stable release:
[Upgrade mlmmjadmin to the latest stable release](./upgrade.mlmmjadmin.html)

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

### Upgrade netdata to the latest stable release (v2.1.1)

If you have netdata installed, you can upgrade it by following this tutorial:
[Upgrade netdata](./upgrade.netdata.html).

### Fixed: incorrect sql column name in Fail2ban script

Run command below to download patched file.

```
wget -O /usr/local/bin/fail2ban_banned_db \
    https://raw.githubusercontent.com/iredmail/iRedMail/1.7.2/samples/fail2ban/bin/fail2ban_banned_db
```

### Fixed: Not serve ACME challenge over HTTP directly

Let's Encrypt cert renewal may fail with error `Connection refused` if the
HTTP request is redirected to HTTPS.

- Replace `/etc/nginx/sites-available/00-default.conf` by content below:

```
#
# Note: This file must be loaded before other virtual host config files,
#
# HTTP
server {
    # Listen on ipv4
    listen 80;
    #listen [::]:80;

    server_name _;

    # Allow ACME challenge to be served over HTTP (don't redirect to HTTPS).
    location ~* ^/.well-known/acme-challenge/ {
        root /opt/www/well_known;
        try_files $uri =404;
        allow all;
    }

    # Redirect all insecure http requests to https.
    location / {
        return 301 https://$host$request_uri;
    }
}
```

- Create new directory `/opt/www/well_known`, set correct owner, group and
  permission, then restart Nginx service:

```
mkdir -p /opt/www/well_known
chown root:root /opt/www/well_known
chmod 0755 /opt/www/well_known
service nginx restart
```

Note: If you renew cert with `certbot` program and `--webroot` argument,
you may need to specify `-w /opt/www/well_known` (or
`--webroot-path /opt/www/well_known`) each time from now on.

## For OpenLDAP backend

### Update LDAP schema file

New schema allows mail alias account to use 2 more attributes:
- `accessPolicy`,
- `listModerator`.

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

```
ftp -o /tmp/iredmail.schema https://github.com/iredmail/iRedMail/raw/1.7.2/samples/iredmail/iredmail.schema
mv /etc/openldap/schema/iredmail.schema{,.bak}
cp -f /tmp/iredmail.schema /etc/openldap/schema/
rcctl restart slapd
```

### Fixed: incorrect sql table name in SOGo config file

!!! attention

    This's a bug introduced in iRedMail-1.7.1, this fix is applicable if your
    server was deployed with iRedMail-1.7.1.

Fix incorrect sql table name in SOGo config file, rename the table in SQL
database, and restart SOGO service:

```
perl -pi -e 's#PH_SOGO_DB_TABLE_ADMIN#sogo_admin#g' /etc/sogo/sogo.conf
mysql sogo -e "RENAME TABLE PH_SOGO_DB_TABLE_ADMIN TO sogo_admin;"
service sogo restart
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

### Fixed: incorrect sql table name in SOGo config file

!!! attention

    This's a bug introduced in iRedMail-1.7.1, this fix is applicable if your
    server was deployed with iRedMail-1.7.1.

Fix incorrect sql table name in SOGo config file, rename the table in SQL
database, and restart SOGO service:

```
perl -pi -e 's#PH_SOGO_DB_TABLE_ADMIN#sogo_admin#g' /etc/sogo/sogo.conf
mysql sogo -e "RENAME TABLE PH_SOGO_DB_TABLE_ADMIN TO sogo_admin;"
service sogo restart
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

### Fixed: incorrect sql table name in SOGo config file

!!! attention

    This's a bug introduced in iRedMail-1.7.1, this fix is applicable if your
    server was deployed with iRedMail-1.7.1.

Fix incorrect sql table name in SOGo config file:

```
perl -pi -e 's#PH_SOGO_DB_TABLE_ADMIN#sogo_admin#g' /etc/sogo/sogo.conf
```

Switch to PostgreSQL daemon user, rename the table in SQL database, and restart SOGO service:

```
su - postgres
psql -d sogo -c "ALTER TABLE PH_SOGO_DB_TABLE_ADMIN RENAME TO sogo_admin;"
service sogo restart
```
