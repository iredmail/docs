# Whitelists and Blacklists

[TOC]

This tutorial shows you how to whitelist and blacklist senders or recipients
with iRedAdmin-Pro and script shipped in iRedAPD (since iRedAPD-1.7.1).

## Manage whitelists and blacklists with iRedAdmin-Pro

With iRedAdmin-Pro, you can manage several levels of whitelists and blacklists:

* Global white/blacklists: under menu `System -> Anti Spam -> Whitelists & Blacklists`.
* Per-domain white/blacklists: in domain profile page, under tab `Whitelists and Blacklists`.
* Per-user white/blacklists: in user profile page, under tab `Whitelists and Blacklists`.

Screenshot attached below.

## Manage whitelists and blacklists with SQL commands

Since iRedAPD-1.7.1, iRedAPD ships script `tools/wblist_admin.py` to help you
manage white/blacklists. To get full usage message, please run this script
without argument like this:

```
# cd /opt/iredapd/tools/
# python wblist_admin.py
```

Sample usages:

* Add server-wide whitelisted or blacklisted senders:

```
# python wblist_admin.py --add --whitelist 202.96.134.133 john@example.com @test.com @.abc.com
# python wblist_admin.py --add --blacklist 202.96.134.133 john@example.com @test.com @.abc.com
```

* Show server-wide whitelisted and blacklisted senders:

```
# python wblist_admin.py --list --whitelist
# python wblist_admin.py --list --blacklist
```

* For per-domain or per-user white/blacklists, please add argument `--account`.
  like below:

```
# python wblist_admin.py --account mydomain.com --add --whitelist 202.96.134.133
# python wblist_admin.py --account user@mydomain.com --add --blacklist 202.96.134.133

# python wblist_admin.py --account mydomain.com --list --whitelist
# python wblist_admin.py --account user@mydomain.com --list --blacklist
```

* For outbound messages, please add argument `--outbound`. like below:

```
# python wblist_admin.py --outbound --account mydomain.com --add --whitelist 202.96.134.133
```

Screenshot of iRedAdmin-Pro:

![](http://www.iredmail.org/images/iredadmin/system_wblist.png)
