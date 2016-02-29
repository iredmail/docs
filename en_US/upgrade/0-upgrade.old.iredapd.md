# Upgrade iRedAPD from v1.3.x or earlier versions to latest release

> iRedAPD source code is hosted on [BitBucket](https://bitbucket.org/zhb/iredapd/).

> Release Notes are available here: [iRedAPD Release Notes](./iredapd.releases.html).

> If you're trying to upgrade iRedAPD-1.4.0 or later releases to the latest
> iRedAPD, please check this tutorial instead: [Upgrade iRedAPD](./upgrade.iredapd.html)

> We provide remote upgrade service, check [the price](../support.html) and [contact us](../contact.html).

This tutorial describes how to upgrade iRedAPD from v1.3.x or earlier versions
to the later releases, it's applicable on all Linux/BSD distributions supported
by iRedMail.

!!! note "Important Notes"

    * Since iRedAPD-`1.4.0`, we use Python source file as config file, not
      `.ini` format anymore.
    * We don't need second instance `iredapd-rr` anymore (it listens on port
      `7778`), just one instance, one listen port `7777` is required.

Steps to upgrade iRedAPD-1.3.x or earlier versions:

* Download the latest stable release here: [http://iredmail.org/yum/misc/](http://iredmail.org/yum/misc/)
  For example, iRedAPD-1.4.4.tar.bz2.
* Upload it to your iRedMail server. Assume it's `/root/iRedAPD-1.4.4.tar.bz2`
  on the server.
* Extract downloaded package and move to `/opt/`, set correct owner and permission:

```
# tar xjf /root/iRedAPD-1.4.4.tar.bz2 -C /opt/
# cd /opt
# chown -R iredapd:iredapd iRedAPD-1.4.4
# chmod -R 0700 iRedAPD-1.4.4
```

* Generate new config file from sample file, and set correct file owner and permission.

```
# cd /opt/iRedAPD-1.4.4/
# cp settings.py.sample settings.py
# chown -R iredapd:iredapd settings.py
# chmod -R 0400 settings.py
```

__WARNING__: Config file `/opt/iredapd/settings.py` contains sensitive infomation
(username, password), please don't make it world-readable. Permission 0400 is
the best.

* Open iRedAPD config file `/opt/iredapd/settings.py`, and sync settings with
  old iRedAPD config file `/opt/iRedAPD-[OLD-VERSION]/etc/iredapd.ini`.

    * In old version, parameters under `[ldap]` section are now new parameters
      start with `ldap_`.
    * In old version, all parameters under `[sql]` (or `[mysql]`) section are
      now new parameters start with `sql_`.

* Remove symbol link of old release:

```
# rm -i /opt/iredapd               # <- Don't not end with '/'.
```

* Copy new RC script. We have scripts for different Linux/BSD distributions,
  please copy the correct one for your distribution:

    * `/opt/iredapd/rc_scripts/iredapd.rhel`: For Red Hat, CentOS, Scientific Linux.
    * `/opt/iredapd/rc_scripts/iredapd.debian`: For Debian and Ubuntu.
    * `/opt/iredapd/rc_scripts/iredapd.freebsd`: For FreeBSD. Please copy to `/usr/local/etc/rc.d/`.
    * `/opt/iredapd/rc_scripts/iredapd.openbsd`: For OpenBSD. Please copy to `/etc/rc.d/`.

```
# cp /opt/iredapd/rc_scripts/iredapd.rhel /etc/init.d/iredapd
# chmod +x /etc/init.d/iredapd
```

* Create symbol link to the latest release:

```
# cd /opt/
# ln -s iRedAPD-1.4.4 iredapd
```

* Restart iRedAPD service:

```
#
# ---- On Linux ----
#
# /etc/init.d/iredapd restart

#
# ---- On FreeBSD ----
#
# /usr/local/etc/rc.d/iredapd restart

#
# ---- On OpenBSD ----
#
# /etc/rc.d/iredapd restart
```

* If you don't have file `/etc/init.d/iredapd-rr` (on Linux), or
  `/etc/rc.d/iredapd-rr` (on OpenBSD), or `/usr/local/etc/rc.d/iredapd-rr`
  (on FreeBSD), it's safe to ignore below steps. But if you have it, please
  stop service `iredapd-rr`, then move all enabled plugin names listed in
  `/opt/iRedAPD-[OLD_VERSION]/etc/iredapd-rr.ini` to new config file
  `/opt/iredapd/settings.py`, in parameter `plugins = `.

```
# /etc/init.d/iredapd-rr stop
# rm /etc/init.d/iredapd-rr
```

Check whether you have `check_policy_service inet:127.0.0.1:__7778__` in Postfix
config file `/etc/postfix/main.cf` (Linux/OpenBSD) or
`/usr/local/etc/postfix/main.cf` (FreeBSD), if you have it, please remove it,
then restart Postfix service.
