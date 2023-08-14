# Installeer iRedMail op Red Hat Enterprise Linux, CentOS

!!! attention

	 Bekijk onze lichtgewicht on-premise e-mail archiveringsoftware ontwikkeld door 
	 het iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! attention

    Het is aangeraden om het __iRedMail Easy__ deployment en support
    platform te gebruiken om je e-mail server op te zetten en up to date te houden.
    Technische ondersteuning is beschikbaar via het ticket-systeem.

    Lees meer: [iRedMail Easy - Meet our new deployment and support platform](./iredmail-easy.getting.start.html)

## Systeemvereisten

!!! warning

    * iRedMail is gemaakt om geïnstalleerd te worden op een __NIEUWE__ server, dat betekent dat je server nog __GEEN__ e-mail gerelateerde componenten geïnstalleerd heeft.
      bv: MySQL, OpenLDAP, Postfix, Dovecot, Amavisd, etc. iRedMail zal automatisch alles installeren en configureren. Als er toch e-mail gerelateerde componenten op je server zijn, kan et zijn dat je bestaande bestanden/configuraties worden gewijzigd. Ook al zou iRedMail normaal gezien backups moeten maken voordat wijzigingen worden gemaakt, kan het zijn dat dat systeem niet werkt zoals het zou moeten.
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

Om iRedMail te installeren op Debian of Ubuntu Linux, heb je nodig:

