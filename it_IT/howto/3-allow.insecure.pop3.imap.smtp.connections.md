# Permettere connessioni inscurire senza STARTTLS per POP3/IMAP/SMTP

[TOC]

Con la configurazione di default di iRedMail, tutti i client di posta sono forzati ad usare i servizi POP3/IMAP/SMTP over STARTTLS per ottenere connessioni sicure. Se il vostro client di posta tentasse l'accesso alla casella di posta con il protocollo POP3/IMAP/SMTP senza il support TLS, otterreste un messaggio di errore simile quello sottostante:

```
Plaintext authentication disallowed on non-secure (SSL/TLS) connections
```

Questo tutorial descrive come abilitare connessioni insicure per l'uso quotidiano.

!!! note

    Se avete uno o solo pochi apparati di rete come stampanti e firewall che necessitano di inviare mail  con una connessione insicura, seguite invece questo tutorial:  [Abilitare apparati di rete interni ad inviare mail con connessione inscure](./additional.smtp.port.html).

## Abilitare connessioni POP3/IMAP insicure

Se volete abilitare i servizi POP3/IMAP/SMTP senza STARTTLS per qualche ragione (di nuovo è una cosa non raccomandata), aggiornate i due seguenti parametri nel file di configurazione di Dovecot, `/etc/dovecot/dovecot.conf` e riavviate il servizio di Dovecot:

* su Linux ed OpenBSD è `/etc/dovecot/dovecot.conf`
* su FreeBSD è  `/usr/local/etc/dovecot/dovecot.conf`

```
disable_plaintext_auth=no
ssl=yes
```

Nuovamente, è fortemente raccomandato di usare solo POP3S/IMAPS per una migliore sicurezza.

La configurazione di default, e raccomandata, impostata da iRedMail è:

```
disable_plaintext_auth=yes
ssl=required
```

## Abilitare connessioni STMP insicure

Commentate la riga sottostante nel file di configurazione di Postifx, `/etc/postfix/main.cf` e ricaricate o riavviate il servizio Postfix:

```
smtpd_tls_auth_only=yes
```

