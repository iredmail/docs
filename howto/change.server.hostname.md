# Change server hostname

To change server hostname after iRedMail installation, please update below
files to replace old hostname by the new one:

## System config files

* `/etc/hosts`

* Debian/Ubuntu: `/etc/hostname`
* Debian/Ubuntu: `/etc/mailname`

## Postfix

* `/var/spool/postfix/etc/hosts`
* `/etc/postfix/main.cf` (Linux/OpenBSD) or `/usr/local/etc/postfix/main.cf` (FreeBSD)

## Awstats

* `/etc/awstats/awstats.web.conf`
* `/etc/awstats/awstats.smtp.conf`

## Apache

* RHEL/CentOS: `/etc/httpd/conf/httpd.conf`
* Debian/Ubuntu: `/etc/apache2/apache.conf`

## Amavisd

* RHEL/CentOS, OpenBSD: `/etc/amavisd/amavisd.conf`
* Debian/Ubuntu: `/etc/amavis/conf.d/50-user`
* FreeBSD: `/usr/local/etc/amavisd.conf`

## SOGO

* `/etc/httpd/conf.d/SOGo.conf`
* `/etc/apache2/conf.d/SOGo.conf`
* `/etc/apache2/conf-available/SOGo.conf`

