# Abilitare utente ad inviare mail senza l'autenticazione smtp

Create questo file di testo: `/etc/postfix/accepted_unauth_senders`, elencandoci tutti gli indirizzi mail degli utenti abilitati ad inviare posta senza l'autenticazione smtp. Verrà usato l'indirizzo `user@example.com` come esempio:

```
user@example.com OK
```

Create un file db hash con il comando `postmap` :

```
# postmap hash:/etc/postfix/accepted_unauth_senders
```

Modificate il file di configurazione di Postfix `/etc/postmap/main.cf` affinché uso questo file di testo:

```
smtpd_sender_restrictions = 
    check_sender_access hash:/etc/postfix/accepted_unauth_senders,
    [...OTHER RESTRICTIONS HERE...]
```

Riavviate/ricaricate Postfix per rendere effettiva la modifica.


```
# /etc/init.d/postfix restart
```
