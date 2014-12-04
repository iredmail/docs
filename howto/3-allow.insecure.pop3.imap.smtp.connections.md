# Allow insecure POP3/IMAP/SMTP connections without STARTTLS

With default iRedMail setting, all clients are forced to use POP3/IMAP/SMTP
services over STARTTLS for secure connections. If your mail clients
try to access mailbox via protocol POP3/IMAP without TLS support, you will
get error message like below:

```
Plaintext authentication disallowed on non-secure (SSL/TLS) connections
```

## Allow insecure POP3/IMAP connections

If you want to enable POP3/IMAP services without STARTTLS for some reason
(again, not recommended), please update below two parameters in Dovecot config
file `/etc/dovecot/dovecot.conf` and restart Dovecot service:

* on Linux and OpenBSD, it's `/etc/dovecot/dovecot.conf`
* on FreeBSD, it's `/usr/local/etc/dovecot/dovecot.conf`

```
disable_plaintext_auth=no
ssl=yes
```

Again, it's strongly recommended to use only POP3S/IMAPS for better security.

Default and recommended setting configured by iRedMail is:

```
disable_plaintext_auth=yes
ssl=required
```

## Allow insecure SMTP connection

Please comment out below line in Postfix config file `/etc/postfix/main.cf`
and reload or restart Postfix service:

```
smtpd_tls_auth_only=yes
```
