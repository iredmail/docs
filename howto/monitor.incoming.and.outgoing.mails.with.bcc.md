# Monitor incoming and outgoing mails with BCC

[TOC]

This tutorial describes how to configure your iRedMail server
to monitor incoming and outgoing mails with BCC, via iRedAdmin-Pro or other
tools.

__Important note__: the destination email address used to store emails
must exist. In this tutorial, they're `outbound@example.com` and
`inboud@example.com`.

## Manage BCC settings with iRedAdmin-Pro

With iRedAdmin-Pro, you can configure BCC easily.

* For per-domain BCC settings, please go to domain profile page, then you can
manage BCC settings under tab `BCC`.
* For per-user BCC settings, please go to user profile page, then you can
manage BCC settings under tab `BCC`.

## SQL: Manage BCC settings with SQL command line tools

We take MySQL backend for example, but the SQL commands should work with
PostgreSQL too.

* To add per-domain bcc settings for domain `mydomain.com`, you can add
  below records in SQL database `vmail`:

```sql
-- BCC outgoing emails to 'outbound@example.com'
mysql> INSERT INTO sender_bcc_domain (domain, bcc_address, active, created)
       VALUES ('mydomain.com', 'outbound@example.com', 1, NOW());

-- BCC incoming emails to 'inbound@example.com'
mysql> INSERT INTO recipient_bcc_domain (domain, bcc_address, active, created)
       VALUES ('mydomain.com', 'inbound@example.com', 1, NOW());
```

* To add per-user bcc settings for user `user@mydomain.com`, you can add
  below records in SQL database `vmail`:

```sql
-- BCC outgoing emails to 'outbound@example.com'
mysql> INSERT INTO sender_bcc_user (username, bcc_address, domain, active, created)
       VALUES ('user@mydomain.com', 'outbound@example.com', 'mydomain.com', 1, NOW());

-- BCC incoming emails to 'inbound@example.com'
mysql> INSERT INTO recipient_bcc_user (username, bcc_address, domain, active, created)
       VALUES ('user@mydomain.com', 'inbound@example.com', 'mydomain.com', 1, NOW());
```

## LDAP: Manage BCC settings with phpLDAPadmin or other LDAP client tools

* For per-domain BCC settings, you can add below LDAP attribute/value pairs
for domain object:

```
# per-domain sender bcc
enabledService=senderbcc
domainSenderBccAddress=outbound@example.com

# per-domain recipient bcc
enabledService=recipientbcc
domainRecipientBccAddress=inbound@example.com
```

* For per-user BCC settings, you can add below LDAP attribute/value pairs
for user object:

```
# per-domain sender bcc
enabledService=senderbcc
userSenderBccAddress=outbound@example.com

# per-domain recipient bcc
enabledService=recipientbcc
userRecipientBccAddress=inbound@example.com
```

## Screenshot of iRedAdmin-Pro

Per-domain bcc settings:

![](../images/iredadmin/domain_profile_bcc.png)

Per-user bcc settings:

![](../images/iredadmin/user_profile_bcc.png)
