# Upgrade iRedMail from 1.6.5 to 1.6.6

!!! attention

	 Check out the on-premises, lightweight email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! note "Remote Upgrade Assistance"

    Check out our [remote upgrade support](https://www.iredmail.org/support.html) if you need assistance.

## ChangeLog

- Oct 23, 2023: initial publish.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.6.6
```

### Fail2ban: do not ban client which triggered `lost connection after UNKNOWN` error

Please run commands below as root user to get latest filter file for Roundcube:

```
cd /etc/fail2ban/filter.d/
wget -O postfix.iredmail.conf https://raw.githubusercontent.com/iredmail/iRedMail/1.6.6/samples/fail2ban/filter.d/postfix.iredmail.conf
```

Restarting `fail2ban` service is required.

### Upgrade netdata to the latest stable release (1.43.0)

If you have netdata installed, you can upgrade it by following this tutorial:
[Upgrade netdata](./upgrade.netdata.html).

### Upgrade Roundcube webmail to the latest stable release (1.6.4)

!!! warning "CentOS 7: please stick to Roundcube 1.5.2"

    If you're running CentOS 7, please upgrade to Roundcube 1.5.2 instead.
    Roundcube 1.5.3 requires PHP-7, but CentOS 7 ships PHP-5.4 which is not
    supported by Roundcube 1.5.3 and later releases, including 1.6.x.

    __Unfortunately, Roundcube 1.5.2 does NOT contains the security fix which
    shipped in Roundcube 1.5.4 and 1.5.5.__

    It's time to leave your comfort zone and upgrade this server to at least
    CentOS Stream 8 or [Rocky Linux 8](https://docs.rockylinux.org/guides/migrate2rocky/).

!!! warning "Ubuntu 18.04: please stick to Roundcube 1.5.5"

    Ubuntu 18.04 runs old php version, v1.5.5 contains the security fix too.
    Anyway, please consider upgrading your OS to 20.04 LTS as soon as possible.

Roundcube v1.6.4 and 1.5.5 are security updates. Both fix a cross-site
scripting (XSS) vulnerability.

Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release:

* [How to upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).
