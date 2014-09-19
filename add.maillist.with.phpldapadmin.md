<http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/LDAP/Add.Maillist.with.phpLDAPadmin>
# Howto add mail list account with phpLDAPadmin
* Log into your phpLDAPadmin. The default URL is http__S__://your_server.com/phpldapadmin/
* Expand LDAP tree in left panel, find `ou=Groups` under your domain dn.
* Click `ou=Groups` in left panel, then click `Create a child entry` in right panel. [Screenshot](http://screenshots.iredmail.googlecode.com/hg/iredmail/phpldapadmin/create_maillist_ou_groups.png)
* Choose `mailList` in `ObjectClasses` list, then click `Proceed`.
* Select `mail` as RDN, fill necessary values of attributes:

<pre>
dn: mail=demolist@demo.iredmail.org,ou=Groups,domainName=demo.iredmail.org,o=domains,dc=iredmail,dc=org
accountStatus: active
cn: demolist
enabledService: mail
enabledService: deliver
enabledService: displayedInGlobalAddressBook
mail: demolist@demo.iredmail.org
objectClass: mailList
</pre>

Now switch to `ou=Users` under you domain LDAP dn in left panel.

* Expand `ou=Users` in left panel.
* Find user account which you want to assign to new mail list we created above.
* Click user account in left panel.
* If attribute `memberOfGroup` exists in right panel:
	* click `Add value` under it and fill mail address of our new mail list. For example: `demolist@demo.iredmail.org`
	* Click `Update Object` to save settings.
* If attribute `memberOfGroup` doesn't exist in right panel:
	* Click `Add new attribute` in right panel
	* Choose `memberOfGroup` in drop-down list.
	* Fill mail address of our new mail list.
	* Click `Update Object` to save settings.

You can add as many `memberOfGroup=xxx` as you want, which means this user is assigned to many mail lists.

Here's sample to add external users as mail list members:
<pre>
dn: memberOfGroup=demolist@demo.iredmail.org,ou=Externals,domainName=demo.iredmail.org,o=domains,dc=iredmail,dc=org
accountstatus: active
enabledservice: mail
enabledservice: deliver
mail: user01@external.com
mail: user02@external.com
memberofgroup: demolist@demo.iredmail.org
objectclass: mailExternalUser
</pre>

__IMPORTANT NOTE__: If you don't have any mail list member, Postfix will report error like below:
<pre>
Aug  1 15:45:42 mail postfix/smtpd[6024]: NOQUEUE: reject: RCPT from unknown[1.1.1.1]: 550 5.1.1
<it@domain1.ru>: Recipient address rejected: User unknown in virtual mailbox table; from=<test@domain1.ru>
 to=<it@domain1.ru> proto=ESMTP helo=<[2.2.2.2]>
</pre>

__Note:__ You can restrict who can send email to this mailing list by adding LDAP attribute `accessPolicy`. For example:
<pre>
dn: mail=demolist@demo.iredmail.org,ou=Groups,domainName=demo.iredmail.org,o=domains,dc=iredmail,dc=org
accesspolicy: domain
</pre>
Available access policies are listed here (public, domain, subdomain, membersOnly, moderatorsOnly, memebersAndModeratorsOnly): <http://www.iredmail.org/wiki/index.php?title=Install/iRedAPD/OpenLDAP#Available_access_policies>
