# Upgrade iRedAPD

> iRedAPD source code is hosted on [BitBucket](https://bitbucket.org/zhb/iredapd/).

> Release Notes are available here: [iRedAPD Release Notes](./iredapd.releases.html).

> If you're trying to upgrade iRedAPD-1.3.x or earlier releases to the latest
> iRedAPD, please check this tutorial instead: 
> [Upgrade iRedAPD from v1.3.x or earlier versions to latest release](./upgrade.old.iredapd.html).

> We provide remote upgrade service, check [the price](../support.html) and [contact us](../contact.html).

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

Important notes:

* It's recommended to enable plugin `reject_null_sender` in iRedAPD-1.4.4 or
  newer releases to prevent authenticated user sending spam as null sender.

* Plugin `amavisd_wblist` is required if you manage white/blacklists with
  iRedAdmin-Pro.
