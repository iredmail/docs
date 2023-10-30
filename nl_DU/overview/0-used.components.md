# Belangrijkste open-source software die gebruikt wordt in iRedMail, en "the big picture" van hoe e-mails worden verwerkt

!!! attention

	 Bekijk onze lichtgewicht on-premise e-mail archiveringsoftware ontwikkeld door 
	 het iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

## Used Components

Name | Comment
--- |---
[Postfix](http://www.postfix.org) | Mail Transfer Agent (MTA)
[Dovecot](http://www.dovecot.org) | POP3, IMAP en Managesieve server
[Nginx](http://www.nginx.org), [Nginx](http://nginx.org) | Web server
[OpenLDAP](http://www.openldap.org), [ldapd(8)](http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man8/ldapd.8?query=ldapd&arch=i386) | LDAP server, gebruikt voor het opslaan van e-mail accounts (optioneel)
[MySQL](http://www.mysql.com), [MariaDB](https://mariadb.org), [PostgreSQL](http://www.postgresql.org) | SQL server gebruikt voor het opslaan van applicatiedata. Kan ook gebruikt worden om e-mail accounts op te slaan.
[mlmmj](http://mlmmj.org) | Mailing lijst beheerder. Wordt met iRedMail-0.9.8 en latere versies gebundeld.
[Amavisd-new](http://www.amavis.org) | Interface tussen Postfix en SpamAssassin, ClamAV.
[SpamAssassin](http://spamassassin.apache.org) | Content-gebaseerde spam scanner
[ClamAV](http://www.clamav.net/) | Virus scanner
[Roundcube webmail](http://roundcube.net) | Webmail (PHP)
[SOGo Groupware](http://sogo.nu) | Een groupware die kalender (CalDAV), contactenlijst (CardDAV), taken en ActiveSync services voorziet.
[Fail2ban](http://www.fail2ban.org) | Scant logbestanden en verbant IPs die kwaadwillende tekens vertonen.
[iRedAPD](https://github.com/iredmail/iRedAPD/) | Een simpele postfix policy server ontworpen door het iRedMail team, met SRS (Sender Rewrite Scheme) ondersteuning.

## The Big Picture

![](./images/big.picture.png)

## Mailstroom van binnenkomende e-mails

![](./images/flow.inbound.png)

## Mailstroom van buitengaande e-mails

![](./images/flow.outbound.png)

## Zie ook

* [[Locaties van configuratie and log bestanden van belangrijke componenten](https://docs.iredmail.org/file.locations-nl_DU.html)](./file.locations.html)
* [Welke netwerkpoorten staan open bij iRedMail](./network.ports.html)
