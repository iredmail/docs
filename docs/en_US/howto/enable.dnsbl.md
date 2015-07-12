# Enable DNSBL service in Postfix to reduce spam

> Important note: if you're running a high-traffic mail server, you'd better
> setup a local DNS server to cache DNS queries, because free RBL services
> like zen.spamhaus.org may improperly reply if your server exceed the 
> DNS query limit. Also, mail service higly relies on DNS queries, so a local
> DNS server speeds up the mail flow.

You can enable additional DNSBL services in Postfix to reduce spam. We use
`zen.spamhaus.org` for example below.

* Open Postfix config file `/etc/postfix/main.cf` or
`/usr/local/etc/postfix/main.cf` (on FreeBSD), append
`reject_rbl_client zen.spamhaus.org` to parameter `smtpd_recipient_restrictions`.
Final setting looks like below:

```
smtpd_recipient_restrictions = ..., reject_unauth_destination, reject_rbl_client zen.spamhaus.org
```

It must be placed after `reject_unauth_destination`. You can add more DNSBL
services after `reject_unauth_destination`, and they will be queried in the
specified order.

* Restart or reload Postfix service is required.

## References

* [Postfix Configuration Parameters: reject_rbl_client](http://www.postfix.org/postconf.5.html#reject_rbl_client)
* [Spamhaus website](http://www.spamhaus.org)

    * [Spamhaus DNSBL Usage Terms](https://www.spamhaus.org/organization/dnsblusage/)
