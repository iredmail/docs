# LDAP: Add a mail alias account

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

## Add mail alias with iRedAdmin-Pro

With iRedAdmin-Pro, please click menu in main navigation bar: `Add -> Mail Alias'.
Screenshot:

![](./images/iredadmin/alias_create.png)

## Add mail alias with phpLDAPadmin

* Log into phpLDAPadmin as LDAP root dn `cn=Manager` or `cn=vmailadmin`.
* Expand LDAP tree in left panel, click `Create new entry here` under
  `ou=Aliases` of your domain, and select `Default` in right panel.
* Select object class `mailAlias` in right panel.
* Input required fields of mail alias account.

__WARNING__: Attribute `enabledService` requires two values: `mail`, `deliver`.

* Confirm to create.
* Add missing value for attribute `enabledService`:  `mail`, `deliver`.
* Add new attribute `accountStatus` with value `active`. This is required.
* Add alias members (full email address) in attribute `mailForwardingAddress`.
  You can add as many members as you want.

Full LDIF data of a sample mail alias account:

```
dn: mail=myalias@mydomain.com,ou=Aliases,domainName=mydomain.com,o=domains,dc=iredmail,dc=org
objectClass: mailAlias
accountStatus: active
cn: Test Name
enabledService: mail
enabledService: deliver
mail: myalias@mydomain.com
mailForwardingAddress: user1@mydomain.com
mailForwardingAddress: someone@gmail.com
mailForwardingAddress: someone@hotmail.com
```
