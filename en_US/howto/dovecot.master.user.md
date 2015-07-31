# Dovecot Master User: Access user's mailbox without owner's password.

iRedMail-0.8.6 and later releases have Dovecot Master User enabled for all
backends (OpenLDAP, MySQL/MariaDB, PostgreSQL) by default, what you need to do
is adding new master user.

iRedMail configures Dovecot to query master user accounts from config file
`/etc/dovecot/dovecot-master-users-password` (or `dovecot-master-users`) by
default, you can modify this file to add or remove master user.

The format is simple:
```
username:password
```

You can generate a password supported by Dovecot first. for example, SSHA512.
Let's generate password hash for our password `my_master_password`:
```
# doveadm pw -s SSHA512
Enter new password: my_master_password
Retype new password: my_master_password
{SSHA512}B0VHomJaMk6aLXOPglgNgJtCUA8JRnOweAwJxRW6NPWSNZ25rG/L6T05DJXH+t8WCQkemBilgkcEi6mq4Kadssivtts=
```

You can now pick up any username you like, for example, `my_master_user@not-exist.com`.
Now add new master user in file
`/etc/dovecot/dovecot-master-users-passwords` like below:

```
my_master_user@not-exist.com:{SSHA512}B0VHomJaMk6aLXOPglgNgJtCU...
```

Now you can access `user@domain.ltd`'s mailbox (via either IMAP or POP3
protocol) as user `user@domain.ltd*my_master_user@not-exist.com` with password
`my_master_password` with Roundcube webmail (it should work with other MUAs).

WARNING:

* Make sure file `dovecot-master-users-password` is owned by Dovecot
  daemon user and group, with file permission `0500`, so that others cannot view
  the file content.

    * on Linux/FreeBSD, Dovecot daemon user/group is `dovecot/dovecot`.
    * on OpenBSD, Dovecot daemon user/group is `_dovecot/_dovecot`.

* If you don't append a (non-exist) mail domain name in Dovecot Master User
  account, Dovecot will use the domain name of your login username. For example,
  if your real user is `myuser@mydomain.com`, when you try to access this user's
  mailbox as Dovecot Master User `myuser@mydomain.com*my_master_user`, it will
  trigger Dovecot to verify user `my_master_user@mydomain.com` which doesn't
  exist on your server, then this login attempt fails.

## Troubleshooting

If it doesn't work for you, please enable debug mode in Dovecot and check
its log file. If you don't understand what the log says, please create a new
topic in our forum and paste related log:

* [Debug Dovecot](./debug.dovecot.html)
* [iRedMail online support forum](http://www.iredmail.org/forum/)

## References

* Dovecot wiki: [Master users/passwords](http://wiki2.dovecot.org/Authentication/MasterUsers)
