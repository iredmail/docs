# Turn on debug mode in iRedAPD

To turn on debug mode in iRedAPD, please set its log level to `debug` in
iRedAPD config file `/opt/iredapd/settings.py`, then restart iRedAPD
service.

```
# Log level: info, debug.
log_level = 'debug'
```

iRedAPD is configured to log to `/var/log/iredapd.log` by default, so
please monitor this file to check detailed debug log.
