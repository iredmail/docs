# Abilitare apparati di rete interni, ad inviare mail su connessioni insicure

[TOC]

## Scopo

Se avete alcuni apparati di rete come stampanti e firewall, che necessitano di inviare notifiche o mail di report con una connessione insicura smtp, provate i passi successivi per ottenere che funzioni senza modificare le configurazioni di sicurezza di 

## Aprire porta smtp aggiuntiva in Postfix

Dalla versione 0.9.3 di iRedMail con le configurazioni di default, la porta 25 è utilizzata dal servizio postscreen, tutti i client di posta sono obbligati a passare attraverso la pota 587 con STARTTL per ottenere connessioni sicure.

Per supportare apparati di rete che non supportano STARTTLS e SSL, posiamo chiedere a Postfix ti ascoltare su una porta aggiuntiva per il servizio smtp, aggiungendo la linea seguente in `/etc/postfix/master.cf`(su Linux/OpenBSD) oppure `/usr/local/etc/postfix/master.cf` (su FreeBSD):

```
2525      inet  n       -       -       -       -       smtpd
  -o smtpd_sasl_auth_enable=yes
  -o smtpd_sasl_security_options=noanonymous
```

`2525` è il nuovo numero di porta per il servizio smtp. potete cambiarlo nel valore che preferite.

Il riavvio del servizio Posfitx è necessario. Dopo il riavvio potete verificare se si sta ascoltando su questa nuova porta:

```
netstat -ntlp | grep 2525
```

Ora è il momento di aggiornare i vostri apparati di rete, affinché inviino la posta attraverso questo numero di porta, senza usare STARTTLS o SSL.

!!! note

    L'autenticazione SMTP è comunque ancora richiesta per inviare le mail.

## Aggiornare le regole del firewall affinché rifiutino l'accesso  a questa nuova porta dall'esterno della rete locale

É pericoloso esporre questa nuova porta alla rete esterna, per cui dovete aggiornare le regole del vostro firewall affinché rifiuti l'accesso, dall'esterno della rete locale, a questa nuova porta.
