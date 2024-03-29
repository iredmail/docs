# Install iRedMail with a remote MySQL server

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

## Summary

This article introduces how to install iRedMail-__0.9.6__ with an existing remote
MySQL server.

We use below server IP addresses in our example:

* `192.168.1.100`: Remote MySQL server.
* `192.168.1.200`: iRedMail server. We're going to install the latest iRedMail
  on this server.

iRedMail won't install MySQL server (RPM/DEB package) on localhost with remote
MySQL server, but MySQL client tools are still required for remote SQL
connection.

## Requirements

In our case, remote MySQL server runs on server `192.168.1.100`. It must accept
remote connection from iRedMail server __BEFORE__ installing iRedMail, and we
must create a new SQL user with password and proper privileges for remote login
from iRedMail server (`192.168.1.200` in our case).

* Make sure your remote MySQL server accepts remote connection from iRedMail
  server. For example, you can check it with command `netstat`:

```
# netstat -ntlp | grep 3306
tcp        0      0 0.0.0.0:3306            0.0.0.0:*               LISTEN      2479/mysqld
```

If MySQL server is listening on only 127.0.0.1, please update parameter
`bind-address` in MySQL config file `my.cnf` to make sure it listens on all
available IPv4 addresses like below, restarting MySQL service is required:

* On Red Hat Enterprise Linux, CentOS, openSUSE, OpenBSD, it's `/etc/my.cnf`.
* On Debian, Ubuntu, it's `/etc/mysql/my.cnf`.
* On FreeBSD, it's `/var/db/mysql/my.cnf`.

```
# If you comment out this parameter, it listens on all available IPv6 addresses
bind-address = 0.0.0.0
```

* Make sure remote MySQL request will not be blocked by network firewall like
  iptables (Linux), ipfw (FreeBSD) or PF (OpenBSD).

* Create a new SQL user (`admin_iredmail`) with new password (`admin_password`)
  and all privileges on remote MySQL server (of course you must choose another
  strong password):

    !!! warning

        This SQL user will be used for daily backup, please do not delete it
        after iRedMail installation.

```
-- Run on remote MySQL server as root user
GRANT ALL PRIVILEGES ON *.* TO 'admin_iredmail'@'192.168.1.200' IDENTIFIED BY 'admin_password' WITH GRANT OPTION;
FLUSH PRIVILEGES;
FLUSH HOSTS;
```

With above commands, MySQL user `admin_iredmail` is allowed to connect from IP
address `192.168.1.200` with password `admin_password`.

__Notes__:

* `WITH GRANT OPTION` in above SQL command is required.
* Of course you can use `root` or other MySQL user as remote MySQL user name
  in above SQL command, but a custom user name should be better to help you
  understand what it's used for, and less confuse with default `root` user.
* You must replace `192.168.1.200` by the real IP address of your iRedMail
  server in above command.

If you tried to install iRedMail with this remote MySQL server before, please
backup existing databases __on remote MySQL server first__, then drop them and
delete related MySQL users, because they will be created by iRedMail
automatically on remote MySQL server:

```
-- Run on remote MySQL server as root user
DROP DATABASE amavisd;
DROP DATABASE iredadmin;
DROP DATABASE iredapd;
DROP DATABASE roundcubemail;
DROP DATABASE sogo;
DROP DATABASE vmail;

DROP USER 'amavisd'@'192.168.1.200';
DROP USER 'iredadmin'@'192.168.1.200';
DROP USER 'iredapd'@'192.168.1.200';
DROP USER 'roundcube'@'192.168.1.200';
DROP USER 'sogo'@'192.168.1.200';
DROP USER 'vmail'@'192.168.1.200';
DROP USER 'vmailadmin'@'192.168.1.200';
```

## Install iRedMail

Please follow iRedMail installation guide strictly, but start iRedMail
installer with below command instead of the original one (`bash iRedMail.sh`):

!!! warning

    If you use an IPv6 address for remote MySQL server address , please
    surround it with `[]` like this: `[fd01:2345:6789:1::1]`.

```
USE_EXISTING_MYSQL='YES' \
    MYSQL_SERVER_ADDRESS='192.168.1.100' \
    MYSQL_SERVER_PORT='3306' \
    MYSQL_ROOT_USER='admin_iredmail' \
    MYSQL_ROOT_PASSWD='admin_password' \
    MYSQL_GRANT_HOST='192.168.1.200' \
    bash iRedMail.sh
```

It will launch iRedMail installation wizard as usual.

Parameters we used in above command line:

* `USE_EXISTING_MYSQL`: Remote MySQL server address.
* `MYSQL_SERVER_ADDRESS`: Remote MySQL server address.
* `MYSQL_SERVER_PORT`: Remote MySQL server port. Default is `3306`.
* `MYSQL_ROOT_USER`: MySQL user name we created on remote MySQL server before installing iRedMail.
* `MYSQL_ROOT_PASSWD`: MySQL password that we created on remote MySQL server before installing iRedMail.
* `MYSQL_GRANT_HOST`: Hostname or IP address of iRedMail server.

iRedMail will create new SQL users for applications like Postfix, Amavisd,
Roundcube webmail, etc, and grant proper privileges to them which will connect
from iRedMail server.

One more optional parameter is `INITIALIZE_SQL_DATA`. If you don't want
iRedMail installer to initialize any sql records, please set
`INITIALIZE_SQL_DATA=NO`. This way iRedMail installer will just configure
related config files to use remote MySQL server.
