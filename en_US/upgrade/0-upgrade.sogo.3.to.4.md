# Upgrade SOGo from v3 to v4

[TOC]

SOGo v4 was released on Mar 7, 2018 by the SOGo team (<https://sogo.nu>), it
will become the main branch with most active development.
If you're satisfied with SOGo v3, you're free to stick to it.

## Upgrade SOGo On RHEL/CentOS

* Backup config files first:

```
mkdir -p /root/sogo-backup/{sogo,sysconfig}
cp /etc/sogo/* /root/sogo-backup/sogo/
cp /etc/sysconfig/sogo /root/sogo-backup/sysconfig/
```

* Backup its SQL database:

```
bash /var/vmail/backup/backup_sogo.sh
```

* Open file `/etc/yum.repos.d/sogo.repo`, change the version number in
  `baseurl=` line from `3` to `4`:

```
baseurl=https://packages.inverse.ca/SOGo/nightly/4/rhel/$releasever/$basearch/
```

* SOGo relies on the GNUstep packages provided by SOGo team, and must not use
  the packages from EPEL repo. Please open file `/etc/yum.repos.d/epel.repo`,
  make sure you have line like below:

```
exclude=gnustep*
```

* Upgrade SOGo packages:

```
yum clean all
yum update 'sogo*' 'sope*'
```

* Run the script shipped in SOGo-4.x to update SQL structure:
    * For LDAP and MySQL/MariaDB backends:

    ```
    bash /usr/share/doc/sogo-4.*/sql-update-3.2.10_to_4.0.0-mysql.sh
    ```

    * For PostgreSQL backend:

    ```bash /usr/share/doc/sogo-4.*/sql-update-3.2.10_to_4.0.0.sh```

* Restart SOGo and memcached services:

```
service memcached restart
service sogod restart
```

## Upgrade SOGo On Debian/Ubuntu

* Backup config files first:

```
mkdir -p /root/sogo-backup/{sogo,default}
cp /etc/sogo/* /root/sogo-backup/sogo/
cp /etc/default/sogo /root/sogo-backup/default/
```

* Backup its SQL database:

```
bash /var/vmail/backup/backup_sogo.sh
```

* Open file `/etc/apt/sources.list` or `/etc/apt/sources.list.d/sogo-nightly.list`,
  change the version number `3` to `4`, like below:

```
# Debian
https://packages.inverse.ca/SOGo/nightly/4/debian ...

# Ubuntu
https://packages.inverse.ca/SOGo/nightly/4/ubuntu ...
```

* Upgrade SOGo packages:

```
apt-get update
apt-get install --only-upgrade sogo sogo-activesync
```

* Run the script shipped in SOGo-4.x to update SQL structure:
    * For LDAP and MySQL/MariaDB backends:

    ```
    bash /usr/share/doc/sogo/sql-update-3.2.10_to_4.0.0-mysql.sh
    ```

    * For PostgreSQL backend:

    ```bash /usr/share/doc/sogo/sql-update-3.2.10_to_4.0.0.sh```

* Restart SOGo and memcached services:

```
service memcached restart
service sogo restart
```

## Upgrade SOGo On FreeBSD

FreeBSD ports tree still ships SOGo-3, so no SQL structure change after you
update ports `www/sogo3` and `www/sogo3-activesync`.

## Upgrade SOGo On OpenBSD

OpenBSD 6.3 still ships SOGo-3, so no SQL structure change after you update
sogo/sope packages with `pkg_add` command.

## Troubleshooting

If SOGo doesn't work as expected, please check its log file
`/var/log/sogo/sogo.log`. If you don't understand what the error message means,
please extract related error message and post to our online support forum:
<https://forum.iredmail.org/>.
