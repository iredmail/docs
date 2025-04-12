# Webmail customization

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

## Roundcube webmail

* The text `Roundcube Webmail` under login screen can be replaced by updating
  parameter `product_name` in [Roundcube config file](./file.locations.html#roundcube).
* Logo image can be customized with parameter `skin_logo` in Roundcube config
  file

```
$config['product_name'] = 'My Company Name';
$config['skin_logo'] = '...';   // Please read the comment lines in
                                // /opt/www/roundcubemail/config/defaults.inc.php
                                // for more details
```

* [Styling the Roundcube Frontend](https://github.com/roundcube/roundcubemail/wiki/Skins)

## SOGo Groupware

### HTML templates

[How to customize the HTML](https://sogo.nu/support/faq/how-to-customize-the-html.html)

### Logo image

You can set custom logo image displayed on the login page of SOGo by replacing
file `sogo-full.svg`, but it will be overridden each time you upgrade SOGo
packages:

* On RHEL/CentOS: `/usr/lib64/GNUstep/SOGo/WebServerResources/img/sogo-full.svg`
* On Debian/Ubuntu, it's `/usr/lib/GNUstep/SOGo/WebServerResources/img/sogo-full.svg`
* On FreeBSD, it's `/usr/local/GNUstep/Local/Library/SOGo/WebServerResources/img/sogo-full.svg`.
* On OpenBSD, it's `/usr/local/lib/GNUstep/SOGo/WebServerResources/img/sogo-full.svg`.

Another way to customize Nginx config file to handle http request to this
logo image.

Edit file `/etc/nginx/templates/sogo.tmpl`, add these lines at the beginning:

```
location = /SOGo.woa/WebServerResources/img/sogo-full.svg {
    return 301 https://myhost.com/sogo-full.svg;
}
```

You can even use different logo images for each web domain:

```
location = /SOGo.woa/WebServerResources/img/sogo-full.svg {
    if ($host = "domain1.com") {
        return 301 https://myhost.com/sogo-full-domain1.com.svg;
    }

    if ($host = "domain2.com") {
        return 301 https://myhost.com/sogo-full-domain2.com.svg;
    }

    return 404;
}
```
