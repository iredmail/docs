# Turn on debug mode in Cluebringer

To turn on debug mode in Cluebringer, please increase its log level in
Cluebringer config file, set what it should log, and restart Cluebringer
service.

* on RHEL/CentOS, it's `/etc/policyd/cluebringer.conf`.
* on Debian/Ubuntu, it's `/etc/cluebringer/cluebringer.conf`.
* on FreeBSD, it's `/usr/local/etc/cluebringer.conf`.
* on OpenBSD: we don't have Cluebringer installed. We use built-in
  [spamd(8)](http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man8/spamd.8?query=spamd)
  for greylisting, whitelisting and blacklisting.

```
log_level=4
log_detail=modules,tracking,policies
```

Cluebringer is configured to log to `/var/log/cbpolicyd.log` by default, so
please monitor this file to check detailed debug log.
