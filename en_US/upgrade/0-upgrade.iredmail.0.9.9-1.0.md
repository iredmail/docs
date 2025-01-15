# Upgrade iRedMail from 0.9.9 to 1.0

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! note "Remote Upgrade Assistance"

    Check out our [remote upgrade support](https://www.iredmail.org/support.html) if you need assistance.

## ChangeLog

* Apr 18, 2020, mention how to configure Dovecot to track user last login time.
* Dec 11 2019, mention not to enable quota-status service in Dovecot-2.1.x.
* Dec 9, 2019, initial release.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.0
```

### Upgrade iRedAPD (Postfix policy server) to the latest stable release: 3.3

!!! attention

    iRedAPD offers SRS (Sender Rewriting Scheme) support in this release, but
    it's disabled by default, please read our tutorial to understand known
    issues and how to enable it: [Enable SRS (Sender Rewriting Scheme) support](./srs.html).

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

### Upgrade iRedAdmin (open source edition) to the latest stable release: 0.9.9

Please follow this tutorial to upgrade iRedAdmin open source edition to the
latest stable release:
[Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html)

### Upgrade mlmmjadmin to the latest stable release (2.1)

Please follow below tutorial to upgrade mlmmjadmin to the latest stable release:
[Upgrade mlmmjadmin to the latest stable release](./upgrade.mlmmjadmin.html)

### Upgrade Roundcube webmail to the latest stable release: 1.4.1

!!! warning "Roundcube 1.4"

    Since Roundcube 1.3, at least __PHP 5.4__ is required. If your server is
    running PHP 5.3 and cannot upgrade to 5.4, please upgrade Roundcube
    the latest 1.2 branch instead.

The latest Roundcube webmail 1.4.1 offers a shiny new web UI.
Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release (1.4.1):

* [How to upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).

### Upgrade netdata to the latest stable release (1.19.0)

If you have netdata installed, you can upgrade it by following this tutorial:
[Upgrade netdata](./upgrade.netdata.html).

### Fixed: improper order of Postfix smtpd_sender_restriction rules

iRedMail-0.9.9 and earlier releases didn't configure Postfix to apply custom
restriction rule before querying DNS records of sender domain,
this way you cannot whitelist some sender mail domains which don't have
DNS records (especially your internal mail domains used in LAN). Please follow
steps below to fix it.

* Open file `/etc/postfix/main.cf` (Linux/OpenBSD) or
  `/usr/local/etc/postfix/main.cf` (FreeBSD), find parameter
  `smtpd_sender_restrictions` like below:

```
smtpd_sender_restrictions =
    reject_unknown_sender_domain
    ...
    check_sender_access pcre:...
```

* Move the `reject_unknown_sender_domain` line after `check_sender_access` line
  like below:

```
smtpd_sender_restrictions =
    ...
    check_sender_access pcre:...
    reject_unknown_sender_domain
```

* Reloading or restarting Postfix service is required.

### Fixed: fix improper HELO rule which blocks new Facebook servers

Facebook has some new servers which uses `<ip>.mail-mail.facebook.com` as
HELO identities, this is blocked by the default HELO rules configured by
iRedMail-0.9.9 and earlier releases. Please fix it with EITHER step described
below, but solution 1 is the recommended.

1. Prepend line below in `/etc/postfix/helo_access.pcre` (Linux/OpenBSD) and
  `/usr/local/etc/postfix/helo_access.pcre` (FreeBSD):

```
/^\d{1,3}-\d{1,3}-\d{1,3}-\d{1,3}\.mail-mail\.facebook\.com$/ DUNNO
```

2. Or, find line below in `helo_access.pcre` and remove it.

```
/(\d{1,3}[\.-]\d{1,3}[\.-]\d{1,3}[\.-]\d{1,3})/ REJECT ACCESS DENIED. Your email was rejected because the sending mail server appears to be on a dynamic IP address that should not be doing direct mail delivery
```

Reloading or restarting Postfix service is required.

### Fixed: Incorrect SSL CA file path in Postfix on FreeBSD and OpenBSD

!!! attention

    This applies to only FreeBSD and OpenBSD, NOT Linux.

FreeBSD and OpenBSD has all CAs in file `/etc/ssl/cert.pem`, but it's
configured by iRedMail to load multiple CA files under `/etc/ssl/certs`
directory like Linux. Commands below fix this issue.

```
postconf -e smtpd_tls_CAfile=/etc/ssl/cert.pem
postconf -e smtpd_tls_CApath=''
postfix reload
```

### Fail2ban: slightly loose filter rule for postfix

We received few reports from clients that Outlook for macOS may trigger some
unexpected smtp errors, and caught by the Fail2ban filter rules shipped by
iRedMail, so we decide to remove the filter rule used to match Postfix log
`lost connection after EHLO`.

Please follow commands below to get the updated filter rules.

* On Linux:

```
cd /etc/fail2ban/filter.d/
wget -O postfix.iredmail.conf https://github.com/iredmail/iRedMail/raw/1.0/samples/fail2ban/filter.d/postfix.iredmail.conf
wget -O dovecot.iredmail.conf https://github.com/iredmail/iRedMail/raw/1.0/samples/fail2ban/filter.d/dovecot.iredmail.conf
```

Restarting Fail2ban service is required.

## For OpenLDAP backend

### [OPTIONAL] Enable mailbox quota status check in Dovecot and Postfix.

With default iRedMail settings, Postfix accepts email without checking whether
user's mailbox is over quota, then pipes email to Dovecot LDA for local
delivery. If mailbox is over quota, Dovecot can not save message to mailbox
and generates a "sender non-delivery notification" to sender.

With the change below, Postfix will query mailbox quota status from Dovecot
directly, then reject email if it's over quota. It saves system resource used
to process this email (e.g. spam/virus scanning), and avoids bounce message.

#### Add required LDAP attribute/value pair for all mail users

According to the Dovecot settings configured by iRedMail, all mail users
should have LDAP attribute/value pair `enabledService=quota-status` to use
this service.

* Download script used to update existing mail accounts:

```
cd /root/
wget https://github.com/iredmail/iRedMail/raw/1.0/update/ldap/updateLDAPValues_099_to_1.py
```

* Open downloaded file `updateLDAPValues_099_to_1.py`, set LDAP server
  related settings in this file. For example:

```
# Part of file: updateLDAPValues_099_to_1.py

uri = 'ldap://127.0.0.1:389'
basedn = 'o=domains,dc=example,dc=com'
bind_dn = 'cn=vmailadmin,dc=example,dc=com'
bind_pw = 'passwd'
```

You can find required LDAP credential in iRedAdmin config file or
`iRedMail.tips` file under your iRedMail installation directory. Using either
`cn=Manager,dc=xx,dc=xx` or `cn=vmailadmin,dc=xx,dc=xx` as bind dn is ok, both
of them have read-write privilege to update mail accounts.

* Execute this script, it will add required data:

```
# python2 updateLDAPValues_099_to_1.py
```

#### Enable quota-status service in Dovecot

!!! warning

    This feature requires Dovecot-2.2 or later releases, do not apply it on
    Dovecot-2.1.x or earlier versions.

Open Dovecot config file `/etc/dovecot/dovecot.conf` (Linux/OpenBSD) or
`/usr/local/etc/dovecot/dovecot.conf` (FreeBSD), find the `plugin {}` block
and add 3 new parameters:

```
plugin {
    ...
    # Used by quota-status service.
    quota_status_success = DUNNO
    quota_status_nouser = DUNNO
    quota_status_overquota = "552 5.2.2 Mailbox is full"
    ...
}
```

In same `dovecot.conf`, append settings below __at the end of file__:

* With settings below, Dovecot quota-status service will listen on `127.0.0.1:12340`.
* You can change the port number `12340` to any other spare one if you want.

```
service quota-status {
    executable = quota-status -p postfix
    client_limit = 1
    inet_listener {
        address = 127.0.0.1
        port = 12340
    }
}
```

Restarting Dovecot service is required.

#### Enable quota status check in Postfix

!!! warning

    This feature requires Dovecot-2.2 or later releases, do not apply it on
    Dovecot-2.1.x or earlier versions.

Open Postfix config file `/etc/postfix/main.cf` (Linux/OpenBSD) or
`/usr/local/etc/postfix/main.cf` (FreeBSD), find parameter
`smtpd_recipient_restrictions` and append a new `check_policy_service` setting
__at the end__ like below:

```
smtpd_recipient_restrictions =
    ...
    check_policy_service inet:127.0.0.1:12340
```

Restarting Postfix service is required.

### [OPTIONAL] Track the time of user last login via IMAP/POP3

Sometimes you may want/need to know the time of user last login via IMAP/POP3,
and here's the tutorial to implement this feature. If you run iRedAdmin-Pro
admin panel, it's visiable on the web UI directly.

* [Track user last login time](./track.user.last.login.html)

## For MySQL/MariaDB backends

### [OPTIONAL] Enable mailbox quota status check in Dovecot and Postfix.

With default iRedMail settings, Postfix accepts email without checking whether
user's mailbox is over quota, then pipes email to Dovecot LDA for local
delivery. If mailbox is over quota, Dovecot can not save message to mailbox
and generates a "sender non-delivery notification" to sender.

With the change below, Postfix will query mailbox quota status from Dovecot
directly, then reject email if it's over quota. It saves system resource used
to process this email (e.g. spam/virus scanning), and avoids bounce message.

#### Add new SQL column in `vmail.mailbox` table

According to the Dovecot settings configured by iRedMail, a new SQL column
`mailbox.enablequota-status` is required.

Download plain SQL file used to create required column and index, then import
it directly as MySQL root user (Please run commands below as `root` user):

```
wget -O /tmp/iredmail.mysql https://github.com/iredmail/iRedMail/raw/1.0/update/1.0/iredmail.mysql
mysql vmail < /tmp/iredmail.mysql
rm -f /tmp/iredmail.mysql
```

#### Enable quota-status service in Dovecot

!!! warning

    This feature requires Dovecot-2.2 or later releases, do not apply it on
    Dovecot-2.1.x or earlier versions.

Open Dovecot config file `/etc/dovecot/dovecot.conf` (Linux/OpenBSD) or
`/usr/local/etc/dovecot/dovecot.conf` (FreeBSD), find the `plugin {}` block
and add 3 new parameters:

```
plugin {
    ...
    # Used by quota-status service.
    quota_status_success = DUNNO
    quota_status_nouser = DUNNO
    quota_status_overquota = "552 5.2.2 Mailbox is full"
    ...
}
```

In same `dovecot.conf`, append settings below __at the end of file__:

* With settings below, Dovecot quota-status service will listen on `127.0.0.1:12340`.
* You can change the port number `12340` to any other spare one if you want.

```
service quota-status {
    executable = quota-status -p postfix
    client_limit = 1
    inet_listener {
        address = 127.0.0.1
        port = 12340
    }
}
```

Restarting Dovecot service is required.

#### Enable quota status check in Postfix

!!! warning

    This feature requires Dovecot-2.2 or later releases, do not apply it on
    Dovecot-2.1.x or earlier versions.

Open Postfix config file `/etc/postfix/main.cf` (Linux/OpenBSD) or
`/usr/local/etc/postfix/main.cf` (FreeBSD), find parameter
`smtpd_recipient_restrictions` and append a new `check_policy_service` setting
__at the end__ like below:

```
smtpd_recipient_restrictions =
    ...
    check_policy_service inet:127.0.0.1:12340
```

Restarting Postfix service is required.

### [OPTIONAL] Track the time of user last login via IMAP/POP3

Sometimes you may want/need to know the time of user last login via IMAP/POP3,
and here's the tutorial to implement this feature. If you run iRedAdmin-Pro
admin panel, it's visiable on the web UI directly.

* [Track user last login time](./track.user.last.login.html)

## For PostgreSQL backend

### [OPTIONAL] Enable mailbox quota status check in Dovecot and Postfix.

With default iRedMail settings, Postfix accepts email without checking whether
user's mailbox is over quota, then pipes email to Dovecot LDA for local
delivery. If mailbox is over quota, Dovecot can not save message to mailbox
and generates a "sender non-delivery notification" to sender.

With the change below, Postfix will query mailbox quota status from Dovecot
directly, then reject email if it's over quota. It saves system resource used
to process this email (e.g. spam/virus scanning), and avoids bounce message.

#### Add new SQL column in `vmail.mailbox` table

According to the Dovecot settings configured by iRedMail, a new SQL column
`mailbox.enablequota-status` is required.

* Download plain SQL file used to create required column and index:

```
wget -O /tmp/iredmail.pgsql https://github.com/iredmail/iRedMail/raw/1.0/update/1.0/iredmail.pgsql
```

* Connect to PostgreSQL server as `postgres` user and import the SQL file:
    * on Linux, it's `postgres` user
    * on FreeBSD, it's `pgsql` user
    * on OpenBSD, it's `_postgresql` user

```
su - postgres
psql -d vmail < /tmp/iredmail.pgsql
```

* Remove downloaded file as root user:

```
rm -f /tmp/iredmail.pgsql
```

#### Enable quota-status service in Dovecot

!!! warning

    This feature requires Dovecot-2.2 or later releases, do not apply it on
    Dovecot-2.1.x or earlier versions.

Open Dovecot config file `/etc/dovecot/dovecot.conf` (Linux/OpenBSD) or
`/usr/local/etc/dovecot/dovecot.conf` (FreeBSD), find the `plugin {}` block
and add 3 new parameters:

```
plugin {
    ...
    # Used by quota-status service.
    quota_status_success = DUNNO
    quota_status_nouser = DUNNO
    quota_status_overquota = "552 5.2.2 Mailbox is full"
    ...
}
```

In same `dovecot.conf`, append settings below __at the end of file__:

* With settings below, Dovecot quota-status service will listen on `127.0.0.1:12340`.
* You can change the port number `12340` to any other spare one if you want.

```
service quota-status {
    executable = quota-status -p postfix
    client_limit = 1
    inet_listener {
        address = 127.0.0.1
        port = 12340
    }
}
```

Restarting Dovecot service is required.

#### Enable quota status check in Postfix

!!! warning

    This feature requires Dovecot-2.2 or later releases, do not apply it on
    Dovecot-2.1.x or earlier versions.

Open Postfix config file `/etc/postfix/main.cf` (Linux/OpenBSD) or
`/usr/local/etc/postfix/main.cf` (FreeBSD), find parameter
`smtpd_recipient_restrictions` and append a new `check_policy_service` setting
__at the end__ like below:

```
smtpd_recipient_restrictions =
    ...
    check_policy_service inet:127.0.0.1:12340
```

Restarting Postfix service is required.
