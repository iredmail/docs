# Major open source softwares used in iRedMail

[TOC]

## Used Components

Name | Comment
--- |---
[Postfix](http://www.postfix.org) | Mail Transfer Agent (MTA)
[Dovecot](http://www.dovecot.org) | POP3, IMAP and Managesieve server
[Nginx](http://www.nginx.org), [Nginx](http://nginx.org) | Web server
[OpenLDAP](http://www.openldap.org), [ldapd(8)](http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man8/ldapd.8?query=ldapd&arch=i386) | LDAP server, used for storing mail accounts (optional)
[MySQL](http://www.mysql.com), [MariaDB](https://mariadb.org), [PostgreSQL](http://www.postgresql.org) | SQL server used to store application data. Could be used to store mail accounts too.
[mlmmj](http://mlmmj.org) | Mailing list manager. Shipped in iRedMail-0.9.8 and later releases.
[Amavisd-new](http://www.amavis.org) | Interface between Postfix and SpamAssassin, ClamAV.
[SpamAssassin](http://spamassassin.apache.org) | Content-based spam scanner
[ClamAV](http://www.clamav.net/) | Virus scanner
[Roundcube webmail](http://roundcube.net) | Webmail (PHP)
[SOGo Groupware](http://sogo.nu) | A groupware which provides calendar (CalDAV), contact (CardDAV), tasks and ActiveSync services
[Fail2ban](http://www.fail2ban.org) | Scans log files and bans IPs that show the malicious signs
[iRedAPD](https://github.com/iredmail/iRedAPD/) | A simple postfix policy server developed by iRedMail team, with SRS (Sender Rewrite Scheme) support.

## The Big Picture

![](./images/big.picture.png)

## Mail Flow of Inbound Emails

![](./images/flow.inbound.png)

## Mail Flow of Outbound Emails

![](./images/flow.outbound.png)

## See also

* [Locations of configuration and log files of major components](./file.locations.html)
* [Which network ports are open by iRedMail](./network.ports.html)
