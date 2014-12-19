# iRedAdmin-Pro: Enable self-service to allow users to manage their own preferences and more

The latest iRedAdmin-Pro release provides self-service, but it's disabled by
default. You can enable it to allow users to manage their own data:

* Update full name
* Change password
* Mail forwarding control
* Manager per-user whitelists & blacklists
* Manage quarantined mails
* Check received mails and blacklist certain senders if they're spammers.

As a domain admin, you can control which data are allowed to be updated by
users themselves in domain profile page, under tab `Advanced`.

### Enable self-service in iRedAdmin-Pro

Please add below setting in iRedAdmin config file `settings.py`, then restart
Apache service or `uwsgi` service if you're running Nginx.

```
ENABLE_SELF_SERVICE = True
```

You can find exact path of `settings.py` on your server by checking this short
tutorial:
[Locations of configuration and log files of mojor components](./file.locations.html#iredadmin)
