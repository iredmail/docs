# Allow user to send email without smtp authentication

Create a plain text file: `/etc/postfix/accepted_unauth_senders`, list all
users' email addresses which are allowed to send email without smtp
authentication. We use user email address `user@example.com` for example:

```
user@example.com OK
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
