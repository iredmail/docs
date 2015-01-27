# Change server hostname

To change server hostname, please follow our tutorial in iRedMail installation
guide directly:

* [RHEL/CentOS](./install.iredmail.on.rhel.html#set-a-fully-qualified-domain-name-fqdn-hostname-on-your-server)
* [Debian/Ubuntu](./install.iredmail.on.debian.ubuntu.html#set-a-fully-qualified-domain-name-fqdn-hostname-on-your-server)
* [FreeBSD](./install.iredmail.on.freebsd.html#set-a-fully-qualified-domain-name-fqdn-hostname-on-your-server)
* [OpenBSD](./install.iredmail.on.openbsd.html#set-a-fully-qualified-domain-name-fqdn-hostname-on-your-server)

Also, replace old hostname in below configuration files:

* Update Postfix config file `/etc/postfix/main.cf`.
* Amavisd config file `/etc/amavisd/amavisd.conf` or `/etc/amavis/conf.d/50-user` (Debian/Ubuntu).
* `/etc/hosts`
* `/var/spool/postfix/etc/hosts`
* `/usr/local/bin/dovecot-quota-warning.sh`, required only if you're running
  iRedMail-0.8.7 or earlier releases.

* Re-generate ssl cert and key with script `tools/generate_ssl_keys.sh` shipped
  in iRedMail.

