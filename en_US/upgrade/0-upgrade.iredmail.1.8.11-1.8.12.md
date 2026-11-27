# Upgrade iRedMail from 1.8.11 to 1.8.12

!!! attention

    - iRedMail team recommends [iRedMail Enterprise Edition](https://www.iredmail.org/ee.html) for deploying new email server.
    - Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! note "Remote Upgrade Assistance"

    Check out our [remote upgrade support](https://www.iredmail.org/support.html) if you need assistance.

## ChangeLog

- Nov 27, 2026: initial publish.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.8.12
```

### [SECURITY] Fix Nginx config files for Roundcube webmail

Nginx config files shipped in iRedMail 1.8.11 and earlier releases allow
clients to download arbitrary files (including PHP source code) under
Roundcube's installation directory by accessing URL `/mail/static.php/<path>`
(`/static.php/<path>` for the subdomain setup). Please follow steps below to
fix it.

With default iRedMail configuration, only Roundcube's own application files
(PHP source code, templates, localization files, etc.) could be downloaded; no
user data, email messages, credentials, or other privacy or confidential
information were exposed.

!!! note

    - If you use a custom Roundcube base URI (`/mail/` by default) or
      installation directory, please adjust the blocks below.
    - On FreeBSD, the Nginx config files are under
      `/usr/local/etc/nginx/templates/`, and Roundcube is installed under
      `/usr/local/www/roundcube`.

Backup the config files before modifying:

```
cp /etc/nginx/templates/roundcube.tmpl{,.bak}
cp /etc/nginx/templates/roundcube-subdomain.tmpl{,.bak}
```

The `composer.*` deny rule in these config files is incorrect in iRedMail
1.8.11 and earlier: `composer\.*` matches `composer` followed by zero or more
dots, so `composer.json` and `composer.lock` are not blocked by Nginx.
Roundcube's `static.php` already rejects these files, but the rule should be
fixed for defense in depth.

The `static.php` `location` block must also be replaced so Nginx no longer
serves files under the installation directory directly.

#### Update `/etc/nginx/templates/roundcube.tmpl`

Find the two `location` lines below:

```
location ~ ^/mail/(.*\.md|composer\.*|INSTALL|LICENSE|Makefile|UPGRADING)$ { deny all; }
location ~ ^/mail/static.php/(.*\.md|composer\.*|INSTALL|LICENSE|Makefile|UPGRADING)$ { deny all; }
```

Replace them with the two lines below (the `composer` rule is fixed):

```
location ~ ^/mail/(.*\.md|composer\..*|INSTALL|LICENSE|Makefile|UPGRADING)$ { deny all; }
location ~ ^/mail/static.php/(.*\.md|composer\..*|INSTALL|LICENSE|Makefile|UPGRADING)$ { deny all; }
```

Then find the `location` block below:

```
location ~ ^/mail/static.php/(.*) {
    include /etc/nginx/templates/hsts.tmpl;
    alias /opt/www/roundcubemail/$1;
}
```

Replace it by the block below:

```
# Serve static content through PHP: `static.php` validates requested paths, files
# under the installation directory must not be served by Nginx directly.
location ~ ^/mail/static\.php(/|$) {
    include /etc/nginx/templates/hsts.tmpl;
    include /etc/nginx/templates/fastcgi_php.tmpl;

    fastcgi_split_path_info ^(.+?\.php)(/.+)$;
    fastcgi_param SCRIPT_FILENAME /opt/www/roundcubemail/public_html/static.php;
    fastcgi_param PATH_INFO $fastcgi_path_info;
}
```

#### Update `/etc/nginx/templates/roundcube-subdomain.tmpl`

Find the two `location` lines below:

```
location ~ ^/(.*\.md|composer\.*|INSTALL|LICENSE|Makefile|UPGRADING)$ { deny all; }
location ~ ^/static.php/(.*\.md|composer\.*|INSTALL|LICENSE|Makefile|UPGRADING)$ { deny all; }
```

Replace them with the two lines below (the `composer` rule is fixed):

```
location ~ ^/(.*\.md|composer\..*|INSTALL|LICENSE|Makefile|UPGRADING)$ { deny all; }
location ~ ^/static.php/(.*\.md|composer\..*|INSTALL|LICENSE|Makefile|UPGRADING)$ { deny all; }
```

Then find the `location` block below:

```
location ~ ^/static.php/(.*) {
    include /etc/nginx/templates/hsts.tmpl;
    alias /opt/www/roundcubemail/$1;
}
```

Replace it by the block below:

```
# Serve static content through PHP: `static.php` validates requested paths, files
# under the installation directory must not be served by Nginx directly.
location ~ ^/static\.php(/|$) {
    include /etc/nginx/templates/hsts.tmpl;
    include /etc/nginx/templates/fastcgi_php.tmpl;

    fastcgi_split_path_info ^(.+?\.php)(/.+)$;
    fastcgi_param SCRIPT_FILENAME /opt/www/roundcubemail/public_html/static.php;
    fastcgi_param PATH_INFO $fastcgi_path_info;
}
```

Test the Nginx config and restart Nginx service:

```
nginx -t
systemctl restart nginx
```

On FreeBSD, run `service nginx restart` instead. On OpenBSD, run
`rcctl restart nginx`.

After restarting Nginx, accessing
`https://<server>/mail/static.php/program/include/rcmail.php` should return
`404 Not Found` instead of the PHP source code, and
`https://<server>/mail/static.php/composer.json` should return `403 Forbidden`.
For the subdomain setup, use the corresponding URLs without the `/mail/`
prefix.
