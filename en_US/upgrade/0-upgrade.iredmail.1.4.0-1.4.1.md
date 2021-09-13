# Upgrade iRedMail from 1.4.0 to 1.4.1

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

* Sep 13, 2021: Fix incorrect PostgreSQL column type for new columns introduced
  in table `vmail.mailbox`.
* Sep 08, 2021: initial release.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.4.1
```

### Upgrade iRedAPD (Postfix policy server) to the latest stable release (5.0.3)

!!! attention

    iRedAPD has been migrated to Python 3 and doesn't support Python 2 anymore.

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

### Upgrade iRedAdmin (open source edition) to the latest stable release (1.5)

!!! attention

    iRedAdmin has been migrated to Python 3 and doesn't support Python 2 anymore.

Please follow below tutorial to upgrade iRedAdmin to the latest stable release:
[Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html).

### Upgrade mlmmjadmin to the latest stable release (3.1.2)

Please follow below tutorial to upgrade mlmmjadmin to the latest stable release:
[Upgrade mlmmjadmin to the latest stable release](./upgrade.mlmmjadmin.html)

### Amavisd: Add some useful ban rules

Microsoft Office documents are banned with iRedMail default settings, but it's
common that some mailbox may need to receive such documents.

Here we define some ban rules to allow these Office document types, iRedMail
server admin can update per-user spam policy to allow receiving such documents.

- Update Amavisd config file and append these lines before the last line (`1;`):
    - on RHEL/CentOS/Rocky Linux, it's `/etc/amavisd/amavisd.conf`.
    - on Debian/Ubuntu, it's `/etc/amavis/conf.d/50-user`.
    - on FreeBSD, it's `/usr/local/etc/amavisd.conf`.
    - on OpenBSD, it's `/etc/amavisd/amavisd.conf`.

```
# Define some useful rules.
%banned_rules = (
    # Allow all Microsoft Office documents.
    'ALLOW_MS_OFFICE'   => new_RE([qr'.\.(doc|docx|xls|xlsx|ppt|pptx)$'i => 0]),

    # Allow Microsoft Word, Excel, PowerPoint documents separately.
    'ALLOW_MS_WORD'     => new_RE([qr'.\.(doc|docx)$'i => 0]),
    'ALLOW_MS_EXCEL'    => new_RE([qr'.\.(xls|xlsx)$'i => 0]),
    'ALLOW_MS_PPT'      => new_RE([qr'.\.(ppt|pptx)$'i => 0]),

    # Default rule.
    'DEFAULT' => $banned_filename_re,
);
```

- Restarting Amavisd service is required.

Here we defines 5 ban rules:

- `ALLOW_MS_OFFICE`: Allow all Microsoft Office documents.
- `ALLOW_MS_WORD`: Allow Microsoft Word documents (`.doc`, `.docx`).
- `ALLOW_MS_EXCEL`: Allow Microsoft Excel documents (`.xls`, `.xlsx`).
- `ALLOW_MS_PPT`: Allow Microsoft PowerPoint documents (`.ppt`, `.pptx`).
- `DEFAULT`: use the default ban rule defined in `$banned_filename_re`.

You're free to define more ban rules to fit your own needs.

!!! attention

    #### Example: How to use these ban rules

    If you already define per-user, per-domain, or global spam policy with
    iRedAdmin-Pro or manually, you can now assign these ban rules to them.

    For example, if you have spam policy for user `user@domain.com`, to allow
    this user to accept Microsoft Word and Excel documents, you can run SQL
    commands below to achieve it (Note: we use MySQL for example):

        USE amavisd;
        UPDATE policy SET banned_rulenames="ALLOW_MS_WORD,ALLOW_MS_EXCEL" WHERE policy_name="user@domain.com";

## For OpenLDAP backend

### Add new attribute/value pairs for per-user SOGo webmail / calendar / activesync service control

iRedMail-1.4.1 improves SOGo config file and it's able to enable or disable
per-user SOGo webmail, calendar, activesync services with 3 new LDAP
attribute/value pairs:

- `enabledService=sogowebmail`
- `enabledService=sogocalendar`
- `enabledService=sogoactivesync`

The old `enabledService=sogo` is still used to enable or disable whole SOGo
access.

* Download script used to update existing mail accounts:

```
cd /root/
wget https://github.com/iredmail/iRedMail/raw/1.4.1/update/1.4.1/update-ldap.py
```

* Open downloaded file `update-ldap.py`, set LDAP server related settings in
  this file:

    You can find required LDAP credential in iRedAdmin config file
    (`/opt/www/iredadmin/settings.py`), using either
    `cn=Manager,dc=xx,dc=xx` or `cn=vmailadmin,dc=xx,dc=xx` as bind dn is ok.

```
# Part of file: updateLDAPValues_099_to_1.py

