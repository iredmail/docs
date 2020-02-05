# Webmail customization

## Roundcube webmail

* The text `Roundcube Webmail` under login screen can be replaced by updating
  parameter `product_name` in Roundcube config file.
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
file `sogo-logo.png`:

* On RHEL/CentOS, it's `/usr/lib64/GNUstep/SOGo/WebServerResources/img/sogo-logo.png`
* On Debian/Ubuntu, it's `/usr/lib/GNUstep/SOGo/WebServerResources/img/sogo-logo.png`
* On FreeBSD, it's `/usr/local/GNUstep/Local/Library/SOGo/WebServerResources/img/sogo-logo.png`.
* On OpenBSD, it's `/usr/local/lib/GNUstep/SOGo/WebServerResources/img/sogo-logo.png`.
