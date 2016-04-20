# Setup relayhost

[TOC]

Relay host is a server which can accept your email and sent it out to the final
destination for you.

## Global relay host

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

## Sender dependent relay host

!!! note

    * Sender dependent relay host is available in iRedMail-0.9.5 or later releases.

### Manage with iRedAdmin-Pro

Since iRedAdmin-Pro-SQL-2.4.0 or iRedAdmin-Pro-LDAp-2.6.0, it's able to manage
per-domain or per-user sender dependent relay host in domain or user profile
page, under tab `Relay`. Screenshot attached.

### Manage with command line tools

#### MySQL, MariaDB, PostgreSQL

For SQL backends, you can manage sender dependent relay host in SQL table
`mailbox.sender_relayhost`. We use MySQL for example below.

* Per-domain sender dependent relay host:

```
sql> USE vmail;
sql> INSERT INTO sender_relayhost (account, relayhost) VALUES ('@domain.com', '[mail.gmail.com]:25');
```

* Per-user sender dependent relay host:

```
sql> USE vmail;
sql> INSERT INTO sender_relayhost (account, relayhost) VALUES ('user@domain.com', '[mail.gmail.com]:25');
```

#### OpenLDAP

For OpenLDAP backend:

* per-domain sender dependent relay host is stored in attribute `senderRelayHost` of domain account.
* per-user sender dependent relay host is stored in attribute `senderRelayHost` of user account.

Sample LDIF data:

* Per-domain sender dependent relay host

```
dn: domainName=mydomain.com,o=domains,dc=example,dc=com
senderRelayHost: [mail.gmail.com]:25
...
```

* Per-user sender dependent relay host

```
dn: mail=user@mydomain.com,ou=Users,domainName=mydomain.com,o=domains,dc=example,dc=com
senderRelayHost: [mail.gmail.com]:25
...
```

### Screenshot of iRedAdmin-Pro

* iRedAdmin-Pro: Per-domain relay setting:

![](../images/iredadmin/domain_profile_relay.png)

* iRedAdmin-Pro: Per-user relay setting:

![](../images/iredadmin/user_profile_relay.png)

