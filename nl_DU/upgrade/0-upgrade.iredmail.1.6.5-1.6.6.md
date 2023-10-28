# Update iRedMail van versie 1.6.5 naar 1.6.6

!!! attention

	 Bekijk onze lichtgewicht on-premise e-mail archiveringsoftware ontwikkeld door 
	 het iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).**

## ChangeLog

- Oct 23, 2023: initiële publicatie.

## Algemeen (Alle backends zouden dit moeten aanpassen)

### Update `/etc/iredmail-release` met nieuw iRedMail versienummer

iRedMail slaat de huidige versie op in bestand `/etc/iredmail-release` na installatie, het is aangeraden om dit bestand aan te passen nadat je iRedMail hebt geüpdatet,
zodat je weet welke versie van  iRedMail je gebruikt. Bijvoorbeeld:

```
1.6.6
```

### Fail2ban: geen client verbannen die een `lost connection after UNKNOWN` error veroorzaakt

Geef onderstaande commando's in als root gebruiker om het nieuwste filterbestand te verkrijgen voor Roundcube:

```
cd /etc/fail2ban/filter.d/
wget -O postfix.iredmail.conf https://raw.githubusercontent.com/iredmail/iRedMail/1.6.6/samples/fail2ban/filter.d/postfix.iredmail.conf
```

`fail2ban` service herstarten is verplicht.

### Upgrade netdata to the latest stable release (1.43.0)

If you have netdata installed, you can upgrade it by following this tutorial:
[Upgrade netdata](./upgrade.netdata.html).

### Upgrade Roundcube webmail to the latest stable release (1.6.4)

!!! warning "CentOS 7: blijf alstublieft bij Roundcube 1.5.2"

    Als je server CentOS 7 draait, update dan naar Roundcube versie 1.5.2.
    Roundcube versie 1.5.3 heeft PHP-7 nodig, maar CentOS 7 komt met PHP-5.4 wat niet wordt ondersteund door Roundcube versie 1.5.3 en nieuwere versies, inclusief 1.6.x.

    __Jammer genoeg bevat Roundcube 1.5.2 NIET de beveiligingsupdate die met 1.5.4 en 1.5.5 worden toegevoegd.__

    Het is tijd om uw comfortzone te verlaten en deze server te updaten naar ten minste CentOS Stream 8 of [Rocky Linux 8](https://docs.rockylinux.org/guides/migrate2rocky/).

!!! warning "Ubuntu 18.04: please stick to Roundcube 1.5.5"

    !!! warning "Ubuntu 18.04: blijf alstublieft bij Roundcube 1.5.5"

    Ubuntu 18.04 gebruikt een oude php versie, v1.5.5 bevat de beveiligingsupdate ook.  Overweeg alstublieft om het besturingssysteem te updaten naar 20.04 LTS zo snel als mogelijk is.

Roundcube v1.6.4 en 1.5.5 zijn beveiligingsupdates. beide lossen een cross-site
scripting (XSS) vulnerability op.

Volg alstublieft de officiële Roundcube tutorial om Roundcube webmail te updaten naar de nieuwste stabiele versie:

* [Hoe Roundcube updaten](https://github.com/roundcube/roundcubemail/wiki/Upgrade).
