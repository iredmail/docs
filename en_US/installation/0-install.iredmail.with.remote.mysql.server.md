# Install iRedMail with a remote MySQL server

[TOC]

## Summary

This article describes how to install iRedMail (iRedMail-0.8.6 or later
releases) with a remote MySQL server, and you must choose MySQL backend in
iRedMail installation wizard.

We use below server IP addresses in our example:

* `192.168.1.100`: Remote MySQL server.
* `192.168.1.200`: iRedMail server. We're going to install the latest iRedMail
  on this server.

iRedMail won't install MySQL server (RPM/DEB package) on localhost with remote
MySQL server, but MySQL client tools are still required for remote connection.

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

If MySQL server is listening on only 127.0.0.1, you should comment out
`bind-address` parameter in MySQL config file `my.cnf` to make it listen on all
available network interfaces, and restart MySQL service.

* On Red Hat Enterprise Linux, CentOS, openSUSE, OpenBSD, it's `/etc/my.cnf`.
* On Debian, Ubuntu, it's `/etc/mysql/my.cnf`.
* On FreeBSD, it's `/var/db/mysql/my.cnf`.

```
#bind-address = 127.0.0.1
```

* Make sure remote MySQL request will not be blocked by network firewall like
  iptables (Linux), ipfw (FreeBSD) or PF (OpenBSD).

* Create a new SQL user (`admin_iredmail`) with new password (`admin_password`)
  and all privileges on remote MySQL server (of course you must choose another
  strong password):

```
mysql> GRANT ALL PRIVILEGES ON *.* TO 'admin_iredmail'@'192.168.1.200' IDENTIFIED BY 'admin_password' WITH GRANT OPTION;
mysql> FLUSH PRIVILEGES;
mysql> FLUSH HOSTS;
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
* It's recommended to delete this user AFTER iRedMail installation, it won't
  be used anymore. We will give you SQL command to delete it later.

If you tried to install iRedMail with this remote MySQL server before, please
backup existing databases __on remote MySQL server first__, then drop them and
delete related MySQL users, because they will be created by iRedMail
automatically on remote MySQL server:

```
mysql> DROP DATABASE amavisd;
mysql> DROP DATABASE cluebringer;
mysql> DROP DATABASE iredadmin;
mysql> DROP DATABASE roundcubemail;
mysql> DROP DATABASE sogo;
mysql> DROP DATABASE vmail;

mysql> DROP USER 'amavisd'@'192.168.1.200';
mysql> DROP USER 'cluebringer'@'192.168.1.200';
mysql> DROP USER 'iredadmin'@'192.168.1.200';
mysql> DROP USER 'roundcube'@'192.168.1.200';
mysql> DROP USER 'sogo'@'192.168.1.200';
mysql> DROP USER 'vmail'@'192.168.1.200';
mysql> DROP USER 'vmailadmin'@'192.168.1.200';
```

## Install iRedMail

Please follow iRedMail installation guide strictly, but start iRedMail
installer with below command instead of the original one (`bash iRedMail.sh`):

```
# MYSQL_SERVER='192.168.1.100' MYSQL_ROOT_USER='admin_iredmail' MYSQL_GRANT_HOST='192.168.1.200' bash iRedMail.sh
```

It will launch iRedMail installation wizard as usual. When it asks MySQL root
password, please input the password (`admin_password` in our case) we created
on remote MySQL server.

Parameters we used in above command line:

* `MYSQL_SERVER`: Remote MySQL server address.
* `MYSQL_ROOT_USER`: MySQL user name we created on remote MySQL server before installing iRedMail.
* `MYSQL_GRANT_HOST`: Hostname or IP address of iRedMail server.

iRedMail will create new SQL users for applications like Postfix, Amavisd,
Roundcube webmail, etc, and grant proper privileges to them which will connect
from iRedMail server.

One more optional parameter is `MYSQL_SERVER_PORT`. it specifies listen port
of remote MySQL server. Default one is `3306`, you can change it if remote
MySQL server is running on a different port.

## After iRedMail installation

As mentioned above, it's now ok to delete the new MySQL user `admin_iredmail`
on remote MySQL server. It will not be used anymore.

```
mysql> DROP USER 'admin_iredmail'@'192.168.1.200';
```
