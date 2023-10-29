# Locaties van configuratie and log bestanden van belangrijke componenten

!!! attention

	 Bekijk onze lichtgewichte on-premise e-mail archiveringsoftware ontwikkeld door 
	 het iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

## SSL certificaat {: #ssl }

Het zelf-gesigneerd SSL certificaat gegenereerd tijdens iRedMail installatie:

* op RHEL/CentOS:

    * `/etc/pki/tls/certs/iRedMail.crt`
    * Private key: `/etc/pki/tls/private/iRedMail.key`

* op Debian/Ubuntu:

    * `/etc/ssl/certs/iRedMail.crt`
    * Private key: `/etc/ssl/private/iRedMail.key`

* op FreeBSD:

    * `/etc/ssl/certs/iRedMail.crt`
    * Private key: `/etc/ssl/private/iRedMail.key`

* op OpenBSD:

    * `/etc/ssl/iRedMail.crt`
    * Private key: `/etc/ssl/iRedMail.key`

## Postfix {: #postfix }

* op `Linux` en OpenBSD bevinden Postfix configuratiebestanden zich in `/etc/postfix/`.
* op FreeBSD bevinden Postfix configuratiebestanden zich onder `/usr/local/etc/postfix/`.

### Belangrijkste configuratiebestanden: {: #postfix-config }

* `main.cf`: bevat de meeste configuraties.
* `master.cf`: bevat transportgerelateerde instellingen.
* `aliases`: aliassen voor systeemaccounts.
*  `helo_access.pcre`: PCRE regular expressions van HELO check rules.
* `ldap/*.cf`: gebruikt om e-mailaccounts op te vragen. Enkel toepasselijk voor LDAP backends.
* `mysql/*.cf`: gebruikt om e-mailaccounts op te vragen. Enkel voor MySQL/MariaDB backends.
* `pgsql/*.cf`: gebruikt om e-mailaccounts op te vragen. Enkel voor PostgreSQL backend.

### Logbestanden {: #postfix-log }

* op RHEL/CentOS, FreeBSD, OpenBSD, is het `/var/log/maillog`.
* op Debian, Ubuntu, is het `/var/log/mail.log`.

## Dovecot {: #dovecot }

* op Linux en OpenBSD worden Dovecot configuratiebestanden geplaatst in `/etc/dovecot/`.
* op FreeBSD worden Dovecot configuratiebestanden geplaatst in`/usr/local/etc/dovecot/`.

### Configuratiebestanden {: #dovecot-config }

Belangrijkste configuratiebestand is `dovecot.conf`. Het bevat de meeste configuraties.

Extra configuratiebestanden in `/etc/dovecot/`:

* `dovecot-ldap.conf`: gebruikt om e-mail gebruikers en paswoorden op te vragen. Enkel bij LDAP backend.
* `dovecot-mysql.conf`: gebruikt om e-mail gebruikers en paswoorden op te vragen. Enkel bij MySQL/MariaDB backend.
* `dovecot-pgsql.conf`: gebruikt om e-mail gebruikers en paswoorden op te vragen.. Enkel bij PostgreSQL backend.
* `dovecot-used-quota.conf`: gebruikt om in-real-time de e-mailbox quota van een gebruiker op te vragen.
* `dovecot-share-folder.conf`: gebruikt om instellingen van gedeelde IMAP e-mailboxen op te slaan.
* `dovecot-master-users-password` of `dovecot-master-users`: gebruikt om Dovecot master gebruikersaccounts op te slaan.

### Logbestanden {: #dovecot-log }

* `/var/log/dovecot/*.log`: hoofdlogbestand na iRedMail versie 0.9.8.

Vorige versies loggen naar `/var/log/dovecot.log` en `/var/log/dovecot-*.log`.

## Nginx {: #nginx }

* Op `Linux` en OpenBSD:
    * Nginx configuratiebestanden bevinden zich in `/etc/nginx/`
    * uWSGI configuratiebestanden bevinden zich in `/etc/uwsgi/`
* Op FreeBSD:
    * Nginx configuratiebestanden bevinden zich in `/usr/local/etc/nginx`
    * Webapplicaties worden opgeslagen in `/usr/local/www`
    * uWSGI configuratiebestanden bevinden zich in `/usr/local/etc/uwsgi/`

Belangrijkste configuratiebestanden zijn nginx.conf en `default.conf`.

* Op `Linux` en FreeBSD: logbestanden bevinden zich in `/var/log/nginx/`.
* Op OpenBSD: logbestanden bevinden zich in `/var/www/logs/` (zelfde als Apache).

## PHP {: #php }

Belangrijkste configuratiebestand:

