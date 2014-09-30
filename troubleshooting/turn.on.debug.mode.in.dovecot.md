# Turn on debug mode in Dovecot

To turn on debug mode in Dovecot, please update Dovecot config file 
`/etc/dovecot/dovecot.conf` (Linux/OpenBSD) or
`/usr/local/etc/dovecot/dovecot.conf` (FreeBSD), set `mail_debug` to `yes`:

```
mail_debug = yes
```

Restart Dovecot service.

Dovecot is configured to log into 3 log files:

* `/var/log/dovecot.log`: main log file.
* `/var/log/dovecot-sieve.log`: sieve related log.
* `/var/log/dovecot-lmtp.log`: lmtp related log. __NOTE__: old iRedMail release
  doesn't have this file.

If you need authentication and password related debug message, turn on related
settings and restart dovecot service.

```
auth_verbose = yes
auth_debug = yes
auth_debug_passwords = yes
auth_verbose_passwords = yes
```
