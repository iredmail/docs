# Update iRedMail van versie 1.6.3 naar 1.6.4

!!! attention

	 Bekijk onze lichtgewicht on-premise e-mail archiveringsoftware ontwikkeld door 
	 het iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! note "Betaalde externe updateservice"

    We bieden een externe updateservice aan als je je hier niet wilt mee bezig houden,
    [zie hier voor meer informatie](https://www.iredmail.org/support.html) en
    [contacteer ons](https://www.iredmail.org/contact.html).

## ChangeLog

- Jul 28, 2023: initiële publicatie.

## Algemeen (Alle backends zouden dit moeten aanpassen)

### Update `/etc/iredmail-release` met nieuw iRedMail versienummer

iRedMail slaat de huidige versie op in bestand `/etc/iredmail-release` na installatie, het is aangeraden om dit bestand aan te passen nadat je iRedMail hebt geüpdatet,
zodat je weet welke versie van  iRedMail je gebruikt. Bijvoorbeeld:

```
1.6.4
```

### [VERPLICHT] CentOS Stream / Rocky / AlmaLinux 8: Overgang naar PHP v8.0

CentOS / Rocky / AlmaLinux 8 biedt php v8.0 aan in het officiële yum repository, je
kunt overgaan naar php v8.0 door deze korte tutorial te volgen, zodat je Roundcube kunt updaten naar de nieuwste versie: v1.6.2.

- [Update php naar 8.0 op CentOS Stream / Rocky / AlmaLinux 8](./upgrade.php.v8.0.on.centos.8.html)

### Corrigeer incorrect ssl CA bestand en IDN ondersteuning in Postfix

Geef onderstaande shell commando's in als root gebruiker om incorrect ssl ca bestand te corrigeren, ook IDN ondersteuning af te zetten.

* Op RHEL/CentOS/Rocky/AlmaLinux:

```
postconf -e smtp_tls_CAfile='/etc/pki/tls/certs/ca-bundle.crt'
postconf -e smtpd_tls_CAfile='/etc/pki/tls/certs/ca-bundle.crt'
postconf -e smtputf8_enable=no
postfix reload
```

* Op Debian en Ubuntu:

```
postconf -e smtp_tls_CAfile='/etc/ssl/certs/ca-certificates.crt'
postconf -e smtpd_tls_CAfile='/etc/ssl/certs/ca-certificates.crt'
postconf -e smtputf8_enable=no
postfix reload
```

* Op FreeBSD en OpenBSD:

```
postconf -e smtp_tls_CAfile='/etc/ssl/cert.pem'
postconf -e smtpd_tls_CAfile='/etc/ssl/cert.pem'
postconf -e smtputf8_enable=no
postfix reload
```

### Update iRedAPD (Postfix policy server) naar nieuwste stabiele versie (5.3)

Volg onderstaande tutorial om iRedAPD te updaten naar de nieuwste stabiele versie:
[Update iRedAPD naar de nieuwste stabiele versie](./upgrade.iredapd.html)

### Update netdata naar de nieuwste stabiele versie (1.41.0)

Als je netdata hebt geïnstalleerd, kan je het updaten door deze tutorial te volgen:
[Update netdata](./upgrade.netdata.html).

### Update Roundcube webmail naar de nieuwste stabiele versie (1.6.2)

!!! warning "CentOS 7: blijf alstublieft bij Roundcube 1.5.2"

    Als je server CentOS 7 draait, update dan naar Roundcube versie 1.5.2.
    Roundcube versie 1.5.3 heeft PHP-7 nodig, maar CentOS 7 komt met PHP-5.4 wat niet wordt ondersteund door Roundcube versie 1.5.3 (en de nieuwste 1.6.0).

    Het is tijd om uw comfortzone te verlaten en deze server te updaten naar ten minste CentOS Stream 8 of [Rocky Linux 8](https://docs.rockylinux.org/guides/migrate2rocky/).

Volg alstublieft de officiële Roundcube tutorial om Roundcube webmail te updaten naar de nieuwste stabiele versie:

* [Hoe Roundcube updaten](https://github.com/roundcube/roundcubemail/wiki/Upgrade).
