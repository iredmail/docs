# Upgrade iRedMail from 0.9.2 to 0.9.3

[TOC]

__This is still a DRAFT document, do NOT apply it.__

## ChangeLog

> We provide remote upgrade service, check [the price](../support.html) and [contact us](../contact.html).

* 2015-07-03: Dovecot: Fix incorrect quota warning priorities
* 2015-06-30: Dovecot-2.2: Add more special folders as alias folders.
* 2015-06-09: [OPTIONAL] Fixed: Not preserve the case of `${extension}` while delivering message to mailbox.

## General (All backends should apply these steps)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
# File: /etc/iredmail-release

0.9.3
```

### Upgrade iRedAPD (Postfix policy server) to the latest 1.7.0

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[How to upgrade iRedAPD-1.4.0 or later versions to the latest stable release](./upgrade.iredapd.html)

Detailed release notes are available here: [iRedAPD release notes](./iredapd.releases.html).

### Upgrade Roundcube webmail to the latest stable release

Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release immediately: [How to upgrade Roundcube](http://trac.roundcube.net/wiki/Howto_Upgrade)

### [TODO] Amavisd: Fix incorrect setting which signs DKIM on inbound messages

* Add `$interface_policy{'10026'} = 'ORIGINATING';` in amavisd.conf
* Remove '$originating = 1;'
* Update transport `submission` in `/etc/postfix/master.cf` to use
  `content_filter=smtp-amavis:[127.0.0.1]:10026` as content filter.

With these changes, Amavisd will aply policy bank 'ORIGINATING' to emails
submitted through port 587 by smtp authenticated user. This way we clearly
separate emails submitted by smtp authenticated users and inbound message sent
by others, and Amavisd won't sign DKIM on inbound message anymore.

### Dovecot: Fix incorrect quota warning priorities

iRedMail configures Dovecot to send warning message to local user when the
mailbox quota is 85%, 90% or 95% full, but the priorities is wrong. Please
fix it with steps below.

* Find below setting in Dovecot config file `/etc/dovecot/dovecot.conf`
  (Linux/OpenBSD) or `/usr/local/etc/dovecot/dovecot.conf` (FreeBSD):

```
    quota_warning = storage=85%% quota-warning 85 %u
    quota_warning2 = storage=90%% quota-warning 90 %u
    quota_warning3 = storage=95%% quota-warning 95 %u
```

`quota_warning` has the highest priority, `quota_warning3` has the lowest
priority. Only the command for the first exceeded limit is executed, so we must
configure the highest limit first.

With above setting, when the mailbox quota goes from 70% to 98% directly, it
sends warning message to notify user that the quota is 85% full, this is wrong,
it's expected to be warned as 95% full instead.

* Update them to below ones to fix it. Please pay close attention to the percent
  numbers:

```
    quota_warning = storage=95%% quota-warning 95 %u
    quota_warning2 = storage=90%% quota-warning 90 %u
    quota_warning3 = storage=85%% quota-warning 85 %u
```

Restart Dovecot service is required.

For more details, please read Dovecot document:
[Quota Configuration](http://wiki2.dovecot.org/Quota/Configuration)

### Dovecot-2.2: Add more special folders as alias folders

Note: This is applicable to Dovecot-2.2.x. if you're running Dovecot-2.1.x or
earlier versions, please skip this step.

Check Dovecot version number with below command first:

```bash
# dovecot --version
```

Open Dovecot config file `/etc/dovecot/dovecot.conf` (Linux/OpenBSD) or
`/usr/local/etc/dovecot/dovecot.conf` (FreeBSD), find below setting:

```
namespace {
    type = private
    ...
    inbox = yes
    ...
}
```

Add below alias folders inside the same `namespace {}` block:

```
    mailbox "Sent Items" {
        auto = no
        special_use = \Sent
    }

    mailbox "Deleted Messages" {
        auto = no
        special_use = \Trash
    }

    mailbox "Deleted Messages" {
        auto = no
        special_use = \Trash
    }

    # Archive
    mailbox Archive {
        auto = subscribe
        special_use = \Archive
    }
    mailbox Archives {
        auto = no
        special_use = \Archive
    }
```

Restart Dovecot service is required.

### [OPTIONAL] Fixed: Not preserve the case of `${extension}` while delivering message to mailbox

With iRedMail-0.9.2 and earlier releases, email sent to user
`username+Ext@domain.com` (upper case `E`) will be delivered to folder
`ext` (lower case `e`) of `username@domain.com`'s mailbox. This fix will
preserve the case of address extension.

* Open file `/etc/postfix/master.cf` (Linux/OpenBSD) or
  `/usr/local/etc/postfix/master.cf` (FreeBSD), find below lines:

```
# Use dovecot deliver program as LDA.
dovecot unix    -       n       n       -       -      pipe
    flags=DRhu ...
```

* Replace `flags=DRhu` by `flags=DRh` (remove `u`) in the third line:

```
    flags=DRh ...
```

* Save your change and restart Postfix service.
