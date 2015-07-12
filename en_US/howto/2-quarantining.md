# Quarantining

[TOC]


Since iRedMail-`0.7.0`, quarantining related settings in Amavisd are configured
by iRedMail but disabled by default, you can easily enable quarantining with
this tutorial.

With below steps, Virus/Spam/Banned emails will be quarantined into SQL database.
You can then manage quarantined emails with iRedAdmin-Pro.

## Quarantining spam, virus, banned and bad header messages

Edit Amavisd config file, find below settings and update them. If it doesn't
exist, please add them.

* on Red Hat Enterprise Linux, CentOS, Scientific Linux, it's `/etc/amavisd/amavisd.conf`
or `/etc/amavisd.conf`.
* on Debian/Ubuntu, it's `/etc/amavis/conf.d/50-user`.
* on FreeBSD, it's `/usr/local/etc/amavisd.conf`.
* on OpenBSD, it's `/etc/amavisd.conf`.

```
# Part of file: /etc/amavisd/amavisd.conf

# Change values of below parameters to D_DISCARD.
# Detected spams/virus/banned messages will not be delivered to user's mailbox.
$final_virus_destiny = D_DISCARD;
$final_spam_destiny = D_DISCARD;
$final_banned_destiny = D_DISCARD;
$final_bad_header_destiny = D_DISCARD;

# Quarantine SPAM into SQL server.
$spam_quarantine_to = 'spam-quarantine';
$spam_quarantine_method = 'sql:';

# Quarantine VIRUS into SQL server.
$virus_quarantine_to = 'virus-quarantine';
$virus_quarantine_method = 'sql:';

# Quarantine BANNED message into SQL server.
$banned_quarantine_to = 'banned-quarantine';
$banned_files_quarantine_method = 'sql:';

# Quarantine Bad Header message into SQL server.
$bad_header_quarantine_method = 'sql:';
$bad_header_quarantine_to = 'bad-header-quarantine';
```

Also, make sure you have below lines configured in same config file:

```perl
# For MySQL/MariaDB/OpenLDAP backends
@storage_sql_dsn = (
    ['DBI:mysql:database=amavisd;host=127.0.0.1;port=3306', 'amavisd', 'password'],
);

# For PostgreSQL
#@storage_sql_dsn = (
#    ['DBI:Pg:database=amavisd;host=127.0.0.1;port=5432', 'amavisd', 'password'],
#);
```

Restarting amavisd service is required.

## Configure iRedAdmin-Pro to manage quarantined mails

Update iRedAdmin-Pro config file, make sure you have correct settings for Amavisd:

* on Red Hat Enterprise Linux, CentOS, Scientific Linux, it's `/var/www/iredadmin/settings.py`.
* on Debian, Ubuntu, it's `/opt/www/iredadmin/settings.py` or `/usr/share/apache2/iredadmin/settings.py`.
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

Restarting Apache web server or `uwsgi` service (if you're running Nginx as
web server) is required.

You can now login to iRedAdmin-Pro, and manage quarantined messages via menu
`System -> Quarantined Mails`. Choose action in drop-down menu list to release
or delete them.

Screenshots attached at the bottom.

## Quarantine clean emails

Note: If you just want to quarantine clean emails sent from/to certain local
user, please refer to this document instead:
[Quarantine clean emails sent from/to certain local user](./quarantine.clean.mails.per-user.html)

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

![](../images/iredadmin/system_maillog_quarantined.png)

* Expand quarantined mail to view mail body and headers.

![](../images/iredadmin/system_maillog_quarantined_expanded.png)
