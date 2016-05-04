# Upgrade iRedMail from 0.9.5 to 0.9.6

[TOC]

<!--
!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](../support.html) and [contact us](../contact.html).
-->

!!! warning

    THIS IS A DRAFT DOCUMENT, DO NOT APPLY IT.

## ChangeLog

* May 3, 2016: Fixed: cannot deliver email to system account.

## General (All backends should apply these steps)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
0.9.6
```

### Fixed: cannot deliver email to system account.

iRedMail-0.9.5 and early releases have incorrect Postfix settings which causes
emails sent to system account cannot be delivered to mailbox. Steps below fix
it.

Please open file `/etc/postfix/main.cf` (Linux/OpenBSD) or
`/usr/local/etc/postfix/main.cf` (FreeBSD), remove below 2 parameters:

```
home_mailbox = ...
mailbox_command = ...
```

Restarting or reloading Postfix service is required.
