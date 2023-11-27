# Upgrade iRedMail from 1.6.7 to 1.6.8

!!! warning

    THIS IS A DRAFT DOCUMENT, DO NOT APPLY IT.

!!! attention

	 Check out the on-premises, lightweight email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

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
1.6.8
```

### CentOS / Rocky: Fixed: not enable daily cron job to update SpamAssassin rules

SpamAssassin package doesn't create a daily cron job to update rules, so we
have to create one manually. Please run command below to create it:

```
ln -sf /usr/share/spamassassin/sa-update.cron /etc/cron.daily/sa-update
```
