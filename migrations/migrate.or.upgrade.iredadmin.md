# Migrate iRedAdmin open source edition to iRedAdmin-Pro

[TOC]

This tutorial describes how to update or migrate iRedAdmin (either open source
edition or old iRedAdmin-Pro release) to the latest iRedAdmin release (again,
either open source edition or iRedAdmin-Pro).

## Requirements

* You __MUST__ have iRedAdmin open source edition or old iRedAdmin-Pro release
installed and running on your server before upgrading.

## Upgrade Steps

* Upload or copy the latest iRedAdmin-Pro to your server which has iRedAdmin
open source edition or old iRedAdmin-Pro release running. We assume you
uploaded it to `/root/iRedAdmin-Pro-{BACKEND}-x.y.z.tar.bz2` ({BACKEND} is one
of `LDAP`, `MySQL`, `PGSQL`). We will use iRedAdmin-Pro-x.y.z below for
example, please replace x.y.z by the real file name. For example,
`iRedAdmin-Pro-LDAP-2.1.2.tar.bz2`.

* Uncompress and upgrade iRedAdmin-Pro

```
# cd /root/
# tar xjf iRedAdmin-Pro-x.y.z.tar.bz2
# cd iRedAdmin-Pro-x.y.z/tools/
# bash upgrade_iredadmin.sh
```

That's all. If it doesn't work for you, please post a new topic in our
[online support forum](http://www.iredmail.org/forum/).

## Addition optional steps

* If you want to quarantine SPAM/Virus into SQL database and manage them with
iRedAdmin-Pro, please follow this tutorial to update Amavisd settings:
[Quarantining SPAM and Virus emails into SQL database](./quarantining.html)
