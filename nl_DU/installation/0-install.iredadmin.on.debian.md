# Installeer iRedAdmin op Debian, Ubuntu

!!! attention

	 Bekijk onze lichtgewichte on-premise e-mail archiveringsoftware ontwikkeld door 
	 het iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! warning

    Deze tutorial is verouderd en deprecated. Sinds iRedMail-0.9.8 is Apache
    geen optie meer bij installatie en Nginx dus de enige webserver.

> Deze tutorial wordt gebruikt om iRedAdmin helemaal zelf te installeren, onder Apache web server.
>
> Als je al iRedAdmin open source edition of een oude iRedAdmin-Pro-release hebt, kan je simpelweg upgraden naar de nieuwste versie van iRedAdmin door onze korte tutorial te volgen.
> tutorial: [Migrate of upgrade iRedAdmin](./migrate.or.upgrade.iredadmin.html).

## Vereisten

iRedMail zal al de nodige packages zelf installeren, je moet ze niet manueel installeren. Onderstaande paragraaf over de packages alleen maar ter informatie.

* De nieuwste iRedMail versie. [Download de nieuwste iRedMail versie](https://www.iredmail.org/download.html).
  MERK OP: iRedMail moet eerst geïnstalleerd zijn op je server om deze tutorial te kunnen volgen.

* `Apache` 2.2+. Web server.

    * `mod_wsgi` 2.1+. Apache module gebruikt om de Python applicatie te hosten die de Python WSGI interface ondersteund.

* `Python` 2.4+, Belangrijke programmeertaal. Waarschuwing: Python 3.x is nog niet ondersteund.

    * `web.py`, 0.32+. Een door python gestuurd web framework.
    * `MySQLdb`: Een thread-compatibele interface met de populaire MySQL database server die de Python database API voorziet. Verplicht als je e-mail accounts opslaat in OpenLDAP, MySQL of MariaDB.
    * `Python-LDAP` 2.3.7+: Een object-georienteerde API die Python programma's toelaat om LDAP directory servers te gebruiken. Verplicht als je e-mail accounts opslaat in OpenLDAP.
    * `Python-psycopg2`: Interface naar de PostgreSQL database server door Python programma's. Verplicht als je e-mail accounts opslaat in PostgreSQL.

## Download iRedAdmin en configureer Apache web server

* Download iRedAdmin open source edition [hier](https://dl.iredmail.org/yum/misc/).
  Als je iRedAdmin-Pro probeert te installeren, alstublieft, contacteer ons -> [contacteer ons](https://www.iredmail.org/contact.html) om de download link te krijgen voor iRedAdmin-Pro.

* Kopieer iRedAdmin naar `/opt/www`, gebruik correcte permissions voor het bestand, en creëer een link.

```
# tar xjf iRedAdmin-x.y.z.tar.bz2 -C /opt/www/
# cd /opt/www/
# chown -R iredadmin:iredadmin iRedAdmin-x.y.z
# chmod -R 0555 iRedAdmin-x.y.z
# ln -s iRedAdmin-x.y.z iredadmin
```

* Voeg apache configuratiebestand toe: `/etc/apache2/conf.d/iredadmin.conf`.

    Opmerking: Als je server Ubuntu 14.04 of nieuwer draait, is het
    `/etc/apache2/conf-available/iredadmin.conf`. Nadat je dit bestand hebt toegevoegd,
    activeer het aan met dit commando `a2enconf iredadmin`.

```
WSGISocketPrefix /var/run/wsgi
WSGIDaemonProcess iredadmin user=iredadmin threads=15
WSGIProcessGroup iredadmin

AddType text/html .py

<Directory /opt/www/iredadmin/>
    Order deny,allow
    Allow from all
</Directory>
```

* Bewerk `/etc/apache2/sites-enabled/default-ssl`, maak iRedAdmin toegankenlijk via HTTPS.
  Voeg onderstaande lijnen toe voor `</VirtualHost>`:

```
WSGIScriptAlias /iredadmin /opt/www/iredadmin/iredadmin.py/
Alias /iredadmin/static /opt/www/iredadmin/static/
```

* Activeer mod_wsgi module en herstart Apache service:

```
# a2enmod wsgi
# service apache2 restart
```

## Creëer nodige MySQL database en geef privileges

* Creëer MySQL database: `iredadmin`.

```
# mysql -uroot -p
mysql> CREATE DATABASE iredadmin DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
mysql> USE iredadmin;
mysql> SOURCE /opt/www/iredadmin/docs/samples/iredadmin.sql;
```

* Geef privileges aan iRedAdmin gebruiker en maak er een paswoord voor. WAARSCHUWING: Hier gebruiken we 'secret_passwd' als password voor de iRedAdmin gebruiker, vervang dat alstublieft met je eigen passwoord.

```
# mysql -uroot -p
mysql> GRANT SELECT,INSERT,UPDATE,DELETE ON iredadmin.* TO iredadmin@localhost IDENTIFIED BY 'secret_passwd';
mysql> FLUSH PRIVILEGES;
```

## Configureer iRedAdmin

* Kopieer voorbeeldconfiguratiebestand, zorg ervoor dat niet heel de werld het kan aanpassen.

    * settings.py.ldap.sample: voorbeeldconfiguratiebestand voor OpenLDAP backend
    * settings.py.mysql.sample: voorbeeldconfiguratiebestand voor MySQL/MariaDB backend
    * settings.py.pgsql.sample: voorbeeldconfiguratiebestand voor PostgreSQL backend

```
# cd /opt/www/iredadmin/
# cp settings.py.[backend].sample settings.py
# chown iredadmin:iredadmin settings.py
# chmod 0400 settings.py
```

* Update settings.py met correcte waarden. Lees alstublieft `settings.py` voor meer informatie, het is zelfgedocumenteerd.

* Herstart apache web server.

```
# service apache2 restart
```

## Gebruik iRedAdmin

Open je favoriete webbrowser om iRedAdmin te gebruiken: `https://your_server_ip_address-or_domain/iredadmin/`

Zorg ervoor dat je `HTTPS://` gebruikt en niet `HTTP://`, je weet waarschijnlijk wel waarom. (passwoorden in plain-text vs niet in plain-text)

## Probleemoplossing & Debug

Als iRedAdmin niet werkt zoals verwacht, kan je simpelweg `DEBUG = True` aanzetten in
`settings.py`, na het herstarten van apache web server gebruik je opnieuw je favoriete webbrowser
om er terug aan te komen. 
Daarna liefst een nieuwe [forum](https://forum.iredmail.org/) topic aanmaken en je error erbij pasten, zodat het kan worden opgelost.
