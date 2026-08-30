# Upgrade iRedMail from 1.8.6 to 1.8.7

!!! attention

    - iRedMail team recommends [iRedMail Enterprise Edition](https://www.iredmail.org/ee.html) for deploying new email server.
    - Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! note "Remote Upgrade Assistance"

    Check out our [remote upgrade support](https://www.iredmail.org/support.html) if you need assistance.

## ChangeLog

- Aug 30, 2026: initial publish.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.8.7
```

### Incorrect sieve path for Dovecot 2.4 on Debian 13 (trixie) and Ubuntu 26.04 (resolute)

!!! attention

    - This issue only affects Debian 13 (trixie) and Ubuntu 26.04 (resolute).
    - It's [NOT affected](https://github.com/iredmail/docs/blob/master/html/files/dovecot/dovecot-2.4-mariadb.conf#L727) if you upgraded Debian OS from 12 to 13 by following [this tutorial](./upgrade.debian.12-13.html).

The configuration for personal sieve rules in Dovecot 2.4 is incorrect on
Debian 13 (trixie) and Ubuntu 26.04 (resolute), causing Dovecot fail to load
main sieve script. Please follow the steps below to fix the issue.

- Open the file `/etc/dovecot/dovecot.conf` and locate the `sieve_script personal`
  block, which should look like this:
```
sieve_script personal {
    type = personal
    driver = file
    path = ~/sieve/dovecot.sieve
    active_path = ~/sieve/dovecot.sieve
}
```

- Replace `path = ~/sieve/dovecot.sieve` by `path = ~/sieve` and save the changes:

```
sieve_script personal {
    type = personal
    driver = file
    path = ~/sieve
    active_path = ~/sieve/dovecot.sieve
}
```

- Restart `dovecot` service:
```
systemctl restart dovecot
```
