# Upgrade iRedMail from 1.8.0 to 1.8.1

!!! attention

    - iRedMail team recommends [iRedMail Enterprise Edition](https://www.iredmail.org/ee.html) for deploying new email server.
    - Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! note "Remote Upgrade Assistance"

    Check out our [remote upgrade support](https://www.iredmail.org/support.html) if you need assistance.

## ChangeLog

- May 12, 2026: initial publish.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.8.1
```

### Upgrade Roundcube webmail to the latest release (1.7.0)

!!! warning "Roundcube Security Fixes"

    - [Roundcube 1.6.12 addressed 2 security vulnerabilities.](https://roundcube.net/news/2025/12/13/security-updates-1.6.12-and-1.5.12)
    - [Roundcube 1.6.13 addressed 2 security vulnerabilities.](https://roundcube.net/news/2026/02/08/security-updates-1.6.13-and-1.5.13)
    - [Roundcube 1.6.14 addressed 3 security vulnerabilities.](https://roundcube.net/news/2026/03/18/security-updates-1.7-rc5-1.6.14-1.5.14)
    - [Roundcube 1.6.15 addressed 1 security vulnerability.](https://roundcube.net/news/2026/03/29/security-updates-1.7-rc6-1.6.15-1.5.15)

!!! warning "CentOS 7: please stick to Roundcube 1.5.2"

    __It's time to leave your comfort zone and upgrade this server to at least
    CentOS Stream 8 or [Rocky Linux 8](https://docs.rockylinux.org/guides/migrate2rocky/).__

    If you're running CentOS 7, please upgrade to Roundcube 1.5.2 instead.
    Roundcube 1.5.3 requires PHP-7, but CentOS 7 ships PHP-5.4 which is not
    supported by Roundcube 1.5.3 and later releases, including 1.6.x.

    __Unfortunately, Roundcube 1.5.2 does NOT contains multiple security fixes
    which shipped in Roundcube 1.5.6 and 1.6.5.__

!!! warning "CentOS Stream / Rocky / AlmaLinux 8 and 9"

    Roundcube 1.7.0 requires PHP 8.1 or later, please switch to PHP 8.2 with
    commands below __BEFORE__ upgrading Roundcube:

    ```
    dnf module enable -y php:8.2 && dnf module switch-to -y php:8.2
    ```

!!! warning "Ubuntu 18.04: please stick to Roundcube 1.5.9"

    Ubuntu 18.04 runs old php version which is not supported by Roundcube 1.6 and 1.7.

Roundcube 1.7 introduces "mandatory `public_html/` entry-point for HTTP
servers, protecting all installations better", it requires changes in Nginx
config file.

- Backup Nginx config file first:
```
cp /etc/nginx/templates/roundcube.tmpl{,.bak}
cp /etc/nginx/templates/roundcube-subdomain.tmpl{,.bak}
```

- Replace full content of file `/etc/nginx/templates/roundcube.tmpl` by
  below text. Be careful, we use base URI `/mail/`, if you use a different one,
  please replace it manually.
```
# Block direct access to directories and files.
location ~ ^/mail/(SQL|bin|config|installer|logs|temp|vendor)/ { deny all; }
location ~ ^/mail/(.*\.md|composer\.*|INSTALL|LICENSE|Makefile|UPGRADING)$ { deny all; }
location ~ ^/mail/plugins/.*/config.inc.php.* { deny all; }
location ~ ^/mail/plugins/enigma/home($|/.*) { deny all; }

# Block access to directories and files via `public_html/static.php`.
location ~ ^/mail/static.php/(SQL|bin|config|installer|logs|temp|vendor)/ { deny all; }
location ~ ^/mail/static.php/(.*\.md|composer\.*|INSTALL|LICENSE|Makefile|UPGRADING)$ { deny all; }
location ~ ^/mail/static.php/plugins/.*/config.inc.php.* { deny all; }
location ~ ^/mail/static.php/plugins/enigma/home($|/.*) { deny all; }

# Redirect URI `/mail` to `/mail/`.
location = /mail {
    return 301 /mail/;
}

location = /mail/ {
    alias /opt/www/roundcubemail/public_html/;
    index index.php;
}

location ~ ^/mail/static.php/(.*) {
    include /etc/nginx/templates/hsts.tmpl;
    alias /opt/www/roundcubemail/$1;
}

location ~ ^/mail/(.*\.php)$ {
    include /etc/nginx/templates/hsts.tmpl;
    include /etc/nginx/templates/fastcgi_php.tmpl;
    fastcgi_param SCRIPT_FILENAME /opt/www/roundcubemail/public_html/$1;
}
```

- Replace full content of file `/etc/nginx/templates/roundcube-subdomain.tmpl` by
  below text.
```
# Block direct access to directories and files.
location ~ ^/(SQL|bin|config|installer|logs|temp|vendor)/ { deny all; }
location ~ ^/(.*\.md|composer\.*|INSTALL|LICENSE|Makefile|UPGRADING)$ { deny all; }
location ~ ^/plugins/.*/config.inc.php.* { deny all; }
location ~ ^/plugins/enigma/home($|/.*) { deny all; }

# Block access to directories and files via `public_html/static.php`.
location ~ ^/static.php/(SQL|bin|config|installer|logs|temp|vendor)/ { deny all; }
location ~ ^/static.php/(.*\.md|composer\.*|INSTALL|LICENSE|Makefile|UPGRADING)$ { deny all; }
location ~ ^/static.php/plugins/.*/config.inc.php.* { deny all; }
location ~ ^/static.php/plugins/enigma/home($|/.*) { deny all; }

location / {
    root    /opt/www/roundcubemail/public_html;
    index   index.php index.html;
    include /etc/nginx/templates/hsts.tmpl;
}

location ~ ^/static.php/(.*) {
    include /etc/nginx/templates/hsts.tmpl;
    alias /opt/www/roundcubemail/$1;
}

location ~ ^/(.*\.php)$ {
    include /etc/nginx/templates/hsts.tmpl;
    include /etc/nginx/templates/fastcgi_php.tmpl;
    fastcgi_param SCRIPT_FILENAME /opt/www/roundcubemail/public_html/$1;
}
```

- Download the Roundcube 1.7 and upgrade, then restart Nginx service:
```
wget https://github.com/roundcube/roundcubemail/releases/download/1.7.0/roundcubemail-1.7.0-complete.tar.gz
tar zxf roundcubemail-1.7.0-complete.tar.gz
cd roundcubemail-1.7.0
./bin/installto.sh /opt/www/roundcubemail
systemctl restart nginx
```

That's all.

### Upgrade SOGo to latest release (5.12.8), security fixes

[SOGo team released 5.12.8 on May 12](https://www.sogo.nu/news/2026/sogo-v5128-released.html), "Four major vulnerabilities have been reported and fixed in this version 5.12.8 or since the nightly of the 8th of May 2026: sogo_5.12.7.20260508."

__"Those vulnerabilities affect any previous SOGO version. Please update as soon as possible."__

General way to upgrade it is running commands below:

- For CentOS / Rocky / AlmaLinux:
```
yum clean all
yum update -y "sogo*" "*sope*"
systemctl restart sogo
```

- For Debian/Ubuntu:
```
apt update
apt install --only-upgrade -y "sogo*" "*sope*"
systemctl restart sogod
```

### Upgrade netdata to the latest stable release (v2.10.3)

If you have netdata installed, you can upgrade it by following this tutorial:
[Upgrade netdata](./upgrade.netdata.html).

### Upgrade mlmmjadmin to the latest stable release (3.6.3)

Please follow below tutorial to upgrade mlmmjadmin to the latest stable release:
[Upgrade mlmmjadmin to the latest stable release](./upgrade.mlmmjadmin.html)
