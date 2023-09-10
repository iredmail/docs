# Zet debug modus aan in Postfix

!!! attention

	 Bekijk onze lichtgewicht on-premise e-mail archiveringsoftware ontwikkeld door 
	 het iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

Er zijn een paar manieren om debug modus aan te zetten in postfix, je kunt de manier die je verkiest uitvoeren.

## Gedetailleerde logging voor specifieke SMTP connecties

Om smtp verbindingen van een bepaalde client of server te loggen moet de hostname of het IP-adres met de `debug_peer_list` parameter worden opgelijst (in
`/etc/postfix/main.cf`). Bijvoorbeeld:

```
debug_peer_list = 192.168.0.1
```

Je kunt een of meer hosts, domains, adressen en/of net/masks toevoegen. Voer commando `postfix reload` uit om de verandering direct aan te activeren.

## Postfix daemon programma's meer gedetailleerde output laten geven

Er zijn veel daemon services gedefinieerd in `/etc/postfix/master.cf`, bijvoorbeeld:

```
smtp      inet  n       -       n       -       -       smtpd
```

Om gedetailleerde logging over een Postfix daemon te verkrijgen moet je een of meerdere
`-v` opties toevoegen aan diezelfde daemon. Daarna moet je het commando `postfix reload` ingeven.

```
smtp      inet  n       -       n       -       -       smtpd -v
```

* Om problemen te diagnostiseren  met adres rewriting moet je de `-v` optie gebruiken voor
  `cleanup(8)` en/of `trivial-rewrite(8)` daemon.
* Om problemen met e-mail ontvangst te diagnostiseren kan je de `-v` optie specifiëren  voor de
  `qmgr(8)` of `oqmgr(8)` wachtlijn manager, of voor de `lmtp(8)`, `local(8)`,
  `pipe(8)`, `smtp(8)`, of `virtual(8)` delivery agent.

## Zie ook

* [Postfix Debuggen hoe](http://www.postfix.org/DEBUG_README.html)
