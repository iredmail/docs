# Authenticate without domain part in email address

With default settings, client must use full email address as username for
POP3/IMAP/SMTP/webmail login, if you want to login without domain name part in
email address, please follow below steps.

### Dovecot

Open Dovecot config file `/etc/dovecot/dovecot.conf` (Linux/OpenBSD) or
`/usr/local/etc/dovecot/dovecot.conf` (FreeBSD), find parameter
`auth_default_realm`, set the domain name you want to allow user to login
without domain name part in email address. For example:

```
auth_default_realm = mydomain.com
```

Restarting Dovecot is required. After restarted Dovecot, user logins as
`john.smith` will be rewritten to `john.smith@mydomain.com` by Dovecot.
This works for POP3/IMAP/SMTP services.

### [OPTIONAL] Roundcube Webmail

Open Roundcube webmail
[config file `config/main.inc.php`](./file.locations.html#roundcube-webmail),
find parameter `$config['username_domain']`, list your domain name
in this parameter. For example:

```
// Automatically add this domain to user names for login
// Only for IMAP servers that require full e-mail addresses for login
// Specify an array with 'host' => 'domain' values to support multiple hosts
// Supported replacement variables:
// %h - user's IMAP hostname
// %n - hostname ($_SERVER['SERVER_NAME'])
// %t - hostname without the first part
// %d - domain (http hostname $_SERVER['HTTP_HOST'] without the first part)
// %z - IMAP domain (IMAP hostname without the first part)
// For example %n = mail.domain.tld, %t = domain.tld
$config['username_domain'] = 'mydomain.com';
```

Restarting web server (Apache or php-fpm) is recommended.
