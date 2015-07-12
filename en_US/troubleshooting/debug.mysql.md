# Log executed SQL commands in MySQL/MariaDB

> Don't know where MySQL config file is? check this tutorial:
> [Locations of configuration and log files of mojor components](file.locations.html#mysql-mariadb).

To log executed SQL commands, please add below two settings in MySQL/MariaDB
config file `my.cnf`:

```
[mysqld]
general_log = 1
general_log_file = /var/log/mysql.log
```

Then restart MySQL/MariaDB service.

Note: MySQL/MariaDB daemon user must have permission to write this log file.
