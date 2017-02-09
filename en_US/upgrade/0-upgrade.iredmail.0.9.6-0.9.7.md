# Upgrade iRedMail from 0.9.6 to 0.9.7

[TOC]

!!! warning

    THIS IS A DRAFT, DO NOT APPLY ANY STEPS MENTIONED IN THIS TUTORIAL.

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](../support.html) and [contact us](../contact.html).

## ChangeLog

* Feb 9, 2016: Fixed improper Fail2ban filter for Dovecot.

## General (All backends should apply these steps)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
0.9.7
```

### Fixed: Improper Fail2ban filter which causes incorrect ban

Please open file `/etc/fail2ban/filter.d/dovecot.iredmail.conf`, remove line
below:

```
            \(no auth attempts in .* rip=<HOST>
```

Then restart or reload Fail2ban service.
