# Upgrade iRedMail from 1.8.3 to 1.8.4

!!! attention

    - iRedMail team recommends [iRedMail Enterprise Edition](https://www.iredmail.org/ee.html) for deploying new email server.
    - Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! note "Remote Upgrade Assistance"

    Check out our [remote upgrade support](https://www.iredmail.org/support.html) if you need assistance.

## ChangeLog

- Jul 22, 2026: initial publish.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.8.4
```

### Incorrect sieve configuration for Dovecot 2.4 on Debian 13 (trixie) and Ubuntu 26.04 (resolute)

!!! attention

    This issue only affects Debian 13 (Trixie) and Ubuntu 26.04 (Resolute).

The configuration for personal Sieve rules in Dovecot 2.4 is incorrect on
Debian 13 (Trixie) and Ubuntu 26.04 (Resolute), causing Sieve rules to fail to
save. Please follow the steps below to fix the issue.

- Open the file `/etc/dovecot/dovecot.conf` and locate the `sieve_script personal`
  block, which should look like this:
```
sieve_script personal {
    type = personal
    driver = file
    path = ~/sieve
}
```

- Add the `active_path` parameter within the block and save the changes:

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

### Upgrade netdata to the latest stable release (v2.10.4)

If you have netdata installed, you can upgrade it by following this tutorial:
[Upgrade netdata](./upgrade.netdata.html).