uri = 'ldap://127.0.0.1:389'
basedn = 'o=domains,dc=example,dc=com'
bind_dn = 'cn=vmailadmin,dc=example,dc=com'
bind_pw = 'passwd'
```

* Execute this script with Python-3 to update LDAP data:

```
# python3 update-ldap.py
```

### SOGo: Update config file

Open SOGo main config file `/etc/sogo/sogo.conf` (Linux/OpenBSD) or
`/usr/local/etc/sogo/sogo.conf` (FreeBSD), find the `SOGoUserSources` block
like below:

```
    // Authentication using LDAP
    SOGoUserSources = (
        {
            // Used for user authentication
            type = ldap;
            id = users;
            canAuthenticate = YES;

            // ... we omit other config lines here ...
        }
    )
```

Add new parameter `ModulesConstraints` right after `canAuthenticate = YES;`
line like below:

```
    SOGoUserSources = (
        {
            // ... we omit other config lines here ...
            canAuthenticate = YES;

            ModulesConstraints = {
                Mail = { enabledService = sogowebmail; };
                Calendar = { enabledService = sogocalendar; };
                ActiveSync = { enabledService = sogoactivesync; };
            };

            // ... we omit other config lines here ...
        }
    )
```

## For MySQL and MariaDB backends

### Add new SQL columns in `vmail.mailbox` table for per-user SOGo webmail / calendar / activesync service control

iRedMail-1.4.1 introduces 3 new columns used to enable or disable per-user
SOGo webmail, calendar and activesync services:

- `enablesogowebmail`
- `enablesogocalendar`
- `enablesogoactivesync`

Download plain SQL file used to update SQL table, then import it as
MySQL root user (Please run commands below as `root` user):

```
wget -O /tmp/iredmail.mysql https://github.com/iredmail/iRedMail/raw/1.4.1/update/1.4.1/iredmail.mysql
mysql vmail < /tmp/iredmail.mysql
rm -f /tmp/iredmail.mysql
```

### SOGo: Re-create SQL VIEW and update config file

Download plain SQL file used to update SQL table, then import it as
MySQL root user (Please run commands below as `root` user):

```
wget -O /tmp/sogo.mysql https://github.com/iredmail/iRedMail/raw/1.4.1/update/1.4.1/sogo.mysql
mysql sogo < /tmp/sogo.mysql
rm -f /tmp/sogo.mysql
```

Now open SOGo main config file `/etc/sogo/sogo.conf` (Linux/OpenBSD) or
`/usr/local/etc/sogo/sogo.conf` (FreeBSD), find the `SOGoUserSources` block
like below:

```
    // Authentication using SQL
    SOGoUserSources = (
        {
            type = sql;
            id = users;
            viewURL = ...
            canAuthenticate = YES;

            // ... we omit other config lines here ...
        }
    )
```

Add new parameter `ModulesConstraints` right after `canAuthenticate = YES;`
line like below:

```
    SOGoUserSources = (
        {
            // ... we omit other config lines here ...
            canAuthenticate = YES;

            ModulesConstraints = {
                Mail = { c_webmail = y; };
                Calendar = { c_calendar = y; };
                ActiveSync = { c_activesync = y; };
            };

            // ... we omit other config lines here ...
        }
    )
```

Restarting SOGo service is requried.

## For PostgreSQL backend

### Add new SQL columns in `vmail.mailbox` table for per-user SOGo webmail / calendar / activesync service control

iRedMail-1.4.1 introduces 3 new columns used to enable or disable per-user
SOGo webmail, calendar and activesync services:

- `enablesogowebmail`
- `enablesogocalendar`
- `enablesogoactivesync`

Download plain SQL file used to update SQL table:

```
wget -O /tmp/iredmail.pgsql https://github.com/iredmail/iRedMail/raw/1.4.1/update/1.4.1/iredmail.pgsql
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
wget -O /tmp/sogo.pgsql https://github.com/iredmail/iRedMail/raw/1.4.1/update/1.4.1/sogo.pgsql
chmod +r /tmp/sogo.pgsql
```

Please open file `/tmp/sogo.pgsql`, replace string `VMAIL_DB_BIND_PASSWD` by
the real password of SQL user `vmail`. You can find the password in any file
under `/etc/postfix/pgsql/`.

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

Now open SOGo main config file `/etc/sogo/sogo.conf` (Linux/OpenBSD) or
`/usr/local/etc/sogo/sogo.conf` (FreeBSD), find the `SOGoUserSources` block
like below:

```
    // Authentication using SQL
    SOGoUserSources = (
        {
            type = sql;
            id = users;
            viewURL = ...
            canAuthenticate = YES;

            // ... we omit other config lines here ...
        }
    )
```

Add new parameter `ModulesConstraints` right after `canAuthenticate = YES;`
line like below:

```
    SOGoUserSources = (
        {
            // ... we omit other config lines here ...
            canAuthenticate = YES;

            ModulesConstraints = {
                Mail = { c_webmail = y; };
                Calendar = { c_calendar = y; };
                ActiveSync = { c_activesync = y; };
            };

            // ... we omit other config lines here ...
        }
    )
```

Restarting SOGo service is requried.
