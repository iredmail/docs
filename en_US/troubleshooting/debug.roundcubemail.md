# Turn on debug mode in Roundcube webmail

Please follow the tutorial to find Roundcube config file
(`config/config.inc.php`) first: 
[Locations of configuration and log files of major components](./file.locations.html#roundcube-webmail)

Then add settings below in `config/config.inc.php`:

```
// system error reporting, sum of: 1 = log; 4 = show
$config['debug_level'] = 4;

// Log SQL queries
$config['sql_debug'] = true;

// Log IMAP conversation
$config['imap_debug'] = true;

// Log LDAP conversation
$config['ldap_debug'] = true;

// Log SMTP conversation
$config['smtp_debug'] = true;
```

No need to restart web service.

Roundcube is configured (by iRedMail) to log to Postfix log file, it's
`/var/log/maillog` or `/var/log/mail.log`.
