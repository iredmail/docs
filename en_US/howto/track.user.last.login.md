# Track user last login time

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! attention

    * This feature is not available for PostgreSQL backend because Dovecot does
      not yet support updating existing SQL record on conflict primary key.
      References: [1](https://marc.info/?t=155411531600001&r=1&w=2), [2](https://marc.info/?t=155826327900001&r=1&w=2)
    * This tutorial has been updated to support tracking last login time of
      both IMAP and POP3, which is implemented in iRedMail-1.2, you can find
      the difference in upgrade tutorial for iRedMail-1.2 here: [For LDAP backend](./upgrade.iredmail.1.1-1.2.html#improved-last-login-track), [For SQL backends](./upgrade.iredmail.1.1-1.2.html#improved-last-login-track_1).

Dovecot ships a `last_login` plugin since Dovecot-2.2.14, it can be used to
easily save and update user's last-login timestamp in SQL database.

Currently this plugin works with MySQL/MariaDB, but __not PostgreSQL__.

It works on:

* CentOS 7 (Dovecot-2.2.36), 8 (Dovecot-2.2.36)
* Debian 9 (Dovecot-2.2.27)
* Ubuntu 16.04 (Dovecot-2.2.22)
* Ubuntu 18.04 (Dovecot-2.2.33)
* OpenBSD 6.4 (Dovecot-2.2.36), 6.5, 6.6
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
    `imap` INT(11) DEFAULT NULL,
    `pop3` INT(11) DEFAULT NULL,
    `lda` INT(11) DEFAULT NULL,
    PRIMARY KEY (`username`),
    INDEX (`domain`),
    INDEX (`imap`),
    INDEX (`pop3`),
    INDEX (`lda`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

## Configure Dovecot

Open Dovecot config file `/etc/dovecot/dovecot.conf` (Linux/OpenBSD) or
`/usr/local/etc/dovecot/dovecot.conf` (FreeBSD), enable `last_login` plugin
for POP3 and IMAP services by appending plugin name to its `mail_plugins`
parameter like below, and add extra required settings. Note: we use `...` below
as a placeholder for your existing settings.

```
protocol lda {
    # Append plugin name `last_login` here
    mail_plugins = ... last_login
    ...
}

protocol lmtp {
    # Append plugin name `last_login` here
    mail_plugins = ... last_login
    ...
}

protocol imap {
    # Append plugin name `last_login` here
    mail_plugins = ... last_login
    ...
}

protocol pop3 {
    # Append plugin name `last_login` here
    mail_plugins = ... last_login
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
    last_login_key = last-login/%s/%u/%d
}
```

Create file `/etc/dovecot/dovecot-last-login.conf` (Linux/OpenBSD) or
`/usr/local/etc/dovecot/dovecot-last-login.conf` (FreeBSD) with content below:

!!! attention

    * For MySQL/MariaDB backends, please replace `my_secret_password` by the real
      password of SQL user `vmailadmin`.
    * For OpenLDAP backend:
        * replace `dbname=vmail` by `dbname=iredadmin`
        * replace `user=vmailadmin` by `user=iredadmin`
        * replace `my_secret_password` by the real password of SQL user `iredadmin`

```
connect = host=127.0.0.1 port=3306 dbname=vmail user=vmailadmin password=my_secret_password

map {
    pattern = shared/last-login/imap/$user/$domain
    table = last_login
    value_field = imap
    value_type = uint

    fields {
        username = $user
        domain = $domain
    }
}

map {
    pattern = shared/last-login/pop3/$user/$domain
    table = last_login
    value_field = pop3
    value_type = uint

    fields {
        username = $user
        domain = $domain
    }
}

# Track the time of last email delivered to mailbox via LDA.
# Please enable `last_login` plugin in the `protocol lda {}` block in dovecot.conf.
map {
    pattern = shared/last-login/lda/$user/$domain
    table = last_login
    value_field = lda
    value_type = uint

    fields {
        username = $user
        domain = $domain
    }
}

# Track the time of last email delivered to mailbox via LMTP,
# Please enable `last_login` plugin in the `protocol lmtp {}` block in dovecot.conf.
# We treat lmtp as lda, store the time in sql column `lda`.
map {
    pattern = shared/last-login/lmtp/$user/$domain
    table = last_login
    value_field = lda
    value_type = uint

    fields {
        username = $user
        domain = $domain
    }
}
```

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
+-----------------+--------+------------+------+------+
| username        | domain | imap       | pop3 | lda  |
+-----------------+--------+------------+------+------+
| postmaster@a.io | a.io   | 1554172329 | NULL | NULL |
+-----------------+--------+------------+------+------+
1 row in set (0.01 sec)
```

## References

* [Dovecot plugin: last_login](https://doc.dovecot.org/configuration_manual/lastlogin_plugin/)
