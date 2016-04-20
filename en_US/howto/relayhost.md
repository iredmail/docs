# Setup relayhost

Relay host is a server which can accept your email and sent it out to the final
destination for you.

To setup a global relay host in iRedMail, please append below settings in
Postfix config file `/etc/postfix/main.cf` (Linux/OpenBSD) or
`/usr/local/etc/postfix/main.cf` (FreeBSD):

```cfg
relayhost = [relay_server]:25
smtp_sasl_password_maps = hash:/etc/postfix/sasl_password
smtp_sasl_auth_enable = yes
smtp_sasl_mechanism_filter = login
smtp_sasl_security_options = noanonymous
```

!!! note

    * You should relace `relay_server` above by the real server address. for
      example, `relayhost = [37.61.54.158]:25`, `relayhost = [smtp.gmail.com]:25`.
    * For more possible values/formats, please check Postfix document:
      [Postfix transport table format (transport)](http://www.postfix.org/transport.5.html).

Then write the username and password in `/etc/postfix/sasl_password`:

```cfg
relay.server user:password
```

Run `postmap` and restart Postfix service:

```cmd
postmap hash:/etc/postfix/sasl_password
service postfix restart
```

That's it.
