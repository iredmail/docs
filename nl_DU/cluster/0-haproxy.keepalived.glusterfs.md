# Creëer een iRedMail fail-over Cluster met KeepAlived, HAProxy, GlusterFS, OpenLDAP en Mariadb

!!! attention

	 Bekijk onze lichtgewichte on-premise e-mail archiveringsoftware ontwikkeld door 
	 het iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! warning

    Deze tutorial werd toegevoegd door Setyo Prayitno `<jrsetyo _at_ gmail.com>`
    (forum user name `t10`) [on March 13, 2016](https://forum.iredmail.org/topic10773.html).
    Thanks Setyo. :) Het iRedMail Team biedt geen technische ondersteuning voor deze setup.


## TODO

* Gebruik duidelijke hostnames en IP-adressen voor alle betreffende servers.
* Installeer adminer van deze website: <http://adminer.org>

## Doel

Creëer een fail-over cluster met 4 servers(2 backend servers achter HAProxy + KeepAlived).

## Vereisten

* Een geregistreerde (e-mail) domain name. Wij gebruiken `example.com` als (e-mail) domain name in dit document.
* 4 servers, met allemaal CentOS 7 als OS.

    * 2 servers draaien allemaal: HAProxy + KeepAlived voor de frontend, voor de load-balancers, HAProxy en KeepAlived voor de fail-over.
    * 2 servers zorgen voor de echte e-maildiensten. We zullen hiervoor de nieuwste iRedMail versie gebruiken.

In grote lijnen:

![](./images/cluster/contrib/iredmailhat10.png)

## Samenvatting

Hostnames en IP-adressen:

* We gebruiken de hostnames `ha1.example.com` en `ha2.example.com` voor onze 2 servers die HAProxy en KeepAlived draaien. Hierna verwijzen we er verkort naar als `ha1` en `ha2`.

* We gebruiken de hostnames `mail1.example.com` en `mail2.example.com` voor onze 2 servers die iRedMail draaien voor onze e-maildiensten. Die worden afgekort tot `mail1` en `mail2`.

* IP adressen:

```
192.168.1.1 ha1
192.168.1.2 ha2
192.168.1.3 mail1
192.168.1.4 mail2
```

De procedure:

1. Installeer en configureer KeepAlived
2. Installeer en configureer HAProxy
3. Installeer en configureer GlusterFS als glusterserver & glusterclient (je kunt een aparte server gebruiken voor de glusterserver), het is best om een nieuwe harddisk te gebruiken met dezelfde capaciteit
5. Installeer en configureer iRedMail
6. Stel OpenLDAP replication in(Master-Slave)
7. Stel MariaDB replication in(Master-Master)

## Installeer en configureer KeepAlived

Installeer op 2 servers (ha1 & ha2)

* Verander op beide servers `/etc/hosts`:

```
192.168.1.1 ha1
192.168.1.2 ha2
192.168.1.3 mail1
192.168.1.4 mail2
```

* Installeer KeepAlived en maak een backup van de default configuratiebestand:

```
yum install -y keepalived
mv /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf_DEFAULT
```

* Bij ha1:

```
nano /etc/keepalived/keepalived.conf
```

* Verander eth0 naar je huidige interface

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

* Bij ha2, bewerk `/etc/keepalived/keepalived.conf`

Verander `eth0` naar je huidige interface

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

* Activeer KeepAlived op beide servers:

```
systemctl enable keepalived
systemctl start keepalived
```

* Check de status van je virtuele IP (192.168.1.10) met onderstaand commando:

```
ip a
```

## Installeer en configureer HAProxy

* Installeer op beide servers (ha1 & ha2)

```
yum install -y haproxy
mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg_DEFAULT
```

* Bij ha1: bewerk `/etc/haproxy/haproxy.cfg`

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


* Bij ha2, bewerk `/etc/haproxy/haproxy.cfg`

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

* Op beide servers:

Creëer certificaat voor ssl redirect (naar iRedMail Servers)

