# How to upgrade netdata

iRedMail installs netdata with the official binary package.

## Upgrade netdata on Linux

To update netdata on Linux, just download new version of the prebuilt package
from its [github page](https://github.com/netdata/netdata/releases), then run
it:

```
chmod +x netdata-latest.gz.run
./netdata-latest.gz.run --accept
```

That's it.

## Upgrade netdata on FreeBSD

Please upgrade netdata with FreeBSD ports tree.

## [OPTIONAL] Disable sending anonymous statistics.

To opt-out from sending anonymous statistics, please create empty file
`.opt-out-from-anonymous-statistics`:

- On Linux, it's `/opt/netdata/etc/netdata/.opt-out-from-anonymous-statistics`.
- On FreeBSD, it's `/usr/local/etc/netdata/.opt-out-from-anonymous-statistics`.

netdata will detect this file, if exists, no anonymous statistics will be sent.

## See Also

* [Integrate netdata monitor (on FreeBSD server)](./integration.netdata.freebsd.html)
* netdata:
    * [Opt-out from sending anonymous statistics](https://docs.netdata.cloud/docs/anonymous-statistics/#opt-out)
