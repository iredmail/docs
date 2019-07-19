# Turn on debug mode in OpenDMARC

In OpenDMARC config file `/etc/opendmarc.conf`, find parameter `MilterDebug`
like below:

```
MilterDebug 0
```

Set its value to `1` and restart `opendmarc` service to enable debug mode:

```
MilterDebug 1
```

It's configured by iRedMail to log to `/var/log/opendmarc/opendmarc.log`.
