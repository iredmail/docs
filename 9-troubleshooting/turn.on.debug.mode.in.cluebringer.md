# Turn on debug mode in Cluebringer

To turn on debug mode in Cluebringer, please increase its log level in
Cluebringer config file, and restart Cluebringer service.

* on RHEL/CentOS, it's `/etc/policyd/cluebringer.conf`.
* on Debian/Ubuntu, it's `/etc/cluebringer/cluebringer.conf`.
* on FreeBSD, it's `/usr/local/etc/cluebringer.conf`.
* on OpenBSD: we don't have Cluebringer installed on Cluebringer.

```
log_level = 4
```

Cluebringer is configured to log to `/var/log/cbpolicyd.log` by default, so
please monitor this file to check detailed debug log.
