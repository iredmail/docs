<http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/LDAP/Monitor.Incoming.and.Outgoing.Mails.with.BCC>
# Monitor incoming and outgoing mails with BCC

[TOC]

This tutorial describes how to configure your iRedMail server (OpenLDAP backend) to monitor incoming and outgoing mails with BCC, via iRedAdmin-Pro or phpLDAPadmin.

# Configure BCC with iRedAdmin-Pro

With iRedAdmin-Pro, you can configure BCC easily:
## Per-domain BCC settings

Go to domain profile page, then you can enable sender bcc or recipient bcc in tab `BCC`.

* Screenshot: <http://screenshots.iredmail.googlecode.com/hg/iredadmin/domain_profile_bcc.png>

## Per-user BCC settings

Go to user profile page, then you can enable sender bcc or recipient bcc in tab 'Advanced'.

* Screenshot: <http://screenshots.iredmail.googlecode.com/hg/iredadmin/user_profile_bcc.png>

# Configure BCC with phpLDAPadmin

## Per-domain BCC settings

* Login to phpLDAPadmin first.
	* it's accessible via URL http__S__://your_server.com/phpldapadmin/
	* You can find root dn (cn=Manager,dc=xx,dc=xx) or `cn=vmailadmin,dc=xx,dc=xx` in root directory of iRedMail installation directory, e.g. `/root/iRedMail-0.7.2/iRedMail.tips`.

* Expand LDAP tree in left panel, find the domain you want to configure BCC settings. e.g. domainName=example.com.
	* phpLDAPadmin will ask you __Select a template to edit the entry__ in right panel, just select __Default__.

* phpLDAPadmin will show you all currently assigned LDAP attributes and values in right panel, now click link `Add new attribute` in top-right panel to add BCC related attributes:
	* __domainSenderBccAddress__: Used to store email address for sender bcc, all outgoing mails will be BCCed to this email address.
		* __WARNING__: Multiple email addresses is __NOT__ supported.
	* __domainRecipientBccAddress__: Used to store email address for recipient bcc, all incoming mails will be BCCed to this email address.
		* __WARNING__: Multiple email addresses is __NOT__ supported.

* Make sure you have __senderbcc__ and/or __recipientbcc__ as value of attribute __enabledService__, otherwise BCC won't work at all.

## Per-user BCC settings

It's same as per-domain BCC settings. Below are steps:

* Login to phpLDAPadmin first.
	* it's accessible via URL http__S__://your_server.com/phpldapadmin/
	* You can find root dn (cn=Manager,dc=xx,dc=xx) or `cn=vmailadmin,dc=xx,dc=xx` in root directory of iRedMail installation directory, e.g. `/root/iRedMail-0.7.2/iRedMail.tips`.

* Expand LDAP tree in left panel, find the user you want to configure BCC settings. e.g. `mail=user@example.com`.
	* phpLDAPadmin will ask you __Select a template to edit the entry__ in right panel, just select __Default__.

* phpLDAPadmin will show you all currently assigned LDAP attributes and values in right panel, now click link `Add new attribute` in top-right panel to add BCC related attributes:
	* __userSenderBccAddress__: Used to store email address for sender bcc, all outgoing mails will be BCCed to this email address.
		* __WARNING__: Multiple email addresses is __NOT__ supported.
	* __userRecipientBccAddress__: Used to store email address for recipient bcc, all incoming mails will be BCCed to this email address.
		* __WARNING__: Multiple email addresses is __NOT__ supported.

* Make sure you have __senderbcc__ and/or __recipientbcc__ as value of attribute __enabledService__, otherwise BCC won't work at all.