```
mkdir /etc/ssl/iredmail.org/
openssl genrsa -out /etc/ssl/iredmail.org/iredmail.org.key 2048
openssl req -new -key /etc/ssl/iredmail.org/iredmail.org.key -out /etc/ssl/iredmail.org/iredmail.org.csr
openssl x509 -req -days 365 -in /etc/ssl/iredmail.org/iredmail.org.csr -signkey /etc/ssl/iredmail.org/iredmail.org.key -out /etc/ssl/iredmail.org/iredmail.org.crt
cat /etc/ssl/iredmail.org/iredmail.org.crt /etc/ssl/iredmail.org/iredmail.org.key > /etc/ssl/iredmail.org/iredmail.org.pem
```

Activeer HAProxy service

```
systemctl enable haproxy
systemctl start haproxy
```

Check log voor mogelijke errors

```
tail -f /var/log/messages
```

Verleen toegang aan http, https, haproxystat ports

```
firewall-cmd --zone=public --permanent --add-port=80/tcp
firewall-cmd --zone=public --permanent --add-port=443/tcp
firewall-cmd --zone=public --permanent --add-port=9000/tcp
firewall-cmd --complete-reload
```

## GlusterFS

### voeg een nieuwe harddisk toe en formatteer met je gewenste filesystem

ten eerste, voeg een nieuwe harddisk toe met dezelfde capaciteit

* bij beide servers, bewerk `/etc/hosts`:

```
192.168.1.3 mail1
192.168.1.4 mail2
```

* voeg een nieuwe disk toe aan `mail1`:

typ 'n', en druk op enter voor de volgende vraag, (vergeet niet om je informatie in te geven) druk op 'w'

```
fdisk /dev/sdb
/sbin/mkfs.ext4 /dev/sdb1
mkdir /glusterfs1
```

bewerk `/etc/fstab`:

```
/dev/sdb1 /glusterfs1      ext4    defaults        1 2
```

remount alles:

```
mount -a
```

* voeg een nieuwe disk toe aan mail2:

typ 'n', en druk op enter voor de volgende vraag, (vergeet niet om je informatie in te geven) druk op 'w'

```
fdisk /dev/sdb
/sbin/mkfs.ext4 /dev/sdb1
mkdir /glusterfs2
```

bewerk /etc/fstab:

```
/dev/sdb1 /glusterfs2      ext4    defaults        1 2
```

remount alles

```
mount -a
```

### Installeer en Configureer GulsterFS

* Op beide servers (mail1 & mail2):

```
yum -y install epel-release
yum -y install centos-release-gluster38.noarch
yum -y install glusterfs glusterfs-fuse glusterfs-server
```

activeer de service

```
systemctl enable glusterd.service
systemctl start glusterd.service
```

zet firewall uit

```
systemctl stop firewalld.service
systemctl disable firewalld.service
```

* bij mail1:

```
gluster peer probe mail2
```

* bij mail2:

```
gluster peer probe mail1
```

je kunt de status checken met onderstaande commando:

```
gluster peer status
```

* ENKEL EN ALLEEN bij mail1:

```
gluster volume create mailrep-volume replica 2  mail1:/glusterfs1/vmail  mail2:/glusterfs2/vmail force
gluster volume start mailrep-volume
```

verifeer het

```
gluster volume info mailrep-volume
```

* maak een folder aan voor vmail en mount glusterfs aan vmail folder

bij mail1:

```
mkdir  /var/vmail
mount.glusterfs mail1:/mailrep-volume /var/vmail/
```

verander /etc/fstab

```
mail1:/mailrep-volume /var/vmail glusterfs defaults,_netdev 0 0
```

remount alles

```
mount -a
```

check het

```
df -h
```

* bij mail2:

```
mkdir  /var/vmail
mount.glusterfs mail2:/mailrep-volume /var/vmail/
```

verander /etc/fstab:

```
mail2:/mailrep-volume /var/vmail glusterfs defaults,_netdev 0 0
```

remount alles

```
mount -a
```

check het

```
df -h
```

je kunt het testen door een willekeurige bestanden te maken op één van de servers

```
cd /var/vmail; touch R1 R2 R3 R4 R5 R6
```

