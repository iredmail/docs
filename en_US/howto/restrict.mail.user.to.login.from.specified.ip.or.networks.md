# Restrict mail user to login from specified IP addresses or networks

[TOC]

Since iRedMail-0.9.1, it's able to restrict mail users to login from specified
IP addresses or networks.

Allowed IP/networks must be separated by comma. If the user tries to log in
elsewhere, the authentication will fail the same way as if a wrong password
was given.

Below sample usage shows how to restrict mail user `user@domaim.com` to login
from only IP address `172.16.244.1` or network `192.168.1.0/24`.

!!! warning

    If webmail is running on same server, and you want to allow user to login
    from webmail, please allow IP `127.0.0.1` too.

## Manage with iRedAdmin-Pro

With iRedAdmin-Pro, please go to user profile page, click tab `Advanced`,
you will find setting `Restrict to login from specified addresses` like below:

![](./images/iredadmin/user_profile_advanced.png){: width=1000px }

## Manage with SQL command line for SQL backends

```
sql> USE vmail;
sql> UPDATE mailbox SET allow_nets='172.16.244.1,192.168.1.0/24' WHERE username='user@domain.com';
```

To remove this restriction (allow to login from anywhere), just set
value of SQL column `mailbox.allow_nets` to NULL. WARNING: It must be NULL,
not empty string.

## Manage with SQL command line for LDAP backends

To allow user `user@domain.com` to login from IP `172.16.244.1` and network
`192.168.1.0/24`, please add new attribute `allowNets` to this user:

```
allowNets: 192.168.1.10,192.168.1.0/24
```

To remove this restriction, just remove attribute `allowNets` for this user.

# References

* This feature is implemented in iRedMail-0.9.1, and mentioned in iRedMail
  [upgrade tutorial for iRedMail-0.9.0](./upgrade.iredmail.0.9.0-0.9.1.html)

* Dovecot document: [AllowNets](http://wiki2.dovecot.org/PasswordDatabase/ExtraFields/AllowNets)
