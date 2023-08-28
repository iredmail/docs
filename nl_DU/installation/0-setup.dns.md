# Creëer DNS records voor je iRedMail server (A, PTR, MX, SPF, DKIM, DMARC)

!!! attention

	  Bekijk onze lichtgewicht on-premise e-mail archiveringsoftware ontwikkeld door 
	 het iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

__BELANGRIJKE INFORMATIE:__ `A`, `MX` records zijn vereist, `Reverse PTR`, `SPF`,
`DKIM` en `DMARC` zijn optioneel maar __ZWAAR AANGERADEN__.

## `A` record voor server hostname {: id="a" }

### Wat is een `A` record?

`A` records verbinden een FQDN (fully qualified domain name) met een IP-adres. Dit is
meestal het meest gebruikte DNS record type in een DNS systeem. Dit is het DNS
record dat je moet toevoegen als je een domain name wilt laten wijzen naar een webserver.

### Hoe een `A` Record opzetten

* `Name`: Dit zal je host zijn voor je domain en is eigelijk een computer binnen je domain. Je domain name wordt automatisch toegevoegd aan je `Name`.
  Als je probeert om een record te maken voor het systeem `www.mydomain.com`, moet je alleen maar  `www` invullen in de tekstbox.

    __Merk op__: als je het `Name` veld leeglaat zal het standaard verwijzen naar je root record voor je domain  `mydomain.com`. Het record voor de basis van je domain wordt
    een root record of apex record genoemd.

* `IP`: Het IP-adres van je FQDN. Een IP-adres kan worden conceptueel worden voorgesteld als het telefoonnummer van je computer. Dit is hoe een computer een andere computer kan bereiken. Net zoals landcodes, netnummers en telefoonnummers worden gebruikt om iemand op te roepen.

* `TTL`: De TTL (Time to Live) is hoe lang je record in cache moet blijven op systemen die je record verzoeken (resolving nameservers, browsers,
etc.). De TTL staat in seconden, dus 60 is een minuut, 1800 is 30 minuten, etc.

Systemen met een static IP zouden normaal gezien een TTL van 1800 of hoger moeten gebruiken.
Systemen  met een dynamic IP zouden normaal gezien een TTL van 1800 of minder moeten gebruiken.

Hoe lager de TTL, hoe meer een client bij de nameservers (van je domain record) moet gaan vragen naar het IP-adres van je host.
Voor je host zijn IP-adres betekent dit in meer verkeer van en naar je domain name.
Daartegenover kan een hoge TTL voor downtime zorgen als je snel van IPs moet veranderen.

Voorbeeld record:

```
NAME                TTL     TYPE    DATA

www.mydomain.com.   1800    A       192.168.1.2
mail.mydomain.com.  1800    A       192.168.1.5
```

Het eindresultaat van dit record is dat `www.mydomain.com` naar
`192.168.1.2` verwijst, `mail.mydomain.com` naar `192.168.1.5`.

## Reverse PTR record voor server IP-adres {: id="ptr" }

### Wat is een reverse PTR record

Een PTR record of eigenlijk correcter; een reverse PTR record is een manier om
een IP-adres te verbinden met zijn geassocieerde hostname. Dit is exact het omgekeerde van een hostname te verbinden met een IP-adres (`A` record). Bijvoorbeeld: wanneer je de name `mail.mydomain.com` pingt, zal het worden verbonden met het IP-adres door DNS
naar iets zoals `192.168.1.5`. Een reverse PTR record doet het omgekeerde; het zoekt voor de hostname die geassocieerd is met een gegeven IP-adres. In bovenstaand voorbeeld is  het PTR record voor het IP-adres `192.168.1.5` verbonden met `mail.mydomain.com`.

### Waarom je een reverse PTR record nodig hebt

Een reverse PTR record wordt het meeste opgezocht door spam filters.
Het idee hierachter is dat luie spammers die e-mail sturen vanuit kwaadwillende domains meestal geen (juist opgezet) reverse PTR record hebben. Dit criterium wordt gebruikt door spam filters om spam te blokkeren. Als je domein geen correct reverse PTR record heeft __IS HET MOGELIJK__ dat e-mail spam filters je e-mails blokkeren.

### Hoe een Reverse PTR record creëren

Je zult hoogstwaarschijnlijk je ISP moeten contacteren en vragen om een reverse PTR record te maken voor je e-mail server zijn IP-adres. Als je e-mail server zijn hostname bijvoorbeeld `mail.mydomain.com` is, moet je je ISP vragen om een reverse
PTR record te maken voor `192.168.1.5` (your internet public IP-adres) in hun reverse DNS
zone. Reverse DNS zones worden altijd beheerd door je ISP zelfs als je je eigen DNS zone beheert.

