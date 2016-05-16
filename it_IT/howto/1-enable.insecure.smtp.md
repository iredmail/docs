# Abilitare servizio non protetto SMTP su porta 25

Sin dalla versione 0.9.5 di iRedMail, l'autenticazione su porta 25 è disabilitata per default, tutti gli utenti sono costretti a mandare email attraverso la posta 587 (SMTP over TLS). Se avete la necessità di abilitare l'autenticazione insicura sulla porta 25, per qualsivoglia motivo, seguite i passi sotto elencati per abilitarla.

!!! nota

 Se avete la necessita di far usare solo ad un piccolo numero di utenti la porta 25m per esempio una  stampante di rete o vecchi apparati di rete che non sopportano connessioni sicure, potete invece provare questo altro tutorial: [Abilitare apparati interni di rete a mandare mail su connessione insicura](./additional.smtp.port.html)

* Trovate le configurazioni commentate, mostrate qui sotto, nel file di configurazione di Postfix `/etc/postfix/main.cf` (linux/OpenBDS) oppure `/usr/local/etc/postfix/main.cf` per FreeBSD:

```
#
# Enable SASL authentication on port 25 and force TLS-encrypted SASL authentication.
# WARNING: NOT RECOMMENDED to enable smtp auth on port 25, all end users should
#          be forced to submit email through port 587 instead.
#
#smtpd_sasl_auth_enable = yes
#smtpd_tls_auth_only = yes
#smtpd_sasl_security_options = noanonymous
#smtpd_tls_security_level = may
```

* decommentate le ultime 4 righe:

```
smtpd_sasl_auth_enable = yes
smtpd_tls_auth_only = yes
smtpd_sasl_security_options = noanonymous
smtpd_tls_security_level = may
```
* Riavvia o ricarica il servizio Postfix

Questo è tutto.
