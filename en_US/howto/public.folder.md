# How to create and manage public folder

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
chown -R vmail:vmail /var/vmail/public
chmod -R 0700 /var/vmail/public
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

With shell command below, we grant `lookup`, `read`, `write`, `insert`,
`delete`, `expunge` and `create` (sub-directory) permissions to user
`postmaster@test.com` (again, this user is hosted on same server):

```
doveadm acl set -A "Public/TestFolder" "user=postmaster@test.com" lookup read write insert delete expunge create
```

Check the ACl with `doveadm` again:

```
# doveadm acl get -A "Public/TestFolder"
Username        ID                       Global Rights
postmaster@a.cn user=postmaster@test.com        create delete expunge insert lookup read write
```

If you now login to webmail (or other IMAP client) as user `postmaster@test.com`,
you can see a new folder `TestFolder`.

With shell command below, we grant all users hosted on same server `lookup`,
and `read` permissions:

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

## Manage Access Control manually

!!! note

    * if you're running Dovecot-2, it's recommended to manage ACL with `doveadm`
      command.
    * Dovecot will create file `/var/vmail/public/dovecot-acl-list` automatically,
      it lists all mailboxes that have `l` rights assigned. If you manually
      add/edit `dovecot-acl` files, you may need to delete the `dovecot-acl-list`
      to get the mailboxes visible.

Access permission is controlled in file `dovecot-acl` under each shared folder,
let's create it before showing you some examples:

```
touch /var/vmail/public/.TestFolder/dovecot-acl
chown vmail:vmail /var/vmail/public/.TestFolder/dovecot-acl
chmod 0700 /var/vmail/public/.TestFolder/dovecot-acl
```

With shell command below, we grant `lookup` (l), `read` (r), `write` (w),
`insert` (i), `delete` (x), `expunge` (e) and `create sub-directory` (k) permissions to user
`postmaster@test.com` (again, this user is hosted on same server):

```
echo 'user=postmaster@test.com lrwixke' >> /var/vmail/public/.TestFolder/dovecot-acl
```

With shell command below, we grant all users `lookup` (l) and `read` (r)
permissions:

!!! note "Reminder"

    It requires Dovecot setting `acl_anyone = allow` in `dovecot.conf`.

```
echo 'anyone lr' >> /var/vmail/public/.TestFolder/dovecot-acl
```

## Troubleshooting

* If public folder doesn't work as expected, please [turn on debug mode in
  Dovecot](./debug.dovecot.html) to get debug message. If you don't understand
  the debug message, you can post them to our [online support forum](../forum/)
  to get help.

* It's also a good idea to run `doveadm` command with `-D` flag to turn on
  verbose logging, like below:

```
doveadm -D acl ...
```

## References

* Dovecot official documents:

    * [Public Mailboxes](http://wiki2.dovecot.org/SharedMailboxes/Public)
    * [Access Control Lists](http://wiki2.dovecot.org/ACL)
    * [Manage Access Control List with doveadm](http://wiki2.dovecot.org/Tools/Doveadm/ACL)

## See Also

* [Mailbox sharing](./mailbox.sharing.html)
