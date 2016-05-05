# Upgrade SOGo from v2 to v3

[TOC]


SOGo-3.x has a shinny new web UI, you can try the online demo here:
<http://sogo.nu> (search 'demo' on the page).

SOGo team offers support for both SOGo v3 and v2, so it's totally fine if you
want to stick to SOGo-2.x. In case you want to try SOGo-3.x, please try steps
below.

## Upgrade SOGo On RHEL/CentOS

* Backup config files first:

```
mkdir -p /root/sogo-backup/{sogo,sysconfig}
cp /etc/sogo/* /root/sogo-backup/sogo/
cp /etc/sysconfig/sogo /root/sogo-backup/sysconfig/
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
cp /root/sogo-backup/sogo/* /etc/sogo/
cp /root/sogo-backup/sysconfig/sogo /etc/sysconfig/
```

* Restart SOGo service:

```
service sogod restart
```

## Upgrade SOGo On Debian/Ubuntu

* Backup config files first:

```
mkdir -p /root/sogo-backup/{sogo,default}
cp /etc/sogo/* /root/sogo-backup/sogo/
cp /etc/default/sogo /root/sogo-backup/default/
```

* Open file `/etc/apt/sources.list`,

    * On Debian, please replace URL `http://inverse.ca/downloads/SOGo/Debian/` by: `http://inverse.ca/debian-v3/`
    * On Ubuntu, please replace URL `http://inverse.ca/downloads/SOGo/Ubuntu/` by: `http://inverse.ca/ubuntu-v3/`

* Remove `sope` and `sogo` packages first, then install SOGo again:

```
apt-get remove "libsope*" "sogo*"

apt-get update
apt-get install sogo sogo-activesync sope4.9-gdl1-mysql sope4.9-gdl1-postgresql
```

* Restore backup files:

```
cp /root/sogo-backup/sogo/* /etc/sogo/
cp /root/sogo-backup/default/sogo /etc/default/
```

* Restart SOGo service:

```
service sogo restart
```

## Troubleshooting

If SOGo doesn't work as expected, please check its log file
`/var/log/sogo/sogo.log`. If you don't understand what the error message means,
please extract related error message and post to our online support forum:
<http://www.iredmail.org/forum/>.
