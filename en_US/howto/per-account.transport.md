# Per-domain or per-user transport (relay)

[TOC]

Transport mentioned in this tutorial is used to deliver received email to
local mailbox.

## Manage relay manually

With OpenLDAP backend, per-domain transport is set in domain account with
attribute `mtaTransport`, per-user transport is set in user account with
the same attribute. For example:

```
mtaTransport: dovecot
```

With SQL backends, per-domain transport is set in SQL table `vmail.domain`,
column `transport`. For example:

```
sql> USE vmail;

-- Check current transport settings
sql> SELECT domain,transport from domain LIMIT 10;

-- Update transport setting for domain 'my_domain.com'
sql> UPDATE domain SET transport='[new_transport_here]' WHERE domain='my_domain.com';
```

Per-user transport is set in table `vmail.mailbox`, column `transport`.

Per-user transport has higher priority. If no per-user transport is set
for your mail user, per-domain transport will be used.

## Manage relay with iRedAdmin-Pro

With iRedAdmin-Pro, you can easily manage per-domain or per-user transport in
account profile page. Screenshots attached.

* Per-domain transport/relay:

![](../images/iredadmin/domain_profile_relay.png)

* Per-user transport/relay:

![](../images/iredadmin/user_profile_relay.png)
