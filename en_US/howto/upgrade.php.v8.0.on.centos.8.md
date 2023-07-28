# Upgrade php to v8.0 on CentOS Stream / Rocky / AlmaLinux 8

CentOS Stream / Rocky / AlmaLinux 8 offers both php 7 and 8 in official yum
repository `AppStream`, we just need to switch php module to 8.0 with steps
below:

> Please pay close attention to the package names it removes in first command,
> we need to reinstall them later.

```
dnf remove "php*"
dnf module reset php
dnf module enable php:8.0
dnf module switch-to php:8.0
```

Then (re-)install the packages removed by first command above:

```
dnf install php php-{cli,common,gd,fpm,mbstring,xml,json,intl,zip,mysqlnd,ldap,pgsql}
```

Then restart php-fpm service:

```
systemctl restart php-fpm
```
