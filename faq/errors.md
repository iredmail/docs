# Errors you may see while maintaining iRedMail server

[TOC]

## Amavisd

### connect to 127.0.0.1[127.0.0.1]:10024: Connection refused

This error means Amavisd service is not running, please try to start it first.

* RHEL/CentOS/FreeBSD/OpenBSD: ```# service amavisd restart```
* Debian/Ubuntu: ```# service amavis restart```

After restarted amavisd service, please check its
[log file](./file.locations.html#amavisd) to make sure it's running.

Notes:

* At least 1GB memory is required for a low traffic mail server. If your
  server doesn't have enough memory, Amavisd may stop running automatically after
  running for a while. If it's just a testing server, you can follow
  [our tutorial](./completely.disable.amavisd.clamav.spamassassin.html)
  to disable some features of Amavisd to keep it running, or disable it completely.
