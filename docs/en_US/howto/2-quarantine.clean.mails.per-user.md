# Quarantine clean emails sent from/to certain local user

Update [Amavisd config file](./file.locations.html#amavisd), ask it to listen on one additional network port
`10030` (you're free to use another port), and one additional `policy_bank`:

```
$inet_socket_port = [10024, 9998, 10030];

$interface_policy{'10030'} = 'QUARANTINE';
$policy_bank{'QUARANTINE'} = {
    clean_quarantine_method => 'sql:',
    final_destiny_maps_by_ccat => {CC_CLEAN, D_DISCARD},
};

$clean_quarantine_to = 'clean-quarantine';
```

Restart Amavisd service.

* Append below content to Postfix config file `/etc/postfix/master.cf`, ask
  Postfix to listen on one additional network port `10026` (you're free to use
  another port):

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

* Restart Postfix service.

```
service postfix restart
```

* To quarantine all emails sent from/to `user@domain.com`, set its per-user
  transport to `smtp:[127.0.0.1]:10026`.

Now all emails sent from/to `user@domain.com` will be quarantined into SQL
database (specified in Amavisd config file, parameter `@storage_sql_dsn`).

Send an email to `user@domain.com` for testing:

```
# echo "mail body" | mail -s "test subject" user@domain.com
```

## See also

* [Quarantining](./quarantining.html)
