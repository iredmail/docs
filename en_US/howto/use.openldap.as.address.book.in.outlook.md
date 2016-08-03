# Use OpenLDAP as address book in Microsoft Outlook

Tested with Outlook 2007:

* on account settings choose address book tab
* click `New`
* choose `Internet directory service (LDAP)`
* Input the server name or IP address.
* Check the box `This server requires me to logon`
* Input the full LDAP dn of your mail account as login username. For example: `mail=www@testserver.com,ou=Users,domainName=testserver.com,o=domains,dc=testserver,dc=com`, dont forget to input the correct user password.
* Click `More Settings`
* Leave by default
* Click `Search`
* Choose `Custom` and input the LDAP dn or your mail domain: `ou=Users,domainName=testserver.com,o=domains,dc=testserver,dc=com`
* Done.

Please make sure network port `389` (OpenLDAP service) is open to external
network on your iRedMail server, it's blocked in iRedMail by default..
