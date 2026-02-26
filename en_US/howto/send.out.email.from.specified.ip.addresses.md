# Send out email from specified IP address

If you have multiple IP addresses available on your iRedMail server, and would
like to send from different IP Addresses for different domains, follow the
steps below.

### Requirements

- Postfix version 2.7.x or later releases are required.

### Steps

* Create new outgoing SMTP transports in `/etc/postfix/master.cf` like below.

      Note: you must replace our sample IP address `172.16.244.159 ` with your
      real IP address. For IPv6 address, please use `smtp_bind_address6`
      instead of `smtp_bind_address` below.

```
sample-smtp     unix -       -       n       -       -       smtp
    -o smtp_bind_address=172.16.244.159
#    -o smtp_helo_name=example.com
#    -o syslog_name=postfix/sample-smtp
```

Arguments `smtp_helo_name` and `syslog_name` are optional.

* Reload or restart Postfix service to load changed config files:

```shell
postfix reload
```

* Run SQL command below as root user to set local email domain `example.com`
  to send out email from above IP / transport.

    NOTE: We use MySQL/MariaDB below for example. PostgreSQL uses same
    `INSERT INTO` command, OpenLDAP should update attribute `senderRelayHost`
    in domain object.

```shell
USE vmail;
INSERT INTO sender_relayhost (account, relayhost) VALUES ("example.com", "sample-smtp");
```

Now all emails sent by users under local email domain `example.com` will be
sent out from IP `172.16.244.159`.

Note: other local domains will continue using the server's primary IP address
as usual.
