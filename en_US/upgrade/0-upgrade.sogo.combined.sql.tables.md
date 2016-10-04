# Upgrade SOGo SQL schema

With default SOGo settings in iRedMail-0.9.5-1 and earler releases, SOGo will
create 3 SQL tables for each user, this introduces some issues:

* Your `sogo` database will contains lots of sql tables.
* MySQL limits the table name to 64 characters, if your email address is long,
  SOGo cannot create required table for you. Related bug report in SOGo bug
  tracker: <https://sogo.nu/bugs/view.php?id=3447>

We need few steps to migrate SOGo to use 9 SQL tables in total instead of
creating 3 tables for each user. This solution was first introduced in
SOGo-3.0.0.

!!! warning "Warning and Disclaimer"

    It's strongly recommended to try steps below on a testing machine BEFORE
    you do it in production, we (iRedMail team) don't take any responsibility
    for data lose. You have been warned.

* __BACKUP BACKUP BACKUP!!!__

    Backup all SOGo data before you try any commands mentioned in this tutorial,
    including SOGo database, and config file (`/etc/sogo/sogo.conf` on
    Linux/OpenBSD, `/usr/local/etc/sogo/sogo.conf` on FreeBSD).

* Stop SOGo service.
* Stop memcached service.
* Convert old data to new format by running one shell script shipped in SOGo
  package. You can find it with the package management tool like
  `rpm -ql sogo | grep 'combined'` on (RHEL/CentOS),
  `dpkg -L sogo | grep 'combined'` on Debian/Ubuntu, etc.
  Below is sample output on CentOS:

```
# rpm -ql sogo | grep 'combined'
/usr/share/doc/sogo-3.1.5.20160928/sql-update-3.0.0-to-combined-mysql.sh
/usr/share/doc/sogo-3.1.5.20160928/sql-update-3.0.0-to-combined.sh
```

If you are running iRedMail with OpenLDAP or MySQL/MariaDB backend, you need
the first one with `mysql` in file name: `sql-update-3.0.0-to-combined-mysql.sh`,
if you are running iRedMail with PostgreSQL backend, you need the second one
(`sql-update-3.0.0-to-combined.sh`). We use MySQL one for example.

Now run the script as root user (or with `sudo`):

```
bash /usr/share/doc/sogo-3.1.5.20160928/sql-update-3.0.0-to-combined-mysql.sh
```

* Open `/etc/sogo/sogo.conf`, make sure you have 3 NEW parameters:

    * `OCSCacheFolderURL`
    * `OCSStoreURL`
    * `OCSAclURL`

    If you don't have them after running above command, add them manually
    like below (please use the correct SQL username and password):

```
OCSCacheFolderURL = "mysql://sogo:<password>@127.0.0.1:3306/sogo/sogo_cache_folder";
OCSStoreURL = "mysql://sogo:<password>@127.0.0.1:3306/sogo/sogo_store";
OCSAclURL = "mysql://sogo:<password>@127.0.0.1:3306/sogo/sogo_acl";
```

* Start memcached service.
* Start SOGo service. SOGo will create new SQL tables as defined in above new
  parameters:

    * `sogo_cache_folder`
    * `sogo_store`
    * `sogo_acl`

* Login to SOGo webmail, make sure no data lost.

If there's something wrong, please check SOGo log file (`/var/log/sogo/sogo.log`)
to see whether or not it reports some error. Report errors, issues, questions
in our online support forum: <http://www.iredmail.org/forum/>.
