# Errors you may see while maintaining iRedMail server

[TOC]

## Postfix (SMTP)

### Intended policy rejection, please try again later

Sample error message in Postfix log file:

> Jul 24 06:43:08 mx0 postfix/smtpd[12719]: NOQUEUE: reject: RCPT from sender.com[xx.xx.xx.xx]: 451 4.7.1 <recipient@my-domain.com>: Recipient address rejected: __Intentional policy rejection, please try again later__{: .red }; from=<sender@sender-domain.com> to=<recipient@my-domain.com> proto=SMTP helo=<mx2.sender.com>

This error is caused by greylisting service, sender server will retry to
deliver the same email, and your server will accept it after few retries.

* For more technical details about Greylisting, please visit:
    * [Homepage: What is greylisting?](http://greylisting.org)
    * [Articles about greylisting](http://greylisting.org/articles/)
* To manage greylisting service, please read iRedAPD tutorial: [Manage iRedAPD: Greylisting](./manage.iredapd.html#greylisting)

### Sender address rejected: not logged in

Sample error message in Postfix log file:

> Jun 24 11:57:13 mx1 postfix/smtpd[2667]: NOQUEUE: reject: RCPT from
> mail.mydomain.com[1.2.3.4]: 553 5.7.1 <sombody@my-domain.com\>: __Sender address
> rejected: not logged in__{: .red }; from=<sombody@my-domain.com\>
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

### Recipient address rejected: SMTP AUTH is required for users under this sender domain

> With old iRedAPD releases, the error messages may be one of below:
>
> * `SMTP AUTH is required, or it is a spam with forged sender domain`
> * `Recipient address rejected: Policy rejection not logged in`

This error message means sender domain is hosted locally on your iRedMail
server, but sender doesn't perform SMTP AUTH to send email.

1. If the email is not sent by a server or device under your control, most
   likely this email is spam with forged sender address, it's safe to ignore it
   in this case.
1. If the email is sent from your server, that means your MUA (Mail User Agent,
   e.g. Outlook, Thunderbird, etc) is not configured to perform SMTP
   authentication to send email. Enabling smtp auth will fix this automatically.
1. If the email is sent from a server or device __NOT__ under your control,
   you want to bypass the email sent from this sender address but not the whole
   server, please list this sender address in iRedAPD config file
   `/opt/iredapd/settings.py`, parameter `ALLOWED_FORGED_SENDERS` like below:

    ```
    ALLOWED_FORGED_SENDERS = ['user@domain.com']
    ```

    !!! warning

        With this setting, iRedAPD accepts all emails with this forged address
        from __ANY__ mail server.

    Notes:

    * This parameter doesn't exist in `/opt/iredapd/settings.py` by default,
      feel free to add it manually. You can find detailed comments in file
      `/opt/iredapd/libs/default_settings.py`, read the comments to understand
      it better.
    * This parameter name must be in upper cases.

1. If the email is sent by a server or device under your control and you want to
   trust this server/device and bypass all emails, you can whitelist the IP
   address of this server/device in iRedAPD config file `/opt/iredapd/settings.py` like below:

    ```
    MYNETWORKS = ['192.168.0.10', '192.168.0.20', '192.168.0.30']
    ```

    Notes:

    * This parameter doesn't exist in `/opt/iredapd/settings.py` by default,
      feel free to add it manually. You can find detailed comments in file
      `/opt/iredapd/libs/default_settings.py`, read the comments to understand
      it better.
    * This parameter name must be in upper cases.

### Recipient address rejected: Sender is not same as SMTP authenticate username

#### case #1

If the smtp authenticate username is different than the address in mail header
`From:` field, you will get this rejection (by iRedAPD).

Solutions:

* If you don't need to send as different sender, please update your mail
  composer (like Outlook, Thunderbird, webmail, your own script used to send
  email, etc) to use same address as smtp authenticate username and sender
  address in `From:`.
* If you do need to send as different sender address (`From:`), please add one
  setting in iRedAPD config file `/opt/iredapd/settings.py`, then restart
  iRedAPD service:

```
ALLOWED_LOGIN_MISMATCH_SENDERS = ['user@mydomain.com']
```

Notes: `user@mydomain.com` is the email address you used for smtp authentication.

#### case #2

If you're a member of mailing list or mail alias, and trying to send email with
the email address of mailing list/alias as sender address, you will get same
error. There's another setting you can try (either one is ok):

```
ALLOWED_LOGIN_MISMATCH_LIST_MEMBER = True
```

It will allow all members of mailing list/alias to send email with the email
of mailing list/alias as the sender address.

### unreasonable virtual_alias_maps map expansion size for user@domain.com

Sample error message in Postfix log file:

> Feb 11 19:59:06 mail postfix/cleanup[30575]: warning: 23C334232FB3:
> __unreasonable virtual_alias_maps map expansion size__{: .red } for
> user@domain.com -- deferring delivery

It means the maximal number of addresses that virtual alias expansion produces
from each original recipient exceeds hard limit, please either increase the
hard limit (default is 1000), or reduce alias members.

To increase the limit to, for example, 1500, please add below setting in
Postfix config file `/etc/postfix/main.cf`:

```
virtual_alias_expansion_limit = 1500
```

Reference: [Postfix Configuration Parameters](http://www.postfix.org/postconf.5.html#virtual_alias_expansion_limit)

### Helo command rejected: need fully-qualified hostname

Sample error message in Postfix log file:

> Sep 22 08:51:03 mail postfix/smtpd[22067]: NOQUEUE: reject: RCPT from
> dslb-092-074-062-133.092.074.pools.vodafone-ip.de[92.74.62.133]: 504 5.5.2
> <EHSGmbHLUCASPC\>: __Helo command rejected: need fully-qualified hostname__;
> from=<user@domain-a.com> to=<user@domain-b.com> proto=ESMTP helo=<EHSGmbHLUCASPC\>

According to RFC document, HELO identity must be a FQDN (fully-qualified
hostname). Sender sends `EHSGmbHLUCASPC` as HELO hostname, but it's not a FQDN.
It's sender's fault, not your mistake.

As a temporary solution, you can whitelist this HELO hostname
by adding a line like below at the top of file `/etc/postfix/helo_access.pcre`
(Linux/OpenBSD) or `/usr/local/etc/postfix/helo_access.pcre` (FreeBSD):

```
/^EHSGmbHLUCASPC$/ OK
```

### Helo command rejected: Host not found

Sample error message in Postfix log file:

> Aug 13 08:07:14 mail postfix/smtpd[8606]: NOQUEUE: reject: RCPT from mta02.globetel.com.ph[120.28.49.114]: 450 4.7.1 <mta02.globetel.com>: Helo command rejected: Host not found; from=<tcadd01@globetel.com.ph> to=<user@example.com> proto=ESMTP helo=<mta02.globetel.com>

Postfix does DNS query to verify whether A type of DNS record of HELO domain
name `mta02.globetel.com` exists, if not, Postfix rejects the email.

As a temporary solution, you can whitelist this HELO hostname
by adding a line like below at the top of file `/etc/postfix/helo_access.pcre`
(Linux/OpenBSD) or `/usr/local/etc/postfix/helo_access.pcre` (FreeBSD):

```
/^mta02\.globetel\.com$/ OK
```

### Helo command rejected: ACCESS DENIED. Your email was rejected because the sending mail server does not identify itself correctly (.local)

It means sender mail server uses a FQDN hostname which ends with `.local` as
HELO identity. `.local` is not a valid top level domain name, and all mail
servers should use a valid domain name which is resolvable from DNS query.

Two solutions:

1. Temporarily remove this HELO check rule on YOUR server, in file
   `/etc/postfix/helo_access.pcre` (Linux/OpenBSD) or
   `/usr/local/etc/postfix/helo_access.pcre` (FreeBSD), then reload Postfix
   service.
1. Ask sender server system administrator to correct their HELO identity, they
   will experience same issue while sending email to others.

### warning: do not list domain mydomain.com in BOTH mydestination and virtual_mailbox_domains

Sample log in Postfix log file:

> Feb 20 03:31:54 mail postfix/trivial-rewrite[2216]: warning: do not list
> domain mydomain.com in BOTH mydestination and virtual_mailbox_domains

This error message means mail domain name `mydomain.com` is:

* listed in Postfix parameter `mydestination`. Most probably, this domain name
  is value of Postfix parameter `myhostname`, and `myhostname` is value of
  `mydestination`.
* a virtual mail domain name. Most probably, you added this domain with
  iRedAdmin.

To solve this, please either use a different `myhostname` or don't use this
domain name as mail domain (remove it with iRedAdmin). To use a different value
for Postfix parameter `myhostname`, you must also
[change server hostname](./change.server.hostname.html).

## Dovecot (IMAP / POP3)

### Plaintext authentication not allowed without SSL/TLS

Error message in Dovecot log file:

> [ALERT] Plaintext authentication not allowed without SSL/TLS, but your client
> did it anyway. If anyone was listening, the password was exposed.

Dovecot is configured to force clients to use secure IMAP/POP3 connections,
but your client is trying to use plain and insecure connection without TLS or
SSL.

The __BEST__ solution is updating IMAP/POP3 settings in the mail client
application (e.g. Outlook, Thunderbird) to enable secure connection. Please
check [this link](./index.html#mua) to see network port numbers and secure
connection types.

The __NOT RECOMMENDED__ solution is updating Dovecot config file to allow
insecure connection, this is dangerous because your password is sent in plain
text, if someone can trace the network traffic with network gateway / firewall,
your password is explosed. if you clearly understand the risk and still want
to enable insecure connections, please check [this document](./allow.insecure.pop3.imap.smtp.connections.html).

## Amavisd

### connect to 127.0.0.1[127.0.0.1]:10024: Connection refused

This error means Amavisd service is not running, please try to start it first.

* RHEL/CentOS/FreeBSD: ```# service amavisd restart```
* Debian/Ubuntu: ```# service amavis restart```
* OpenBSD: `# /etc/rc.d/amavisd restart` or `# rcctl restart amavisd`

After restarted amavisd service, please check its
[log file](./file.locations.html#amavisd) to make sure it's running.

Notes:

* 4 GB memory is recommended for a low traffic production mail server. If your
  server doesn't have enough memory, Amavisd and ClamAV may be not able to
  start, or stop running automatically after running for a while. If it's just
  a testing server, you can follow
  [our tutorial](./completely.disable.amavisd.clamav.spamassassin.html) to
  disable some features of Amavisd to keep it running, or disable it completely.
