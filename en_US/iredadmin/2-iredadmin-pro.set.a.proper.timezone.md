# iRedAdmin-Pro: Set a proper time zone

[TOC]

!!! attention

    The time zone settings in iRedAdmin is for iRedAdmin itself, not used by
    SOGo or Roundcube.

    * For per-account time zone setting in SOGo, please login to SOGo web UI
      and change it in `Preferences` page. For global setting, please update
      parameter `SOGoTimeZone =` in its config file `sogo.conf`.

    * For per-account time zone setting in Roundcube, please login to Roundcube
      web ui and change it in `Settings` page. For global setting, please
      add or update parameter `$config['timezone’]` in its config file.

    You can find locations of their config files in this document:
    [Locations of configuration and log files of major components](./file.locations.html).

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
