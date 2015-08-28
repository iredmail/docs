# Why append timestamp in maildir path

iRedMail will append timestamp in maildir path by default, here's why.

Depends on the tools/scripts you used to create mail accounts, it's tunable
in scripts shipped within iRedMail and iRedAdmin (file `settings.py`, variable
`MAILDIR_APPEND_TIMESTAMP = True` or `False`).

> Note: Deleting mail accounts with iRedAdmin will not remove the mailboxes on
> file system, so that you can keep user's mailbox for some time.

Think about this situation:

* Employee Michael Jordan has email address mj@domain.ltd. Without timestamp
in maildir path, the maildir path of his mailbox looks like
`/var/vmail/vmail1/domain.ltd/mj/`.

* Michael left company, and your company deleted his mail account. With
iRedAdmin, it just deletes mail accounts stored in LDAP/SQL server, not delete
his mailbox on file system (`/var/vmail/vmail1/domain.ltd/mj`).

* A new talent, Mike Jackson, joined your company, and he want to use
`mj@domain.ltd` since `mj@` is not used by others. And you created it for him.
Without timestamp in maildir path, the maildir path of Mike's mailbox is the
same as Michael's `/var/vmail/vmail1/domain.ltd/mj/`. iRedAdmin doesn't remove
the mailboxes on file system, so Mike will see all emails in Michael's mailbox
if Michael didn't delete them. To avoid this, we append a timestamp in maildir
path to make sure all users will be assigned an unique maildir paths.
