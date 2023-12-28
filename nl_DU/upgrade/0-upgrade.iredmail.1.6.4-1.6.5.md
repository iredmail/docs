# Update iRedMail van versie 1.6.4 naar 1.6.5

!!! attention

	 Bekijk onze lichtgewicht on-premise e-mail archiveringsoftware ontwikkeld door 
	 het iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! note "Betaalde externe updateservice"

    We bieden een externe updateservice aan als je je hier niet wilt mee bezig houden,
    [zie hier voor meer informatie](https://www.iredmail.org/support.html) en
    [contacteer ons](https://www.iredmail.org/contact.html).

## ChangeLog

- Sep 20, 2023: initiële publicatie.

## Algemeen (Alle backends zouden dit moeten aanpassen)

### Update `/etc/iredmail-release` met nieuw iRedMail versienummer

iRedMail slaat de huidige versie op in bestand `/etc/iredmail-release` na installatie, het is aangeraden om dit bestand aan te passen nadat je iRedMail hebt geüpdatet,
zodat je weet welke versie van  iRedMail je gebruikt. Bijvoorbeeld:

```
1.6.5
```

### Update iRedAdmin (open source versie) naar de nieuwste stabiele versie (2.5)

Volg alstublieft onderstaande tutorial om iRedAdmin naar de nieuwste stabiele versie te updaten:
[Update iRedAdmin naar de nieuwste stabiele versie](./migrate.or.upgrade.iredadmin.html).


### Update netdata naar de nieuwste stabiele versie (1.42.4)

Als je netdata hebt geïnstalleerd, kan je het updaten door deze tutorial te volgen:
[Update netdata](./upgrade.netdata.html).

### Update Roundcube webmail naar de nieuwste stabiele versie (1.6.3)

!!! warning "CentOS 7: blijf alstublieft bij Roundcube 1.5.2"

    Als je server CentOS 7 draait, update dan naar Roundcube versie 1.5.2.
    Roundcube versie 1.5.3 heeft PHP-7 nodig, maar CentOS 7 komt met PHP-5.4 wat niet wordt ondersteund door Roundcube versie 1.5.3 (en de nieuwste 1.6.0).

    __Jammer genoeg bevat Roundcube 1.5.2 NIET de beveiligingsupdate die met Roundcube 1.5.4 of 1.6.3 worden toegevoegd.__

    Het is tijd om uw comfortzone te verlaten en deze server te updaten naar ten minste CentOS Stream 8 of [Rocky Linux 8](https://docs.rockylinux.org/guides/migrate2rocky/).

!!! warning "Ubuntu 18.04: blijf alstublieft bij Roundcube 1.5.4"

    Ubuntu 18.04 gebruikt een oude php versie, v1.5.4 bevat de beveiligingsupdate ook.  Overweeg alstublieft om het besturingssysteem te updaten naar 20.04 LTS zo snel als mogelijk is.


Roundcube v1.6.3 en 1.5.4 zijn beveiligingsupdates. beide lossen een cross-site
scripting (XSS) vulnerability op.

Volg alstublieft de officiële Roundcube tutorial om Roundcube webmail te updaten naar de nieuwste stabiele versie:

* [Hoe Roundcube updaten](https://github.com/roundcube/roundcubemail/wiki/Upgrade).
