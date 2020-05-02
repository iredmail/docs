# Allow some user to send email without smtp authentication

[TOC]

!!! attention

    This tutorial applies to iRedMail-1.0 and later releases. If you're running
    an iRedMail-0.9.9 or earlier release, please follow
    [this tutorial](./allow.user.to.send.email.without.authentication.html) instead.

## Postfix

Open file `/etc/postfix/sender_access.pcre` (Linux/OpenBSD) or
`/usr/local/etc/postfix/sender_access.pcre` (FreeBSD), append the user's email
address which you're going to allow to send email without smtp
authentication. We use email address `user@example.com` for example here.

```
/^user@example\.com$/ OK
```

It's ok to use IP address instead like below if you want to allow all emails
sent from this IP address:

```
/^192\.168\.1\.1$/ OK
/^192\.168\.2\./   OK
/^172\.16\./       OK
```

!!! attention

    * File `sender_access.pcre` is in pcre format, check Postfix manual page
      [PCRE_TABLE(5)](http://www.postfix.org/pcre_table.5.html) for more details.
    * For more allowed sender or IP address/network format, please check
      Postfix manual page: [access(5)](http://www.postfix.org/access.5.html).

Now restart or reload postfix to make it work:

```
postfix reload
```

## iRedAPD

iRedAPD plugin `reject_sender_login_mismatch` checks forged sender address.
If sender domain is hosted on your server, but email was sent without smtp
auth, it's considered as a forged email, and iRedAPD rejects this email
(with rejection message: `SMTP AUTH is required for users under this sender
domain`).

* To allow sending email without smtp authentication for user
  `user@example.com`, please add parameter `ALLOWED_FORGED_SENDERS` in
  iRedAPD config file `/opt/iredapd/settings.py` like below. If this parameter
  already exists, please append the user email address in the list.

    You can find default value and detailed comment about this parameter
    in file `/opt/iredapd/libs/default_settings.py`.

```
ALLOWED_FORGED_SENDERS = ['user@example.com']
```

* To bypass sender IP address or network, for example, `192.168.0.1` and
  `192.168.1.0/24`, please add setting in `/opt/iredapd/settings.py` like below:

```
MYNETWORKS = ['192.168.0.1', '192.168.1.0/24']
```

Restarting iRedAPD service is required if you updated `/opt/iredapd/settings.py`.
