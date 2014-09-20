<http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/LDAP/Add.Alias.Account.with.phpLDAPadmin>
# Howto add alias account with phpLDAPadmin
* Log into phpLDAPadmin as `cn=Manager` or `cn=vmailadmin`:  
![](http://screenshots.iredmail.googlecode.com/hg/phpldapadmin/login.png)

* Expand LDAP tree in left panel, click `Create new entry here` under `ou=Aliases` of your domain, and select `Default` in right panel:  
![](http://screenshots.iredmail.googlecode.com/hg/phpldapadmin/create_alias_1.png)

* Select object class `mailAlias` in right panel:  
![](http://screenshots.iredmail.googlecode.com/hg/phpldapadmin/create_alias_2.png)

* Input required fields of alias account:  
![](http://screenshots.iredmail.googlecode.com/hg/phpldapadmin/create_alias_3.png)

	* __WARNING__: Attribute `enabledService` requires two values: `mail`, `deliver`.

* Confirm to create:  
![](http://screenshots.iredmail.googlecode.com/hg/phpldapadmin/create_alias_4.png)

* Add missing value of attribute `enabledService`, and you can add as many destination addresses as you want here (value of attribute `mailForwardingAddress`):  
![](http://screenshots.iredmail.googlecode.com/hg/phpldapadmin/create_alias_5.png)

