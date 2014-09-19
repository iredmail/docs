<http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/LDAP/Turn.On.Debug.Mode.In.OpenLDAP>
# Turn on debug mode in OpenLDAP
In `/etc/openldap/slapd.conf` or `/etc/ldap/slapd.conf`, change `loglevel` to 256, then restart OpenLDAP service.
<pre>
loglevel    256
</pre>

In iRedMail, OpenLDAP will log into `/var/log/openldap.log` by default.