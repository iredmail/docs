# mlmmjadmin upgrade tutorial (RESTful API server used to manage mlmmj mailing list)

!!! warning

    * mlmmjadmin-3.0 and later releases __require Python 3.5+__, only listed
      distribution releases are qualified to upgrade:

        - CentOS 7 and later
        - Debian 9 and later
        - Ubuntu 18.04 and later
        - FreeBSD with latest ports tree
        - OpenBSD 6.6 and later

      If you're running an old Linux/BSD release which doesn't have Python
      3.5+, please stay with mlmmjadmin-2.1, it's the last release supports
      Python 2. if you need to upgrade to mlmmjadmin-2.1, please follow this
      upgrade tutorial instead: [Upgrade mlmmjadmin to v2.1](./upgrade.mlmmjadmin.py2.html).

## Summary

* mlmmjadmin is a RESTful API server used to manage [mlmmj](http://mlmmj.org) mailing list.
* Source code is hosted on [GitHub](https://github.com/iredmail/mlmmjadmin).
* Download the [latest stable release](https://github.com/iredmail/mlmmjadmin/releases)
  and check its release notes.

## Upgrade mlmmjadmin

* Login to the iRedMail server first, and switch to root user with `su` or `sudo`.
* Download the latest package with `wget` command, extract download package and
  run a script to upgrade it.

```
cd /root/
wget https://github.com/iredmail/mlmmjadmin/archive/3.4.0.tar.gz
tar zxf 3.4.0.tar.gz
cd mlmmjadmin-3.4.0/tools/
bash upgrade_mlmmjadmin.sh
```

* That's all.