* op RHEL/CentOS: is het `/etc/php.ini`
* op Debian/Ubuntu:
    * Als je Apache als web server gebruikt:
        * Voor PHP-5 is het: `/etc/php5/apache2/php.ini` (Debian 8, Ubuntu 14.04)
        * Voor PHP-7 is het: `/etc/php/7.0/cli/php.ini` (Ubuntu 16.04)
    * Als je Nginx als web server gebruikt is het: `/etc/php5/fpm/php.ini`.
        * Voor PHP-5 is het: `/etc/php5/fpm/php.ini` (Debian 8, Ubuntu 14.04)
        * Voor PHP-7 is het: `/etc/php/7.0/fpm/php.ini` (Ubuntu 16.04)
* op FreeBSD is het: `/usr/local/etc/php.ini`.
* op OpenBSD is het: `/etc/php-5.X.ini`

## OpenLDAP {: #openldap }

Belangrijkste configuratiebestand:

* op RHEL/CentOS is het: `/etc/openldap/slapd.conf`.
* op Debian/Ubuntu is het: `/etc/ldap/slapd.conf`.
* op FreeBSD is het: `/usr/local/etc/openldap/slapd.conf`.
* op OpenBSD is het: `/etc/openldap/slapd.conf`.

Schemabestanden worden opgeslagen in het `schema/` folder (zelfde folder als `slapd.conf`).

OpenLDAP is standaard geconfigureerd om te loggen naar `/var/log/openldap.log`, als dat leeg is, bekijk dan het normale syslog bestand in `/var/log/messages` of
`/var/log/syslog`.

## MySQL, MariaDB {: #mysql }

Belangrijkste configuratiebestand:

* op RHEL/CentOS: `/etc/my.cnf`.
* op Debian/Ubuntu is het: `/etc/mysql/my.cnf`. Als je MariaDB gebruikt is het:
  `/etc/mysql/mariadb.conf.d/mysqld.cnf`.
* op FreeBSD: `/var/db/mysql/my.cnf`.
* op OpenBSD: `/etc/my.cnf`.

## Roundcube webgebaseerde e-mail {: #roundcube }

* Root folder. Roundcube webmail wordt standaard geïnstalleerd in onderstaand folder:

    * RHEL/CentOS: `/opt/www/roundcubemail`. Het is een symbolische link naar `roundcubemail-x.y.z` onder zelfde folder.

        Opmerking: bij oude versies van iRedMail is het `/var/www/roundcubemail`.

    * Debian/Ubuntu: `/opt/www/roundcubemail`. Het is een symbolische link naar 
      `/opt/www/roundcubemail-x.y.z`.

        Opmerking: bij oude versies van iRedMail is het `/usr/share/apache2/roundcubemail`,
        het is een symbolische link naar `/usr/share/apache2/roundcubemail-x.y.z/`.

    * FreeBSD: `/usr/local/www/roundcube`.
    * OpenBSD: `/opt/www/roundcubemail`. Het is een symbolische link naar `roundcubemail-x.y.z`
     onder hetzelfde folder.

        Opmerking: bij oude versies van iRedMail is het `/var/www/roundcubemail`.

* Configuratiebestanden:

    * Belangrijkste configuratiebestand is `config/config.inc.php` binnen het Roundcube webmail folder.

        Als je een oude versie van Roundcube webmail (0.9.x en vroegere versies) gebruikt, heeft het twee aparte configuratiebestanden: `config/db.inc.php` en
        `config/main.inc.php`.

    * Configuratiebestanden van plugins bevinden zich in je plugin folder. Bijvoorbeeld,
      het configuratiebestand van `password` plugin is `plugins/password/config.inc.php`.

