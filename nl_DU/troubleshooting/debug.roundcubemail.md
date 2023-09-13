# Zet debug modus aan in Roundcube webmail

Volg alstublieft eerst de tutorial om het Roundcube configuratiebestand te vinden
(`config/config.inc.php`):
[Locations of configuration and log files of major components](./file.locations.html#roundcube-webmail)

Daarna kan je onderstaande instellingen toevoegen aan `config/config.inc.php`:

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

Je moet de web service niet herstarten.

Roundcube is geconfigureerd (door iRedMail) om te loggen naar het Postfix logbestand, dat is
`/var/log/maillog` of `/var/log/mail.log`.
