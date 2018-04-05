# Webmail customization

## Roundcube webmail

* [Styling the Roundcube Frontend](https://github.com/roundcube/roundcubemail/wiki/Skins)
* Logo image is defined in each skin under Roundcube directory: `skins/<skin>/images/roundcube_logo.png`.

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
