#  Permettere ad alcuni utenti di mandare mail come fossero un altro utente

iRedMail configura Postfix affinché rifiuti una richiesta quando il mittente
specifica un indirizzo proprietario per il campo MAIL FROM (`From:` header), 
ma il client non ha effettuato l'accesso in modalità SASL come il proprierario
dell'indirizzo MAIL FORM; o quando il client è loggato in modalità SASL, ma 
non è il proprietario dell'indirizzo in MAIL FROM 

A volte possiamo avere la necessità di mandare una mail a nome di un altro
utente, questo manuale descrive come permettere, ad alcuni utenti, di farelo
con il plugin iRedAPD `reject_sender_login_mismatch`.

* Elimina la regola restrittiva `reject_sender_login_mismatch` dal file di 
  di configurazione `smtpd_sender_restrictions` che si trova in
  (`/etc/postfix/main.cf`).
  Il plugin iREDAPD farà le stesse restrizioni per conto vostro.

     Dopo aver rimosso `reject_sender_login_mismatch`, la configurazione di 
     postfix sara come riportato sotto:


```
smtpd_sender_restrictions = permit_mynetworks, permit_sasl_authenticated
```

* Nel file di configurazione iRedADP `/opt/iredapd/settings.py` abilita il 
  plugin:

```python
plugins = ['reject_sender_login_mismatch', ...]
```

* Elenca i mittenti che sono autorizzati ad inviare email con indirizzi 
  diversi dai propri, nel file di configurazione iRedAPD
  `ALLOWED_LOGIN_MISMATCH_SENDERS`. Per esempio:

```python
ALLOWED_LOGIN_MISMATCH_SENDERS = ['user1@here.com', 'user2@here.com']
```

    NOTA: Questo parametro non è presnete di default, aggiungilo manualmente.

Riavvia il servizio iRedAPD. Questo è tutto.
