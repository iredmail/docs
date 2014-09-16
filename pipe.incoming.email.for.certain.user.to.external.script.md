<http://iredmail.org/wiki/index.php?title=IRedMail/FAQ/Pipe.Incoming.Email.For.Certain.User.To.External.Script>
#How to pipe incoming email for certain user to external script 
##Summary

This tutorial explains how to pipe incoming email for certain user to external script.

##Configure Postfix to use your external script as transport

Update file /etc/postfix/master.cf to use your external script as Postfix transport. Add below line at the bottom of file /etc/postfix/master.cf:

<pre>
external-pipe         unix    -       n               n               -               -       pipe
    flags= user=vmail:vmail argv=/path/to/your/external/script.sh
</pre>

__Note__:

* You can use some macros to replace with corresponding information from the Postfix queue manager delivery request. Refer to Postfix manual page for more detail: http://www.postfix.org/pipe.8.html For example:
<pre>
external-pipe         unix    -       n               n               -               -       pipe
    flags=DRhu user=vmail:vmail argv=/path/to/your/external/script.sh -f ${sender} -d ${user}@${domain} -m ${extension}
</pre>


* that the 2nd line needs to be right under the first and must start with whitespace, and the first line cannot start with whitespace or postfix will fail with 'unexpected command-line argument' errors. Also make sure the user= line is pointing to a valid user with permissions to execute the script. This user must not be the postfix or root user or the pipe will fail.

Now restart Postfix service to make this new transport available:
<pre>
# /etc/init.d/postfix restart
</pre>

##Update per-user transport to use this new transport

We need to update per-user transport setting, so that all emails delivered to this user will be piped to this new transport - your script.

* If you have iRedAdmin-Pro-LDAP installed, please go to user profile page, under tab __Advanced__, set __Relay/Transport setting__ to 'external-pipe' (without quotes). Screenshot for your reference: http://screenshots.iredmail.googlecode.com/hg/iredadmin/user_profile_relay.png
* If you have iRedAdmin-Pro-MySQL or iRedAdmin-Pro-PGSQL installed, please go to user profile page, under tab __Relay__, set __Relay/Transport setting__ to 'external-pipe' (without quotes).
* If you don't have iRedAdmin-Pro installed, you have to manually update LDAP/MySQL/PgSQL database to use this new transport.
	*  For OpenLDAP backend, please login to phpLDAPadmin, please add new attribute __mtaTransport__ for your user, set its value to 'external-pipe'.
	* For MySQL/PostgreSQL backend, please execute below command with SQL command line tool (Replace 'user@domain.ltd' by the real email address):
<pre>
sql> USE vmail;
sql> UPDATE mailbox SET transport='external-pipe' WHERE username='user@domain.ltd';
</pre>

That's all.
