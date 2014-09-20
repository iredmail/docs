# Turn on debug mode in Dovecot

To turn on debug mode in Dovecot, please update Dovecot config file 
`/etc/dovecot/dovecot.conf` (Linux/OpenBSD) or
`/usr/local/etc/dovecot/dovecot.conf` (FreeBSD), set `mail_debug` to `yes`:

<pre>
mail_debug = yes
</pre>

Restart Dovecot service.

If you need authentication and password related debug message, turn on related
settings and restart dovecot service.

<pre>
auth_verbose = yes
auth_debug = yes
auth_debug_passwords = yes
auth_verbose_passwords = yes
</pre>
