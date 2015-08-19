# 修改服务器主机名

要在安装 iRedMail 后修改服务器的主机名，请将以下文件中的旧主机名改为新主机名：

## 系统配置文件

* `/etc/hosts`

* Debian/Ubuntu: `/etc/hostname`
* Debian/Ubuntu: `/etc/mailname`

## Postfix

* `/var/spool/postfix/etc/hosts`
* `/etc/postfix/main.cf` (Linux/OpenBSD) 或者 `/usr/local/etc/postfix/main.cf` (FreeBSD)

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
