# SQL: Bulk create mail users

iRedMail ships the shell script `tools/create_mail_user_SQL.sh` to help you
create many mail users quickly.

Sample usage:

* Create the mail domain name `example.com` with iRedAdmin first.
* Bulk create mail users with the shell script:

```shell
# cd iRedMail-0.9.4/tools/
# bash create_mail_user_SQL.sh example.com user1 user2 user3
```

It will generate the plain SQL file `output.sql` in current directory, please
login to SQL server as root user, then import it. for example:

* MySQL or MariaDB:

```shell
# mysql -uroot -p
sql> USE vmail;
sql> SOURCE output.sql;
```

* PostgreSQL:

```
# cp output.sql /tmp
# chmod +r /tmp/output.sql

# su - postgres
$ psql -d vmail
sql> \i output.sql;
```

Notes:

* Default password is same as username. if you prefer to set a password for all
  created users, please open the script and update variable `DEFAULT_PASSWD`
  with new password and set `USE_DEFAULT_PASSWD='YES'`.
* Password scheme is defined in variable `PASSWORD_SCHEME`, default is `SSHA512`.
  `BCRYPT` is recommended on FreeBSD and OpenBSD.
* Per-user mailbox quota is defined in variable `DEFAULT_QUOTA`, default is
  `1024` (1024 MB).
* Maildir path is hashed like  `domain.ltd/u/s/e/username-20150929`. If you
  prefer `domain.ltd/username/`, please set `MAILDIR_STYLE='normal'`.
* Mailbox storage path is defined in variable `STORAGE_BASE_DIRECTORY`, default
  is `/var/vmail/vmail1`.

## See Also

* [LDAP: Bulk create mail users](./ldap.bulk.create.mail.users.html)
