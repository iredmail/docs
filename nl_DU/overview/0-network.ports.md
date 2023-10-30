# Welke netwerkpoorten staan open bij iRedMail

Poort | Service | Software | Info | Publieke Toegang Vereist?
--- |--- |--- |--- |---
25 | smtp | Postfix | Gebruikt voor communicatie tussen e-mail servers. __WAARSCHUWING__: Deze poort __MOET__ openstaan, anders kan je geen e-mail ontvangen die verstuurd is door andere e-mail servers. | __JA (VERPLICHT)__{: .red }
587 | submission | Postfix | SMTP over TLS. Gebruikt door jouw gebruikers om e-mails te versturen. | JA (staat open voor je gebruikers)
110 | pop3 | Dovecot | Gebruikt door jouw gebruikers om e-mails af te halen via het POP3 protocol, beveiligde connectie over STARTTLS staat standaard aan. | JA (staat open voor je gebruikers)
995 | pop3s | Dovecot | Gebruikt door jouw gebruikers om e-mails af te halen via het POP3 protocol over SSL. | JA (staat open voor je gebruikers)
143 | imap |Dovecot | Gebruikt door jouw gebruikers om e-mails af te halen via het POP3 protocol, beveiligde connectie over STARTTLS staat standaard aan. | JA (staat open voor je gebruikers)
993 | imaps | Dovecot | Gebruikt door jouw gebruikers om e-mails af te halen via het IMAP protocol over SSL. | JA (staat open voor je gebruikers)
24 | lmtp | Dovecot | Gebruikt om e-mail te versturen naar lokale inboxen via het LMTP protocol. | NEE (luistert standaard naar poort `127.0.0.1`)
4190 | managesieve | Dovecot | Sieve service gebruikt door jouw gebruikers om e-mail filters te beheren. Opmerking: in oude iRedMail versies is het poort 2000 (deprecated en luistert niet eens in `/etc/services` bestand). | NEE (standaard uitgeschakeld en gebruikers moeten e-mail filters beheren via webmail)
80 | http | Apache/Nginx | Web service. standaard omleiding naar https. | JA (staat open voor je gebruikers)
443 | https | Apache/Nginx | Web service over SSL, beveiligde verbinding. | JA (open voor je webmail en ActiveSync gebruikers)
3306 | mysql | MySQL/MariaDB | MySQL/MariaDB database service | NEE (luistert standaard naar poort `127.0.0.1`)
5432 | postgresql | PostgreSQL | PostgreSQL database service | NEE (luistert standaard naar poort `127.0.0.1`)
389 | ldap | OpenLDAP (of OpenBSD ldapd) | LDAP service, STARTTLS is beschikbaar voor beveiligde verbinding. | NEE (luistert standaard naar poort `127.0.0.1`)
636 |ldaps | OpenLDAP (of OpenBSD ldapd) | LDAP service over SSL. Deprecated, poort 389 met STARTTLS aangeraden. | NEE (Staat standaard niet aan)
10024 | | Amavisd-new | Gebruikt om binnenkomende berichten te scannen, bevat spam/virus scanner DKIM verificatie, toegepast spam beleid. | NEE (luistert standaard naar poort `127.0.0.1`)
10025 | smtp | Postfix | Gebruikt door Amavisd om gescande e-mails terug in de Postfix wachtrij te injecteren. | NEE (luistert standaard naar poort `127.0.0.1`)
10026 | | Amavisd-new | Gebruikt om buitengaande berichten te scannen, bevat spam/virus scanner, DKIM signeren, toegepast spam beleid. | NEE (luistert standaard naar poort `127.0.0.1`)
10027 | | Amavisd-new | Gebruikt door mlmmj mailing lijst beheerder, het slaat standaard de spam/virus/header/banned checks over, maar DKIM signeren staat aan. | NEE (luistert standaard naar poort `127.0.0.1`)
10028 | | Postfix | Gebruikt door Amavisd-new om e-mails te regelen die gestuurd worden door mlmmj mailing lijst beheerder. Geïntroduceerd in iRedMail-0.9.9. | NEE (luistert standaard naar poort `127.0.0.1`)
9998 | | Amavisd-new | Gebruikt om in quarantaine geplaatste e-mails te beheren. | NEE (luistert standaard naar poort `127.0.0.1`)
7777 | | iRedAPD | Postfix policy service voor greylisting, whitelisting, blacklists, throttling, etc | NEE (luistert standaard naar poort `127.0.0.1`)
7778 | | iRedAPD | [SRS](https://en.wikipedia.org/wiki/Sender_Rewriting_Scheme) sender adress rewritting. | NEE (luistert standaard naar poort `127.0.0.1`)
7779 | | iRedAPD | [SRS](https://en.wikipedia.org/wiki/Sender_Rewriting_Scheme) recipient address rewritting. | NEE (luistert standaard naar poort `127.0.0.1`)
7790 | http | mlmmjadmin | RESTful API server gebruikt om mlmmj mailing lijsten te beheren. geïntroduceerd in iRedMail-0.9.8. | NEE (luistert standaard naar poort `127.0.0.1`)
7791 | http | iredadmin | iRedAdmin (alleenstaand uwsgi instance). geïntroduceerd in iRedMail-0.9.9. | NEE (luistert standaard naar poort `127.0.0.1`)
20000 | | SOGo | SOGo groupware  | NEE (luistert standaard naar poort `127.0.0.1`)
11211 | | Memcached | Een gedistribueerd, performant memory object caching systeem. Momenteel enkel gebruikt door SOGo Groupware. | NEE (luistert standaard naar poort `127.0.0.1`)
12340 | | Dovecot | Dovecot quota status. Geïntroduceerd in iRedMail-1.0. | NEE (luistert standaard naar poort `127.0.0.1`)
24242 | | Dovecot | Dovecot service status. Geïntroduceerd in iRedMail-0.9.8. | NEE (luistert standaard naar poort `127.0.0.1`)
19999 | | Netdata | Netdata monitor. Geïntroduceerd in iRedMail-0.9.8. | NEE (luistert standaard naar poort `127.0.0.1`)

!!! note

    * In iRedMail-0.9.2 en vorige versies luistert Policyd of Cluebringer naar
      poort 10031. Deze zijn verwijderd sinds iRedMail-0.9.3, en vervangen door
      iRedAPD.

    * Poort 465, a.k.a. SMTP over SSL, is al jaren deprecated. Gebruik alstublieft
      poort 587.
