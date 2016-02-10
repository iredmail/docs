# Turn on debug mode in Dovecot

> Don't know where Dovecot config files are? check this tutorial:
> [Locations of configuration and log files of major components](file.locations.html#dovecot).

To turn on debug mode in Dovecot, please update below parameter in Dovecot
config file `dovecot.conf`:

```
mail_debug = yes
```

Restart Dovecot service.

If you need authentication and password related debug message, turn on related
settings and restart dovecot service.

```
auth_verbose = yes
auth_debug = yes
auth_debug_passwords = yes
auth_verbose_passwords = yes
```

If you see many error message (like `dovecot fails, spawning too quickly`) in
Dovecot error log while restarting Dovecot, there might be something wrong
in Dovecot config file. Please try to start it on command line manually, it
will report configuration error if any, fix them and start it again:

```
# dovecot -c /etc/dovecot/dovecot.conf
```
