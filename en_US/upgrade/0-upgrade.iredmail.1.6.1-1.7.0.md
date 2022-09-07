# Upgrade iRedMail from 1.6.1 to 1.7.0

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

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
1.7.0
```


## For MySQL/MariaDB backends

### Add missing index for SQL column `forwardings.forwarding`

Download plain SQL file used to update SQL table, then import it as
MySQL root user (Please run commands below as `root` user):

```
wget -O /tmp/iredmail.mysql https://github.com/iredmail/iRedMail/raw/1.7.0/update/1.7.0/iredmail.mysql
mysql vmail < /tmp/iredmail.mysql
rm -f /tmp/iredmail.mysql
```
