# SQL: Add a mail alias account

[TOC]

!!! attention

    * This document is applicable to iRedMail-0.9.7 and later releases.
    * Here's [doc for iRedMail-0.9.6 and earlier releases](./sql.create.mail.alias-20170701.html).

## Create mail alias account with iRedAdmin-Pro

With iRedAdmin-Pro, you can easily add mail list account by click menu:
`Add -> Mail List` (or `Add -> Alias` for SQL backends) in main
navigation bar.

![](../images/iredadmin/maillist_create.png)

## Create mail alias account with SQL command line

To create an mail alias account, you need to add SQL records in 2 sql tables.
for example: create a mail alias account `alias@mydomain.com` and forward emails
to two addresses `someone@gmail.com` and `someone@test.com`:

```mysql
sql> USE vmail;

-- Create mail alias account
sql> INSERT INTO alias (address, domain, active)
                VALUES ('alias@mydomain.com', 'mydomain.com', 1);

-- Forward email to 'someone@gmail.com'
sql> INSERT INTO forwardings (address, forwarding,
                              domain, dest_domain,
                              is_list, active)
                      VALUES ('alias@mydomain.com', 'someone@gmail.com',
                              'mydomain.com', 'gmail.com',
                              1, 1);

-- Forward email to 'someone@test.com'
sql> INSERT INTO forwardings (address, forwarding,
                              domain, dest_domain,
                              is_list, active)
                      VALUES ('alias@mydomain.com', 'someone@test.com',
                              'mydomain.com', 'test.com',
                              1, 1);
```

__NOTES__:

* Please always use lower cases for email addresses.
* If destination address is a mail user under domain hosted on localhost,
  it must exist. Otherwise emails sent to alias account will be bounced after
  expanded to destination addresses.

## Access policy

!!! attention

    Access restriction requires iRedAPD plugin `sql_alias_access_policy`,
    please make sure it's enabled in iRedAPD config file
    `/opt/iredapd/settings.py`.

You can restrict which senders are allowed to send email to this mail alias
account by adding proper policy name in SQL column `alias.accesspolicy`.
For example:

```
sql> UPDATE alias SET accesspolicy='domain' WHERE address='alias@mydomain.com';
```

Available access policies:

Access Policy Name | Comment
--- |---
`public` | no restrictions
`domain` | all users under same domain are allowed to send email to this mail list.
`subdomain` | all users under same domain and all sub-domains are allowed to send email to this mail list.
`membersonly` | only members of this mail list are allowd.
`moderatorsonly` | only moderators of this mail list are allowed.
`membersandmoderatorsonly` | only members and moderators of this mail list are allowed.

### How to assign a moderator

Moderators are email addresses stored in SQL table `alias_moderators`. With
iRedAPD-1.4.5 and later releases, it's ok to use `*@domain.com` as (one of)
moderator for all users under mail domain 'domain.com'.

To assign user `someone@gmail.com` and `someone@outlook.com` as moderator of
mail alias `alias@mydomain.com`:

```
sql> INSERT INTO alias_moderators (address, moderator, domain, dest_domain)
                          VALUES ('alias@mydomain.com', 'someone@gmail.com', 'mydomain.com', 'gmail.com');

sql> INSERT INTO alias_moderators (address, moderator, domain, dest_domain)
                          VALUES ('alias@mydomain.com', 'someone@outlook.com', 'mydomain.com', 'outlook.com');
```

## See also

* [Create mailing list for OpenLDAP backend](./ldap.add.mail.list.html)
