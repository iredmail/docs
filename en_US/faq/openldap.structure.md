# OpenLDAP data structure configured by iRedMail

[TOC]

This is a brief introduction of the OpenLDAP data structure configured by
iRedMail. It may help a little if you want to migrate from/to other LDAP server.

## LDAP schema files

iRedMail requires 7 LDAP schema files listed below, 5 are shipped by OpenLDAP,
1 shipped by Amavisd, one by iRedMail:

* core.schema
* corba.schema
* cosine.schema
* inetorgperson.schema
* nis.schema
* amavisd.schema (names are different on different linux/bsd distros)
* iredmail.schema

If you're migrating to other LDAP server, it must include them all, otherwise
you may not be able to add or update mail accounts.

## Data structure

OpenLDAP configured by iRedMail has hard-coded / predictable structure, and
Postfix / Dovecot / iRedAPD /... are configured to query LDAP based on this
structure.

```
dc=xx,dc=xx
    |- o=domains
        |- domainName=example.com
            |- ou=Aliases
            |- ou=Groups
            |- ...
            |- ou=Users
                |- mail=postmaster@example.com
                |- mail=xxx
                |- ...
```

With this predictable structure:

* it's easy to narrow down the query scope, the narrower the scope is, the
  better performance you gain.

* no need to performing a query first to get the full dn of ldap object you're
  going to modify.

If you don't use this structure:

* you have to update Postfix/Dovecot/iRedAPD/... config files to use different
  query scopes and filters.

* The web-based admin panel - iRedAdmin(-Pro) - heavily relies on the
  predictable structure, if you use different structure, you cannot manage mail
  accounts with iRedAdmin(-Pro).
