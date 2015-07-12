# LDAP: User mail forwarding.

## Set mail forwarding with iRedAdmin-Pro

With iRedAdmin-Pro, you can simply add mail forwarding addresses in user
profile page, under tab `Forwarding`.

Screenshot:

![](../images/iredadmin/user_profile_mail_forwarding.png)

## Set mail forwarding with phpLDAPadmin

To forward emails to other email addresses, you can add value in LDAP attribute
`mailForwardingAddress` of user object.

For example, if you want to forward all emails sent to `user@domain.ltd` to
two addresses: `forward@domain.ltd`, `user@gmail.com`. Steps:

1. Login to phpLDAPadmin (https://[your_server]/phpldapadmin ) as LDAP root dn
`cn=Manager,dc=xx,dc=xx` or 'cn=vmailadmin,dc=xx,dc=xx'.

1. Find the LDAP object of email account which you want to forward emails in
left panel of phpLDAPadmin, click the ldap object, phpLDAPadmin will show you
detailed LDAP attributes/values in right panel.

1. Add a new LDAP attribute `mailForwardingAddress` to this mail account, set
value to first forwarding address `forward@domain.ltd`.

1. Repeat step #3, add another email address: `user@gmail.com`.

1. Save your changes.

Now all emails sent to `user@domain.ltd` will be forwarded to both
`forward@domain.ltd` and `user@gmail.com`.

If you want to save a copy of forwarded email, please add `user@domain.ltd` as
additional value of LDAP attribute `mailForwardingAddress`.

