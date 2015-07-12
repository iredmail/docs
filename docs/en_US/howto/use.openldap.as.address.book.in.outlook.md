# Use OpenLDAP as address book in Microsoft Outlook

Tested with Outlook 2007:

* on account settings choose address book tabs
* click new
* choose Internet directory service(LDAP)
* insert the servername (for me, i set it to IP of the server)
* checked this " this server requires me to logon"
* Fill the username with --> mail=www@testserver.com,ou=Users,domainName=testserver.com,o=domains,dc=testserver,dc=com, dont forget to insert user passwd
* Click "More Settings"
* Leave by default,
* Click "Search"
* Choose "custom" and insert with --> ou=Users,domainName=testserver.com,o=domains,dc=testserver,dc=com
* Finish

you need make sure network port 389 (OpenLDAP service) is open on your iRedMail
server, otherwise, you need config the iptables.
