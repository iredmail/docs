<http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/LDAP/Add.Alias.Domain>
# How to add an alias domain name
__What an alias domain is used for?__ Let's say you have a mail domain 'example.com' hosted on your iRedMail server, if you add domain name `domain.ltd` as an alias domain of `example.com`, all emails sent to `username@domain.ltd` will be delivered to user `username@example.com`'s mailbox.

__NOTE__: With iRedAdmin-Pro, you can simply add alias domain name in domain profile page, under tab `Aliases`. Screenshot for your reference: <http://www.iredmail.org/images/iredadmin/domain_profile_alias.png>

How to add an alias domain with phpLDAPadmin:

1. Login to phpLDAPadmin (`https://[your_server]/phpldapadmin`) as LDAP root dn (cn=Manager,dc=xx,dc=xx)
* Find the LDAP object of mail domain `example.com` which you want to add alias domain in left panel of phpLDAPadmin, click the ldap object, phpLDAPadmin will show detailed LDAP attributes/values of this domain in right panel.
* Add a new LDAP attribute `domainAliasName` to this domain account, set value to `domain.ltd`. Save your change.

Now you should add addition mail address for all mail users, lists, aliases. For example, if you have mail user `user@example.com`, you should add addition email address `user@domain.ltd` for this user. Steps:

1. Find the LDAP object of mail account which you want to add addition email address in left panel of phpLDAPadmin, for example, user `user@example.com`, click the ldap object, phpLDAPadmin will show detailed LDAP attributes/values in right panel.
* Add a new LDAP attribute `shadowAddress` to this mail account, set value to `user@domain.ltd`. `WARNING`: You must user the same username part of original email address.
* Save your change.

If you have several mail accounts (mail users, lists, aliases), you have to add addition email address for them all.
