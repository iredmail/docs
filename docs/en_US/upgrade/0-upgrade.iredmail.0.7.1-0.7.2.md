# Upgrade iRedMail from 0.7.1 to 0.7.2

[TOC]

> We provide remote upgrade service, check [the price](../support.html) and [contact us](../contact.html).

## General (All backends should apply these upgrade steps)

### Update Fail2ban filter

Note: This step is applicable to Linux. We don't have Fail2ban running on FreeBSD.

* Edit `/etc/fail2ban/filter.d/postfix.iredmail.conf`, change line `failregex =`:

```
# Part of file: /etc/fail2ban/filter.d/postfix.iredmail.conf

# Original line:
#failregex = \[<HOST>\]: SASL PLAIN authentication failed

# Modified
failregex = \[<HOST>\]: SASL (PLAIN|LOGIN) authentication failed
```

## MySQL backend special

### Add alias domain support in postfix

Update MySQL query in postfix setting `virtual_mailbox_domains` to query alias
domains.

```
# Part of file: /etc/postfix/mysql/virtual_mailbox_domains.cf

# Original line:
#query       = SELECT domain FROM domain WHERE domain='%s' AND backupmx=0 AND active=1

# Modified:
query       = SELECT domain FROM domain WHERE domain='%s' AND backupmx=0 AND active=1 UNION SELECT alias_domain.alias_domain FROM alias_domain,domain WHERE alias_domain.alias_domain='%s' AND alias_domain.active=1 AND alias_domain.target_domain=domain.domain AND domain.active=1 AND domain.backupmx=0
```
