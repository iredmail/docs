# Major open source softwares used in iRedMail

[TOC]

## Used Components

Name | Comment
--- |---
[Postfix](http://www.postfix.org) | Mail Transfer Agent (MTA)
[Dovecot](http://www.dovecot.org) | POP3, IMAP and Managesieve server
[Apache](http://httpd.apache.org), [Nginx](http://nginx.org) | Web server
[OpenLDAP](http://www.openldap.org), [ldapd(8)](http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man8/ldapd.8?query=ldapd&arch=i386) | LDAP server, used for storing mail accounts (optional)
[MySQL](http://www.mysql.com), [MariaDB](https://mariadb.org), [PostgreSQL](http://www.postgresql.org) | SQL server used to store application data. Could be used to store mail accounts too.
[Amavisd-new](http://www.amavis.org) | Interface between Postfix and SpamAssassin, ClamAV. it calls SpamAssassin and ClamAV for content-based spam/virus scanning
[SpamAssassin](http://spamassassin.apache.org) | Content-based spam scanner
[ClamAV](http://www.clamav.net/) | Virus scanner
[Roundcube](http://roundcube.net) | Webmail (PHP)
[SOGo Groupware](http://sogo.nu) | A groupware which provides calendar (CalDAV), contact (CardDAV), tasks and ActiveSync services
[Fail2ban](http://www.fail2ban.org) | Scans log files and bans IPs that show the malicious signs -- too many password failures, seeking for exploits, etc
[Awstats](http://www.awstats.org) | Apache and Postfix log analyzer
[iRedAPD](https://bitbucket.org/zhb/iredapd/) | A postfix policy server developed by iRedMail team
<strike>[Cluebringer](http://www.policyd.org)</strike> | <strike>A postfix policy server. Deprecated since iRedMail-0.9.3.</strike>  

## The Big Picture

![](./images/big.picture.png)

## Mail Flow of Inbound Emails

![](./images/flow.inbound.png)

## Mail Flow of Outbound Emails

![](./images/flow.outbound.png)

## See also

* [Locations of configuration and log files of major components](./file.locations.html)
* [Which network ports are open by iRedMail](./network.ports.html)
