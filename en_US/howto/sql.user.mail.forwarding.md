# SQL: User mail forwarding

[TOC]

!!! attention

    * This document is applicable to iRedMail-0.9.7 and later releases.
    * Here's [doc for iRedMail-0.9.6 and earlier releases](./sql.user.mail.forwarding-20170701.html).

## Set mail forwarding with iRedAdmin-Pro

With iRedAdmin-Pro, you can manage mail forwarding addresses in user
profile page, under tab `Forwarding`.

Screenshot:

![](./images/iredadmin/user_profile_mail_forwarding.png){: width=1000px }

## Set mail forwarding with SQL command line

Let's say you have an __existing__ mail user `user@domain.com`, and you want to
forward all received emails to another address `forward@example.com`,
to achieve this, you can login to SQL server and update `vmail` database like
below:

```
USE vmail;
INSERT INTO forwardings (address, forwarding,
                         domain, dest_domain,
                         is_forwarding, active)
                 VALUES ('user@domain.com', 'forward@example.com',
                         'domain.com', 'example.com',
                         1, 1);
```

If you want to forward email to multiple addresses, please create more records
like above:

```
USE vmail;

-- Forwarding to address 'forward-2@example.com'
INSERT INTO forwardings (address, forwarding,
                         domain, dest_domain,
                         is_forwarding, active)
                 VALUES ('user@domain.com', 'forward-2@example.com',
                         'domain.com', 'example.com',
                         1, 1);

-- Forwarding to address 'forward-3@example.com'
INSERT INTO forwardings (address, forwarding,
                         domain, dest_domain,
                         is_forwarding, active)
                 VALUES ('user@domain.com', 'forward-3@example.com',
                         'domain.com', 'example.com',
                         1, 1);
```

To save a copy of forwarded email in mailbox, please add your own email address
as a forwarding destination like below:

```
INSERT INTO forwardings (address, forwarding,
                         domain, dest_domain,
                         is_forwarding, active)
                 VALUES ('user@domain.com', 'user@domain.com',
                         'domain.com', 'domain.com',
                         1, 1);
```

## Related tutorial

* [LDAP: user mail forwarding](./ldap.user.mail.forwarding.html)
