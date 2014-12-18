# Turn on debug mode in Dovecot

> Don't know where Amavisd config file is? check this tutorial:
> [Locations of configuration and log files of mojor components](file.locations.html#dovecot).

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
