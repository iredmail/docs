# Zet debug logging aan in Fail2ban

!!! attention

	 Bekijk onze lichtgewicht on-premise e-mail archiveringsoftware ontwikkeld door 
	 het iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

Om debug modus aan te zetten in Fail2ban moet je zijn logniveau instellen op `debug` in
configuratiebestand `/etc/fail2ban/fail2ban.local`, dan fail2ban service herstarten.
Als bestand `/etc/fail2ban/fail2ban.local` niet bestaat, gebruik dan
`/etc/fail2ban/fail2ban.conf`.

```
loglevel = DEBUG
```

## Logbestand

Fail2ban kan loggen naar verschillende logbestanden afhankelijk van de Linux/BSD distributie:

- `/var/log/fail2ban.log`
- `/var/log/fail2ban/fail2ban.log`
- `/var/log/messages`
- `/var/log/syslog`
