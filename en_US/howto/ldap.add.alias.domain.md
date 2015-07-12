# LDAP: Add an alias domain

## What an alias domain is used for?

Let's say you have a mail domain `example.com` hosted on your iRedMail server,
if you add domain name `domain.ltd` as an alias domain of `example.com`, all
emails sent to `username@domain.ltd` will be delivered to user
`username@example.com`'s mailbox.

## Add alias domain with iRedAdmin-Pro

With iRedAdmin-Pro, you can simply add alias domain name in domain profile page,
under tab `Aliases`.

Screenshot:

![](../images/iredadmin/domain_profile_alias.png)

## How to add an alias domain with phpLDAPadmin:

* Login to phpLDAPadmin (`https://[your_server]/phpldapadmin`) as LDAP root dn
(`cn=Manager,dc=xx,dc=xx`)

* Find the LDAP object of your mail domain which you want to add alias
domain in left panel of phpLDAPadmin, click the ldap object, phpLDAPadmin will
show detailed LDAP attributes/values of this domain in right panel.

* Add a new LDAP attribute `domainAliasName` to this domain account, set value
to the alias domain (e.g. `domain.com`). Save your change.

Now you should add additional mail address for all mail users, lists, aliases.
For example, if you have mail user `user@example.com`, you should add additional
email address `user@domain.ltd` for this user. Steps:

* Find the LDAP object of mail account which you want to add additional email
address in left panel of phpLDAPadmin, for example, user `user@example.com`,
click the ldap object, phpLDAPadmin will show detailed LDAP attributes/values
in right panel.

* Add a new LDAP attribute `shadowAddress` to this mail account, set value to
`user@domain.ltd`. __WARNING__: You must user the same username part as
original email address.

* Save your change.

If you have several mail accounts (mail users, lists, aliases), you have to
add additional email address for them all.
