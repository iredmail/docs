# Allow user to send email without smtp authentication

[TOC]

!!! attention

    This tutorial is applicable to iRedMail-0.9.9 and earlier releases. If
    you're running a later release, please follow
    [this tutorial](./allow.send.without.smtp.auth.html) instead.

## Postfix

Create a plain text file: `/etc/postfix/sender_access.pcre`, list all
users' email addresses which are allowed to send email without smtp
authentication. We use user email address `user@example.com` for example:

```
/^user@example\.com$/ OK
```

It's ok to use IP address instead like below:

> For more allowed sender format, please check Postfix manual page: [access(5)](http://www.postfix.org/access.5.html).

```
/^192\.168\.1\.1$/ OK
/^192\.168\.2\./   OK
/^172\.16\./       OK
```

Update Postfix config file `/etc/postfix/main.cf` to use this pcre file:

```
smtpd_sender_restrictions =
    check_sender_access pcre:/etc/postfix/sender_access.pcre,
    [...OTHER RESTRICTIONS HERE...]
```

Restart/reload postfix to make it work:

```
# /etc/init.d/postfix restart
```

## iRedAPD

iRedAPD plugin `reject_sender_login_mismatch` will check forged sender address.
If sender domain is hosted on your server, but no smtp auth, it will be
considered as a forged email. In this case, iRedAPD will reject this email
(with rejection message: `Policy rejection not logged in`), so we need to
bypass the sender email address. If email is sent from an internal network
device like printer, fax, we can also its IP address directly.

* To bypass sender email address `user@example.com`, please add setting in
  `/opt/iredapd/settings.py` like below:

```
ALLOWED_FORGED_SENDERS = ['user@example.com']
```

* To bypass sender IP address or network, for example, `192.168.0.1` and
  `192.168.1.0/24`, please add setting in `/opt/iredapd/settings.py` like below:

```
MYNETWORKS = ['192.168.0.1', '192.168.1.0/24']
```

Restarting iRedAPD service is required if you updated `/opt/iredapd/settings.py`.

## References

* Postfix documents:
    * [check_sender_access](http://www.postfix.org/postconf.5.html#check_sender_access)
    * Manual page: [access(5)](http://www.postfix.org/access.5.html)
    * Manual page: [pcre_table(5)](http://www.postfix.org/pcre_table.5.html)
