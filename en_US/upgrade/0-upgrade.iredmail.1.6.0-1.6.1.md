# Upgrade iRedMail from 1.6.0 to 1.6.1

[TOC]

!!! warning

    THIS IS A DRAFT DOCUMENT, DO NOT APPLY IT.

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.6.1
```

### Upgrade netdata to the latest stable release (1.35.1)

If you have netdata installed, you can upgrade it by following this tutorial:
[Upgrade netdata](./upgrade.netdata.html).

## General (All backends should apply these changes)

### Postfix: Bypass more facebook HELO hostnames

Find below line in `/etc/postfix/helo_access.pcre` (Linux/OpenBSD) or
`/usr/local/etc/postfix/helo_access.pcre` (FreeBSD):

```
/^\d{1,3}-\d{1,3}-\d{1,3}-\d{1,3}\.mail-(mail|campmail)\.facebook\.com$/ OK
```

Replace it by:

```
/^\d{1,3}-\d{1,3}-\d{1,3}-\d{1,3}\.mail-.*\.facebook\.com$/ OK
```

Reloading or restarting postfix service is required.
