# LDAP: Add per-domain catch-all account

With default setting, iRedMail will reject emails sent to non-existing mail
accounts under hosted mail domains. If you want to accept these emails, you
need a per-domain catch-all account.

With OpenLDAP backend, you can add an catch-all account for mail domain
`example.com` like below:

```
dn: mail=@example.com,ou=Users,domainName=example.com,o=domains,dc=iredmail,dc=org
accountstatus: active
cn: catch-all
mail: @example.com
mailForwardingAddress: user_1@example.com
mailForwardingAddress: user_2@example.com
objectclass: inetOrgPerson
objectclass: mailUser
sn: catch-all
uid: catch-all
```

With above catch-all account, emails sent to non-existing addresses will be
forwarded to both `user_1@example.com` and `user_2@example.com`.

__NOTE__: With iRedAdmin-Pro, you can manage catch-all account in domain
profile directly. Screenshot attached.

![](../images/iredadmin/domain_profile_catchall.png)

## See also

* [Add per-domain catch-all account for MySQL/MariaDB/PostgreSQL backends](./sql.add.catch-all.html)
