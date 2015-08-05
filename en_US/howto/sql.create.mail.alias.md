# SQL: Add a mail alias account

[TOC]

## Create mail alias account with iRedAdmin-Pro

With iRedAdmin-Pro, you can easily add mail list account by click menu:
`Add -> Mail List` (or `Add -> Alias` for SQL backends) in main
navigation bar.

![](../images/iredadmin/maillist_create.png)

## Create mail alias account with SQL command line

To create an mail alias account, you can simply insert a SQL record in table
`vmail.alias`. For example:

```mysql
sql> USE vmail;
sql> INSERT INTO alias (address, goto, domain, islist) \
     VALUES ('original@example.com', \
             'user1@example.com,user2@example.com,user1@test.com', \
             'example.com', \
             1);
```

__NOTES__:

* Please always use lower cases for email addresses.
* Multiple destination addresses must be separated by comma.
* If destination address is a mail user under domain hosted on localhost,
  it must exist. Otherwise emails sent to alias account will be bounced after
  expanded to destination addresses.

## Access policy

You can restrict which senders are allowed to send email to this mail alias
account by adding proper policy name in SQL column `alias.accesspolicy`.
For example:

```
sql> UPDATE alias SET accesspolicy='domain' WHERE address='original@example.com';
```

Available access policies are:

* `public`: no restrictions.
* `domain`: all users under same domain are allowed to send email to this mail list.
* `subdomain`: all users under same domain and sub-domains are allowed to send email to this mail list.
* `membersOnly`: only members of this mail list are allowd.
* `moderatorsOnly`: only moderators of this mail list are allowed. Moderators
  are email addresses stored in SQL column `alias.moderators`. With iRedAPD-1.4.5,
  it's ok to use `*@domain.com` as (one of) moderator for all users under
  mail domain 'domain.com'.
* `memebersAndModeratorsOnly`: only members and moderators of this mail list are allowed.

Access restriction is implemented in iRedAPD (a simple Postfix policy server),
iRedMail has it enabled by default. You'd better check its config file
`/opt/iredapd/settings.py` to make sure plugin `sql_alias_access_policy` is
enabled in parameter `plugins = []`.

## See also

* [Create mailing list for OpenLDAP backend](./ldap.add.mail.list.html)
