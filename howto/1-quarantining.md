# Quarantining

[TOC]

## Summary
Since iRedMail-`0.7.0`, quarantining related settings in Amavisd are configured
by iRedMail but disabled by default, you can easily enable quarantining with
this tutorial.

With below steps, Virus/Spam/Banned emails will be quarantined into SQL database.
You can then manage quarantined emails with iRedAdmin-Pro.

## Update Amavisd config file to enable quarantining

Edit Amavisd config file, find below settings and update them. If it doesn't
exist, please add them.

* on Red Hat Enterprise Linux, CentOS, Scientific Linux, it's `/etc/amavisd/amavisd.conf`
or `/etc/amavisd.conf`.
* on Debian/Ubuntu, it's `/etc/amavis/conf.d/50-user`.
* on FreeBSD, it's `/usr/local/etc/amavisd.conf`.
* on OpenBSD, it's `/etc/amavisd.conf`.

```
# File: amavisd.conf

# Change below 3 parameters to D_DISCARD.
$final_virus_destiny = D_DISCARD;
$final_spam_destiny = D_DISCARD;
$final_banned_destiny = D_DISCARD;

# Quarantine SPAM into SQL server.
$spam_quarantine_to = 'spam-quarantine';
$spam_quarantine_method = 'sql:';

# Quarantine VIRUS into SQL server.
$virus_quarantine_to = 'virus-quarantine';
$virus_quarantine_method = 'sql:';

# Quarantine BANNED emails into SQL server.
$banned_quarantine_to = 'banned-quarantine';
$banned_files_quarantine_method = 'sql:';
```

Also, make sure you have below lines configured in same config file:

```perl
# For MySQL
@storage_sql_dsn = (
    ['DBI:mysql:database=amavisd;host=127.0.0.1;port=3306', 'amavisd', 'password'],
);

# For PostgreSQL
#@storage_sql_dsn = (
#    ['DBI:Pg:database=amavisd;host=127.0.0.1;port=5432', 'amavisd', 'password'],
#);
```

Restart amavisd service to make it work.

## Configure iRedAdmin-Pro to manage quarantined mails

Update iRedAdmin-Pro config file, make sure you have correct settings for Amavisd:

* on Red Hat Enterprise Linux, CentOS, Scientific Linux, it's `/var/www/iredadmin/settings.py`.
* on Debian, Ubuntu, it's `/usr/share/apache2/iredadmin/settings.py`.
* on FreeBSD, it's `/usr/local/www/iredadmin/settings.py`.
* on OpenBSD, it's `/var/www/iredadmin/settings.py`.

```python
# File: settings.py

amavisd_db_host = '127.0.0.1'
amavisd_db_port = 3306
amavisd_db_name = 'amavisd'
amavisd_db_user = 'amavisd'
amavisd_db_password = 'password'

# Log basic info of inbound/outbound, no mail body stored.
amavisd_enable_logging = True

# Quarantining management
amavisd_enable_quarantine = True
amavisd_quarantine_port = 9998

# Per-recipient policy lookup
amavisd_enable_policy_lookup = True
```

Restart Apache web server to make it work.

You can now login to iRedAdmin-Pro, and manage quarantined mails via menu
`System -> Quarantined Mails`. Choose action in drop-down menu list to release
or delete them.

Screenshots attached at the bottom.

## Quarantine clean emails

If you want to quarantine clean emails into SQL database for further approval
or whatever reason, please follow below steps:

* Update below parameters in Amavisd config file `amavisd.conf`:

```perl
$clean_quarantine_method = 'sql:';
$clean_quarantine_to = 'clean-quarantine';
```

* Find policy bank `MYUSERS`, append two lines in this policy bank:

```perl
$policy_bank{'MYUSERS'} = {
    ...
    clean_quarantine_method => 'sql:',
    final_destiny_by_ccat => {CC_CLEAN, D_DISCARD},
}
```

* Restart Amavisd service.

Now all clean emails sent by your mail users will be quarantined into SQL
database.

## Screenshots

* View quarantined mails:

![](http://www.iredmail.org/images/iredadmin/system_maillog_quarantined.png)

* Expand quarantined mail to view mail body and headers.

![](http://www.iredmail.org/images/iredadmin/system_maillog_quarantined_expanded.png)
