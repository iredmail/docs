# Allow user to send email without smtp authentication

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