* Logbestand. Roundcube is standaard geconfigureerd om te loggen naar het [Postfix logbestand](#postfix) .
  {: #roundcube-log }

!!! warning

    Roundcube slaat alle standaardinstellingen op in `config/defaults.inc.php`, bewerk dat alstublieft niet, in plaats daarvan zou je de instellingen die je wilt aanpassen moeten kopiëren van
    `config/defaults.inc.php` naar `config/config.inc.php`, dan bewerken in
    `config/config.inc.php`.

## Amavisd {: #amavisd }

### Belangrijkste configuratiebestand {: #amavisd-config }

* op RHEL/CentOS is het `/etc/amavisd/amavisd.conf`.
* op Debian/Ubuntu is het `/etc/amavis/conf.d/50-user`.

    Debian/Ubuntu heeft nog wat aanvullende configuratiebestanden onder `/etc/amavis/conf.d/`, maar je kunt die altijd aanpassen in `/etc/amavis/conf.d/50-user`.
    Wanneer we `amavisd.conf` opnoemen in andere documenten, betekent dat altijd `50-user`
    op Debian/Ubuntu.

* op FreeBSD is het `/usr/local/etc/amavisd.conf`.
* op OpenBSD is het `/etc/amavisd.conf`.

### Logbestanden {: #amavisd-log }

Amavisd is geconfigureerd om te loggen naar het [Postfix logbestand](#postfix) door iRedMail.

## SpamAssassin {: #spamassassin }

!!! attention

    Met standaard iRedMail instelling wordt SpamAssassin opgeroepen door Amavisd, niet gestart als daemon.

 Belangrijkste configuratiebestand:
{: #spamassassin-config }

* Op Linux/OpenBSD is het `/etc/mail/spamassassin/local.cf`.
* Op FreeBSD is het `/usr/local/etc/mail/spamassassin/local.cf`.

SpamAssassin heeft geen apart logbestand, om SpamAssassin te doen loggen moet je `$sa_debug = 1;` toevoegen aan het Amavisd configuratiebestand, dan de Amavisd service herstarten.
{: #spamassassin-log }

## Fail2ban {: #fail2ban }

Belangrijkste configuratiebestand:
{: #fail2ban-config }

* Op Linux/OpenBSD is het `/etc/fail2ban/jail.local`.
* Op FreeBSD is het `/usr/local/etc/fail2ban/jail.local`.

!!! warning

    Alle aangepaste instellingen moeten geplaatst worden in `jail.local`, en
    `jail.conf` mag je niet aanraken, zodat het updaten van je Fail2ban binaire softwarepakket niet het verliezen/aanpassen van je eigen instellingen tot gevolg heeft.

Filters:

* Op Linux/OpenBSD zijn alle filters gedefinieerd in bestanden onder `/etc/fail2ban/filter.d/`.
* Op FreeBSD zijn alle filters gedefinieerd in bestanden onder  `/usr/local/etc/fail2ban/filter.d/`.

Ban/Unban acties:

* Op Linux/OpenBSD zijn alle acties gedefinieerd in bestanden onder  `/etc/fail2ban/action.d/`.
* Op FreeBSD zijn alle filters gedefinieerd in bestanden onder  `/usr/local/etc/fail2ban/action.d/`.

Logbestand: Fail2ban logt naar het standaard syslog bestand.
{: #fail2ban-log }

* op RHEL/CentOS/OpenBSD/FreeBSD is het `/var/log/messages`.
* op Debian/Ubuntu is het `/var/log/syslog`.

## SOGo Groupware {: #sogo }

* Belangrijkste configuratiebestand
    * on Linux/OpenBSD: `/etc/sogo/sogo.conf`
    * op FreeBSD: `/usr/local/etc/sogo/sogo.conf`
* Logbestand is `/var/log/sogo/sogo.log`.

## mlmmjadmin {: #mlmmjadmin }

* Configuratiebestand: `/opt/mlmmjadmin/settings.py` (zelfde op alle Linux/BSD distributies)
* Logbestand: `/var/log/mlmmjadmin/mlmmjadmin.log`
* Folders voor data:
    * Alle actieve mailinglijsten: `/var/vmail/mlmmj`. Inclusief archief.
    * Verwijderde en gearchiveerde mailinglijsten: `/var/vmail/mlmmj-archive`

## iRedAPD {: #iredapd }

* Belangrijkste configuratiebestand is `/opt/iredapd/settings.py` op all Linux/BSD distributies.
* Logbestand:

    * Met iRedAPD-1.7.0 en latere versies is het logbestand `/var/log/iredapd/iredapd.log`.
    * Met iRedAPD-1.6.0 en latere versies is het logbestand `/var/log/iredapd.log`.

## iRedAdmin {: #iredadmin }

Belangrijkste configuratiebestand:

* Op RHEL/CentOS is het `/opt/www/iredadmin/settings.py`.

    Opmerking: bij oude iRedMail versies is het `/var/www/iredadmin/settings.py`.

* op Debian/Ubuntu is het `/opt/www/iredadmin/settings.py`.

    Opmerking: bij oude iRedMail versies is het `/usr/share/apache2/iredadmin/settings.py`.

* op FreeBSD is het `/opt/www/iredadmin/settings.py`.

    Opmerking: bij oude iRedMail versies is het `/usr/local/www/iredadmin/settings.py`.

* op OpenBSD is het `/opt/www/iredadmin/settings.py`.

    Opmerking: bij oude iRedMail versies is het `/var/www/iredadmin/settings.py`.

iRedAdmin is een web-applicatie, wanneer debug modus aanstaat, zal het error berichten loggen naar:

* Als je Apache gebruikt, logt het naar het  [Apache ssl error logbestand](#apache).
* Als je Nginx met uwsgi gebruikt:
    * op Debian/Ubuntu logt het naar `/var/log/uwsgi/app/iredadmin.log`.
    * op RHEL/CentOS logt het naar `/var/log/messages`.
    * op OpenBSD logt het naar `/var/www/logs/uwsgi.log`.
    * op FreeBSD logt het naar `/var/log/uwsgi-iredadmin.log`.

Opmerking: Als je enige iRedAdmin bestanden hebt aangepast (niet alleen configuratiebestanden), moet je
Apache of uwsgi service (als je Nginx gebruikt) herstarten om de aangepaste bestanden in te laden.

