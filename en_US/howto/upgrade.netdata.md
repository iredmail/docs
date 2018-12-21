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

## See Also

* [Integrate netdata monitor (on FreeBSD server)](./integration.netdata.freebsd.html)
