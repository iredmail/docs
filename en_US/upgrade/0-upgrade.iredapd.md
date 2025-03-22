# Upgrade iRedAPD

!!! attention

    * Release Notes are available here: [iRedAPD Release Notes](./iredapd.releases.html).

!!! warning

    * iRedAPD-4.0 and later releases __require Python 3.5+__, only listed
      distribution releases are qualified to upgrade:

        - CentOS 7 and later
        - Debian 9 and later
        - Ubuntu 18.04 and later
        - FreeBSD with latest ports tree
        - OpenBSD 6.6 and later

      If you're running an old Linux/BSD release which doesn't have Python
      3.5+, please stay with iRedAPD-3.6, it's the last release supports Python
      2. if you need to upgrade to iRedAPD-3.6, please follow this upgrade
      tutorial instead: [Upgrade iRedAPD from v1.4.0 or later releases to v3.6](./upgrade.iredapd.py2.html).

This tutorial describes how to upgrade iRedAPD to the latest stable release on
listed distribution releases listed above.

Run commands below on your iRedMail server:

```
cd /root
wget -O iRedAPD-5.9.0.tar.gz https://github.com/iredmail/iRedAPD/archive/5.9.0.tar.gz
tar zxf iRedAPD-5.9.0.tar.gz
cd iRedAPD-5.9.0/tools/
bash upgrade_iredapd.sh
```

That's all.

## See Also

* [Manage iRedAPD (white/blacklists, greylisting, throttling and more)](./manage.iredapd.html)
* [Enable SRS (Sender Rewriting Scheme) support](./srs.html)
