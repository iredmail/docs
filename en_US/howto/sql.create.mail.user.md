# SQL: Create new mail user

!!! attention

    This document is applicable to iRedMail-0.9.6 and later releases.
    If you're running iRedMail-0.9.5-1 or earlier releases, please check
    tutorial [SQL: Bulk create new mail users](./sql.bulk.create.mail.users.html)
    instead.

iRedMail ships the shell script `tools/create_mail_user_SQL.sh` to help you
create new mail user quickly. With some shell scripting trick, it's easy to
create many mail users.

Sample usage:

* Create the mail domain name `example.com` with iRedAdmin first.
* Create a new mail user with the shell script:

```shell
# cd iRedMail-0.9.6/tools/
# bash create_mail_user_SQL.sh user1@example.com plain_password
```

It will print SQL commands used to create this new user, you can save it to a
file, then login to SQL server as root user and import this file. for example:

* MySQL or MariaDB:

```shell
# cd iRedMail-0.9.6/tools/
# bash create_mail_user_SQL.sh user1@example.com plain_password > user.sql

# mysql -uroot -p
sql> USE vmail;
sql> SOURCE user.sql;
```

* PostgreSQL:

```
# cd iRedMail-0.9.6/tools/
# bash create_mail_user_SQL.sh user1@example.com plain_password > /tmp/user.sql

# su - postgres
$ psql -d vmail
sql> \i output.sql;
```

Don't forget to remove /tmp/user.sql.

Notes:

* Password scheme is defined in variable `PASSWORD_SCHEME`, default is `SSHA512`.
  `BCRYPT` is recommended on FreeBSD and OpenBSD.
* Per-user mailbox quota is defined in variable `DEFAULT_QUOTA`, default is
  `1024` (1 GB).
* Maildir path is hashed like  `domain.ltd/u/s/e/username-20150929`. If you
  prefer `domain.ltd/username/`, please set `MAILDIR_STYLE='normal'`.
* Mailbox storage path is defined in variable `STORAGE_BASE_DIRECTORY`, default
  is `/var/vmail/vmail1`.

## See Also

* [LDAP: Bulk create mail users](./ldap.bulk.create.mail.users.html)
