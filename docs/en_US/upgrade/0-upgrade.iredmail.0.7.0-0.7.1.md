# Upgrade iRedMail from 0.7.0 to 0.7.1

[TOC]

## ChangeLog

> We provide remote upgrade service, check [the price](../support.html) and [contact us](../contact.html).

* 2011-08-01 readability and hints in config-files
* 2011-05-04 Remove MySQL backend special changes. Not required.
* 2011-05-01 Initial version.

## OpenLDAP backend special

### Support alias domain in mail alias and catch-all account

* Edit both `/etc/postfix/ldap/catchall_maps.cf` and
  `/etc/postfix/ldap/virtual_alias_maps.cf`, remove `domainName=%d` in
  `search_base`:

```
# Part of file: /etc/postfix/ldap/catchall_maps.cf, /etc/postfix/ldap/virtual_alias_maps.cf

# OLD SETTING
search_base     = domainName=%d,o=domains,dc=XXX

# NEW SETTING
search_base     = o=domains,dc=XXX
```

* Restart postfix service to make it work.
