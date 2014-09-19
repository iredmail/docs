<http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/LDAP/Add.Mail.Forwarding.Address>
# How to forward emails to other email addresses
If you want to forward email to other email addresses, you can add value in LDAP attribute 'mailForwardingAddress' of user object.

For example, if you want to forward all emails sent to 'user@domain.ltd' to two addresses: forward@domain.ltd, user@gmail.com. Steps with phpLDAPadmin:

1. Login to phpLDAPadmin (https://[your_server]/phpldapadmin ) as LDAP root dn (cn=Manager,dc=xx,dc=xx)
* Find the LDAP object of email account which you want to forward emails in left panel of phpLDAPadmin, click the ldap object, phpLDAPadmin will show detailed LDAP attributes/values in right panel.
* Add a new LDAP attribute 'mailForwardingAddress' to this mail account, set value to __forward@domain.ltd__.
* Repeat step #3, add another email address as value of 'mailForwardingAddress': user@gmail.com.
* Save your changes. Now all emails sent to 'user@domain.ltd' will be forwarded to both forward@domain.ltd and user@gmail.com.

If you want to save a copy of forwarded email, please add 'user@domain.ltd' as addition value of LDAP attribute 'mailForwardingAddress'.

NOTE: With iRedAdmin-Pro, you can simply add forwarding addresses in user profile page, under tab "Forwarding". Screenshot for your reference: <http://www.iredmail.org/images/iredadmin/user_profile_mail_forwarding.png>