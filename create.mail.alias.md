<http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/SQL/Create.Mail.Alias>
# How to create an mail alias account with SQL command line
To create an mail alias account, you can simply insert a SQL record in table `vmail.alias`. For example:

<pre>
sql> USE vmail;
sql> INSERT INTO alias (address, goto, domain) VALUES ('original@example.com', 'user1@example.com,user2@example.com,user1@test.com', 'example.com');
</pre>

__NOTES__:

* Please always use lower cases for email addresses.
* Please separated multiple destination addresses by comma.
* If destination address is a user under domain which is hosted on localhost, it must exist. Otherwise emails sent to alias account will be bounced after expanded to destination addresses.
