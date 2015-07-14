# Disable greylisting in Cluebringer

* Find Cluebringer config file `cluebringer.conf` on your server with this
  document: [Locations of configuration and log files of mojor components](./file.locations.html#cluebringer)

* Find below lines in `cluebringer.conf`:

```
[Greylisting]
enable=1
```

To disable gryelisting, please change `enabled=1` to `enabled=0`, then restart
Cluebringer service.
