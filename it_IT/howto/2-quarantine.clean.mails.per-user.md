# Mettere in quarantena le email pulite inviate da / per certo utente locale

Modificare [il file di configurazione di Amavisd](./file.locations.html#amavisd) specificando che deve ascoltare su una porta aggiuntiva, la `10030` (siete liberi di usare un'altra porta), ed una `policy_bank` aggiuntiva:

```
$inet_socket_port = [10024, 9998, 10030];

$interface_policy{'10030'} = 'QUARANTINE';
$policy_bank{'QUARANTINE'} = {
    clean_quarantine_method => 'sql:',
    final_destiny_maps_by_ccat => {CC_CLEAN, D_DISCARD},
};

$clean_quarantine_to = 'clean-quarantine';
```

Riavviare il servizio Amavisd.

* Aggiungete il codice sottostante al file di configurazione di Postfix `/etc/postfix/master.cf`, configurando così Postfix per ascoltare sulla porta aggiuntiva `10026` (siete liberi di usare un'altra porta):

```
127.0.0.1:10026 inet n  -   -   -   -  smtpd
    -o content_filter=smtp-amavis:[127.0.0.1]:10030
    -o recipient_bcc_maps=
    -o sender_bcc_maps=
    -o mynetworks_style=host
    -o mynetworks=127.0.0.0/8
    -o local_recipient_maps=
    -o relay_recipient_maps=
    -o strict_rfc821_envelopes=yes
    -o smtp_tls_security_level=none
    -o smtpd_tls_security_level=none
    -o smtpd_restriction_classes=
    -o smtpd_delay_reject=no
    -o smtpd_client_restrictions=permit_mynetworks,reject
    -o smtpd_helo_restrictions=
    -o smtpd_sender_restrictions=
    -o smtpd_recipient_restrictions=permit_mynetworks,reject
    -o smtpd_end_of_data_restrictions=
    -o smtpd_error_sleep_time=0
    -o smtpd_soft_error_limit=1001
    -o smtpd_hard_error_limit=1000
    -o smtpd_client_connection_count_limit=0
    -o smtpd_client_connection_rate_limit=0
    -o receive_override_options=no_header_body_checks,no_unknown_recipient_checks,no_address_mappings
```

* Riavviate il servizio Postfix.

```
service postfix restart
```

Per mettere in quarantena tutte le mail inviate da/per `user@domain.com` configurate il per-user transport a `smtp:[127.0.0.1]:10026`.

Ora tutte le mail mandate da/per `user@domain.com` saranno messe in quarantena in un database SQL (specificato nel file di configurazione di Amavisd al parametro `@storage_sql_dsn`).

Inviate, come prova,  una mail a `user@domain.com`:

```
# echo "mail body" | mail -s "test subject" user@domain.com
```

## Vedi anche

* [Mettere in quarantena](./quarantining.html)
