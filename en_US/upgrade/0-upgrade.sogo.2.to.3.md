# Upgrade SOGo from v2 to v3

[TOC]


SOGo-3.x has a shinny new web UI, you can try the online demo here:
<http://sogo.nu> (search 'demo' on the page).

SOGo team offers support for both SOGo v3 and v2, so it's totally fine if you
want to stick to SOGo-2.x. In case you want to try SOGo-3.x, please try steps
below.

## Upgrade SOGo On RHEL/CentOS

* Backup 2 config files first:

```
cp /etc/sogo/sogo.conf /etc/sogo/sogo.conf.bak
cp /etc/sysconfig/sogo /etc/sysconfig/sogo.bak
```

* Open file `/etc/yum.repos.d/sogo.repo`, change the `baseurl=` setting to:

```
baseurl=http://inverse.ca/rhel-v3/$releasever/$basearch/
```

* Remove `sope` and `sogo` packages first, then install SOGo again:

```
yum remove "sope*" "sogo*"
yum install sogo sogo-ealarms-notify sogo-tool sogo-activesync sope49-gdl1-mysql sope49-gdl1-postgresql
```

* Restore backup files:

```
cp /etc/sogo/sogo.conf.bak /etc/sogo/sogo.conf
cp /etc/sysconfig/sogo.bak /etc/sysconfig/sogo
```

* Restart SOGo service:

```
service sogod restart
```

## Upgrade SOGo On Debian/Ubuntu

* Backup 2 config files first:

```
cp /etc/sogo/sogo.conf /etc/sogo/sogo.conf.bak
cp /etc/default/sogo /etc/default/sogo.bak
```

* Open file `/etc/apt/sources.list`,

    * On Debian, please replace URL `http://inverse.ca/downloads/SOGo/Debian/` by: `http://inverse.ca/debian-v3/`
    * On Ubuntu, please replace URL `http://inverse.ca/downloads/SOGo/Ubuntu/` by: `http://inverse.ca/ubuntu-v3/`

* Remove `sope` and `sogo` packages first, then install SOGo again:

```
apt-get remove "sope*" "sogo*"

apt-get update
apt-get install sogo sogo-activesync sope4.9-gdl1-mysql sope4.9-gdl1-postgresql
```

* Restore backup files:

```
cp /etc/sogo/sogo.conf.bak /etc/sogo/sogo.conf
cp /etc/default/sogo.bak /etc/default/sogo
```

* Restart SOGo service:

```
service sogo restart
```

## Troubleshooting

If SOGo doesn't work as expected, please check its log file `/var/log/sogo/sogo.log`. If you don't understand what the error message means, please extract related error message and post to our online support forum: <http://www.iredmail.org/forum/>.
