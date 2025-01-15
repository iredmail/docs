# Upgrade iRedMail from 0.7.1 to 0.7.2

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! note "Remote Upgrade Assistance"

    Check out our [remote upgrade support](https://www.iredmail.org/support.html) if you need assistance.

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
