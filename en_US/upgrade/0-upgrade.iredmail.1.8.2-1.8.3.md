# Upgrade iRedMail from 1.8.2 to 1.8.3

!!! attention

    - iRedMail team recommends [iRedMail Enterprise Edition](https://www.iredmail.org/ee.html) for deploying new email server.
    - Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! note "Remote Upgrade Assistance"

    Check out our [remote upgrade support](https://www.iredmail.org/support.html) if you need assistance.

## ChangeLog

- Jul 7, 2026: initial publish.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.8.3
```

### Upgrade Roundcube webmail to the latest release (1.7.2)

!!! warning "Roundcube Security Fixes"

    - [Roundcube 1.6.17, 1.7.2 addressed 6 security vulnerabilities.](https://roundcube.net/news/2026/07/05/security-updates-1.6.17-and-1.7.2)
    - [Roundcube 1.6.16, 1.7.1 addressed 8 security vulnerabilities.](https://roundcube.net/news/2026/05/24/security-updates-1.6.16-and-1.7.1)
    - [Roundcube 1.6.15 addressed 1 security vulnerability.](https://roundcube.net/news/2026/03/29/security-updates-1.7-rc6-1.6.15-1.5.15)
    - [Roundcube 1.6.14 addressed 3 security vulnerabilities.](https://roundcube.net/news/2026/03/18/security-updates-1.7-rc5-1.6.14-1.5.14)
    - [Roundcube 1.6.13 addressed 2 security vulnerabilities.](https://roundcube.net/news/2026/02/08/security-updates-1.6.13-and-1.5.13)
    - [Roundcube 1.6.12 addressed 2 security vulnerabilities.](https://roundcube.net/news/2025/12/13/security-updates-1.6.12-and-1.5.12)

!!! warning "CentOS 7: please stick to Roundcube 1.5.2"

    __It's time to leave your comfort zone and upgrade this server to at least
    CentOS Stream 8 or [Rocky Linux 8](https://docs.rockylinux.org/guides/migrate2rocky/).__

    If you're running CentOS 7, please upgrade to Roundcube 1.5.2 instead.
    Roundcube 1.5.3 requires PHP-7, but CentOS 7 ships PHP-5.4 which is not
    supported by Roundcube 1.5.3 and later releases, including 1.6.x.

    __Unfortunately, Roundcube 1.5.2 does NOT contains multiple security fixes
    which shipped in Roundcube 1.5.6 and 1.6.5.__

!!! warning "CentOS Stream / Rocky / AlmaLinux 8 and 9"

    Roundcube 1.7.0 and later releases requires PHP 8.1 or later, please switch
    to PHP 8.2 with commands below __BEFORE__ upgrading Roundcube:

    ```
    dnf module enable -y php:8.2
    dnf module switch-to -y php:8.2
    ```

!!! warning "Ubuntu 18.04: please stick to Roundcube 1.5.15"

    Ubuntu 18.04 runs old php version which is not supported by Roundcube 1.6 and 1.7.

Download the Roundcube 1.7.2 complete package and upgrade, then restart Nginx service:
```
wget https://github.com/roundcube/roundcubemail/releases/download/1.7.2/roundcubemail-1.7.2-complete.tar.gz
tar zxf roundcubemail-1.7.2-complete.tar.gz
cd roundcubemail-1.7.2
./bin/installto.sh /opt/www/roundcubemail
systemctl restart nginx
```

That's all.
