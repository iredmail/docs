# Abilita membro all'invio di mail come mail list o mail alias

Per abilitare un account di un membro di una mailinglist (o mail alias) a inviar-e mail com mailinglist (o mail alias) seguite i passi seguenti:

* Rimuovere `reject_sender_login_mismatch` dal file di configurazione di Postfix,  `/etc/postfix/main.cf`.
* Abilitare il plugin iRedAPD  `reject_sender_login_mismatch` nel file di configurazione di iRedPAD `/opt/iredapd/settings.py`.
* aggiungere una nuova configurazione in `/opt/iredapd/settings.py` per abilitare l'utente a mandare mail come mailinglist o mail alias:

```
ALLOWED_LOGIN_MISMATCH_LIST_MEMBER = True
```

- Riavviare entrambi i servizi Postfix ed iRedAPD