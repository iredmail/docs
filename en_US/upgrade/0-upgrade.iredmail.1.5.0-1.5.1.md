# Upgrade iRedMail from 1.5.0 to 1.5.1

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! note "Remote Upgrade Assistance"

    Check out our [remote upgrade support](https://www.iredmail.org/support.html) if you need assistance.

## ChangeLog

- Dec 31, 2021: initial release.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.5.1
```

### Upgrade Roundcube webmail to the latest stable release (1.5.2)

!!! warning "MySQL and MariaDB server tunning"

    On CentOS 7, Debian 10 and Ubuntu 18.04, you must add 2 parameters under
    `[mysqld]` section in MySQL or MariaDB config file to avoid error
    `Specified key was too long; max key length is 767 bytes`:

    - On CentOS 7: it's `/etc/my.cnf`
    - On Debian 10: it's `/etc/mysql/my.cnf`

    ```innodb_large_prefix=ON```
    ```innodb_file_format=Barracuda```

Roundcube 1.5.2 addresses one XSS security fix, also fixes some monir issues.

Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release:

* [How to upgrade Roundcube](https://github.com/roundcube/roundcubemail/wiki/Upgrade).
