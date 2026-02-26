# Send out email from specified IP address

[TOC]

If you have multiple IP addresses available on your iRedMail server, and would
like to send from different IP Addresses for different domains, follow the
steps below.

## Requirements

- Postfix version 2.7.x or later releases are required.

## Configuration

* Create new transport in `/etc/postfix/master.cf` like below:

    - Replace IP address `172.16.244.159 ` by your real IP address.
    - For IPv6 address, use `smtp_bind_address6` instead of `smtp_bind_address`.
    - Arguments `smtp_helo_name` and `syslog_name` are optional.

```
sample-smtp     unix -       -       n       -       -       smtp
    -o smtp_bind_address=172.16.244.159
#    -o smtp_helo_name=example.com
#    -o syslog_name=postfix/sample-smtp
```

### Use case 1: Force all users under local domain to send out from specified IP address

You have email domain name `example.com` hosted on iRedMail server, and you
want to force all emails sent by users under `example.com` to be sent from
specified IP address.

* Add Postfix setting `sender_dependent_default_transport_maps` to the end of
  `/etc/postfix/main.cf` like below:

```
sender_dependent_default_transport_maps = hash:/etc/postfix/sdd_transport
```

* Create file `/etc/postfix/sdd_transport` with content below (Replace
 `example.com` by your real local domain name):

```
@example.com   sample-smtp:
```

* Run `postmap` and reload Posfix service to load changed settings:

```shell
postmap /etc/postfix/sdd_transport
postfix reload
```

### Use case 2: Sent to certain recipient domains from specified IP address

You want to force all emails sent from iRedMail server to Gmail (`gmail.com`)
to be sent from specified IP address.

* Add recipient domain name (`gmail.com`) and transport name in
`/etc/postfix/transport` like below:

```
gmail.com sample-smtp:
```

You may want to force for all sub-domain names (e.g. `x.gmail.com`, `y.gmail.com`) too:
```
.gmail.com sample-smtp:
```

* Run `postmap` and reload Posfix service to load changed settings:
```shell
postmap /etc/postfix/transport
postfix reload
```
