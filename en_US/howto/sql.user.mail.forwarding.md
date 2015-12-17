# SQL: User mail forwarding

[TOC]

## Set mail forwarding with iRedAdmin-Pro

With iRedAdmin-Pro, you can manage mail forwarding addresses in user
profile page, under tab `Forwarding`.

Screenshot:

![](../images/iredadmin/user_profile_mail_forwarding.png)

## Set mail forwarding with SQL command line

Let's say you have an existing mail user `user@domain.com`, and you want to
forward all received emails to another address `forward@example.com`,
to achieve this, you can login to SQL server and update `vmail` database like
below:

```
sql> USE vmail;
sql> UPDATE alias SET goto='forward@example.com' WHERE address='user@domain.com';
```

If you want to forward email to multiple destinations, please separate
addresses with comma like below:

```
sql> UPDATE alias SET goto='forward_1@example.com,forward_2@example.com,forward_3@example.com' WHERE address='user@domain.com';
```

To save a copy of forwarded email in mailbox, please add your own email address
as a forwarding destination like below:

```
sql> UPDATE alias SET goto='user@domain.com,forward_1@example.com' WHERE address='user@domain.com';
```

## Related tutorial

* [LDAP: user mail forwarding](./ldap.user.mail.forwarding.html)
