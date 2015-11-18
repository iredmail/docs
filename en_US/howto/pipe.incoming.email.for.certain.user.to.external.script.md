# Pipe incoming email for certain user to external script 

This tutorial explains how to pipe incoming email for certain user to external script.

## Configure Postfix to use your external script as transport

To pipe incoming emails to external script, you must add your external script
as Postfix transport program. Please add below line at the bottom of Postfix
config file `/etc/postfix/master.cf`:

```
external-pipe   unix    -   n   n   -   -   pipe
    flags=DRhu user=vmail:vmail argv=/path/to/your/external/script.sh
```

__Note__:

* You can use some macros to replace with corresponding information from the
Postfix queue manager delivery request. Refer to Postfix manual page
[pipe(8)](http://www.postfix.org/pipe.8.html) for more details. For example:

```
external-pipe   unix    -   n   n   -   -   pipe
    flags=DRhu user=vmail:vmail argv=/path/to/your/external/script.sh -f ${sender} -d ${user}@${domain} -m ${extension}
```

* the second line needs to be right under the first line and must start with
one (or more) whitespace, and the first line cannot start with whitespace,
otherwise postfix will fail with `unexpected command-line argument` errors.
Also make sure the `user=` line is pointing to a valid user with permissions
to execute the script. This user must not be the postfix or root user, otherwise
or the pipe will fail.

Now restart Postfix service to make this new transport available:

```
# /etc/init.d/postfix restart
```

## Update per-user transport to use this new transport

We need to update per-user transport setting, so that all emails delivered to
this user will be piped to this new transport - your script.

* If you have iRedAdmin-Pro:

    * For iRedAdmin-Pro OpenLDAP edition, please go to user profile page, under
tab `Advanced`, set `Relay/Transport setting` to `external-pipe`. Screenshot:

![](../images/iredadmin/user_profile_relay.png)

    * For iRedAdmin-Pro MySQL or PostgreSQL edition, please go to user profile
      page, under tab `Relay`, set `Relay/Transport setting` to `external-pipe`.

* If you don't have iRedAdmin-Pro, please update LDAP/MySQL/PgSQL database to
use this new transport.

	*  For OpenLDAP backend, please login to phpLDAPadmin, add new attribute
       `mtaTransport` for your user, set its value to `external-pipe`.

	* For MySQL/PostgreSQL backend, please execute below command with SQL
      command line tool (Replace 'user@domain.ltd' by the real email address):

```
sql> USE vmail;
sql> UPDATE mailbox SET transport='external-pipe' WHERE username='user@domain.ltd';
```

That's all.
