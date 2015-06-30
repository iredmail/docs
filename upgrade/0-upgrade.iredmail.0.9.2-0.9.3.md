# Upgrade iRedMail from 0.9.2 to 0.9.3

[TOC]

__This is still a DRAFT document, do NOT apply it.__

## ChangeLog

> We provide remote upgrade service, check [the price](../support.html) and [contact us](../contact.html).

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

### Dovecot-2.2: Add more special folders as alias folders

Note: This is applicable to Dovecot-2.2.x. if you're running Dovecot-2.1.x or
earlier versions, please skip this step. Check Dovecot version number with
below command:

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
