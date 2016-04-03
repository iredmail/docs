# Migrate from Cluebringer to iRedAPD

[TOC]

## Summary

iRedMail-0.9.3 and later releases drop Cluebringer, and replace it by iRedAPD,
because:

* Cluebringer is not under active development anymore.
* No new Cluebringer release since 2013 (the latest stable release doesn't
  support IPv6).
* Cluebringer is not available in Debian (jessie) official repositories
  anymore, developers didn't bring it back.

Not all Cluebringer features are implemented in iRedAPD, but the most important
2 features have been implemented:

* throttling
* greylisting

If you need other Cluebringer features, please stay with Cluebringer and let
us know which features you need, so that we can implement it in future release
of iRedAPD.

## Migrate to iRedAPD

### Upgrade iRedAPD to 1.7.0 or later releases

Please Make sure you're running iRedAPD-1.7.0 or later release, you can check
the version number with command below:

```
grep '__version__' /opt/iredapd/libs/__init__.py
```

If you're not running iRedAPD-1.7.0 or later release, please follow our
tutorial to upgrade it: [Upgrade iRedAPD](./upgrade.iredapd.html).

### Migrate Cluebringer to iRedAPD

iRedAPD-1.7.0 and later release ship two scripts to migrate greylisting and
throttling settings from Cluebringer:

* `/opt/iredapd/tools/migrate_cluebringer_greylisting.py`: used to migrate
  greylisting settings.
* `/opt/iredapd/tools/migrate_cluebringer_throttle.py`: used to migrate
  throttling settings.

Please open above two files, update below parameters with correct SQL server
address, port, database name, username and password for your existing
Cluebringer database. You can find them in files below:

* On RHEL/CentOS, it's `/etc/policyd/cluebringer.conf`.
* Debian/Ubuntu: it's `/etc/cluebringer/cluebringer.conf`.
* FreeBSD: it's `/usr/local/etc/cluebringer.conf`.
* OpenBSD: Not applicable, cluebringer is not available on OpenBSD.

```
cluebringer_db_host = '127.0.0.1'
cluebringer_db_port = 3306
cluebringer_db_name = 'cluebringer'
cluebringer_db_user = 'root'
cluebringer_db_password = ''
```

Then run below commands to migrate greylisting and throttling settings:

```
# cd /opt/iredapd/tools/
# python migrate_cluebringer_greylisting.py
# python migrate_cluebringer_throttle.py
```

That's it.

## After migration

### Enable required plugins, remove old plugins

> Restarting iRedAPD service is required if you changed its config file.

* To enable whitelists, blacklists, greylisting and throttling offered by
  iRedAPD, please enable plugins `amavisd_wblist`, `greylisting` and `throttle`
  in iRedAPD config file like below:

```
# File: /opt/iredapd/settings.py

plugins = [..., 'amavisd_wblist', 'greylisting', 'throttle']
```

The order of plugin names doesn't matter.

* Several plugins in old iRedAPD have been removed, you should remove them
  from parameter `plugins =` in iRedAPD config file:

    * ldap_amavisd_block_blacklisted_senders
    * ldap_recipient_restrictions
    * sql_user_restrictions
    * amavisd_message_size_limit

    First 3 plugins are replaced by `amavisd_wblist`, last one is replaced by
    plugin `throttle`.

### Disable Cluebringer in Postfix

After migrated to iRedAPD, we need to update Postfix config file
`/etc/postfix/main.cf` (Linux) or `/usr/local/etc/postfix/main.cf` (FreeBSD)
to remove Cluebringer settings:

* Remove all `check_policy_service inet:127.0.0.1:10031` in `main.cf`, like below:

```
smtpd_recipient_restrictions =
    ...
    check_policy_service inet:127.0.0.1:10031       # <- Remove this line
    ...

smtpd_end_of_data_restrictions =
    ...
    check_policy_service inet:127.0.0.1:10031       # <- Remove this line
    ...
```

### Enable iRedAPD in Postfix

Make sure iRedAPD are enabled in __BOTH__ `smtpd_recipient_restrictions`
and `smtpd_end_of_data_restrictions` like below:

```
smtpd_recipient_restrictions =
    ...
    check_policy_service inet:127.0.0.1:7777
    permit_mynetworks
    ...

smtpd_end_of_data_restrictions = check_policy_service inet:127.0.0.1:7777
```

!!! note

    If you have additional IP addresses/networks listed in Postfix setting
    "mynetworks =", you have to list them all in iRedAPD config file
    (`/opt/iredapd/settings.py`) too, like below:

    ```MYNETWORKS = ['xx.xx.xx.xx', 'xx.xx.xx.0/24', ...]```

### Restart Postfix service

Reloading or restarting Postfix service is required after changed `main.cf`.

* On Linux/FreeBSD:

```
# service postfix restart
```

* On OpenBSD:

```
# /etc/rc.d/postfix restart
```

### Stop Cluebringer service, and remove Cluebringer packages

We don't need Cluebringer anymore, so it's ok to stop cluebringer service and
remove the packages:

* On RHEL/CentOS:

```
# service cbpolicyd stop && yum remove cluebringer
```

* On Debian/Ubuntu:

```
# service postfix-cluebringer stop && apt-get remove --purge postfix-cluebringer
```

* On FreeBSD:

```
# service policyd2 stop && cd /usr/ports/mail/policyd2/ && make deinstall
```

* Edit root user's cron job, remove the one used to clean up Cluebringer SQL
  database:

    1. Run command to edit root user's cron job: ```# crontab -e -u root```
    1. Find cron job like below, remove it or comment out it:

```
3   3   *   *   *   /usr/sbin/cbpadmin --config=/etc/policyd/cluebringer.conf --cleanup >/dev/null
```

* Optionally, you can drop its SQL database `cluebringer` also.

### Disable Cluebringer in iRedAdmin-Pro

To disable Cluebringer integration in iRedAdmin-Pro, please set
`policyd_enabled = False` in iRedAdmin-Pro config file, then restart Apache
or uwsgi (if you're running Nginx) service.

> After you have upgraded to the latest iRedAdmin-Pro release (at least
> iRedAdmin-Pro-LDAP-2.4.0, or iRedAdmin-Pro-SQL-2.2.0, both released on Dec 14,
> 2015), you can either __COMMENT OUT__ or __REMOVE__ all parameters which start
> with `policyd_` in iRedAdmin-Pro config file, for example:
 
```
policyd_enabled =
policyd_db_host =
policyd_db_port =
policyd_db_name =
policyd_db_user =
policyd_db_password =
```
