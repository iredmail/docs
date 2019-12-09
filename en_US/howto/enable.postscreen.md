# Enable postscreen service

[TOC]

__WARNING__: With postscreen service enabled, your users must use port 587 to
send email, port 25 will be used by postscreen service instead of normal smtp
service.

## Enable postscreen service

iRedMail ships a script to enable postscreen. You can enable it with steps below:

1. Download script `enable_postscreen.sh` from [iRedMail source code
   repository](https://github.com/iredmail/iRedMail/blob/1.0/tools/enable_postscreen.sh).
1. Upload this script to your iRedMail server, then execute it to enable
   postscreen service:

```
# bash enable_postscreen.sh
```

That's all.

Important notes:

* It will backup `/etc/postfix/main.cf` and `/etc/postfix/master.cf` first,
  if postscreen doesn't work, you can restore these 2 files.
* It uses several DNSBL servers by default, you'd better open
  `/etc/postfix/main.cf` (Linux/OpenBSD) or `/usr/local/etc/postfix/main.cf`
  (FreeBSD) to check the DNSBL servers it enabled, you're free to remove some
  of them (or add new ones) if you want.

## Disable postscreen service

If your iRedMail already have postscreen service enabled, it's easy to disable
it by following steps below.

* Open file `/etc/postfix/master.cf`, find lines below (usually they're first
  few lines in this file):

```
#smtp      inet  n       -       -       -       -       smtpd
smtp      inet  n       -       -       -       1       postscreen
smtpd     pass  -       -       n       -       -       smtpd
```

* Uncomment first line, comment out the other 2 lines:

```
smtp      inet  n       -       -       -       -       smtpd
#smtp      inet  n       -       -       -       1       postscreen
#smtpd     pass  -       -       n       -       -       smtpd
```

* Now restart or reload Postfix service. That's it. No need to modify any
  setting in `/etc/postfix/main.cf`.

## See Also

If you don't want to use postscreen service, you can [enable DNSBL service](./enable.dnsbl.html)
instead, it helps a lot too, but less effective than postscreen service.

## References

* [Postfix Postscreen Howto](http://www.postfix.org/POSTSCREEN_README.html)
* [Postfix manual page: postscreen(8)](http://www.postfix.org/postscreen.8.html)
