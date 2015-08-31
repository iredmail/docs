# LDAP: Add a mail list account

[TOC]

## Add mail list with iRedAdmin-Pro

With iRedAdmin-Pro, you can easily add mail list account by click menu:
`Add -> Mail List` in main navigation bar.

![](../images/iredadmin/maillist_create.png)

## Add mail list with phpLDAPadmin

* Login to phpLDAPadmin (httpS://[your_server]/phpldapadmin/)
* Expand LDAP tree in left panel, find `ou=Groups` under your domain dn.
* Click `ou=Groups` in left panel, then click `Create a child entry` in right
  panel.
* Choose `mailList` in `ObjectClasses` list, then click `Proceed`.
* Select `mail` as RDN, fill necessary values of attributes:

```
dn: mail=demolist@mydomain.com,ou=Groups,domainName=mydomain.com,o=domains,dc=iredmail,dc=org
accountStatus: active
cn: demolist
enabledService: mail
enabledService: deliver
enabledService: displayedInGlobalAddressBook
mail: demolist@mydomain.com
objectClass: mailList
```

Now switch to `ou=Users` under you domain LDAP dn in left panel.

* Expand `ou=Users` in left panel.
* Find user account which you want to assign to new mail list we created above.
* Click user account in left panel.
* If attribute `memberOfGroup` exists in right panel:
	* click `Add value` under it and fill mail address of our new mail list. For example: `demolist@mydomain.com`
	* Click `Update Object` to save settings.
* If attribute `memberOfGroup` doesn't exist in right panel:
	* Click `Add new attribute` in right panel
	* Choose `memberOfGroup` in drop-down list.
	* Fill mail address of our new mail list.
	* Click `Update Object` to save settings.

You can add as many `memberOfGroup=xxx` as you want, which means this user is assigned to many mail lists.

Here's sample to add external users as mail list members:

```
dn: memberOfGroup=demolist@mydomain.com,ou=Externals,domainName=mydomain.com,o=domains,dc=iredmail,dc=org
accountstatus: active
enabledservice: mail
enabledservice: deliver
mail: user01@external.com
mail: user02@external.com
memberofgroup: demolist@mydomain.com
objectclass: mailExternalUser
```

__IMPORTANT NOTE__: If you don't have any mail list member, Postfix will report error like below:

```
Aug  1 15:45:42 mail postfix/smtpd[6024]: NOQUEUE: reject: RCPT from unknown[1.1.1.1]: 550 5.1.1
<it@domain1.ru>: Recipient address rejected: User unknown in virtual mailbox table; from=<test@domain1.ru>
 to=<it@domain1.ru> proto=ESMTP helo=<[2.2.2.2]>
```

## Mail list access policies

You can restrict who can send email to this mailing list by adding LDAP attribute `accessPolicy`. For example:

```
dn: mail=demolist@mydomain.com,ou=Groups,domainName=mydomain.com,o=domains,dc=iredmail,dc=org
accesspolicy: domain
...
```

Available access policies are:

* `public`: no restrictions.
* `domain`: all users under same domain are allowed to send email to this mail list.
* `subdomain`: all users under same domain and sub-domains are allowed to send email to this mail list.
* `membersOnly`: only members of this mail list are allowd.
* `allowedOnly`: only moderators of this mail list are allowed. Moderators
  are email addresses stored in SQL column `alias.moderators`. With iRedAPD-1.4.5,
  it's ok to use `*@domain.com` as (one of) moderator for all users under
  mail domain 'domain.com'.
* `memebersAndModeratorsOnly`: only members and moderators of this mail list are allowed.

Access restriction is implemented in iRedAPD (a simple Postfix policy server),
iRedMail has it enabled by default. You'd better check its config file
`/opt/iredapd/settings.py` to make sure plugin `sql_alias_access_policy` is
enabled in parameter `plugins = []`.

## See also

* [Create mailing list (mail alias account) for SQL backend (MySQL/MariaDB/PostgreSQL)](./sql.create.mail.alias.html)