* Een __NIEUWE__, werkende installatie van een RHEL of CentOS. Ondersteunde versies staan op de 
  [Download](https://www.iredmail.org/download.html) pagina.
* Ten minste `4 GB` RAM is nodig voor een e-mail server onder lage load met spam/virus scanner aanstaan.
* Wees zeker dat 3 UID/GID niet in gebruik zijn door andere gebruiker/groep: 2000, 2001, 2002.

## Voorbereiding

### Een fully qualified domain name (FQDN) opzetten als hostname voor je server

Of je server nu een testserver is of een production server, is het sterk aangeraden om een fully qualified domain name (FQDN) op te zetten als je hostname.

Geef commando `hostname -f` in om huidige hostname te zien:

```shell
$ hostname -f
mx.example.com
```

Op RHEL/CentOS Linux wordt de hostname bepaald door 2 bestanden::

1. `/etc/hostname`:

    ```
    mx.example.com
    ```

1. `/etc/hosts`: hostname <=> IP-adress mapping. Waarschuwing: Geef de FQDN hostname op als eerste item.

    ```
    127.0.0.1   mx.example.com mx localhost localhost.localdomain
    ```

Verifieer de FQDN hostname. Als het niet is veranderd na de bovenstaande bestanden te bewerken, herstart dan de server.

```
$ hostname -f
mx.example.com
```

### Zet SELinux af.

iRedMail werkt niet met SELinux, dus zet het alstublieft uit door onderstaande lijn te bewerken in `/etc/selinux/config`. Herstart de server en SELinux zal volledig uitstaan.

```
SELINUX=disabled
```

Als je liever wilt dat SELinux je waarschuwt in plaats van stil te blijven, kan je het als volgt aanpassen:

```
SELINUX=permissive
```

Zet het direct uit zonder je server te herstarten.

```
# setenforce 0
```

### Zet yum repositories aan om nieuwe packages te installeren

* Op CentOS:
    - Zet officiële yum repositories aan. Zorg ervoor dat:
	 Bij CentOS 8 en CentOS 8 Stream `appstream` en `powertools` aan staan.
    - Het repo `epel` aanstaat.
    - __ZET__ alle andere repositories van derden __UIT__ om package conflicts te vermijden.

* Op Red Hat Enterprise Linux:
    - Zet Red Hat Network aan om packages te installeren, of creëer een lokaal yum repository met DVD/CD ISO images.
    - Zet `epel` repo aan (dit kun je doen door package `epel-release`  te installeren)
    - Op Red Hat Enterprise Linux, zet alstublieft repository `codeready-builder-for-rhel-8-x86_64-rpms` en repository `epel` aan met onderstaand commando:

```
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
subscription-manager repos --enable codeready-builder-for-rhel-8-x86_64-rpms
```

!!! attention

    Gezien dat de officiëele RHEL/CentOS en EPEL repositories niet alle nodige packages bevatten met alle nodige functies, heeft het iRedMail team deze
    packages vezameld en aangeboden via een iRedMail repository dat standaard aanstaat bij installatie. Je kunt alle aanwezige packages 
    [hier](https://dl.iredmail.org/yum/rpms/) zien, bekijk alstublieft de `README` en de
    `ChangeLog` onder elke folder voor meer informatie. Source RPMs (srpm)
    gebruikt door het iRedMail team om deze packages te voorzien, vind je
    [hier(https://dl.iredmail.org/yum/srpms/).

### Download de nieuwste versie van iRedMail

* Ga naar [Downloadpagina](https://www.iredmail.org/download.html) om de nieuwste 
stabiele versie van iRedMail te verkrijgen.

* Upload iRedMail naar je e-mailserver via ftp of scp of een andere methode die je kunt gebruiken, 
log in en installeer iRedMail. We gaan ervan uit dat je het hebt geüpload naar
  `/root/iRedMail-x.y.z.tar.gz` (verander x.y.z met de echte cijfers van de versie die je hebt gedownload).

* Decomprimeer iRedMail tarball:

```
cd /root/
tar zxf iRedMail-x.y.z.tar.gz
```

## Start iRedMail installatieprogramma

Je server is nu klaar om het iRedMail installatieprogramma op te starten.
Het zal je meerdere simpele vragen stellen, dit allemaal is het enige dat je moet doen om een volledig werkende e-mailserver op te starten.

```
cd /root/iRedMail-x.y.z/
bash iRedMail.sh
```

## Screenshots van installatie:

* Welkom en bedankt voor je gebruik

![](./images/installation/welcome.png){: width="700px" }

* Specifieer locatie om alle mailboxen op te slaan, standaard is `/var/vmail/`.

![](./images/installation/mail_storage.png){: width="700px" }

* Kies backend dat gebruikt wordt om e-mail accounts op te slaan. Je kunt alle accounts 
beheren met iRedAdmin, ons webgebaseerd iRedMail administratiepaneel

!!! note

    Er is geen groot verschil tussen de aangeboden backends, het is
    dus sterk aangeraden om diegene te gebruiken die je het beste kent
    voor makkelijker beheer en onderhoud na installatie.

![](./images/installation/backends.png){: width="700px" }

* Als je kiest om e-mail accounts op te slaan in OpenLDAP, zal het iRedMail installatieprogramma
je vragen om een LDAP suffix op te stellen.

![](./images/installation/ldap_suffix.png){: width="700px" }

!!! boodschap "aan alle MySQL/MariaDB/PostgreSQL gebruikers"

    Als je kiest om e-mail accounts op te slaan in MySQL/MariaDB/PostgreSQL,
    zal het installatieprogramma een willekeurig, sterk password voor je bedenken.
    Je kunt het terugvinden in het bestand `iRedMail.tips`.

* Voer je eerste e-mail domain name in

![](./images/installation/first_domain.png){: width="700px" }

* Creëer password voor admin-account die de eerste e-mailgebruiker is.

__Opmerking__: Deze account is een admin account en een e-mailgebruiker. Dat betekent dat je kunt inloggen
op de webmail en het administratiepaneel (iRedAdmin) met deze account, de login username is het volledige e-mailadres.

![](./images/installation/admin_pw.png){: width="700px" }

* Kies optionele componenten

    !!! attention

        __Which webmail should you choose?__ Roundcube or SOGo?

        - Roundcube is a fast and lightweight webmail, and webmail only.
          If all you need is a webmail to access mailbox and manage mail
          filters, then Roundcube is the best option.
        - SOGo offers webmail, calendar (CalDAV), contacts (CardDAV) and
          ActiveSync. If you need calendar and contacts support, also syncing
          them to mobile or PC mail client applications, then SOGo is the one
          to go. Note: If you have many ActiveSync clients, it requires a lot RAM.
        - It's ok to install both, but you can only manage mail filters with
          Roundcube in this case, because the filter rules generated by
          Roundcube and SOGo are not compatible. You can [force to enable it in
          SOGo](./why.no.sieve.support.in.sogo.html), but please inform end
          users and ask them to stick to one of them for managing mail filters.

![](./images/installation/optional_components.png){: width="700px" }


Nadat je bovenstaande vragen hebt beantwoord, zal het iRedMail installatieprogramma
je vragen om je veranderingen te bekijken en toe te staan. Het zal de nodige packages
automatisch installeren en configureren.
Typ `y` of `Y` en druk op `Enter` om te starten. 

![](./images/installation/review.png){: width="700px" }

## Belangrijke dingen die je __MOET__ weten na installatie

!!! warning

    Het zwakste deel van je e-mailserver is een gebruiker hun password.
    Spammers willen je server niet hacken, ze willen gewoon spam sturen vanuit je e-mailserver.
    Alstublieft __ALTIJD ALTIJD ALTIJD__ gebruikers forceren om sterke paswoorden te gebruiken.

* Lees bestand `/root/iRedMail-x.y.z/iRedMail.tips` ten eerste bevat het:

    * URLs, usernames en paswoorden van webgebaseerde applicaties
    * Locaties van e-mail gerelateerde software configuratiebestanden. je kunt ook deze tutorial raadplegen:
      [Locaties van configuratiebestanden en logbestanden van belangrijke componenten](./file.locations.html).
    * Andere belangrijke en vertrouwelijke informatie

* [Creëer DNS records voor je e-mailserver](./setup.dns.html)
* [Hoe je e-mail client configureren](./index.html#configure-mail-client-applications)
* [Locaties van configuratiebestanden en logbestanden van belangrijke componenten](./file.locations.html)
* Het is sterk aangeraden om een SSl certificaat te verkrijgen om irritante waarschuwingen in je webbrowser
of e-mailclient te voorkomen als je je mailbox opent via
  HTTPS/IMAPS/POP3/SMTPS. [Let's Encrypt deelt __GRATIS__ SSL certificaten uit](https://letsencrypt.org).
  We hebben een document voor je om
  [een gekocht SSL certificaat te gebruiken](./use.a.bought.ssl.certificate.html).
* Als je meerdere gebruikers tegelijkertijd moet creëren, bekijk ons document over
  [OpenLDAP](./ldap.bulk.create.mail.users.html) en
  [MySQL/MariaDB/PostgreSQL](./sql.bulk.create.mail.users.html).
* Als je een drukke e-mailserver beheert hebben wij [wat suggesties voor betere performantie](./performance.tuning.html).

## Toegang tot webmail en andere web applicaties

Nadat de installatie succesvol werd afgerond, kan je webgebaseerde programma's gebruiken als je
ervoor had gekozen om die te installeren. Vervang `your_server` hieronder door je server hostname of IP-adres

* __Roundcube webmail__: <https://your_server/mail/>
* __SOGo Groupware__: <https://your_server/SOGo>
* __Web admin panel (iRedAdmin)__: <https://your_server/iredadmin/>

## Verkrijg technische ondersteuning

* Je bent welkom op ons [online ondersteuningsforum](https://forum.iredmail.org/) om feedback, ideën en suggesties te communiceren.
Het reageert sneller dan je denkt.
* We bieden ook betalende professionele ondersteuning aan, check onze website voor meer informatie: [Verkrijg Professionele ondersteuning van het iRedMail Team](https://www.iredmail.org/support.html).
