# Upgrade iRedMail Enterprise Edition

iRedMail Enterprise Edition is a single binary program, upgrading is simple:

- Download the latest version from our [website](https://www.iredmail.org/ee.html).
- Stop the service.
- Replace the program file and set correct owner / group / permission.
- Start the service.
- Login as global admin and click the `Upgrade` button. It handles all required
  changes like updating config files, applying SQL structure changes, etc.

That's all.

Let's take `v1.0-beta9` as new version, Linux OS and amd64 architecture for example:

```
wget -O /tmp/iredmail https://dl.iredmail.org/ee/iredmail-enterprise-v1.0-beta9-linux-amd64
service iredmail stop
mv /tmp/iredmail /usr/local/bin/iredmail
chown root /usr/local/bin/iredmail
chmod 0500 /usr/local/bin/iredmail
service iredmail start
```

After upgraded software, please login to its web UI as global admin and check
the `Software` card on Dashboard page, if there's some update for deployed
software like Postfix, Dovecot, Nginx, etc, it will show the
`Apply iRedMail Changes` button, click it to finish the upgrade.

That's all.

![](./images/ee/dashboard-upgrade.png)

## See Also

- [ChangeLog of iRedMail Enterprise Edition](./ee.changelog.html)
