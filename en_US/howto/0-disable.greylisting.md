# Disable greylisting in Cluebringer

!!! warning

    Cluebringer has been removed from iRedMail since iRedMail-0.9.3, if you're
    still running Cluebringer, please follow our tutorial to migrate to
    iRedAPD: [Migrate from Cluebringer to iRedAPD](./cluebringer.to.iredapd.html).


* Find Cluebringer config file `cluebringer.conf` on your server with this
  document: [Locations of configuration and log files of major components](./file.locations.html#cluebringer)

* Find below lines in `cluebringer.conf`:

```
[Greylisting]
enable=1
```

To disable gryelisting, please change `enabled=1` to `enabled=0`, then restart
Cluebringer service.
