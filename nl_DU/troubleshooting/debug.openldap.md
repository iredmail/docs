# Zet debug modus aan in OpenLDAP

Bewerk in OpenLDAP configuratiebestand `slapd.conf` parameter `loglevel` naar waarde `256`, herstart OpenLDAP service.

* Op RHEL/CentOS en OpenBSD is het  `/etc/openldap/slapd.conf`
* Op Debian/Ubuntu is het `/etc/ldap/slapd.conf`
* Op FreeBSD is het  `/usr/local/etc/openldap/slapd.conf`

```
loglevel    256
```

OpenLDAP wordt standaard geconfigureerd door iRedMail om te loggen naar  `/var/log/openldap.log`.
