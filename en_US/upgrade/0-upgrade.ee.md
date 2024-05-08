# Upgrade iRedMail Enterprise Edition

iRedMail Enterprise Edition is a single binary program, upgrading is simple:

- Download latest version from [website](https://www.iredmail.org/ee.html)
- Stop the service
- Replace the program file
- Start the service

```
wget -O /tmp/iredmail https://dl.iredmail.org/iredmail-enterprise-v1.0-beta4-linux-amd64
service iredmail stop
mv /tmp/iredmail /usr/local/bin/iredmail
chmod 0700 /usr/local/bin/iredmail
service iredmail start
```

After upgraded software, please login to its web UI as global admin and check
the `Software` card, if there's some update for deployed software like Postfix,
Dovecot, Nginx, etc, it will show you a `Upgrade Now` button, click it to
finish the upgrade.

![](./images/enterprise/dashboard-upgrade.png)
