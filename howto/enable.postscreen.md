# Enable postscreen service

__WARNING__: With postscreen service enabled, your users must use port 587 to
send email, port 25 will be used by postscreen service instead of normal smtp
service.

iRedMail ships a script to enable postscreen. You can enable it with steps below:

* Download script `enable_postscreen.sh` from [iRedMail source code repository](https://bitbucket.org/zhb/iredmail/src/default/iRedMail/tools/?at=default)
* Upload this script to your iRedMail server, then below command to enable
  postscreen:

```
# bash enable_postscreen.sh
```

It uses several DNSBL servers by default, you'd better open
`/etc/postfix/main.cf` (Linux/OpenBSD) or `/usr/local/etc/postfix/main.cf`
(FreeBSD) to check the DNSBL servers it enabled, you're free to remove some
DNSBL servers if you want.

## See Also

If you don't want to use postscreen service, you can [enable DNSBL service](./enable.dnsbl.html)
instead, it helps a lot too, but less effective than postscreen service.

## References

* [Postfix Postscreen Howto](http://www.postfix.org/POSTSCREEN_README.html)
* [Postfix manual page: postscreen(8)](http://www.postfix.org/postscreen.8.html)
