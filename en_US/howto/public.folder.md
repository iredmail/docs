# How to create and manage public folder

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

!!! warning

    This tutorial is applicable for Dovecot 2.3. [Dovecot 2.4 uses slightly
    different config syntax](https://doc.dovecot.org/2.4.1/core/config/shared_mailboxes.html#public-shared-mailboxes).

[TOC]

iRedMail has setting for public folder in `/etc/dovecot/dovecot.conf`,
what you need to do is:

* enable the setting for public folder
* choose a preferred directory as public folder
* set proper ACL rules to control the access

In this tutorial, we will show you how to share a public folder named `TestFolder`.

## Enable public folder in Dovecot

Find sample settings like below in Dovecot config file `/etc/dovecot/dovecot.conf`:

```
# Public mailboxes.
# Refer to Dovecot wiki page for more details:
# http://wiki2.dovecot.org/SharedMailboxes/Public
#namespace {
#    type = public
#    separator = /
#    prefix = Public/
#
#    # CONTROL=: Mark this public folder as read-only mailbox
#    # INDEX=: Per-user \Seen flag
#    location = maildir:/var/vmail/public/:CONTROL=~/Maildir/public:INDEX=~/Maildir/public
#
#    # Allow users to subscribe to the public folders.
#    subscriptions = yes
#}
```

Remove comment marks (`#`) for above `namespace {}` block, like below:

```
# Public mailboxes.
# Refer to Dovecot wiki page for more details:
# http://wiki2.dovecot.org/SharedMailboxes/Public
namespace {
    type = public
    separator = /
    prefix = Public/

    # CONTROL=: Mark this public folder as read-only mailbox
    # INDEX=: Per-user \Seen flag
    location = maildir:/var/vmail/public/:CONTROL=~/Maildir/public:INDEX=~/Maildir/public

    # Allow users to subscribe to the public folders.
    subscriptions = yes
}
```

If you want to share the public folder to all users hosted on same server,
please also remove the comment mark in below line in `dovecot.conf`:

```
    acl_anyone = allow
```

Restarting Dovecot service is required after changed its config file.

Important notes:

* With above setting, it uses `/var/vmail/public` as public folder. You're free
  to change it to a preferred directory. We use `/var/vmail/public/` in this
  tutorial for example.
* Please make sure the public folder is owned by user/group `vmail:vmail`
  with permission `0700`.

Now let's create required folder and our first shared folder `TestFolder`.

```
mkdir -p /var/vmail/public/.TestFolder
chown -R vmail:vmail /var/vmail/public/.TestFolder
chmod -R 0700 /var/vmail/public/.TestFolder
```

!!! note "Notes"

    * There's a dot in folder name while creating it, it's `.TestFolder`, not
      `TestFolder`. All folders with a prefixed dot will be considered as an
      IMAP folder by Dovecot with iRedMail default settings.

    * There are no `cur/`, `new/` or `tmp/` directories directly under the
      `/var/mail/public/` folder, because the `Public/` namespace isn't a
      mailbox itself. If you create them manually, it does become a selectable
      mailbox.

With steps above, if you login to webmail (or other IMAP client) as any mail
user hosted on same server, there's no visible public folder at all -- this is
correct, because no one has permission to access this folder right now.

## Manage Access Control with `doveadm`

Before we set any permission, let's check the access control of this public
folder first with command `doveadm acl get`:

```
doveadm acl get -A "Public/TestFolder"
```

You can see output like below, no access control at all:

```
Username ID Global Rights
```

Below is list of all available permissions. Please check [Dovecot web
site](http://wiki2.dovecot.org/ACL) for more details or update.

!!! note "Permissions"

    Permission name (short) | Permission name (full) | Comment
    ---|---|---
    l | lookup | Mailbox is visible in mailbox list. Mailbox can be subscribed to.
    r | read | Mailbox can be opened for reading.
    w | write | Message flags and keywords can be changed, except `\Seen` and `\Deleted`
    s | write-seen | `\Seen` flag can be changed
    t | write-deleted | `\Deleted` flag can be changed
    i | insert | Messages can be written or copied to the mailbox
    p | post | Messages can be posted to the mailbox by LDA, e.g. from Sieve scripts
    e | expunge | Messages can be expunged
    k | create | Mailboxes can be created (or renamed) directly under this mailbox
    x | delete | Mailbox can be deleted
    a | admin | Administration rights to the mailbox (currently: ability to change ACLs for mailbox)

With shell command below, we grant some permissions to user
`postmaster@test.com` (again, this user is hosted on same server):

```
doveadm acl set "Public/TestFolder" "user=postmaster@test.com" lookup read write write-seen write-deleted insert delete expunge create
```

Check the ACl with `doveadm` again:

```
# doveadm acl get -A "Public/TestFolder"
Username        ID                       Global Rights
postmaster@a.cn user=postmaster@test.com        create delete expunge insert lookup read write
```

If you now login to webmail (or other IMAP client) as user `postmaster@test.com`,
you can see a new folder `TestFolder`.

With shell command below, we grant all users (with the `-A` argument) hosted on
same server `lookup`, and `read` permissions:

```
doveadm acl set -A "Public/TestFolder" "anyone" lookup read
```

Check the ACl with `doveadm` now:

```
# doveadm acl get -A "Public/TestFolder"
Username        ID                       Global Rights
postmaster@a.cn anyone                          lookup read
postmaster@a.cn user=postmaster@test.com        create delete expunge insert lookup read write
```

If you login to webmail (or other IMAP client) as any user hosted on same
server, you can see a new folder `TestFolder`.

With shell command below we delete access control for user `postmaster@test.com`:

```
doveadm acl delete -A "Public/TestFolder" "user=postmaster@test.com"
```

For more details about ACL control, please read Dovecot tutorials mentioned in
[References](#references) below.

## Troubleshooting

* If public folder doesn't work as expected, please [turn on debug mode in
  Dovecot](./debug.dovecot.html) to get debug message. If you don't understand
  the debug message, you can post them to our [online support forum](https://forum.iredmail.org/)
  to get help.

* It's also a good idea to run `doveadm` command with `-D` flag to turn on
  verbose logging, like below:

```
doveadm -D acl ...
```

## Use someone's mailbox as public folder

If you want to use someone's mailbox as public folder, here's a simplest way to
achieve it.

Let's say you want to share user `public@domain.com`'s mailbox as public folder
`PublicMailbox`, and its maildir path is
`/var/vmail/vmail1/domain.com/p/u/b/public-20160714100502/Maildir/`. What you
need to do are:

* creating a symbol link to this maildir path like below
* set proper ACL with `doveadm acl` (check steps above)

!!! warning

    There's a dot prepended in public mailbox name, it's `public/.PublicMailbox`,
    not `public/PublicMailbox`.

```
ln -s /var/vmail/vmail1/domain.com/p/u/b/public-20160714100502/Maildir /var/vmail/public/.PublicMailbox
```

## References

* Dovecot official documents:

    * [Public Mailboxes](http://wiki2.dovecot.org/SharedMailboxes/Public)
    * [Access Control Lists](http://wiki2.dovecot.org/ACL)
    * [Manage Access Control List with doveadm](http://wiki2.dovecot.org/Tools/Doveadm/ACL)

## See Also

* [Mailbox sharing](./mailbox.sharing.html)
