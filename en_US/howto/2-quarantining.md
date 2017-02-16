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

### Notify users about quarantined mails

iRedAdmin-Pro ships script `tools/notify_quarantined_recipients.py` to notify
users which have email quarantined in SQL database.

Default notification email contains basic info of each quarantined email:

* mail subject
* sender
* recipient
* spam level (score)
* mail arrived time

The notification email message is read from (HTML) template file
`tools/notify_quarantined_recipients.html`, if you want to modify it, please
copy it to `tools/notify_quarantined_recipients.html.custom` then modify it.
During upgrading iRedAdmin-Pro, this custom file will be copied to
new iRedAdmin-Pro directory, so you won't lose your customization.

Several parameters are required by this script in iRedAdmin-Pro config file:

```
# SMTP server address, port, username, password used to send notification mail.
NOTIFICATION_SMTP_SERVER = 'localhost'
NOTIFICATION_SMTP_PORT = 587
NOTIFICATION_SMTP_STARTTLS = True
NOTIFICATION_SMTP_USER = 'no-reply@localhost.local'
NOTIFICATION_SMTP_PASSWORD = ''
NOTIFICATION_SMTP_DEBUG_LEVEL = 0

# URL of your iRedAdmin-Pro login page which will be shown in notification
# email, so that user can login to manage quarantined emails.
# Sample: 'https://your_server.com/iredadmin/'
#
# Note: mail domain must have self-service enabled, otherwise normal
#       mail user cannot login to iRedAdmin-Pro for self-service.
NOTIFICATION_URL_SELF_SERVICE = 'https://[your_server]/iredadmin/'

# Subject of notification email. Available placeholders:
#   - %(total)d -- number of quarantined mails in total
NOTIFICATION_QUARANTINE_MAIL_SUBJECT = '[Attention] You have %(total)d emails quarantined and not delivered to mailbox'
```

To notify user periodly, please add a cron job for root user to run
`tools/notify_quarantined_recipients.py`. For example, every 6 hours ('6 hours'
is just an example, the period is totally up to you):

```
1 */6 * * * /usr/bin/python /var/www/iredadmin/tools/notify_quarantined_recipients.py --force-all >/dev/null
```

Don't forget to use the correct path to `notify_quarantined_recipients.py` on your server.

You can also run this script manually to notify users. for example,
on RHEL/CentOS:

```
cd /var/www/iredadmin/tools/
python notify_quarantined_recipients.py --force-all
```

`notify_quarantined_recipients.py` supports few arguments:

Argument | Comment
---|---
`--force-all` | Send notification to all users which have email quarantined
`--force-all-time` |  Notify users for their all quarantined emails instead of just new ones since last notification.
`--notify-backupmx` |  Send notification to all recipients under backup mx domain

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

* Find policy bank `ORIGINATING`, append two lines in this policy bank:

```perl
$policy_bank{'ORIGINATING'} = {
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
