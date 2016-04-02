# Errors you may see while maintaining iRedMail server

[TOC]

## Postfix

### Sender address rejected: not logged in

Sample error message in Postfix log file:

> Jun 24 11:57:13 mx1 postfix/smtpd[2667]: NOQUEUE: reject: RCPT from
> mail.mydomain.com[1.2.3.4]: 553 5.7.1 <sombody@my-domain.com\>: Sender address
> rejected: not logged in; from=<sombody@my-domain.com\>
> to=<receipent@receipentdomain.com\> proto=ESMTP helo=<client_helo.com\>

This error is caused by incorrectly configured mail client application, not a
server issue.

All mail users are forced to perform SMTP auth before sending email, so you
must configure your mail client applications (Outlook, Thunderbird, ...) to
enable SMTP authentication.

### Sender address rejected: not owned by user user@domain.ltd

This error is caused by restriction rule `reject_sender_login_mismatch` in
Postfix parameter `smtpd_recipient_restrictions`, in file `/etc/postfix/main.cf`:

```
smtpd_recipient_restrictions =
    ...
    reject_sender_login_mismatch,
    ...
```

It will reject the request when $smtpd_sender_login_maps specifies an owner
for the MAIL FROM address, but the client is not (SASL) logged in as that MAIL
FROM address owner; or when the client is (SASL) logged in, but the client
login name doesn't own the MAIL FROM address according to $smtpd_sender_login_maps.
Check [manual page of Postfix configuration file](http://www.postfix.org/postconf.5.html#reject_sender_login_mismatch) for more details.

Removing `reject_sender_login_mismatch` and restarting Postfix service fixes
this issue.

!!! note

    If you want to allow some users to send as other users, or allow all users
    to send as their alias addresses, or allow member of mail list/alias to send
    as mail list/alias, you should try iRedAPD plugin `reject_sender_login_mismatch`
    instead (requires iRedAPD-1.4.4 or later releases).

    Read comments in file `/opt/iredapd/plugins/reject_sender_login_mismatch.py`,
    then enable it in iRedAPD config file `/opt/iredapd/settings.py` (`plugins = `),
    restart iRedAPD service. That's all.

### unreasonable virtual_alias_maps map expansion size for user@domain.com

Sample error message in Postfix log file:

> Feb 11 19:59:06 mail postfix/cleanup[30575]: warning: 23C334232FB3:
> unreasonable virtual_alias_maps map expansion size for user@domain.com
> -- deferring delivery

It means the maximal number of addresses that virtual alias expansion produces
from each original recipient exceeds hard limit, please either increase the
hard limit (default is 1000), or reduce alias members.

To increase the limit to, for example, 1500, please add below setting in
Postfix config file `/etc/postfix/main.cf`:

```
virtual_alias_expansion_limit = 1500
```

Reference: [Postfix Configuration Parameters](http://www.postfix.org/postconf.5.html#virtual_alias_expansion_limit)

## Amavisd

### connect to 127.0.0.1[127.0.0.1]:10024: Connection refused

This error means Amavisd service is not running, please try to start it first.

* RHEL/CentOS/FreeBSD: ```# service amavisd restart```
* Debian/Ubuntu: ```# service amavis restart```
* OpenBSD: `# /etc/rc.d/amavisd restart` or `# rcctl restart amavisd`

After restarted amavisd service, please check its
[log file](./file.locations.html#amavisd) to make sure it's running.

Notes:

* At least 2GB memory is required for a low traffic mail server. If your
  server doesn't have enough memory, Amavisd and ClamAV may be not able to
  start, or stop running automatically after running for a while. If it's just
  a testing server, you can follow
  [our tutorial](./completely.disable.amavisd.clamav.spamassassin.html) to
  disable some features of Amavisd to keep it running, or disable it completely.
