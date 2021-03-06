# Enable DNSBL service in Postfix to reduce spam

!!! attention

    If you're running a high-traffic mail server, you'd better setup a local
    DNS server to cache DNS queries, because free RBL services like
    `zen.spamhaus.org` may improperly reply if your server exceed the DNS
    query limit. Also, mail service higly relies on DNS queries, so a local
    DNS server speeds up the mail flow.

You can enable additional DNSBL services in Postfix to reduce spam. We use
`zen.spamhaus.org` for example below.

* Open Postfix config file `/etc/postfix/main.cf` or
  `/usr/local/etc/postfix/main.cf` (on FreeBSD), append
  `reject_rbl_client zen.spamhaus.org` to parameter `smtpd_recipient_restrictions`.
  Final setting looks like below:

```
smtpd_recipient_restrictions =
    ...
    reject_unauth_destination
    reject_rbl_client zen.spamhaus.org=127.0.0.[2..11]
    reject_rbl_client b.barracudacentral.org=127.0.0.2
```

It must be placed after `reject_unauth_destination`. You can add more DNSBL
services after `reject_unauth_destination`, and they will be queried in the
specified order.

Postfix will perform DNS query against `zen.spamhaus.org`, and wait for the
response code, only `127.0.0.2` to `127.0.0.11` are meaningful, so we use
`=127.0.0.[2..11]` to tell Postfix only reject clients when we get those
response code.

* If you have postscreen service enabled, you should add DNSBL services for
  postscreen service instead, so please don't use any `reject_rbl_client` in
  `smtpd_recipient_restrictions` parameter, but use below one instead:

```
postscreen_dnsbl_sites =
    zen.spamhaus.org=127.0.0.[2..11]*3
    b.barracudacentral.org=127.0.0.2*2
```

* Restart or reload Postfix service is required.

## See also

* [Enable postscreen service](./enable.postscreen.html)

## References

* [Postfix Configuration Parameters: reject_rbl_client](http://www.postfix.org/postconf.5.html#reject_rbl_client)
* [Spamhaus website](http://www.spamhaus.org)

    * [Spamhaus DNSBL Usage Terms](https://www.spamhaus.org/organization/dnsblusage/)