## MX record voor e-mail domain name {: id="mx" }

### Wat is een MX record

Een Mail Exchanger Record of meer bekend een MX record is een ingevoerde toevoeging in de DNS server van je domain dat andere e-mail servers vertelt waar je e-mail server zich bevindt. Wanneer iemand een e-mail stuurt naar een gebruiker op jouw server en die e-mail komt van het internet, voorziet MX de locatie of het IP-adres om die e-mail naartoe te sturen. Een MX record is de locatie van je e-mail server die je vrijgeeft aan de buitenwereld via DNS.

De meeste e-mail servers hebben gemiddeld meer dan één MX record, wat betekent dat
je meer dan één e-mail server kunt gebruiken om e-mails te ontvangen. Elk MX record heeft een op voorhand gegeven prioriteitsnummer dat wordt vastgelegd in DNS. Het MX record met __het laagste nummer heeft de hoogste prioriteit__ en dat wordt als je primaire MX record of belangrijkste e-mail server gezien. Het volgende laagste mx nummer heeft de op één na hoogste prioriteit en zo voort. Je hebt gemiddeld gezien meer dan één e-mail server, één als primaire e-mail server en de rest als backups, maar 1 MX record voor je e-mail server is ook OK.

### Hoe een MX record creëren

Als je ISP of domain name registrar je DNS service voorziet, kan je hun vragen om
er een te creëren. Als je je eigen DNS servers beheert moet je het MX record(s) zelf opstellen in je DNS zone.

Voorbeeld MX record:

```
NAME            PRIORITY    TYPE    DATA

mydomain.com.   10          mx      mail.mydomain.com.
```

Het eindresultaat van dit record is dat alle emails die gestuurd worden naar `[user]@mydomain.com` op `mail.mydomain.com` worden ontvangen.

## autodiscover voor je domain

### Wat is een autoconfig/autodiscover record

autoconfig/autodiscover records laten mail clients toe om automatisch de client configuratie van de mailbox te verkrijgen via DNS records. Als de te configureren mailbox bijvoorbeeld `user@company.com` is, zal je mail client automatisch checken bij `autodiscover.company.com` voor de correcte configuratie.

