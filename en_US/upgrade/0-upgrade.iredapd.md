# Upgrade iRedAPD

> Release Notes are available here: [iRedAPD Release Notes](./iredapd.releases.html).

> If you're trying to upgrade iRedAPD-1.3.x or earlier releases to the latest
> iRedAPD, please check this tutorial instead: 
> [Upgrade iRedAPD from v1.3.x or earlier versions to latest release](./upgrade.old.iredapd.html).

> We offer remote upgrade service, check [the price](../support.html) and [contact us](../contact.html).

This tutorial describes how to upgrade iRedAPD from `1.4.0` or later releases
to the latest stable release. It's applicable on all Linux/BSD distributions
supported by iRedMail.

* Download the latest stable release here: [http://www.iredmail.org/yum/misc/](http://www.iredmail.org/yum/misc/)
  For example, iRedAPD-1.6.0.tar.bz2.
* Upload it to your iRedMail server. Assume it's `/root/iRedAPD-1.6.0.tar.bz2`.
* Extract downloaded package and execute upgrade script:

```
# cd /root
# tar xjf iRedAPD-1.6.0.tar.bz2
# cd iRedAPD-1.6.0/tools/
# bash upgrade_iredapd.sh
```

That's all.

----

If you're upgrading iRedAPD-1.6.0 (or older release) to iRedAPD-1.7.0 (or newer
release), please create new SQL database `iredapd` with sql commands below:

> Note: You can create a strong password for SQL user with command:
> `eval </dev/urandom tr -dc A-Za-z0-9 | (head -c $1 &>/dev/null || head -c 30)`

* For OpenLDAP, MySQL, MariaDB backends, please login to SQL server as `root`
  user, then create required database (replace sample password `passwd` in
  sql command by the strong password you generated):

```
$ mysql -u root -p

sql> CREATE DATABASE IF NOT EXISTS iredapd DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
sql> USE iredapd;
sql> SOURCE /opt/iredapd/SQL/iredapd.mysql;
sql> GRANT ALL ON iredapd.* TO "iredapd"@"localhost" IDENTIFIED BY "passwd";
sql> FLUSH PRIVILEGES;
```

Now update iRedAPD SQL database name, sql user name, and password in iRedAPD
config file `/opt/iredapd/settings.py` (all parameters start with `iredapd_db_`).

* For PostgreSQL backend, please copy `/opt/iredapd/SQL/iredapd.pgsql` to `/tmp`
  first, then switch to system user `postgres` (It's `_postgresql` on OpenBSD)
  with `su` command, execute sql commands below:

```
# cp /opt/iredapd/SQL/iredapd.pgsql /tmp/
# chmod 0755 /tmp/iredapd.pgsql

---- Switch to system user `postgres` here ----

$ psql

-- Create database
sql> CREATE DATABASE iredapd WITH TEMPLATE template0 ENCODING 'UTF8';

-- Create user
sql> CREATE USER iredapd WITH ENCRYPTED PASSWORD 'passwd' NOSUPERUSER NOCREATEDB NOCREATEROLE;
sql> ALTER DATABASE iredapd OWNER TO iredapd;

-- Import SQL template
sql> \c iredapd;
sql> \i /tmp/iredapd.pgsql;

-- Grant permissions
sql> GRANT ALL ON throttle,throttle_tracking TO iredapd;
sql> GRANT ALL ON throttle_id_seq,throttle_tracking_id_seq TO iredapd;
```

Now update iRedAPD SQL database name, sql user name, and password in iRedAPD
config file `/opt/iredapd/settings.py` (all parameters start with `iredapd_db_`).

----

Important notes:

* It's recommended to enable plugin `reject_null_sender` in iRedAPD-1.4.4 or
  newer releases to prevent authenticated user sending spam as null sender.

* Plugin `amavisd_wblist` is required if you manage white/blacklists with
  iRedAdmin-Pro.

# See Also

* iRedAPD source code is hosted on [BitBucket](https://bitbucket.org/zhb/iredapd/).
