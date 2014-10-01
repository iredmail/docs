# Allow insecure POP3/IMAP connection without STARTTLS

With default iRedMail setting, all clients are forced to use IMAPS and POPS (via
STARTTLS) for better security by default. If your mail clients try to access
mailbox via protocol POP3 (port 110) or IMAP (port 143) without TLS support,
you will get error message like below:

```
Plaintext authentication disallowed on non-secure (SSL/TLS) connections
```

If you want to enable POP3/IMAPS without STARTTLS for some reason (again, not
recommended), please update below two parameters in Dovecot config file
`dovecot.conf` and restart Dovecot service:

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
