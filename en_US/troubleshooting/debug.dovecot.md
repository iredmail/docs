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

# Set to 'yes' or 'plain', to output plaintext password (NOT RECOMMENDED).
auth_verbose_passwords = plain
```

If Dovecot service cannot start, please run it manually, it will print the
error message on console:

```shell
dovecot -c /etc/dovecot/dovecot.conf
```

## Debug LDAP queries

If you're running iRedMail with OpenLDAP backend, you can increase debug level
for LDAP in `/etc/dovecot/dovecot-ldap.conf` with parameter `debug_level`,
add or update it to `1`, then restart dovecot service:

```
debug_level = 1
```

You can also set it to `-1` which means everything.
