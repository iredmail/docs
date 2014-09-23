# Turn on debug mode in OpenLDAP

In OpenLDAP config file `slapd.conf`, update parameter `loglevel` to value `256`, then restart OpenLDAP service.

* On RHEL/CentOS and OpenBSD, it's `/etc/openldap/slapd.conf`
* On Debian/Ubuntu, it's `/etc/ldap/slapd.conf`
* On FreeBSD, it's `/usr/local/etc/openldap/slapd.conf`

```
loglevel    256
```

OpenLDAP is configured by iRedMail to log into `/var/log/openldap.log` by default.
