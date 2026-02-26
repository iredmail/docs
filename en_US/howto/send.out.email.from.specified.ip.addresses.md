# Send out email from specified IP address

If you have multiple IP addresses available on your iRedMail server, and would
like to send from different IP Addresses for different domains, follow the
steps below.

### Requirements

- Postfix version 2.7.x or later releases are required.

### Steps

* Create new transport in `/etc/postfix/master.cf` like below:

    Notes:

    - Replace IP address `172.16.244.159 ` by your real IP address.
    - For IPv6 address, use `smtp_bind_address6` instead of `smtp_bind_address`.
    - Arguments `smtp_helo_name` and `syslog_name` are optional.

```
sample-smtp     unix -       -       n       -       -       smtp
    -o smtp_bind_address=172.16.244.159
#    -o smtp_helo_name=example.com
#    -o syslog_name=postfix/sample-smtp
```

* Add Postfix setting `sender_dependent_default_transport_maps` to the end of
  `/etc/postfix/main.cf` like below:

```
sender_dependent_default_transport_maps = pcre:/etc/postfix/sdd_transport.pcre
```

* Create file `/etc/postfix/sdd_transport.pcre` with content below (Replace
 `example.com` by your real domain name):

```
/@example\.com$/   sample-smtp:
```

Reload Posfix service to load changed settings:

```shell
postfix reload
```

Note: any unmatched domains will continue using the server's primary IP address
just as before.
