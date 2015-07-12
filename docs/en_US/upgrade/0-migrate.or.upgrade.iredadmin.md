# Migrate or upgrade iRedAdmin

[TOC]

> We provide remote upgrade service, check [the price](../support.html) and [contact us](../contact.html).

This tutorial describes how to update or migrate iRedAdmin (either open source
edition or old iRedAdmin-Pro release) to the latest iRedAdmin release (again,
either open source edition or iRedAdmin-Pro).

## Requirements

You __MUST__ have iRedAdmin open source edition or old iRedAdmin-Pro release
installed and running on your server before upgrading.

## Download the latest iRedAdmin

* iRedAdmin (open source edition) is available for download [here](http://www.iredmail.org/yum/misc/).
* How to download the latest iRedAdmin-Pro

    All customers can get download link of new release by following below steps:

    * Login to iRedAdmin-Pro as global admin.
    * Click `License` button on the top-right corner. it will show you basic
      license info and a `Download` button if new version is available.
    * Click `Download` button, your mailbox (license owner) will receive an email
      with download link in a short time. Note: if your mail server has greylisting
      enabled, it may take longer, please be patient and don't request download
      link again and again.

    if you cannot download iRedAdmin-Pro for some reason, [contact us](../contact.html) directly.

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

    * For OpenLDAP/MySQL/MariaDB backends: <pre>sql> USE iredadmin;
sql> ALTER TABLE log MODIFY COLUMN ip VARCHAR(40) NOT NULL DEFAULT '';
sql> ALTER TABLE log MODIFY COLUMN event VARCHAR(20) NOT NULL DEFAULT '';</pre>
    * For PostgreSQL: <pre>sql> \c iredadmin;
sql> ALTER TABLE log ALTER COLUMN ip TYPE VARCHAR(40);
sql> ALTER TABLE log ALTER COLUMN event TYPE VARCHAR(20);</pre>

That's all. If it doesn't work for you, please post a new topic in our
[online support forum](http://www.iredmail.org/forum/).

## Additional steps

* To quarantine SPAM/Virus into SQL database and manage them with
  iRedAdmin-Pro, please follow this tutorial to update Amavisd settings:
  [Quarantining SPAM and Virus emails into SQL database](./quarantining.html)

* To manage white/blacklist with iRedAdmin-Pro, please enable
  per-recipient policy lookup in Amavisd, and enable plugin `amavisd_wblist`
  in iRedAPD config file (`/opt/iredapd/settings.py`, parameter `plugins =`):
  [Amavisd: Enable per-recipient policy lookup](./amavisd.per-recipient.policy.lookup.html)

    Note: Cluebringer still provides white/blacklists, but iRedAdmin-Pro
    doesn't manage them anymore after iRedMail-0.9.0 release. So please
    migreate Cluebringer white/blacklists to Amavisd database by following
    this [forum post](http://www.iredmail.org/forum/post35480.html#p35480).
