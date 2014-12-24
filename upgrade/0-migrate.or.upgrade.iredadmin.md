# Migrate or upgrade iRedAdmin

[TOC]

This tutorial describes how to update or migrate iRedAdmin (either open source
edition or old iRedAdmin-Pro release) to the latest iRedAdmin release (again,
either open source edition or iRedAdmin-Pro).

## Requirements

* You __MUST__ have iRedAdmin open source edition or old iRedAdmin-Pro release
installed and running on your server before upgrading.

## Upgrade Steps

* Upload or copy the latest iRedAdmin to your server which has iRedAdmin
open source edition or old iRedAdmin-Pro release running. We assume you
uploaded it to `/root/iRedAdmin-{BACKEND}-x.y.z.tar.bz2` ({BACKEND} is one
of `LDAP`, `MySQL`, `PGSQL`). We will use iRedAdmin-x.y.z below for
example, please replace x.y.z by the real file name. For example,
`iRedAdmin-Pro-LDAP-2.1.2.tar.bz2`.

* Uncompress and upgrade iRedAdmin:

```
# cd /root/
# tar xjf iRedAdmin-x.y.z.tar.bz2
# cd iRedAdmin-x.y.z/tools/
# bash upgrade_iredadmin.sh
```

* If you're running iRedMail-`0.8.7` or earlier version, please login to SQL
  server as root user (for MySQL/MariaDB, it's `root` user, for PostgreSQL,
  it's `postgres` user) to alter SQL table `iredadmin.log` with below SQL command:

    * For MySQL/MariaDB: <pre>sql> ALTER TABLE log MODIFY COLUMN ip VARCHAR(40) NOT NULL DEFAULT '';</pre>
    * For PostgreSQL: <pre>sql> ALTER TABLE log ALTER COLUMN ip TYPE varchar(40);</pre>

That's all. If it doesn't work for you, please post a new topic in our
[online support forum](http://www.iredmail.org/forum/).

## Addition steps

* To quarantine SPAM/Virus into SQL database and manage them with
  iRedAdmin-Pro, please follow this tutorial to update Amavisd settings:
  [Quarantining SPAM and Virus emails into SQL database](./quarantining.html)

* To manage white/blacklist with iRedAdmin-Pro, please enable
  per-recipient policy lookup in Amavisd, and enable plugin `amavisd_wblist`
  in iRedAPD config file (`/opt/iredapd/settings.py`, parameter `plugins =`):
  [Amavisd: Enable per-recipient policy lookup](./amavisd.per-recipient.policy.lookup.html)

    Note: Cluebringer still provides white/blacklists, but iRedAdmin-Pro
    doesn't manage them anymore after iRedMail-0.9.0 release.