om zeker te zijn, check de bestanden op beide servers

```
ls -la /var/vmail
```

## Installeer and configureer iRedMail

* Installeer de nieuwste iRedMail-versie op de 2 servers(mail1 & mail2)

* Om iRedMail te installeren op CentOS, kan de volgende installatieguide gebruikt worden:
  [Install iRedMail on Red Hat Enterprise Linux, CentOS](./install.iredmail.on.rhel.html)

!!! note

    * installeer iRedMail eerst bij `mail1`, nadat mail1 klaar is kan je het installeren op mail2 (het is best om niet te rebooten na de iRedMail-installatie, wacht totdat de configuratie klaar is)

    * vergeet niet om LDAP te kiezen en de standaard mail folder te gebruiken: `/var/vmail`
    * kies Nginx als webserver


## Configureer LDAP replicatie (Master-Slave)

* bij mail1 (MASTER), bewerk `/etc/openldap/slapd.conf`:

```
moduleload syncprov
index entryCSN,entryUUID eq
overlay syncprov
syncprov-checkpoint 100 10
syncprov-sessionlog 200
```

* bij mail2 (SLAVE), bewerk `/etc/openldap/slapd.conf`:

!!! attention

    je kunt het password van bind dn `cn=vmail,dc=xx,dc=xx` in Postfix LDAP
    query bestand vinden `/etc/postfix/ldap/`.

```
syncrepl rid=001
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

Op beide servers configureer je firewalld om gluster port, ldap port en database te accepteren,
of je maakt je eigen regels:

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

herlaad firewall regels:

```
firewall-cmd --complete-reload
```

herstart OpenLDAP service:

```
systemctl restart slapd
```

## Configureer MariaDB replicatie (Master-Master)

* bij mail1, bewerk `/etc/my.cnf`:

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

herstart MariaDB service:

```
systemctl restart mariadb
```

* bij mail2, bewerk `/etc/my.cnf`:

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

herstart MariaDB service:

```
systemctl restart mariadb
```

### creëer replicator dbuser op beide servers ##

* bij mail1, login als MariaDB root user en voer onderstaande sql commando's uit:

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

check master status in colom `File` en `Position`:

* bij mail2:

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

* verander naar je eigen master status, MASTER_LOG_FILE komt van `File`, MASTER_LOG_POS komt van `Position` van master mail1
* check master status voor `File` en `Position`

herstart MariaDB service:

```
systemctl restart mariadb
```

* bij mail1, login als MariaDB root user:

```
slave stop;
CHANGE MASTER TO MASTER_HOST = '192.168.1.4', MASTER_USER = 'replicator', MASTER_PASSWORD = '12345678', MASTER_LOG_FILE = 'mariadb-bin.000001', MASTER_LOG_POS = 289;
slave start;
show slave status\G;
exit;
```

* verander naar je eigen master status, MASTER_LOG_FILE komt van `File`, MASTER_LOG_POS komt van `Position` van master mail2

herstart MariaDB service:

```
systemctl restart mariadb
```

* herstart één van de mailservers en wacht tot die volledig online is, herstart dan de andere mailserver

## Testen

* Voor HA te testen kan je proberen om één van de servers te shutdownen (ha1 of ha2 --/OF-- mail1 of mail2).
* Je kunt users maken via iredadmin op mail1, dan checken of of die ook op mail2 zichtbaar zijn.
* Je kunt proberen inloggen via roundcubemail 'roundcubemail->users'.
* Alleen mail1 kan gebruikers toevoegen en wijzigen.
* Deze e-mailserver dient als Glusterserver & Glusterclient, als je de servers wilt herstarten, herstart deze totdat dit is opgestart en herstart dan de rest.
* Als alle servers op hetzelfde moment worden herstart zal '/var/vmail' folder niet worden gemount. je zult dan manueel de mount moeten forceren met dit commando:

```
gluster volume start mailrep-volume force
```


Om gemakkelijk de database te bekijken, kan je adminer <http://adminer.org/> installeren (het is een webgebaseerde SQL management tool, maar 1 PHP bestand).
