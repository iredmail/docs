# Upgrade iRedMail from 1.5.2 to 1.6.0

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

- Jun 5, 2022: Add mlmmjadmin upgrade tutorial.
- May 20, 2022: initial release.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.6.0
```

### Upgrade mlmmjadmin to the latest stable release (3.1.5)

Please follow below tutorial to upgrade mlmmjadmin to the latest stable release:
[Upgrade mlmmjadmin to the latest stable release](./upgrade.mlmmjadmin.html)

### Upgrade iRedAdmin (open source edition) to the latest stable release (1.7)

Please follow below tutorial to upgrade iRedAdmin to the latest stable release:
[Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html).

### Upgrade netdata to the latest stable release (1.34.1)

If you have netdata installed, you can upgrade it by following this tutorial:
[Upgrade netdata](./upgrade.netdata.html).

## For PostgreSQL backend

### Move SQL view `sogo.users` to `vmail` database

In iRedMail-1.5.2 and early releases, we create SQL view `users` in `sogo`
database, it invokes PostgreSQL extension `dblink` to query `vmail` database,
this causes end users can not change passwords in SOGo webmail.

With steps below, we create SQL view `sogo_users` in `vmail` database, so that
end users can change their own passwords.

Download plain SQL file used to update SQL table:

```
wget -O /tmp/sogo_view.pgsql https://github.com/iredmail/iRedMail/raw/1.6.0/update/1.6.0/sogo_view.pgsql
chmod +r /tmp/sogo_view.pgsql
```

* Connect to PostgreSQL server as `postgres` user and import the SQL file:
    * on Linux, it's `postgres` user
    * on FreeBSD, it's `pgsql` user
    * on OpenBSD, it's `_postgresql` user

```
su - postgres
psql -d vmail < /tmp/sogo_view.pgsql
```

* Remove downloaded file:

```
rm -f /tmp/sogo_view.pgsql
```

Now we need to update SOGo config file to use this new SQL view.

- Open file `/etc/sogo/sogo.conf`, find block `SOGoUserSources = ()` like below:

```
    SOGoUserSources = (
        {
            type = sql;
            id = users;
            viewURL = "postgresql://sogo:...@127.0.0.1:5432/sogo/users";
            canAuthenticate = YES;
            ...
        },
    );
```

- Update the `viewURL =` line:
    - Replace the SQL database name `sogo` by `vmail`
    - Replace the SQL table name `users` by `sogo_users`

```
            viewURL = "postgresql://sogo:...@127.0.0.1:5432/vmail/sogo_users";
```

- Restart memcached and SOGo service (Note: on CentOS, the service name is
  `sogod`, not `sogo`):

```
service memcached restart
service sogo restart
```


- Connect to PostgreSQL server as `postgres` user and drop old SQL view, it's not used anymore.
    * on Linux, it's `postgres` user
    * on FreeBSD, it's `pgsql` user
    * on OpenBSD, it's `_postgresql` user

```
su - postgres
psql -d sogo -c "DROP VIEW users"
```
