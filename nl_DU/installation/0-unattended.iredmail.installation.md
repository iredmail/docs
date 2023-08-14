# Voer stille iRedMail installatie uit zonder toezicht en user input

!!! attention

	 Bekijk onze lichtgewichte on-premise e-mail archiveringsoftware ontwikkeld door 
	 het iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

## Samenvatting

Het iRedMail installatieprogramma slaat zijn eigen configuraties op in een bestand genaamd  `config` tijdens installatie. Als je bijvoorbeeld iRedMail-1.2 hebt gedownload naar `/root`, is dat: `/root/iRedMail-1.2/config` .

Wanneer je het iRedMail installatieprogramma start, detecteert het automatisch 
het configuratiebestand, en vraagt het voor je bevestiging om degene te gebruiken die het gevonden heeft. Je kunt deze procedure gebruiken om een iRedMail installatie uit te voeren zonder erbij te moeten zijn.

## Genereer een voorbeeldconfiguratiebestand

Om een voorbeeldconfiguratiebestand te genereren kan je het installatieprogramma opstarten:

```bash
bash iRedMail.sh
```

Nadat je de installatiewizard hebt overlopen, geeft het iRedMail installatieprogramma je configuraties weer en vraagt het voor bevestiging om de echte installatie te starten.
Je moet de installatie hier niet voltooien omdat je alleen maar het configuratiebestand nodig hebt.

Laat je niet tegenhouden om dit `config` bestand te openen, de instellingen te veranderen naar wat je van de echte installatie wilt.

## Start een nieuwe server op met voordien gemaakt configuratiebestand

Om een nieuwe server op te starten met voordien gemaakt configuratiebestand:

* Download iRedMail installatieprogramma van website: [Download](https://www.iredmail.org/download.html).
* Upload het gecomprimeerde iRedMail installatieprogramma naar de nieuwe server en decomprimeer het bestand. we gaan ervan uit dat u het bestand in deze map decomprimeert: `/root/iRedMail-1.2/`.
* Upload het voordien gemaakte configuratiebestand naar `/root/iRedMail-1.2/config` op de nieuwe server.
* Lanceer het iRedMail installatieprogramma nu met wat voordien-gedefinieerde variabelen:

```bash
AUTO_USE_EXISTING_CONFIG_FILE=y \
    AUTO_INSTALL_WITHOUT_CONFIRM=y \
    AUTO_CLEANUP_REMOVE_SENDMAIL=y \
    AUTO_CLEANUP_REPLACE_FIREWALL_RULES=y \
    AUTO_CLEANUP_RESTART_FIREWALL=y \
    AUTO_CLEANUP_REPLACE_MYSQL_CONFIG=y \
    bash iRedMail.sh
```

Het is makkelijk te begrijpen wat de namen van de variabelen betekenen:

* `AUTO_USE_EXISTING_CONFIG_FILE=y`: Gebruik bestaand `config` bestand zonder voor bevestiging te vragen.
* `AUTO_INSTALL_WITHOUT_CONFIRM=y`: Start de installatie zonder voor bevestiging te vragen.
* `AUTO_CLEANUP_REMOVE_SENDMAIL=y`: Verwijder `sendmail` package zonder voor bevestiging te vragen.
* `AUTO_CLEANUP_REPLACE_FIREWALL_RULES=y`: Kopieer en gebruik de firewall regels die standaard samen met het iRedMail installatieprogramma ter beschikking staan.
* `AUTO_CLEANUP_RESTART_FIREWALL=y`: herstart firewall service zonder voor bevestiging te vragen.
* `AUTO_CLEANUP_REPLACE_MYSQL_CONFIG=y`: Kopieer en gebruik het MySQL (server) configuratiebestand dat standaard samen met het iRedMail installatieprogramma ter beschikking staat.
