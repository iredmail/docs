# Allow user to send email without smtp authentication

## Postfix

Create a plain text file: `/etc/postfix/accepted_unauth_senders`, list all
users' email addresses which are allowed to send email without smtp
authentication. We use user email address `user@example.com` for example:

```
user@example.com OK
```

It's ok to use IP address instead like below:

> For more allowed sender format, please check Postfix manual page: [access(5)](http://www.postfix.org/access.5.html).

```
192.168.1.1 OK
192.168.2   OK
172.16      OK
```

Create hash db file with `postmap` command:

```
# postmap hash:/etc/postfix/accepted_unauth_senders
```

Modify Postfix config file `/etc/postfix/main.cf` to use this text file:

```
smtpd_sender_restrictions = 
    check_sender_access hash:/etc/postfix/accepted_unauth_senders,
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
bypass either sender email address. If email is sent by an internal network
device like printer, fax, we can also its IP address directly.

* To bypass sender email address `user@example.com`, please add setting in
  `/opt/iredapd/settings.py` like below:

```
ALLOWED_FORGED_SENDERS = ['user@example.com']
```

* To bypass sender IP address, for example, `192.168.0.1`, please add setting
  in `/opt/iredapd/settings.py` like below:

```
MYNETWORKS = ['192.168.0.1']
```

Restarting iRedAPD service is required if you updated `/opt/iredapd/settings.py`.
