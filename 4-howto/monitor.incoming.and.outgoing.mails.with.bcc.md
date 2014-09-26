# Monitor incoming and outgoing mails with BCC

[TOC]

This tutorial describes how to configure your iRedMail server (OpenLDAP backend)
to monitor incoming and outgoing mails with BCC, via iRedAdmin-Pro or phpLDAPadmin.

## Manage BCC settings with iRedAdmin-Pro

With iRedAdmin-Pro, you can configure BCC easily.

* For per-domain BCC settings, please go to domain profile page, then you can
manage BCC settings under tab `BCC`.

Screenshot:
![](http://www.iredmail.org/images/iredadmin/domain_profile_bcc.png)

* For per-user BCC settings, please go to user profile page, then you can
manage BCC settings under tab `BCC`.

Screenshot:
![](http://www.iredmail.org/images/iredadmin/user_profile_bcc.png)

## Manager BCC settings with phpLDAPadmin or other LDAP client tools

* For per-domain BCC settings, you can add below LDAP attribute/value pairs
for domain object:

```
# per-domain sender bcc
enabledService=senderbcc
domainSenderBccAddress=user@domain.com

# per-domain recipient bcc
enabledService=recipientbcc
domainRecipientBccAddress=user@domain.com
```

* For per-user BCC settings, you can add below LDAP attribute/value pairs
for user object:

```
# per-domain sender bcc
enabledService=senderbcc
userSenderBccAddress=user@domain.com

# per-domain recipient bcc
enabledService=recipientbcc
userRecipientBccAddress=user@domain.com
```

