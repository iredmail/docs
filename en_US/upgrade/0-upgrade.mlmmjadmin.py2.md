# mlmmjadmin upgrade tutorial (RESTful API server used to manage mlmmj mailing list)

## Summary

* mlmmjadmin is a RESTful API server used to manage [mlmmj](http://mlmmj.org) mailing list.
* Source code is hosted on [GitHub](https://github.com/iredmail/mlmmjadmin).
* Download the [latest stable release](https://github.com/iredmail/mlmmjadmin/releases)
  and check its release notes.


## Upgrade mlmmjadmin

* Login to the iRedMail server first, and switch to root user with `su` or `sudo`.
* Download the latest package with `wget` command, extract download package and
  run a script to upgrade it. Note: We use version `2.1` for example here, `2.1.tar.gz`.

```
cd /root/
wget https://github.com/iredmail/mlmmjadmin/archive/2.1.tar.gz
tar zxf 2.1.tar.gz
cd mlmmjadmin-2.1/tools/
bash upgrade_mlmmjadmin.sh
```

* That's all.
