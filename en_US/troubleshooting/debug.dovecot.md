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

If Dovecot service cannot start, please run it manually, it will print the
error message on console:

```shell
dovecot -c /etc/dovecot/dovecot.conf
```
