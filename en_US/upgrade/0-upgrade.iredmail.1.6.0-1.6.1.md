# Upgrade iRedMail from 1.6.0 to 1.6.1

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

- Aug 22, 2022: initial publish.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.6.1
```

### Upgrade iRedAPD (Postfix policy server) to the latest stable release (5.1)

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

### Upgrade iRedAdmin (open source edition) to the latest stable release (1.8)

Please follow below tutorial to upgrade iRedAdmin to the latest stable release:
[Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html).

### Upgrade netdata to the latest stable release (1.35.1)

If you have netdata installed, you can upgrade it by following this tutorial:
[Upgrade netdata](./upgrade.netdata.html).

### Upgrade Roundcube webmail to the latest stable release (1.5.3)

!!! warning "CentOS 7: please stick to Roundcube 1.5.2"

    If you're running CentOS 7, please upgrade to Roundcube 1.5.2 instead.
    Roundcube 1.5.3 requires PHP-7, but CentOS 7 ships PHP-5.4 which is not
    supported by Roundcube 1.5.3 (and the latest 1.6.0).

    It's time to leave your comfort zone and upgrade this server to CentOS
    Stream 8 or [Rocky Linux 8](https://docs.rockylinux.org/guides/migrate2rocky/).

!!! attention

    Latest Roundcube release is 1.6.0, but it still has some compatibility
    issues with PHP-8 (Ubuntu 22.04 ships PHP-8.1), so we suggest wait for
    next new release, e.g. Roundcube 1.6.1 or even 1.6.2.

    If you're running Debian 11 or Ubuntu 20.04, it's ok to upgrade to
    Roundcube 1.6.0 since both ship PHP-7.4.

Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release:

* [How to upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).

## General (All backends should apply these changes)

### Postfix: Bypass more facebook HELO hostnames

Find below line in `/etc/postfix/helo_access.pcre` (Linux/OpenBSD) or
`/usr/local/etc/postfix/helo_access.pcre` (FreeBSD):

```
/^\d{1,3}-\d{1,3}-\d{1,3}-\d{1,3}\.mail-(mail|campmail)\.facebook\.com$/ OK
```

Replace it by:

```
/^\d{1,3}-\d{1,3}-\d{1,3}-\d{1,3}\.mail-.*\.facebook\.com$/ OK
```

Reloading or restarting postfix service is required.

### SOGo: New yum / apt repository sites, new GPG signing key

SOGo team [announced](https://www.mail-archive.com/users@sogo.nu/msg31386.html)
that the SOGo groupware was acquired by Alinto on 16 May 2022, and [officially
transferred](https://www.mail-archive.com/users@sogo.nu/msg31614.html) since
08 Aug 2022. New yum and apt repository site replaces old one, so all users
must update the yum / apt repo config file for updating packages.

#### CentOS, CentOS Stream, Rocky Linux

- Replace all content in file `/etc/yum.repos.d/sogo.repo` by content below:

```
[SOGo]
name=SOGo Groupware
baseurl=https://packages.sogo.nu/nightly/5/rhel/$releasever/$basearch
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/sogo-nightly
```

- Run commands to download GPG key, refresh yum repo metadata and (optionally)
  update sogo packages:

```
wget \
    -O /etc/pki/rpm-gpg/sogo-nightly \
    https://keys.openpgp.org/vks/v1/by-fingerprint/74FFC6D72B925A34B5D356BDF8A27B36A6E2EAE9
yum clean metadata
yum update 'sogo*' '*sope*'
```

#### Debian, Ubuntu

- Import GPG key with command below (run as `root` user):

```
wget -O- "https://keys.openpgp.org/vks/v1/by-fingerprint/74FFC6D72B925A34B5D356BDF8A27B36A6E2EAE9" | gpg --dearmor | apt-key add -
```

- Open file `/etc/apt/sources.list.d/sogo-nightly.list`, replace URL
  `https://packages.inverse.ca/SOGo/` by `https://packages.sogo.nu/`.

- Refresh the repository metadata:

```
apt-get update
```

## For OpenLDAP backend

### Fixed: SOGo: Not expand mailing list members while inviting a mailing list in event

Please open SOGo config file `/etc/sogo/sogo.conf` (on Linux/OpenBSD) or
`/usr/local/etc/sogo/sogo.conf` (on FreeBSD), find the `SOGoUserSources`
parameter like below:

```
    SOGoUserSources = (
        {
            // Used for user authentication
            type = ldap;
            id = users;
            canAuthenticate = YES;

            // ... omit other lines ...
        },
```

Add new parameter `GroupObjectClasses` like below:

```
    SOGoUserSources = (
        {
            // Used for user authentication
            type = ldap;
            id = users;
            canAuthenticate = YES;

            // ... omit other lines ...

            GroupObjectClasses = (
                "mailList",
                "group",
                "groupOfNames",
                "groupOfUniqueNames",
                "posixgroup"
            );
        },
```

Restarting SOGo service is required.

## For MySQL / MariaDB backends

### Enable iRedAPD plugin for mailing list access control

iRedMail-1.6.0 and earlier releases didn't enable plugin `sql_ml_access_policy`
by default, this causes some confusion, and not stop unauthorized emails to
certain mailing lists.

Please open file `/opt/iredapd/settings.py`, find parameter `plugins =` like
below:

```
plugins = [..., "sql_alias_access_policy"]
```

Append the plugin name `sql_ml_access_policy` like below:

```
plugins = [..., "sql_alias_access_policy", "sql_ml_access_policy"]
```

Restarting `iredapd` service is required.

## For PostgreSQL backend

### Enable iRedAPD plugin for mailing list access control

iRedMail-1.6.0 and earlier releases didn't enable plugin `sql_ml_access_policy`
by default, this causes some confusion, and not stop unauthorized emails to
certain mailing lists.

Please open file `/opt/iredapd/settings.py`, find parameter `plugins =` like
below:

```
plugins = [..., "sql_alias_access_policy"]
```

Append the plugin name `sql_ml_access_policy` like below:

```
plugins = [..., "sql_alias_access_policy", "sql_ml_access_policy"]
```

Restarting `iredapd` service is required.

### SOGo: Fix incorrect SQL database and table names

Since iRedMail-1.6.0, we create SQL VIEW in `vmail` database directly for
user authentication in SOGo Groupware, but its config file was configured with
wrong SQL database and table names.

- Open file `/etc/sogo/sogo.conf` (on Linux/OpenBSD) or
  `/usr/local/etc/sogo/sogo.conf` (on FreeBSD), find __ALL__ `viewURL =`
  parameters like below:

```
            viewURL = "postgresql://.../sogo/users";
```

- Replace the database name `sogo` and `users`:

```
            viewURL = "postgresql://.../vmail/sogo_users";
```

- Restart memcached and SOGo service (Note: on CentOS, the service name is
  `sogod`, not `sogo`):

```
service memcached restart
service sogo restart
```
