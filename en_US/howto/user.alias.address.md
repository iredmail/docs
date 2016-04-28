# Per-user alias address

[TOC]

Since iRedMail-0.9.3, we have per-user alias address support, that means mail
user `john.smith@domain.com` can have additional email addresses like
`john@domain.com`, `js@domain.com` and more, all emails sent to these addresses
will be delivered to same mailbox (`john.smith@domain.com`). With per-user
alias address support, you don't need to create separated mail alias accounts
anymore.

## Manage per-user alias addresses with iRedAdmin-Pro

You can manage per-user alias addresses with iRedAdmin-Pro in user profile
page, under tab "Aliases". Screenshot attached below.

## SQL backend: Manage per-user alias addresses with SQL command line

Add additional email addresses `sales@domain.com`, `bill@domain.com` for
existing user `john@domain.com`:

```
sql> USE vmail;

sql> INSERT INTO alias (address, goto, alias_to, is_alias, domain)
                VALUES ('sales@domain.com', 'john@domain.com', 'john@domain.com', 1, 'domain.com');

sql> INSERT INTO alias (address, goto, alias_to, is_alias, domain)
                VALUES ('bill@domain.com', 'john@domain.com', 'john@domain.com', 1, 'domain.com');
```

* Account `sales@domain.com` and `bill@domain.com` are NOT existing mail user accounts.
* Values of column `alias.goto` and `alias.alias_to` must be the same -- email address of the existing mail user.
* In above sample, `bill@domain.com` could be an email address which belongs to your alias domain.
* You're free to add as many additional email addresses as you want.

## LDAP backend: Manage per-user alias addresses

For LDAP backend, per-user alias addresses are stored in LDAP attribute
`shadowAddress` of user object, and attribute/value pair
`enabledService=shadowaddress` is required. For example:

```
dn: mail=john@domain.com,ou=Users,domainName=domain.com,o=domains,dc=xxx,dc=xxx
enabledService: shadowaddress
shadowAddress: sales@domain.com
shadowAddress: bill@domain.com
...
```

## Screenshot of iRedAdmin-Pro

![](../images/iredadmin/user_profile_aliases.png){:width="1024px"}
