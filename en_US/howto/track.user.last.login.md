# Track user last login time

[TOC]

!!! warning

    This feature is not available for PostgreSQL backend due to Dovecot does
    not yet support updating existing SQL record on conflict primary key.

    Relevent posts in Dovecot mailing lists:

    - <https://marc.info/?t=155411531600001&r=1&w=2>
    - <https://marc.info/?t=155826327900001&r=1&w=2>

Dovecot ships a `last_login` plugin since Dovecot-2.2.14, it can be used to
easily save and update user's last-login timestamp in SQL database.

!!! attention

    * Currently this plugin works with MySQL/MariaDB, but __not PostgreSQL__.
    * It works on:
        * CentOS 7 (Dovecot-2.2.36)
        * Debian 9 (Dovecot-2.2.27)
        * Ubuntu 16.04 (Dovecot-2.2.22)
        * Ubuntu 18.04 (Dovecot-2.2.33)
        * OpenBSD 6.4 (Dovecot-2.2.36)
        * FreeBSD (Dovecot-2.3.x in ports tree)

## Create required SQL table to store last login info

We need to create a sql table to store the user last login info.

* For MySQL/MariaDB backends, we create the sql table in database `vmail`.
* For OpenLDAP backend, since it doesn't have `vmail` SQL database, so we
  create it in `iredadmin` instead, it will be easier for iRedAdmin(-Pro) to
  read this info.

SQL statement:

```
CREATE TABLE IF NOT EXISTS `last_login` (
    `username` VARCHAR(255) NOT NULL DEFAULT '',
    `domain` VARCHAR(255) NOT NULL DEFAULT '',
    `last_login` INT(11) DEFAULT NULL,
    PRIMARY KEY (`username`),
    INDEX (domain),
    INDEX (`last_login`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

## Configure Dovecot

Open Dovecot config file `/etc/dovecot/dovecot.conf` (Linux/OpenBSD) or
`/usr/local/etc/dovecot/dovecot.conf` (FreeBSD), enable `last_login` plugin
for POP3 and IMAP services by appending plugin name to its `mail_plugins`
parameter like below, and add extra required settings. Note: we use `...` below
as a placeholder for your existing settings.

```
protocol imap {
    mail_plugins = ... last_login       # Append plugin name here
    ...
}

protocol pop3 {
    mail_plugins = ... last_login       # Append plugin name here
    ...
}

dict {
    ...

    # Add this line. For FreeBSD, please replace the path by
    # /usr/local/etc/dovecot/dovecot-last-login.conf
    lastlogin = mysql:/etc/dovecot/dovecot-last-login.conf
}

plugin {
    ...

    # Add 2 lines
    last_login_dict = proxy::lastlogin
    last_login_key = last-login/%u/%d
}
```

Create file `/etc/dovecot/dovecot-last-login.conf` (Linux/OpenBSD) or
`/usr/local/etc/dovecot/dovecot-last-login.conf` (FreeBSD) with content below:

```
connect = host=127.0.0.1 port=3306 dbname=vmail user=vmailadmin password=my_secret_password

map {
    pattern = shared/last-login/$user/$domain
    table = last_login
    value_field = last_login
    value_type = uint

    fields {
        username = $user
        domain = $domain
    }
}
```

* For MySQL/MariaDB backends, please replace `my_secret_password` by the real
  password of SQL user `vmailadmin`.
* For OpenLDAP backend:
    * replace `dbname=vmail` by `dbname=iredadmin`
    * replace `user=vmailadmin` by `user=iredadmin`
    * replace `my_secret_password` by the real password of SQL user `iredadmin`

Since this file contain SQL username and password, we must protect it with
proper owner/group and permission (we use Linux/BSD for example below):

```
chown dovecot:dovecot /etc/dovecot/dovecot-last-login.conf
chmod 0400 /etc/dovecot/dovecot-last-login.conf
```

Now it's ok to restart Dovecot service.

## Test

After restarted Dovecot service, please monitor its log file
`/var/log/dovecot/dovecot.log`, if there's something wrong, Dovecot will log
the error message to this file.

Try to access your mailbox with webmail or MUA like Outlook/Thunderbird, you
should see the time has been updated in SQL table `vmail.last_login`
(MySQL/MariaDB backends) or `iredadmin.last_login` (OpenLDAP backend). For
example:

```
sql> USE vmail;
sql> SELECT * FROM last_login;
+-----------------+--------+------------+
| username        | domain | last_login |
+-----------------+--------+------------+
| postmaster@a.io | a.io   | 1554172329 |
+-----------------+--------+------------+
1 row in set (0.01 sec)
```

## References

* [Dovecot plugin: last_login](https://wiki.dovecot.org/Plugins/LastLogin)
