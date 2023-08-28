# iRedMail Pro: Getting started

!!! attention

	 Bekijk onze lichtgewicht on-premise e-mail archiveringsoftware ontwikkeld door 
	 het iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! attention

    - Alle accountpaswoorden zijn volledig willekeurig gegenereerd tijdens installatie, ze worden bewaard onder `/root/.iredmail/kv/` op je server. Ze zijn ook georganiseerd in het bestand
      `/root/iRedMail/iRedMail.tips`.
    - Om een al-bestaande iRedMail server om te zetten in een __iRedMail Pro__ installatie,
      bekijk deze tutorial:
      [Migrate from iRedMail to iRedMail Easy platform](./migrate.to.iredmail.easy.html).

## Samenvatting

__iRedMail Pro__ is een webgebaseerd, on-prem iRedMail server installatieprogramma en administratiepaneel.

Met iRedMail Pro is het gemakkelijk om de server te installeren (en mogelijks herinstalleren) en up-to-date te houden.
Je kunt ook (mail-service gerelateerde) instellingen configureren via de web UI.

We moedigen alle gebruikers aan om nieuwe iRedMail servers op te starten met iRedMail Pro en
om servers up-to-date to houden.

Als je het klassieke downloadbare iRedMail installatieprogramma verkiest, kan je daarvoor hier tutorials terugvinden: [Installeer iRedMail.](./index.html#install)

## Systeemvereisten

!!! warning

    * iRedMail is gemaakt om geïnstalleerd te worden op een __NIEUWE__ server, dat betekent dat je server nog __GEEN__ e-mail gerelateerde componenten geïnstalleerd heeft.
      bv: MySQL, OpenLDAP, Postfix, Dovecot, Amavisd, etc. iRedMail zal automatisch alles installeren en configureren. Als er toch e-mail gerelateerde componenten op je server zijn kan het zijn dat je bestaande bestanden/configuraties worden gewijzigd. Ook al zou iRedMail normaal gezien backups moeten maken voordat wijzigingen worden gemaakt, kan het zijn dat dat systeem niet werkt zoals het zou moeten.
    * __Port 25 is vereist__ voor e-mail, maar veel Internet Service Providers blokkeren standaard port 25.

        Port 25 wordt gebruikt voor communicatie tussen e-mail servers, __het moet open staan__,
        anders zal je server geen e-mail kunnen ontvangen of versturen.
        Contacteer je ISP om zeker te zijn dat het niet geblokkeerd is, of om het te deblokkeren.

          - Linode. legde uit in een [blog post](https://www.linode.com/blog/linode/a-new-policy-to-help-fight-spam/),
            dat je een support ticket moet openen om port 25 te deblokkeren. 
            als je linode kiest als VPS provider en op de link hier klikt, krijgt de Linode account van het iRedMail team 15-20 dollar [sign up to Linode with our reference](https://www.linode.com/?r=b4d04083428fb99ce452d84b57253d11692a0850) Bedankt.
          - Vultr. [Port 25 is standaard geblokkeerd](https://www.vultr.com/docs/what-ports-are-blocked/), deblokkeren kan je aanvragen door [een support ticket te openen](https://my.vultr.com/support/create_ticket/).
          - Amazon AWS EC2. Vraag om [de throttle op port 25](https://aws.amazon.com/premiumsupport/knowledge-center/ec2-port-25-throttle/) te verwijderen.
          - Google Cloud Platform.
          - Microsoft Azure.
          - DigitalOcean. Volgens [een post in hun community](https://www.digitalocean.com/community/questions/port-25-465-is-blocked-how-can-i-enable-it), __LIJKT__ het onmogelijk om port 25 te deblokkeren, dat betekent dat je __GEEN__ e-mailserver kunt starten bij DigitalOcean VPS.

### Ondersteunde Linux en BSD sofwareversies

Dit zijn de ondersteunde Linux/BSD softwareversies die ondersteund worden bij __iRedMail Pro__:

Distributie | Softwareversie
--- |---
CentOS Stream | 8, 9
Rocky Linux | 8, 9
AlmaLinux | 8, 9
Debian | 11
Ubuntu | 20.04, 22.04
OpenBSD | 7.2

Als je iRedMail moet installeren op FreeBSD, gebruik dan alstublieft het [downloadbare installatieprogramma](https://www.iredmail.org/download.html) indeplaats.

### Hardware Requirements

* Ten minste `4 GB` RAM is nodig voor een e-mail server onder lage load met spam/virus scanner aanstaan.
* Als je van plan bent om SOGo Groupware te gebruiken (dat webmail, kalender(CalDAV), contactenlijst(CardDAV), en ActiveSync voorziet), heb je veel meer geheugen nodig. Overweeg bijvoorbeeld 16GB RAM om 500 ActiveSync clients te voorzien.

## Download en start het installatieprogramma

Geef onderstaande commando's in op je server om iRedMail pro te downloaden voor Linux (x86_64):

```
wget -O /usr/local/bin/iredmail https://dl.iredmail.org/iredmail-2.0-beta1-linux-x86_64
chmod +x /usr/local/bin/iredmail
```

Lanceer het installatieprogramma:

```
/usr/local/bin/iredmail
```

Dit draait een webserver op port `8080`, ga er naartoe met een webbrowser en gebruik de installatiewizard om iRedMail te installeren.

Na installatie draait het op port `7793`.

Hieronder bevinden zich screenshots van de installatiewizard.

## Installatie

### Kies je verkozen backend

Een backend is een SQL of LDAP database die gebruikt wordt om mail domains en
accounts op te slaan. Er is geen groot verschil tussen de aangeboden backends, het is dus sterk aangeraden om diegene te gebruiken die je het beste kent voor makkelijker beheer en onderhoud na installatie.

![](./images/pro/setup-backend.png){: width="700px" }

### Kies componenten die je wilt gebruiken

Een component is een softwareprogramma (of softwaregroep, service) die (een) bepaald(e) network service(s) voorziet. Op deze pagina kan je de componenten kiezen die je wilt gebruiken op je e-mail server.

![](./images/pro/setup-components.png){: width="700px" }

### Vereiste instellingen

Weinig settings zijn vereist om een e-mail server op te starten.

Merk op: terwijl je typt zal het je ingegeven waarde controleren, wacht alstublieft tussen de 1 à 3 seconden totdat het verificatie afrond.

![](./images/pro/setup-required-settings.png){: width="700px" }

### Optionele instellingen

Afhankelijk van welke componenten je kiest om te installeren, zullen de instellingen op deze pagina anders zijn.

![](./images/pro/setup-optional-settings.png){: width="700px" }

### Verifiëer en installeer

!!! attention

    Alle accountpaswoorden worden willekeurig gegenereerd tijdens installatie.
     Ze bevinden zich in bestanden onder `/root/.iredmail/kv/` op je eigen e-mailserver, en staan ook georganiseerd in
    bestand `/root/iRedMail/iRedMail.tips` ter informatie.

Verifiëer de instellingen:

![](./images/pro/setup-review-and-deploy.png){: width="700px" }

Klik op de `Confirm and Deploy` knop om installatie direct te starten:

![](./images/pro/setup-deploy.png){: width="700px" }

### Installatie compleet

Nadat installatie succesvol is, zou je informatie moeten zien omtrent het inloggen  op het administratiepaneel.
Ga alstublieft naar de URL en log in met gegeven username en paswoord.

Merk op: Dit is een globaal administratiepaneel dat alle privileges heeft.

![](./images/pro/setup-complete.png){: width="500px" }

### Log in op het administratiepaneel

Nadat je bent ingelogd op het administratiepaneel kan je softwarecomponenten beheren, e-mail server settings aanpassen, e-mail accounts beheren, etc.

![](./images/pro/components.png){: width="700px" }
<br/>
![](./images/pro/server-settings.png){: width="700px" }
<br/>
![](./images/pro/domains.png){: width="700px" }

## Zie ook

* [Creëer DNS records voor je e-mailserver](./setup.dns.html)
* [Vraag een gratis SSL certificaat aan bij Let's  Encrypt](./letsencrypt.html)
* [Configureer e-mail client applicaties](./index.html#mua)