Daarover is meer informatie te vinden hier:
[DNS records creëren voor autoconfig en autodiscover](https://docs.iredmail.org/iredmail-easy.autoconfig.autodiscover.html).

### Hoe een autoconfig/autodiscover record creëren

Als je ISP of domain name registrar je DNS service voorziet, kan je hun vragen om
er een te creëren. Als je je eigen DNS servers beheert moet je het autoconfig/autodiscover record(s) zelf opstellen in je DNS zone.

Voorbeeld autoconfig/autodiscover record:

```
NAME            PRIORITY    TYPE    DATA

autodiscover.mydomain.com.   10          A      mail.mydomain.com.
autoconfig.mydomain.com.   10          A      mail.mydomain.com.
```

## SPF record voor je e-mail domain name {: id="spf" }

### Wat is een SPF record

SPF is een spam en phishing bestrijdingsmethode die DNS SPF-records gebruikt
die definiëren welke hosts toegestaan zijn om e-mails te versturen vanuit een bepaald domain. Voor meer informatie over SPF, raadpleeg [wikipedia](https://en.wikipedia.org/wiki/Sender_Policy_Framework).

Het werkt door een DNS SPF-record te definiëren voor een e-mail domain name die  specificeert welke hosts (e-mail servers) toegelaten zijn om e-mail te versturen vanuit een bepaalde domain name.

Andere e-mail servers kunnen dit record opzoeken als ze e-mail krijgen van je domain, zo kunnen ze verifiëren dat die e-mail server is toegelaten om e-mail te sturen.

### Hoe een SPF record creëeren

SPF is een TXT type DNS record, je kunt er IP-adress(en) of MX domains in oplijsten.
Bijvoorbeeld:

```
mydomain.com.   3600    IN  TXT "v=spf1 mx -all"
```

Dit SPF record zorgt ervoor dat alle e-mails die gestuurd worden van alle servers gedefinieerd in het MX record van `mydomain.com` toegelaten worden als `someone@mydomain.com`.

`-all` betekent verbied alle emails gestuurd van alle andere servers. Als het te strict is voor jouw geval, kan je `~all` gebruiken, wat een soft fail betekent (onzeker).

Je kunt ook IP-adress(en) specifiëren:

```
mydomain.com.   3600    IN  TXT "v=spf1 ip4:111.111.111.111 ip4:111.111.111.222 -all"
```

Natuurlijk kan je ze ook allebei (of meer dan 2) invoegen in hetzelfde record:

```
mydomain.com.   3600    IN  TXT "v=spf1 mx ip4:111.111.111.222 -all"
```

Er zijn nog meer validatiesystemen die je kunt gebruiken, raadpleeg
[wikipedia](https://en.wikipedia.org/wiki/Sender_Policy_Framework) voor meer details.

## DKIM record voor je e-mail domain name {: id="dkim" }

### Wat is een DKIM record

DKIM zorgt ervoor dat een organisatie verantwoordelijk is voor een bericht op een manier die kan worden geverifieerd door de ontvanger. De organisatie kan direct in contact komen met het bericht, zoals bij de schrijver van het bericht het geval is,  de site die het gestuurd heeft of een tussenpersoon langs de weg die de e-mail aflegt. Het kan ook een indirecte handler zijn, zoals een onafhankelijke service die assistentie biedt aan een directe handler. DKIM definieert een framework voor digitaal e-mail te signeren op domain niveau, door zijn gebruik van public-key cryptografie en domain name service als key server technologie 
([RFC4871](http://www.dkim.org/specs/rfc5585.html#RFC4871)). 
Het staat verificatie van de eigenaar van een bericht toe, samen met zekerheid dat de inhoud van het bericht niet werd verandert. DKIM zal ook een mechanisme voorzien dat mensen die hun e-mail signeren toelaat om informatie vrij te geven over hoe hun e-mail normaal gesigneerd is; dit laat e-mail ontvangers toe om aanvullende beoordeling te maken over ongesigneerde berichten.
De authenticatie van DKIM kan meehelpen in de globale controle van "spam" en "phishing".

Een persoon of organisatie heeft een "identiteit" -- dat betekent, een verzameling van eigenschappen dat hun onderscheid van een andere identiteit. Geassocieerd met deze abstractie kan een label gebruikt worden als standaard, of "identifier".
Dit is het verschil tussen een ding en de naam van dat ding. DKIM gebruikt een domain name als identificatiemethode om te verwijzen naar de identiteit van een verantwoordelijke organisatie of persoon. In DKIM wordt dit ID Signing Domain
IDentifier (SDID) genoemd, het bevindt zich in de DKIM-Signature header fields `d=`
tag. Merk op dat eenzelfde identiteit meerdere ID's kan hebben.

### Hoe een DKIM record creëren

* Geef onderstaand commando in in je terminal om je DKIM keys weer te geven:

    !!! attention

        * Op sommige Linux/BSD distributions, moet je het commando `amavisd-new` 
        gebruiken indeplaats van `amavisd`.
        * Moest CentOS klagen `/etc/amavisd.conf not found`, dan
          moet je het commando ingeven met zijn configuratiebestand. Bijvoorbeeld:

          ```amavisd -c /etc/amavisd/amavisd.conf showkeys```

```bash
# amavisd showkeys
dkim._domainkey.mydomain.com.   3600 TXT (
  "v=DKIM1; p="
  "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDYArsr2BKbdhv9efugByf7LhaK"
  "txFUt0ec5+1dWmcDv0WH0qZLFK711sibNN5LutvnaiuH+w3Kr8Ylbw8gq2j0UBok"
  "FcMycUvOBd7nsYn/TUrOua3Nns+qKSJBy88IWSh2zHaGbjRYujyWSTjlPELJ0H+5"
  "EV711qseo/omquskkwIDAQAB")
```

* Kopieer de output van bovenstaand commando naar een lijn zoals hieronder te zien is, verwijder alle quotes, maar houd `;`. __we hebben alleen de string nodig binnen  `()`__, dat is de waarde van ons DKIM DNS record.

```
v=DKIM1; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDYArsr2BKbdhv9efugBy...
```

__Merk op: BIND ([De meest gebruikte Name Server Software](http://www.isc.org/downloads/bind/))
aanvaardt dit soort van multi-line formaat, daar kun je het gewoon in je domain zone kopieëren.

* Voeg een `TXT` type DNS record voor domain name `dkim._domainkey.mydomain.com` toe,
  stel als waarde de lijn in die je voordien hebt geformatteerd (voorbeeld hierboven te zien): `v=DKIM1; p=...`.

    > WAARSCHUWING: Een gebruikelijke fout is om dit DKIM record met domain name
    > `mydomain.com` te verbinden, dat is fout. Zorg ervoor dat je het toevoegt aan domain name `dkim._domainkey.mydomain.com`.

* Nadat je dit hebt toegevoegd in DNS, kan je het checken met `dig` of `nslookup`:

```
$ dig -t txt dkim._domainkey.mydomain.com

$ nslookup -type=txt dkim._domainkey.foodmall.com
```

Voorbeeld mogelijke output:

```
dkim._domainkey.mydomain.com. 600 IN TXT	"v=DKIM1\;p=..."

```

 Verifieer het met Amavisd:

```shell
# amavisd testkeys
TESTING: dkim._domainkey.mydomain.com       => pass
```

Als het `pass` laat zien, werkt het.

__Merk op__: Als je een DNS service gebruikt die wordt voorzien door je ISP, kan het zijn dat nieuwe DNS records een paar uur op zich laten wachten.

Als je een opnieuw een (nieuwe) DKIM key wilt genereren, bekijk dan onze andere tutorial:
[Signeer DKIM signature bij uitgaande e-mails voor nieuw mail domain](./sign.dkim.signature.for.new.domain.html).

## DMARC record voor de e-mail domain name {: id="dmarc" }

### Wat is DMARC, en hoe vecht het phishing aan?

Quote van [FAQ pagina op dmarc.org website](https://dmarc.org/wiki/FAQ) (het is sterk aangeraden om de volledige FAQ pagina te lezen):

> DMARC biedt een makkelijke manier aan voor zowel e-mailverzenders als e-mailontvangers om te bepalen of een gegeven bericht echt komt van de afzender, en wat te doen als dat niet het geval is. Dit maakt het gemakkelijker om spam en phishing te identificerend, zorgt ervoor dat dit niet in mensen hun inbox terechtkomt.
>
> DMARC is een voorgestelde standaard dat e-mail e-mailverzenders en e-mailontvangers toelaat om informatie te delen over de e-mails die ze naar elkaar sturen.
> Deze informatie help e-mailverzenders om hun e-mail authenticatieinfrastructuur te verbeteren zodat al hun mail kan worden geauthenticeerd. Het geeft de echte eigenaar van een internet domain een manier om kwaadwillende berichten zoals
> gespoofte spamberichten of phishing e-mails direct naar de spam folder te verplaatsen, of zelfs gewoon weigeren om ze te ontvangen.

Wat belangrijke documenten van <https://dmarc.org>:

* [DMARC FAQ](https://dmarc.org/wiki/FAQ)
    * [Why is DMARC Important?](https://dmarc.org/wiki/FAQ#Why_is_DMARC_important.3F)
* [How Does DMARC Work?](https://dmarc.org/overview/)
* [Specifications](https://dmarc.org/resources/specification/)

### Hoe een DMARC record creëren 

!!! attention

    DMARC steunt op correct gecreëerde SPF en DKIM records, zorg ervoor dat je correcte up-to-date SPF en DKIM records hebt.

Een DMARC record is een TXT type DNS record.

Een vereenvoudigd DMARC record ziet er zo uit:

```
v=DMARC1; p=none; rua=mailto:dmarc@mydomain.com
```

Een gedetailleerd DMARC record ziet er zo uit:

```
v=DMARC1; p=reject; sp=none; adkim=s; aspf=s; rua=mailto:dmarc@mydomain.com; ruf=mailto:dmarc@mydomain.com
```

* `v=DMARC1` identificeert de DMARC protocol versie, momenteel is enkel `DMARC1` een optie,   `v=DMARC1` moet als eerste komen in een DMARC record.
* `adkim` specifieert hoeveel het DMARC record overeenkomt met DKIM. Er zijn 2 opties:
    * `r`: relaxte modus (`adkim=r`)
    * `s`: stricte modus (`adkim=s`)
* `aspf` specifieert hoeveel het DMARC record overeenkomt met SPF. Er zijn 2 opties:
    * `r`: relaxte modus (`aspf=r`)
    * `s`: stricte modus (`aspf=s`)
* `p` specifieert de procedure voor het domain. Het vertelt de ontvangende
  server wat te doen als het DMARC verificatiemechanisme zijn veri faalt. Er zijn 3 mogelijke opties:

    * `none` (`p=none`): De eigenaar van het domain verzoekt om geen specifieke actie te ondernemen omtrent de verzending van het bericht.
    * `quarantine` (`p=quarantine`): De eigenaar van het domain verzoekt dat e-mail die het DMARC verificatiemechanisme faalt gezien wordt als verdacht. Afhankelijk van de mogelijkheden die de ontvanger tot hun beschikking heeft kan dat betekenen: 'plaats in spam folder', 'markeer als verdacht', 'plaats e-mail in quarantaine' of misschien meer.
    * `reject` (`p=reject`): De eigenaar van het domain verzoekt dat e-mail die het DMARC verificatiemechanisme faalt wordt afgewezen.

    !!! attention

        - Als je zeker bent dat al je e-mails gestuurd worden vanuit de server(s) die staan opgelijst in je SPF record, of dat ze een correct gesigneerde DKIM signatuur hebben, is `p=reject` sterk aangeraden.
        - Volgens [RFC 7489](https://tools.ietf.org/html/rfc7489#section-6.3),
          __MOETEN de "v" en "p" tags altijd aanwezig zijn en MOETEN ze altijd in die volgorde voorkomen.__
          dus plaats altijd eerst de "p" tag direct gevolgd door de "v" tag. bv:
          `v=DMARC1; p=reject; aspf=s; ...` is ok, maar niet `v=DMARC1; aspf=s; p=reject; ...`.

* `sp` specifieert procedure voor alle subdomains. Dit is optioneel. Mogelijke opties zijn hetzelfde als `p`.
* `rua` specifieert een transportmechanisme om verzamelde feedback te versturen. Momenteel is enkel `mailto:` ondersteund. Dit is optioneel.
* `ruf` specifieert een transportmechanisme om berichtspecifieke fouten te rapporteren. Momenteel is enkel `mailto:` ondersteund. Dit is optioneel.

## SRV record voor Jabber/XMPP service

Als je Prosody installeert (met het iRedMail Easy platform) als Jabber/XMPP server,
zijn 2 SRV records vereist.

Als je e-mail domain name `mydomain.com` is en je server hostname
`mail.mydomain.com` is, moet je 2 SRV type DNS records toevoegen:

- `_xmpp-client._tcp.mydomain.com`
- `_xmpp-server._tcp.mydomain.com`

Voorbeeld DNS records:

```
_xmpp-client._tcp.mydomain.com 18000 IN SRV 0 5 5222 mail.mydomain.com
_xmpp-server._tcp.example.com. 18000 IN SRV 0 5 5269 mail.mydomain.com
```

Het doelwit domain `mail.mydomain.com` __MOET__ een bestaand A record zijn, het kan geen
IP-adres of CNAME record zijn.

## Registeer je e-mail domain bij Google Postmaster Tools

Deze stap is __optioneel__, maar __zwaar aangeraden__.

Google Postmaster Tools website: <https://postmaster.google.com>, en
[Postmaster Tools FAQs](https://support.google.com/mail/answer/6258950).

Het is zeer simpel: registreer je e-mail domain hier, en ze zullen je een
text record geven voor je DNS zodat Google eigendom van het domain kan valideren.

Waarom Google Postmaster Tools gebruiken? Quote van
[Google Postmaster Tools help page](https://support.google.com/mail/answer/6227174):

> Als je veel e-mails stuurt naar Gmail users, kan je met Postmaster Tools het volgende zien:
>
> * Of gebruikers je e-mails als spam markeren
> * Of je 'Gmail's best practices' volgt
> * Waarom je e-mails misschien niet worden ontvangen
> * Of je e-mails veilig worden verstuurd

het *__KAN__* ook helpen om je e-mails uit de  `Junk` mailbox te houden.

Als je moeilijkheden hebt om e-mail te versturen naar Gmail (of Google Apps), Biedt Google wat informatie aan over best practices om te verzekeren dat je e-mail wordt doorgestuurd naar Gmail gebruikers: [Bulk Senders Guidelines](https://support.google.com/mail/answer/81126?hl=en).

Je kunt ook dit formulier invullen om Google te contacteren:
[Bulk Sender Contact Form](https://support.google.com/mail/contact/bulk_send_new?rd=1)

## Check Outlook.com Postmaster site

De Outlook Postmaster voorziet wat nuttige informatie voor e-mail server admins, als de e-mail die je gestuurd hebt Outlook.com gemarkeerd wordt als spam, kijk hier dan eens naar:

- [Outlook.com Postmaster](https://sendersupport.olc.protection.outlook.com/pm/)
- [Smart Network Data Service](https://sendersupport.olc.protection.outlook.com/snds/)

## Referenties

* [wikipedia: Sender Policy Framework](https://en.wikipedia.org/wiki/Sender_Policy_Framework)
* [http://www.dkim.org/](http://www.dkim.org/)
