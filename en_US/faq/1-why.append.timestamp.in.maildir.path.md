# Why append timestamp in maildir path

iRedMail appends a timestamp to user's maildir path by default, people asked
many times why we do this, and here's why. :)

Think about this situation:

* Employee __Michael Jordan__ has email address `mj@domain.ltd`. Without timestamp
  in maildir path, his maildir path should be `/var/vmail/vmail1/domain.ltd/mj/`.

* Michael left company someday, your company removed his mail account, and
  scheduled to remove his mailbox in certain years (either according to local
  law to keep it, or you just want to save a backup copy).

* A new talent, __Mike Jackson__, joined your company, and he wants to use
  `mj@domain.ltd` since it is not used by anyone else right now. You created it
  for him. Without timestamp in maildir path, his maildir path will be
  same as __Michael Jordan__'s which is `/var/vmail/vmail1/domain.ltd/mj/`.
  In this case, __Mike Jackson__ will see all old emails left in __Michael Jordan__'s
  mailbox.

To avoid this issue, iRedMail appends a timestamp in maildir path to make sure
all users have their own unique maildir paths.

!!! attention

    If you create mail user with iRedAdmin or iRedAdmin-Pro, it's tuneable:

    - [Customize maildir path](https://docs.iredmail.org/iredadmin-pro.customize.maildir.path.html)
