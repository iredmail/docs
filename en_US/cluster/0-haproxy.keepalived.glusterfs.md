# Build an iRedMail fail-over Cluster with KeepAlived, HAProxy, GlusterFS, OpenLDAP, Mariadb

[TOC]

This tutorial was contributed by Setyo Prayitno <<jrsetyo@gmail.com>> (forum user
name `t10`) [on March 13, 2016](http://www.iredmail.org/forum/topic10773.html).
Thanks Setyo. :)

## TODO

* Use clear server hostnames and IP addresses for all involved servers.
* Install adminer from <http://adminer.org>

## Goal

Build a fail-over cluster with 4 servers (2 backend servers behind HAProxy + KeepAlived).

## Requirements

* A valid mail domain name. We use `example.com` as mail domain name in this document.
* 4 servers, all are CentOS 7.

    * 2 servers run HAProxy + KeepAlived as a frontend for load-balance
      (HAProxy) and fail-over (KeepAlived).
    * 2 servers run the actual mail services. We will install the latest
      iRedMail release for this.

The big picture:

![](https://bytebucket.org/jrt10/catatan/raw/master/iredmailhat10.bmp)

## Summary

Hostnames and IP addresses:

* We use hostname `ha1.example.com` and `ha2.example.com` for our 2 servers
  which runs HAProxy and KeepAlived, use `ha1` and `ha2` for short.

* We use hostname `mail1.example.com` and `mail2.example.com` for our 2 servers
  which runs iRedMail for mail services, use `mail1` and `mail2` for short.

* IP addresses:

```
192.168.1.1 ha1
192.168.1.2 ha2
192.168.1.3 mail1
192.168.1.4 mail2
```

The procedure:

1. Install and configure KeepAlived
1. Install and configure HAProxy
1. Install and configure GlusterFS as glusterserver & glusterclient (you can
   use separate machine for glusterserver) it's better to use a new hard drive
   with the same capacity
1. Install and configure iRedMail
1. Setup OpenLDAP replication (Master-Slave)
1. Setup MariaDB replication (Master-Master)

## Install and configure KeepAlived

Install on 2 servers (ha1 & ha2)

* on both servers, update `/etc/hosts`:

```
192.168.1.1 ha1
192.168.1.2 ha2
192.168.1.3 mail1
192.168.1.4 mail2
```

* Install KeepAlived and backup default config file:

```
yum install -y keepalived
mv /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf_DEFAULT
```

* on ha1:

```
nano /etc/keepalived/keepalived.conf
```

* change eth0 to your existing interface

```
vrrp_script chk_haproxy {
    script "killall -0 haproxy" # check the haproxy process
    interval 2 # every 2 seconds
    weight 2 # add 2 points if OK
}

vrrp_instance VI_1 {
    interface eth0 # interface to monitor
    state MASTER # MASTER on ha1, BACKUP on ha2
    virtual_router_id 51
    priority 101 # 101 on ha1, 100 on ha2
    virtual_ipaddress {
    192.168.1.10 # virtual ip address
    }
    track_script {
        chk_haproxy
    }
}
```

* on ha2, update `/etc/keepalived/keepalived.conf`

change `eth0` to your existing interface

```
vrrp_script chk_haproxy {
    script "killall -0 haproxy" # check the haproxy process
    interval 2 # every 2 seconds
    weight 2 # add 2 points if OK
}
vrrp_instance VI_1 {
    interface eth0 # interface to monitor
    state BACKUP # MASTER on ha1, BACKUP on ha2
    virtual_router_id 51
    priority 101 # 101 on ha1, 100 on ha2
    virtual_ipaddress {
    192.168.1.10 # virtual ip address
    }
    track_script {
        chk_haproxy
    }
}
```

* activate KeepAlived service on both servers:

```
systemctl enable keepalived
systemctl start keepalived
```

* Check status of virtual IP (192.168.1.10) with command below:

```
ip a
```

## Install and configure HAProxy

* Install on both servers (ha1 & ha2)

```
yum install -y haproxy
mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg_DEFAULT
```

* on ha1: update `/etc/haproxy/haproxy.cfg`

```
global
        log 127.0.0.1   local0
        log 127.0.0.1   local1 debug
        maxconn   45000 # Total Max Connections.
        daemon
        nbproc      1 # Number of processing cores.

defaults
        timeout server 86400000
        timeout connect 86400000
        timeout client 86400000
        timeout queue   1000s

# [HTTP Site Configuration]
listen  http_web 192.168.1.10:80
        bind *:80
        bind *:443 ssl crt /etc/ssl/iredmail.org/iredmail.org.pem
        redirect scheme https if !{ ssl_fc }
        mode http
        balance roundrobin  # Load Balancing algorithm
        option httpchk
        option forwardfor
        server mail1 192.168.1.3:443 weight 1 maxconn 512 check
        server mail2 192.168.1.4:443 weight 1 maxconn 512 check

# [HTTPS Site Configuration]
listen  https_web 192.168.1.10:443
        mode tcp
        balance source# Load Balancing algorithm
        reqadd X-Forwarded-Proto:\ http
        server mail1 192.168.1.3:443 weight 1 maxconn 512 check
        server mail2 192.168.1.4:443 weight 1 maxconn 512 check

# Reporting
listen stats
    bind :9000
    mode http

    # Enable statistics
    stats enable

    # Hide HAPRoxy version, a necessity for any public-facing site
    stats hide-version

    # Show text in authentication popup
    stats realm Authorization

    # URI of the stats page: localhost:9000/haproxy_stats
    stats uri /haproxy_stats

    # Set a username and password
    stats auth yourUsername:yourPassword
```


* on ha2, update `/etc/haproxy/haproxy.cfg`

```
global
        log 127.0.0.1   local0
        log 127.0.0.1   local1 debug
        maxconn   45000 # Total Max Connections.
        daemon
        nbproc      1 # Number of processing cores.

defaults
        timeout server 86400000
        timeout connect 86400000
        timeout client 86400000
        timeout queue   1000s

# [HTTP Site Configuration]
listen  http_web 192.168.1.10:80
        bind *:80
        bind *:443 ssl crt /etc/ssl/iredmail.org/iredmail.org.pem
        redirect scheme https if !{ ssl_fc }
        mode http
        balance roundrobin  # Load Balancing algorithm
        option httpchk
        option forwardfor
        server mail1 192.168.1.3:80 weight 1 maxconn 512 check
        server mail2 192.168.1.4:80 weight 1 maxconn 512 check

# [HTTPS Site Configuration]
listen  https_web 192.168.1.10:443
        mode tcp
        balance source# Load Balancing algorithm
        reqadd X-Forwarded-Proto:\ http
        server mail1 192.168.1.3:443 weight 1 maxconn 512 check
        server mail2 192.168.1.4:443 weight 1 maxconn 512 check

# Reporting
listen stats
    bind :9000
    mode http

    # Enable statistics
    stats enable

    # Hide HAPRoxy version, a necessity for any public-facing site
    stats hide-version

    # Show text in authentication popup
    stats realm Authorization

    # URI of the stats page: localhost:9000/haproxy_stats
    stats uri /haproxy_stats

    # Set a username and password
    stats auth yourUsername:yourPassword
```

* on both servers:

create cert for ssl redirect (to iRedMail Servers)

```
mkdir /etc/ssl/iredmail.org/
openssl genrsa -out /etc/ssl/iredmail.org/iredmail.org.key 2048
openssl req -new -key /etc/ssl/iredmail.org/iredmail.org.key -out /etc/ssl/iredmail.org/iredmail.org.csr
openssl x509 -req -days 365 -in /etc/ssl/iredmail.org/iredmail.org.csr -signkey /etc/ssl/iredmail.org/iredmail.org.key -out /etc/ssl/iredmail.org/iredmail.org.crt
cat /etc/ssl/iredmail.org/iredmail.org.crt /etc/ssl/iredmail.org/iredmail.org.key > /etc/ssl/iredmail.org/iredmail.org.pem
```

activate HAProxy service

```
systemctl enable haproxy
systemctl start haproxy
```

check log if any errors

```
tail -f /var/log/messages
```

allow http, https, haproxystat ports

```
firewall-cmd --zone=public --permanent --add-port=80/tcp
firewall-cmd --zone=public --permanent --add-port=443/tcp
firewall-cmd --zone=public --permanent --add-port=9000/tcp
firewall-cmd --complete-reload
```

## GlusterFS

### Add new hard disk and format with preferred file system

first, add new hard drive with the same capacity

* on both servers, update `/etc/hosts`:

```
192.168.1.3 mail1
192.168.1.4 mail2
```

* add new disk on `mail1`:

type 'n', and hit enter for next question, (dont forget to write) hit 'w'

```
fdisk /dev/sdb
/sbin/mkfs.ext4 /dev/sdb1
mkdir /glusterfs1
```

Update `/etc/fstab`:

```
/dev/sdb1 /glusterfs1      ext4    defaults        1 2
```

remount all:

```
mount -a
```

* add new disk on mail2:

type 'n', and hit enter for next question, (dont forget to write) hit 'w'

```
fdisk /dev/sdb
/sbin/mkfs.ext4 /dev/sdb1
mkdir /glusterfs2
```

Update /etc/fstab:

```
/dev/sdb1 /glusterfs1      ext4    defaults        1 2
```

remount all

```
mount -a
```

### Install and Configure GulsterFS

* on both servers (mail1 & mail2):

```
rpm  -ivh  http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
wget -P /etc/yum.repos.d http://download.gluster.org/pub/gluster/glusterfs/3.7/3.7.5/CentOS/glusterfs-epel.repo
yum -y install glusterfs glusterfs-fuse glusterfs-server
```

activate the service

```
systemctl enable glusterd.service
systemctl start glusterd.service
```

disabling firewall

```
systemctl stop firewalld.service
systemctl disable firewalld.service
```

* on mail1:

```
gluster peer probe mail2
```

* on mail2:

```
gluster peer probe mail1
```

you can check status with command below:

```
gluster peer status
```

* ONLY on mail1:

```
gluster volume create mailrep-volume replica 2  mail1:/glusterfs1/vmail  mail2:/glusterfs2/vmail force
gluster volume start mailrep-volume
```

check it

```
gluster volume info mailrep-volume
```

* create folder for vmail and mount glusterfs to vmail folder

on mail1:

```
mkdir  /var/vmail
mount.glusterfs mail1:/mailrep-volume /var/vmail/
```

Update /etc/fstab

```
mail1:/mailrep-volume /var/vmail glusterfs defaults,_netdev 0 0
```

remount all

```
mount -a
```

check it

```
df -h
```

* on mail2:

```
mkdir  /var/vmail
mount.glusterfs mail2:/mailrep-volume /var/vmail/
```

Update /etc/fstab:

```
mail2:/mailrep-volume /var/vmail glusterfs defaults,_netdev 0 0
```

remount all

```
mount -a
```

check it

```
df -h
```

you can test it by creating any files on one of your mail servers

```
cd /var/vmail; touch R1 R2 R3 R4 R5 R6
```

make sure it, by checking files on both servers

```
ls -la /var/vmail
```

## Install and configure iRedMail

* Install the latest iRedMail on 2 servers (mail1 & mail2)

* For installing iRedMail on CentOS, please check its installation guide:
  [Install iRedMail on Red Hat Enterprise Linux, CentOS](./install.iredmail.on.rhel.html)

!!! note

    * install iRedMail on `mail1` first, after mail1 finish you can install it
      to mail2 (better do not reboot after installing iRedMail, wait untill
      finish install/configure)

    * Dont forget to choose LDAP and using default mail folder: `/var/vmail`
    * Choose Nginx as web server


## Configure LDAP replication (Master-Slave)

* on mail1 (MASTER), update `/etc/openldap/slapd.conf`:

```
moduleload syncprov
index entryCSN,entryUUID eq
overlay syncprov
syncprov-checkpoint 100 10
syncprov-sessionlog 200
```

* on mail2 (SLAVE), update `/etc/openldap/slapd.conf`:

```
syncrepl   rid=001
           provider=ldap://mail1:389
           searchbase="dc=iredmail,dc=kom"
           bindmethod=simple
           binddn="cn=vmail,dc=iredmail,dc=kom"
           credentials=erec3xiThBUW9QnnU9Bnifp3434
           schemachecking=on
           type=refreshOnly
           retry="60 +"
           scope=sub
           interval=00:00:01:00
           attrs="*,+"
```

on both servers set firewalld to accept gluster port, ldap port, and database to each servers,
or you can set by your own rules:

```
firewall-cmd --permanent \
     --zone=iredmail \
     --add-rich-rule='rule family="ipv4" source address="192.168.1.3/24" port protocol="tcp" port="389" accept'

firewall-cmd --permanent \
    --zone=iredmail \
    --add-rich-rule='rule family="ipv4" source address="192.168.1.4/24" port protocol="tcp" port="3306" accept'

firewall-cmd --zone=iredmail --permanent --add-port=111/udp
firewall-cmd --zone=iredmail --permanent --add-port=24007/tcp
firewall-cmd --zone=iredmail --permanent --add-port=24008/tcp
firewall-cmd --zone=iredmail --permanent --add-port=24009/tcp
firewall-cmd --zone=iredmail --permanent --add-port=139/tcp
firewall-cmd --zone=iredmail --permanent --add-port=445/tcp
firewall-cmd --zone=iredmail --permanent --add-port=965/tcp
firewall-cmd --zone=iredmail --permanent --add-port=2049/tcp
firewall-cmd --zone=iredmail --permanent --add-port=38465-38469/tcp
firewall-cmd --zone=iredmail --permanent --add-port=631/tcp
firewall-cmd --zone=iredmail --permanent --add-port=963/tcp
firewall-cmd --zone=iredmail --permanent --add-port=49152-49251/tcp
```

reload firewall rules:

```
firewall-cmd --complete-reload
```

Restart OpenLDAP service:

```
systemctl restart slapd
```

## Configure MariaDB replication (Master-Master)

* on mail1, update `/etc/my.cnf`:

```
server-id                   = 1
    log_bin                 = /var/log/mariadb/mariadb-bin.log
    log-slave-updates
    log-bin-index           = /var/log/mariadb/log-bin.index
    log-error               = /var/log/mariadb/error.log
    relay-log               = /var/log/mariadb/relay.log
    relay-log-info-file     = /var/log/mariadb/relay-log.info
    relay-log-index         = /var/log/mariadb/relay-log.index
    auto_increment_increment = 10
    auto_increment_offset   = 1
    binlog_do_db            = amavisd
    binlog_do_db            = iredadmin
    binlog_do_db            = roundcubemail
    binlog_do_db            = sogo
    binlog-ignore-db=test
    binlog-ignore-db=information_schema
    binlog-ignore-db=mysql
    binlog-ignore-db=iredapd
    log-slave-updates
    replicate-ignore-db=test
    replicate-ignore-db=information_schema
    replicate-ignore-db=mysql
    replicate-ignore-db=iredapd
```

Restart MariaDB service:

```
systemctl restart mariadb
```

*on mail2, update `/etc/my.cnf`:

```
server-id                   = 2
    log_bin                 = /var/log/mariadb/mariadb-bin.log
    log-slave-updates
    log-bin-index           = /var/log/mariadb/log-bin.index
    log-error               = /var/log/mariadb/error.log
    relay-log               = /var/log/mariadb/relay.log
    relay-log-info-file     = /var/log/mariadb/relay-log.info
    relay-log-index         = /var/log/mariadb/relay-log.index
    auto_increment_increment = 10
    auto_increment_offset = 1
    binlog_do_db            = amavisd
    binlog_do_db            = iredadmin
    binlog_do_db            = roundcubemail
    binlog_do_db            = sogo
    binlog-ignore-db=test
    binlog-ignore-db=information_schema
    binlog-ignore-db=mysql
    binlog-ignore-db=iredapd
    log-slave-updates
    replicate-ignore-db=test
    replicate-ignore-db=information_schema
    replicate-ignore-db=mysql
    replicate-ignore-db=iredapd
```

Restart MariaDB service:

```
systemctl restart mariadb
```

### create replicator dbuser on both servers ##

* on mail1, login as MariaDB root user, then execute sql commands below:

```
create user 'replicator'@'%' identified by '12345678';
grant replication slave on *.* to 'replicator'@'%';
SHOW MASTER STATUS;
+--------------------+----------+----------------------------------------------+-------------------------------+
| File               | Position | Binlog_Do_DB                                 | Binlog_Ignore_DB              |
+--------------------+----------+----------------------------------------------+-------------------------------+
| mariadb-bin.000001 |      245 | amavisd,iredadmin,iredapd,roundcubemail,sogo | test,information_schema,mysql |
+--------------------+----------+----------------------------------------------+-------------------------------+
```

check master status in column `File` and `Position`:

* on mail2:

```
create user 'replicator'@'%' identified by '12345678';
grant replication slave on *.* to 'replicator'@'%';
slave stop;
CHANGE MASTER TO MASTER_HOST = '192.168.1.3', MASTER_USER = 'replicator', MASTER_PASSWORD = '12345678', MASTER_LOG_FILE = 'mariadb-bin.000001', MASTER_LOG_POS = 245;
slave start;
SHOW MASTER STATUS;
+--------------------+----------+----------------------------------------------+-------------------------------+
| File               | Position | Binlog_Do_DB                                 | Binlog_Ignore_DB              |
+--------------------+----------+----------------------------------------------+-------------------------------+
| mariadb-bin.000001 |     289 | amavisd,iredadmin,iredapd,roundcubemail,sogo | test,information_schema,mysql |
+--------------------+----------+----------------------------------------------+-------------------------------+

show slave status\G;
```

* change to your own master status MASTER_LOG_FILE is from `File`, MASTER_LOG_POS is from `Position` of master mail1
* check master status for `File` and `Position`

Restart MariaDB service:

```
systemctl restart mariadb
```

* on mail1, login as MariaDB root user:

```
slave stop;
CHANGE MASTER TO MASTER_HOST = '192.168.1.4', MASTER_USER = 'replicator', MASTER_PASSWORD = '12345678', MASTER_LOG_FILE = 'mariadb-bin.000001', MASTER_LOG_POS = 289;
slave start;
show slave status\G;
exit;
```

* change to your own master status MASTER_LOG_FILE is from `File`, MASTER_LOG_POS is from `Position` of master mail2*.

Restart MariaDB service:

```
systemctl restart mariadb
```

* reboot one of mailserver and wait till up, then reboot the other mailserver

## Testing

* For HA Testing, u can try to shutdown one of your server to testing it (ha1 or ha2 --/OR-- mail1 or mail2)
* u can create users using iredadmin on mail1, then check users from mail2 and you can see its already sync
* try to login using roundcubemail from any mailserver then u can check users on database 'roundcubemail->users', and its already sync
* only mail1 'can add n modify' users
* this mailservers act as Glusterserver & Glusterclient, if u want to reboot the servers, please reboot first server untill this up then reboot the second server.
* if all servers are reboot for the same time it will not mounting '/var/vmail' folder. u must force mount manually using this command 'gluster volume start mailrep-volume force'


To view the DB easily, you may want to install adminer from <http://adminer.org/> (it's web-based SQL management tool, just a single PHP file):
