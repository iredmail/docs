# Zet debug modus aan in iRedAPD

!!! attention

	 Bekijk onze lichtgewicht on-premise e-mail archiveringsoftware ontwikkeld door 
	 het iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

Om debug modus aan te zetten in iRedAPD moet je het logniveau instellen op `debug` in
iRedAPD configuratiebestand `/opt/iredapd/settings.py`, daarna iRedAPD
service herstarten.

```
# Log level: info, debug.
log_level = 'debug'
```

### Logbestand

Het logbestand is geconfigureerd in `/opt/iredapd/settings.py`, door parameter `log_file =`.
Bekijk zijn logbestand voor een gedetailleerde log.

* iRedAPD-1.7.0 en nieuwer: `/var/log/iredapd/iredapd.log`
* iRedAPD-1.6.0 en ouder: `/var/log/iredapd.log`
