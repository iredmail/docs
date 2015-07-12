# Send out email from specified IP address

If you have multiple IP addresses available on your iRedMail server, and would
like to send from different IP Addresses for different domains, follow the
steps below.

### Requirement

This can only be set up on Postfix version `>=2.7.x`, because the parameter we
need `sender_dependent_default_transport_maps` is available in Postfix-2.7 and
later releases.

To check your Postfix version run:

```
# postconf mail_version
```

Which would return something like: `mail_version = 2.10.3`

### Steps

* Add Postfix setting `sender_dependent_default_transport_maps` to the end of
  `/etc/postfix/main.cf` like below:

```
sender_dependent_default_transport_maps = pcre:/etc/postfix/sdd_transport.pcre
```
    
* Add file `/etc/postfix/sdd_transport.pcre` with below content. NOTE: we use
  domain `example.com` for example, it will use transport `sample-smtp` - see
  examples.

```
/@example\.com$/   sample-smtp:
```

* Create new outgoing SMTP transports in `/etc/postfix/master.cf` like below.
  Note: you must replace our sample IP address `172.16.244.159 ` with your IP
  address. If you want to use IPv6 address, please use `smtp_bind_address6`
  instead of `smtp_bind_address` below.
   
```
sample-smtp     unix -       -       n       -       -       smtp
    -o smtp_bind_address=172.16.244.159
#    -o smtp_helo_name=example.com
#    -o syslog_name=postfix-example-com
```

Option `smtp_helo_name` and `syslog_name` are optional.

After this restart the Postfix service to apply your changes:

```
# /etc/init.d/postfix restart
```
 
Note: any unmatched domains will continue using the server's primary IP address
just as before.
