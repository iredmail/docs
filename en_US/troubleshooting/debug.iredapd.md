# Turn on debug mode in iRedAPD

To turn on debug mode in iRedAPD, please set its log level to `debug` in
iRedAPD config file `/opt/iredapd/settings.py`, then restart iRedAPD
service.

```
# Log level: info, debug.
log_level = 'debug'
```

### Log File

Log file is configured in `/opt/iredapd/settings.py`, parameter `log_file =`.
Please monitor its log file to check detailed debug log.

* iRedAPD-1.7.0 and later: `/var/log/iredapd/iredapd.log`
* iRedAPD-1.6.0 and earlier: `/var/log/iredapd.log`
