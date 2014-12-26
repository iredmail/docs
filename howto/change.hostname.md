# Change server hostname

If you want to change server hostname, please replace old hostname in below
files:

* Update Postfix config file `/etc/postfix/main.cf`.
* Amavisd config file `/etc/amavisd/amavisd.conf` or `/etc/amavis/conf.d/50-user` (Debian/Ubuntu).
* `/etc/hosts`
* `/var/spool/postfix/etc/hosts`
* `/usr/local/bin/dovecot-quota-warning.sh`, required only if you're running
  iRedMail-0.8.7 or earlier releases.

* Re-generate ssl cert and key with script `tools/generate_ssl_keys.sh` shipped
  in iRedMail.

