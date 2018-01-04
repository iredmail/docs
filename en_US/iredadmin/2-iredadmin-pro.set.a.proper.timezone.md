# iRedAdmin-Pro: Set a proper time zone

[TOC]

iRedAdmin-Pro uses time zone `GMT` by default, you can change it in several ways.

## Server wide time zone

To set a server wide time zone, please add setting below with the proper time
zone in iRedAdmin config file:

```
LOCAL_TIMEZONE = 'GMT+05:00'
```

You can find more sample time zones in file `libs/default_settings.py` under
iRedAdmin directory.

## Per-account time zone

Admin or user can set per-user time zone in their own profile page:

![](./images/iredadmin/user_profile_general.png)
