# Upgrade iRedMail from 1.7.0 to 1.7.1

!!! attention

	 Check out the on-premises, lightweight email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

!!! warning

    THIS IS A DRAFT DOCUMENT, DO NOT APPLY IT ON PRODUCTION SERVER.

## ChangeLog

- XX YY, 2024: initial publish.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.7.1
```

## For MariaDB backend

### Fixed: Amavisd cannot save mail subject longer than 255 characters.

iRedMail uses `VARBINARY(255)` to store mail subject in Amavisd database,
it fails if subject is longer.

```
wget -O /tmp/amavisd.sql https://raw.githubusercontent.com/iredmail/iRedMail/1.7.1/update/1.7.1/amavisd.mysql
mysql amavisd < /tmp/amavisd.sql
rm -f /tmp/amavisd.sql
```
