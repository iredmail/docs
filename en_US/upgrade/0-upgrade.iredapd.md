# Upgrade iRedAPD

!!! attention

    * Release Notes are available here: [iRedAPD Release Notes](./iredapd.releases.html).
    * If you're trying to upgrade iRedAPD-1.3.x or earlier releases to the latest
      iRedAPD, please check this tutorial instead:
      [Upgrade iRedAPD from v1.3.x or earlier versions to latest release](./upgrade.old.iredapd.html).
    * iRedMail and iRedAdmin-Pro completely drop support for Cluebringer, if
      you're still running Cluebringer, please migrate to iRedAPD by following
      [our tutorial](./cluebringer.to.iredapd.html).

!!! warning

    For iRedMail SQL backends, the latest iRedAPD release requires at least
    iRedMail-0.9.7 because it needs the newly introduced SQL table
    `vmail.forwardings`.

This tutorial describes how to upgrade iRedAPD from `1.4.0` or later releases
to the latest stable release. It's applicable on all Linux/BSD distributions
supported by iRedMail.

1. Download the latest stable release here: <https://dl.iredmail.org/yum/misc/>.
   For example, `iRedAPD-3.5.tar.gz`.
1. Upload it to your iRedMail server. Assume it's `/root/iRedAPD-3.5.tar.gz`.
1. Extract downloaded package and execute upgrade script:

!!! attention

    If you're running iRedMail with OpenLDAP or MySQL/MariaDB backends,
    upgrading from iRedAPD-1.6.0 or earlier releases requires MySQL root username
    and password, please get them before you run upgrade script.

```
# cd /root
# tar xvf iRedAPD-3.5.tar.gz
# cd iRedAPD-3.5/tools/
# bash upgrade_iredapd.sh
```

That's all.

!!! note "Plugins"

    * It's recommended to enable plugin `reject_null_sender` in iRedAPD-1.4.4
      or later releases to prevent authenticated user sending spam as null sender.

    * Plugin `amavisd_wblist` is required for whitelisting and blacklisting.

## See Also

* [Enable SRS (Sender Rewriting Scheme) support](./srs.html)
* [Migrate Cluebringer to iRedAPD](./cluebringer.to.iredapd.html)
