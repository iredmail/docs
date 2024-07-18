# Upgrade iRedMail from 1.6.8 to 1.7.0

!!! attention

	 Check out the on-premises, lightweight email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

- July 17, 2024: initial publish.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.7.0
```

### Upgrade Roundcube webmail to the latest stable release (1.6.7)

!!! warning "CentOS 7: please stick to Roundcube 1.5.2"

    __It's time to leave your comfort zone and upgrade this server to at least
    CentOS Stream 8 or [Rocky Linux 8](https://docs.rockylinux.org/guides/migrate2rocky/).__

    If you're running CentOS 7, please upgrade to Roundcube 1.5.2 instead.
    Roundcube 1.5.3 requires PHP-7, but CentOS 7 ships PHP-5.4 which is not
    supported by Roundcube 1.5.3 and later releases, including 1.6.x.

    __Unfortunately, Roundcube 1.5.2 does NOT contains multiple security fixes
    which shipped in Roundcube 1.5.6 and 1.6.5.__

!!! warning "Ubuntu 18.04: please stick to Roundcube 1.5.7"

    Ubuntu 18.04 runs old php version, v1.5.6 contains the security fix too.
    Anyway, please consider upgrading your OS to at least 20.04 LTS as soon as
    possible.

* [Upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).

### Upgrade SOGo to latest 5.10.0 and add required new parameter

SOGo v5.10.0 introduces a required new parameter `OCSAdminURL` in config file.
Please add this new parameter and upgrade SOGo to latest nightly build.

Add new parameter `OCSAdminURL` in sogo.conf for the new SQL table `sogo_admin` introduced in SOGo v5.10.0.

### Upgrade mlmmjadmin to the latest stable release (3.2.1)

Please follow below tutorial to upgrade mlmmjadmin to the latest stable release:
[Upgrade mlmmjadmin to the latest stable release](./upgrade.mlmmjadmin.html)

### Upgrade iRedAPD (Postfix policy server) to the latest stable release (5.6.0)

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

### Upgrade iRedAdmin (open source edition) to the latest stable release (2.6)

!!! warning

    It addresses 2 possible XSS vulnerabilities, please upgrade as soon as possible.

Please follow below tutorial to upgrade iRedAdmin to the latest stable release:
[Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html).

### Upgrade netdata to the latest stable release (1.46.2)

If you have netdata installed, you can upgrade it by following this tutorial:
[Upgrade netdata](./upgrade.netdata.html).

### [OPTIONAL] Disable multi-threaded database reload in ClamAV

```
ConcurrentDatabaseReload no
```

## For MariaDB backend

### Store enabeld jail names in SQL database

!!! attention

    This step is required if you configured Fail2ban to [store banned IP
    addresses in SQL database](./fail2ban.sql.html) for easier management on
    iRedAdmin-Pro.

Copy and run shell commands below to implement this improvement:
```
# Create new SQL table 'fail2ban.jails' to store jail names:
wget -O /tmp/f2b.sql https://raw.githubusercontent.com/iredmail/iRedMail/1.7.0/update/1.7.0/fail2ban.mysql
mysql fail2ban < /tmp/f2b.sql
rm -f /tmp/f2b.sql

# Replace action script:
wget -O /usr/local/bin/fail2ban_banned_db \
    https://raw.githubusercontent.com/iredmail/iRedMail/1.7.0/samples/fail2ban/bin/fail2ban_banned_db

# Replace action config file
wget -O /etc/fail2ban/action.d/banned_db.conf \
    https://raw.githubusercontent.com/iredmail/iRedMail/1.7.0/samples/fail2ban/action.d/banned_db.conf

# Restarting fail2ban service is required:
systemctl restart fail2ban
```

## For PostgreSQL backend

### Store enabeld jail names in SQL database

!!! attention

    This step is required if you configured Fail2ban to [store banned IP
    addresses in SQL database](./fail2ban.sql.html) for easier management on
    iRedAdmin-Pro.

Copy and run shell commands below to implement this improvement:
```
# Create new SQL table 'fail2ban.jails' to store jail names:
wget -O /tmp/f2b.sql https://raw.githubusercontent.com/iredmail/iRedMail/1.7.0/update/1.7.0/fail2ban.pgsql
su - postgres
psql -d fail2ban -c "\i /tmp/f2b.sql"
rm -f /tmp/f2b.sql

# Replace action script:
wget -O /usr/local/bin/fail2ban_banned_db \
    https://raw.githubusercontent.com/iredmail/iRedMail/1.7.0/samples/fail2ban/bin/fail2ban_banned_db

# Replace action config file
wget -O /etc/fail2ban/action.d/banned_db.conf \
    https://raw.githubusercontent.com/iredmail/iRedMail/1.7.0/samples/fail2ban/action.d/banned_db.conf

# Restarting fail2ban service is required:
systemctl restart fail2ban
```

### [OPTIONAL] Track user last login time

iRedMail supports tracking user last login time for MySQL/MariaDB/OpenLDAP
backends since iRedMail-1.2, but not PostgreSQL backend. It now finally comes.

This feature is offered by Dovecot, and is available in Dovecot-2.3.16 and
later version, so it's available on:

- Debian 12
- Ubuntu 22.04 and later releases
- CentOS / Rocky / AlmaLinux 9
- OpenBSD 7.3 and later releases

Please follow this tutorial to implement it:

- [Track user last login time](https://docs.iredmail.org/track.user.last.login.html)

## For OpenLDAP backend

### Store enabeld jail names in SQL database

!!! attention

    This step is required if you configured Fail2ban to [store banned IP
    addresses in SQL database](./fail2ban.sql.html) for easier management on
    iRedAdmin-Pro.

Copy and run shell commands below to implement this improvement:
```
# Create new SQL table 'fail2ban.jails' to store jail names:
wget -O /tmp/f2b.sql https://raw.githubusercontent.com/iredmail/iRedMail/1.7.0/update/1.7.0/fail2ban.mysql
mysql fail2ban < /tmp/f2b.sql
rm -f /tmp/f2b.sql

# Replace action script:
wget -O /usr/local/bin/fail2ban_banned_db \
    https://raw.githubusercontent.com/iredmail/iRedMail/1.7.0/samples/fail2ban/bin/fail2ban_banned_db

# Replace action config file
wget -O /etc/fail2ban/action.d/banned_db.conf \
    https://raw.githubusercontent.com/iredmail/iRedMail/1.7.0/samples/fail2ban/action.d/banned_db.conf

# Restarting fail2ban service is required:
systemctl restart fail2ban
```
