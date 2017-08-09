# Fixes you need after upgrading Debian from 8 to 9

[TOC]

## Postfix

Run commands:

```
# Backup files
cp /etc/postfix/main.cf /etc/postfix/main.cf.bak
cp /etc/postfix/master.cf /etc/postfix/master.cf

# Update main.cf and master.cf
postconf -e daemon_directory='/usr/lib/postfix/sbin'
postconf -e shlib_directory='/usr/lib/postfix'
postconf -e compatibility_level=2
for i in $(postconf -Mf | grep '^[0-9a-zA-Z]' | awk '{print $1"/"$2"/chroot=n"}'); do postconf -F $i; done
```

* Incorrect `daemon_directory` causes Postfix cannot start.
* Incorrect `shlib_directory` causes Postfix cannot find pcre/mysql/pgsql/ldap modules.
* Debian 8 ships Postfix 2.x, but Debian 9 ships Postfix 3.x, we need to disable compatible mode.

## Dovecot

Please remove `!SSLv2` from parameter `ssl_protocols`, and restart Dovecot service:

```
ssl_protocols = !SSLv3
```

## Fail2ban

There's a duplicate parameter in file `/etc/fail2ban/jail.conf`, under section
`[pam-generic]` like below:

```
[pam-generic]
...
port = all
...
port = anyport
```

Comment out `port = anyport` and restart fail2ban service.
