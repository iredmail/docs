# SQL: Mark existing mail user as global domain admin

[TOC]

### Mark user as global domain admin with iRedAdmin-Pro

With iRedAdmin-Pro, you can mark user as either global domain admin or normal
domain admin in user profile page, under tab `General`.

![](../images/iredadmin/user_profile_general.png)

### Mark user as global domain admin with SQL command line tool

> If you don't have any mail account, please follow this tutorial to create a
> new mail user: [SQL: Bulk create mail users](./sql.bulk.create.mail.users.html).

Let's say you want to mark existing user `user@mydomain.com` as global domain
admin, please follow steps below to achieve this.

* Login to SQL server as either SQL root user or `vmailadmin` user.

    * About SQL root user:
    
        * for MySQL or MariaDB: SQL root user is `root`.
        * for PostgreSQL: it's system account `postgres` on Linux, or
          `postgresql` on FreeBSD, or `_pgsql` on OpenBSD.

    * You can find their passwords in file `iRedMail.tips` under iRedMail
      installation directory. for example, `/root/iRedMail-0.9.3/iRedMail.tips`.

* Update SQL table `vmail.mailbox` and `vmail.domain_admins` to mark this user
  as global domain admin:

```
sql> UPDATE mailbox SET isadmin=1,isglobaladmin=1 WHERE username='user@mydomain.com';
sql> INSERT INTO domain_admins (username, domain) VALUES ('user@mydomain.com', 'ALL');
```

Now you can login to iRedAdmin-Pro as `user@mydomain.com`, it's global domain
admin.
