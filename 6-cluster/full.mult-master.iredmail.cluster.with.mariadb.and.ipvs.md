# An Ultra-HA, full Mult-Master E-mail cluster with iRedMail, MariaDB, and IPVS  

[TOC]

## Introduction

iRedMail is a very nifty piece of software. Setting up a full mail server on modern Linux is indeed possible; there are guides for every part of the system, preconfigured templates, and many-a mailing list post. However, iRedMail does something special: it makes it easy. Easy to install, easy to administer, and and easy to use. However, there are very few guides on how to deploy a *complete*, clustered iRedMail solution. Let's talk a bit about what I mean by that.

I know e-mail, having deployed Debian-Linux-based carrier-grade mail platforms as part of my job. Setting up a cluster for production use, you want something that's fault-tolerant on every level. If you have 3 physical servers, you want to make sure you can keep your systems running even if you have to bring one down for maintenance, or due to a catastrophic hardware fault. You want to make sure you don't lose anything because one server crashed. However, many HA setups are not full multi-master; sure, you can lose a node, but it better not be server*1*. The setup I propose below addresses this: it doesn't matter which of your N nodes fails, you can always perform every task you need; and without proper monitoring, you might not even notice you have a problem! Some may think this is overkill, but the result is very compelling for anyone who values a 100% uptime!

The setup I'm using is based on Debian Wheezy (7), the latest stable release of the Debian GNU/Linux operating system; 64-bit is of course recommended. I am very dilligent on separating services, for good reason: ease of manageability and flexibility, and as a result this guide uses slightly more VMs and IP addresses than one may expect. I will break down the cluster now so you have a better idea of how this is running.

Please note that while this guide has parts that can be copy-pasted, and most specified shell commands and config files will work as intended, I do expect you to understand what you're doing, and RTFM if you don't; a decent knowledge of Linux System Administration is a must here. I don't go into any detail about creating your VMs, or any basic system administration tasks or commands, or what specific config options in files do. Also, all IP addresses/hostnames are fictitious and must be replaced, and anything in <> square brackets must be filled in with you own information. Finally, please note that I offer NO GUARANTEED SUPPORT FOR THIS GUIDE, though if you have a good question I'll probably answer it.


## The Cluster

My home cluster is a fairly simple beast: there are two distinct hypervisors (hv1.example.net and hv2.example.net) running KVM, and a single file server (filer1.example.net). At this time, mostly due to budget reasons (it's a homelab, and those cost a lot of money in power!), I am not replicating to a second fileserver, and hence the backend Maildir storage is not HA in my setup. This can be acomplished in a huge number of ways (glusterFS, DRBD, manual sync) but is outside the scope of this guide. I assume that "filer1.example.net" is some device, providing a single NFS interface for backend storage of Maildirs.

The Virtual Machines running on hv1.example.net and hv2.example.net are served via NFS from filer1, as are the Maildirs used for storing e-mail. This NFS is on a private network local to the servers, and this network also carries LDAP sync and Database traffic. The virtual machines are tied to a hypervisor: each *1* server is on hv1.example.net and each *2* server is on hv2.example.net. It's worth pointing out now that this cluster could easily be expanded to 3 hypervisors (and hence a *3* server for each service) if desired; this is recommended for the Database cluster in particular, however in my setup the filer1.example.net is the third, quorum-holding database server.

I expect your setup to be slightly different. If so, just adapt this guide; I use consistent naming throughout (sed might be your friend here)!


2a) Virtual machines and networking

The cluster comprises the following service VMs, all running Debian Wheezy:

* lbX, IPVS load balancers
* dbX, MariaDB/Galera MySQL servers
* mailX, iRedMail/LDAP servers

Additionally, one VIP address for the load balancers is required:

* lb0, IPVS VIP

And one IP for the file server containing Maildirs:

* filer1, NFS server

The entire cluster therefore uses 8 IP addresses (ignoring the hypervisors, and any other VMs you might have set up). For the purposes of this guide, I assume two networks: "public", 1.1.1.0/24, and "private" , 10.1.1.0/24. You can omit either network and use a single private network; my proper "public" network uses routable public IPs, while the "private" network is unrouted, and certain replication traffic and NFS are kept on the "private" network for security. You can ignore this convention if you want, or even use Masquerade mode with IPVS, to hide all these services behind a single "public" IP and keep it all behind NAT. Whatever works for your environment! If you don't have a proper DNS setup, you can use this template in your "/etc/hosts" file on each host. 

	# "Public"
	1.1.1.11	filer1.example.net
	1.1.1.12	lb0.example.net # (VIP)
	1.1.1.13	lb1.example.net
	1.1.1.14	lb2.example.net
	1.1.1.15	db1.example.net
	1.1.1.16	db2.example.net
	1.1.1.17	mail1.example.net
	1.1.1.18	mail2.example.net
	# "Private"
	10.1.1.11	filer1.local
	10.1.1.13	lb1.local
	10.1.1.14	lb2.local
	10.1.1.15	db1.local
	10.1.1.16	db2.local
	10.1.1.17	mail1.local
	10.1.1.18	mail2.local

Note that there are no VIP in the "private" network: since all its services are load-balanced from the "public" IP, it is unnecessary for there to be a "local" VIP. I recommend firewalling the VIP address (of course) to block MySQL traffic from the outside world if you are using a true public IP, though other services should probably be "public".


2b) A note on example conventions

Thoughout this guide, when command-lines are given, the following rules will be held:

  i) the beginning of the prompt will indicate the server name, either as:
	server1 # <command>
     for a specific server ID, or:
	serverX # <command> 
     for all servers in that category, or even:
	serva1, servb2 # <command>
     for two specific server names
 ii) the seperator character shall be isolated on both sides by a space (for ease of copying a single command, but
     discouraging block copying) and will consist of:
	# - for a root-level account
	$ - for an unprivileged account
iii) for simplicity, most commands in this guide are written as an unprivileged user with "sudo" prepended;
     commands that require the actual *root* account (e.g. the iRedMail.sh setup script) will use # instead
 iv) when editing a text file, the raw contents from server1 will be presented after the command (usually 'sudo
     vim'), followed by a 'diff' of the differences between server1 and server2, if necessary; one can extrapolate 
     the third server or any other differences if desired
  v) any comments regarding a text file will follow the output and diff, prepended by a [*] for each comment


## Setting up IPVS, ldirectord, and keepalived

Chapter source: http://www.ultramonkey.org/papers/lvs_tutorial/html/

The first and probably easiest part of this cluster is the load balancing configuration. It is a very straightforward setup, with 2 load-balancers sharing 1 VIP address: if contact is lost, keepalived moves the VIP between the two servers on a weighted basis (lb1 is prefered to lb2). 

Start by installing the required packages on both hosts.

lbX $ sudo apt-get update
lbX $ sudo apt-get upgrade
lbX $ sudo apt-get install ipvsadm ldirectord keepalived


3a) keepalived

Begin by editing the keepalivd configuration. This will set up the VIP between the two load balancers, and allow it to fail over from lb1 to lb2 in the event lb1 goes down, thus preserving services to anyone connecting to the cluster through this IP.

lbX $ sudo vim /etc/keepalived/keepalived.conf

vrrp_instance VI_1 {
	state MASTER
	interface eth0
	virtual_router_id 1
	priority 200
	authentication {
		auth_type PASS
		auth_pass mySuperSecretPassw0rd
	}
	virtual_ipaddress {
		1.1.1.12/24;
	}
}

5c5
<         priority 200
---
>         priority 100

[*] The adjusted priority on lb2 allows lb1 to take precidence and prevent flapping between the two load balancers. If you have a third lbX host, you can make its priority something less than 100 to ensure it will be last in the chain.

Restart the keepalived service on both hosts:

lbX $ sudo service keepalived restart

You should now see the VIP in the list of IP addresses on lb1:

lb1 $ ip a
[...]
eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 11:11:11:11:11:11 brd ff:ff:ff:ff:ff:ff
    inet 1.1.1.13/24 brd 1.1.1.255 scope global eth0
    inet 1.1.1.12/24 scope global secondary eth0
[...]

Now stop keepalived on lb1, and observe lb2: the IP address will transfer after a second or two:

lb1 $ sudo service keepalived stop

lb2 $ ip a
[...]
eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether 11:11:11:22:22:22 brd ff:ff:ff:ff:ff:ff
    inet 1.1.1.14/24 brd 1.1.1.255 scope global eth0
    inet 1.1.1.12/24 scope global secondary eth0
[...]

You can then restart the keepalived service on lb1 and the IP address will return to it, exactly as expected.


3b) ldirectord

Next is the ldirectord configuration. ldirectord is a load balancer using IPVS, the Linux kernel virtual server, to distribute traffing entering on a VIP between a number of "real servers", . It contains a number of different load-balancing and routing options, however for our purposes, with a "public" network, we will use the 'routed' mode, whereby traffic is directly routed from the VIP to the real server, which has configured on a loopback interface the VIP, allowing traffic to be sent directly back to the client from the real server, reducing load on the load balancers. In effect, the routers simply keep track of incoming packets while the outgoing packets flow right to the client.

ldirectord works by performing regular health checks on the real servers; if one is found to be non-working, it is removed from the IPVS configuration, thus preventing clients from being directed to a dead server. Once the service has been restored, ldirectord re-adds the real server to the IPVS configuration, and load-balancing resumes.

The following ldirectord.cf file contains all the services that will be provided in HA mode for client access, the list of which is: MySQL, HTTP/S, IMAPS, POPS, and SMTPSUB. I don't allow unsecured access via IMAP or POP3 directly to my mail servers, but you can add these services if desired.

```
lbX $ sudo vim /etc/ldirectord.cf

logfile="daemon"
fallbackcommand=""
failurecount=3
checkinterval=5
fork=yes

# MySQL database to db1/db2
virtual=1.1.1.12:3306
        real=1.1.1.15:3306 gate
        real=1.1.1.16:3306 gate
        service=mysql
        scheduler=sh
        login="monitor"
        passwd="monitoringPassw0rd"
        request="SELECT * from monitoring.monitoring;"
# Mail services to mail1/mail2
virtual=1.1.1.12:80
        real=1.1.1.17:80 gate
        real=1.1.1.18:80 gate
        service=http
        scheduler=sh
        request="ldirectord.txt"
        receive="ldirectord"
virtual=1.1.1.12:443
        real=1.1.1.17:443 gate
        real=1.1.1.18:443 gate
        service=https
        scheduler=sh
        request="ldirectord.txt"
        receive="ldirectord"
virtual=1.1.1.12:993
        real=1.1.1.17:993 gate
        real=1.1.1.18:993 gate
        service=imaps
virtual=1.1.1.12:995
        real=1.1.1.17:995 gate
        real=1.1.1.18:995 gate
        service=pops
virtual=1.1.1.12:465
        real=1.1.1.17:465 gate
        real=1.1.1.18:465 gate
        service=smtp
```

* Both servers are identical.
* Service checks for MySQL and HTTP/S will be addressed in their relevant sections.

Reload the ldirectord service, and use "ipvsadm" to view the resulting IPVS configuration (IP-to-hostname translation is used, if you don't have reverse DNS configured you will see IP addresses):

```
lbX $ sudo service ldirectord restart
lbX $ sudo ipvsadm
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  lb0.example.net:mysql sh
  -> db1.example.net:mysql        Route   1      0          0         
  -> db2.example.net:mysql        Route   1      0          0
TCP  lb0.example.net:http sh
  -> mail1.example.net:http       Route   1      0          0         
  -> mail2.example.net:http       Route   1      0          0
TCP  lb0.example.net:https sh
  -> mail1.example.net:https      Route   1      0          0         
  -> mail2.example.net:https      Route   1      0          0
TCP  lb0.example.net:imaps wrr
  -> mail1.example.net:imaps      Route   1      0          0         
  -> mail2.example.net:imaps      Route   1      0          0
TCP  lb0.example.net:pops wrr
  -> mail1.example.net:pops       Route   1      0          0         
  -> mail2.example.net:pops       Route   1      0          0
TCP  lb0.example.net:submission wrr
  -> mail1.example.net:submission Route   1      0          0         
  -> mail2.example.net:submission Route   1      0          0

However, since you have not yet configured any services, there will be no real servers in your output, only the lines containing "lb0.example.net":

IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  lb0.example.net:mysql sh
TCP  lb0.example.net:http sh
TCP  lb0.example.net:https sh
TCP  lb0.example.net:imaps wrr
TCP  lb0.example.net:pops wrr
TCP  lb0.example.net:submission wrr
```

Once this guide is done, compare the resulting output from "ipvsadm" to the above output, and you should see it match!

This concludes the configuration required on the load balancers themselves. However, one more piece of configuration must be done to *each* real server: it must have the VIP address added to a loopback interface to allow services on the server to use that address to reply to clients. This is a required part of the "direct-routing" mode used in IPVS. If you are using an alternate routing mode (for example Masquerade), you do not need this step. On each dbX and mailX host:

```
serverX $ sudo vim /etc/network/interfaces

# Loopback interface
auto lo
iface lo inet loopback

# IPVS-DR loopback interface
auto lo:0
iface lo:0 inet static
        address 1.1.1.12
        netmask 255.255.255.255
        pre-up sysctl -w net.ipv4.conf.all.arp_ignore=1
        pre-up sysctl -w net.ipv4.conf.all.arp_announce=2

# Other interfaces, server-specific...
[...]
```

* All servers are identical.

This concludes the configuration of the load balancer setup, and the VIP that will direct requests to the client machines.


## Setting up MariaDB and Galera multi-master SQL

Chapter source: https://blog.mariadb.org/installing-mariadb-galera-cluster-on-debian-ubuntu/

As seen above, one of the load-balanced services is MySQL. Databases are used extensively in e-mail servers: they hold information about active accounts, sessions, filter policies; the list goes on. The services of the dbX servers could be integrated into the mailX servers themselves, however in my usage it makes more sense to separate them. You can easily run all of the following on the mailX servers and reduce your IP usage by two if you so desire (just don't forget to edit the ldirectord.cf file in Chapter 3 to match!)

The MySQL cluster will be provided by MariaDB, a community-driven fork of Oracle's MySQL, and headed by the original developers of MySQL. It is combined with the Galera replication engine to allow a multi-master cluster than can be load-balanced by IPVS. I am using version 5.5 for maximum compatibility, though the newer releases could be used as well. To prevent split-brain, we also use a third host in the Galera cluster, which will be provided by the filer1 server; if you are using this guide to set up a 3-server cluster, you can exclude that host as quorum will be provided by 3 dbX servers. Run all commands below on filer1 as well as dbX.

Start by adding the MariaDB sources (other mirrors can be found at https://downloads.mariadb.org/mariadb/repositories/) into your apt configuration:

dbX $ sudo apt-get install python-software-properties
dbX $ sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db
dbX $ sudo add-apt-repository 'deb http://mariadb.mirror.rafal.ca/repo/5.5/debian wheezy main'

Then update and install the required packages:

dbX $ sudo apt-get update
dbX $ sudo apt-get install rsync galera mariadb-galera-server

You will be asked for a root password during setup; ensure it is identical on all hosts. Once installed, stop the mysql process as we need it off for the next steps.

dbX $ sudo service mysql stop

The Galera configuration below is extremely simple; read the Galera documentation for more advanced configuration options. Set the local IP addresses of the cluster members in the "wsrep_cluster_address" line, to keep replication traffic on the unrouted local network. You can also set the "wsrep_cluster_name" to a new value; this is in effect a shared secret for the cluster.

```
dbX $ sudo vim /etc/mysql/conf.d/galera.cnf
	
[mysqld]
# MySQL settings
binlog_format=ROW
default-storage-engine=innodb
innodb_autoinc_lock_mode=2
query_cache_size=0
query_cache_type=0
bind-address=0.0.0.0
# Galera settings
wsrep_provider=/usr/lib/galera/libgalera_smm.so
wsrep_cluster_name="db_cluster"
wsrep_cluster_address="gcomm://10.1.1.11,10.1.1.15,10.1.1.16"
wsrep_sst_method=rsync
```

* All servers are identical.

Also clone the /etc/mysql/debian.cnf file from db1 to the other database hosts; this will, combined with the tweaks below, prevent "debian-sys-maint" access denied warnings when starting the other cluster nodes.

Warning: Before we continue, I have discovered a bug in this setup. Because of the IPVS-DR loopback, the Galera cluster will sometimes fail to start on the second or third node of the cluster. The reasons I do not completely understand. To mitigate this however, I made a modification to the "/etc/init.d/mysql" initscript to add an "ifdown lo:0" and corresponding "ifup lo:0" at the beginning and end, respectively, of the "start" function. I recommend doing this to save you hours of headaches!

Once the configuration is in place on all nodes, we can start the cluster on the first node:

db1 $ sudo service mysql start --wsrep-new-cluster

The "--wsrep-new-cluster" directive creates a new active cluster; if all hosts in the Galera cluster go down, you will need to execute this command on a node again to start up the cluster. Data is of course preserved when running this command, and the host it is run on will become the "primary" sync source for the other members of the cluster.

On the remaining nodes, start the MySQL service normally:

db2,filer1 $ sudo service mysql start

If all goes well, they will connect to the cluster master, and data will synchronize. Check the number of nodes in the cluster with:

db1 $ mysql -u root -p -e 'SELECT VARIABLE_VALUE as "cluster size" FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE VARIABLE_NAME="wsrep_cluster_size"'
+--------------+
| cluster size |
+--------------+
| 3            |
+--------------+

There are a number of configuration tweaks that must be performed to properly use the MySQL cluster as expected. Enter the database server, and:

db1 $ mysql -u root -p
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 104893
Server version: 5.5.38-MariaDB-1~wheezy-wsrep-log mariadb.org binary distribution, wsrep_25.10.r3997
Copyright (c) 2000, 2014, Oracle, Monty Program Ab and others.
Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
MariaDB [(none)]> 

  i) Create a "new" root user with global host access. Yes, you can restrict this per-host, but that gets messy fast 
     and if you have a *properly secured* network, you shouldn't have to worry about this too much.

MariaDB [(none)]> GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION IDENTIFIED BY '<MySQL root password>';
MariaDB [(none)]> GRANT PROXY ON ''@'' TO 'root'@'%' WITH GRANT OPTION;

 Test that this user works by logging in to another MySQL shell, and if it works fine, drop all "old" root users:

MariaDB [(none)]> SELECT User,Host from mysql.user;
[view the resulting list of users]
MariaDB [(none)]> DROP USER 'root'@'db1';
MariaDB [(none)]> DROP USER 'root'@'db2';
[etc.]

 ii) Create a "new" debian-sys-maint user, with slighly more restricted access than the root user; again this user
     should be for the global host for simplicity.

MariaDB [(none)]> GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, RELOAD, SHUTDOWN, PROCESS, FILE, REFERENCES, INDEX, ALTER, SHOW DATABASES, SUPER, CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, REPLICATION SLAVE, REPLICATION CLIENT, CREATE VIEW, SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, CREATE USER, EVENT, TRIGGER ON *.* TO 'debian-sys-maint'@'%' IDENTIFIED BY '<debian-sys-maint password from /etc/mysql/debian.cnf>' WITH GRANT OPTION;

 Make sure that the "/etc/mysql.debian.cnf" file is identical between all the dbX nodes. And like the root user, drop all "old" debian-sys-maint users:

MariaDB [(none)]> DROP USER 'debian-sys-maint'@'db1';
MariaDB [(none)]> DROP USER 'debian-sys-maint'@'db2';
[etc.]

Attempt to stop the mysql service on any one node; it should suceed without any warnings or errors about permission denied; restart it and resume configuration.

Now we will add some data to the cluster and observe its replication. The data used is, conveniently, the monitoring framework required by ldirectord.

db1 $ mysql -u root -p
MariaDB [(none)]> 

Begin by creating a new database called 'monitoring'; these values were set in Chapter 3, in ldirectord.cf:

MariaDB [(none)]> CREATE DATABASE monitoring;

Create a new user, 'monitor', identified by the password 'monitoringPassw0rd', and grant select access to the 'monitoring' database:

MariaDB [(none)]> GRANT SELECT ON monitoring.* TO 'monitor'@'%' IDENTIFIED BY 'monitoringPassw0rd';

Now, change into the monitoring database, and create a table called "monitoring" containing some data:

MariaDB [(none)]> USE monitoring;         
MariaDB [monitoring]> CREATE TABLE monitoring (data VARCHAR(1));
MariaDB [monitoring]> INSERT INTO monitoring (data) VALUES ("X");
MariaDB [monitoring]> SELECT * FROM monitoring.monitoring;
+------+
| data |
+------+
| X    |
+------+
MariaDB [monitoring]> quit
Bye

You have now set up the monitoring table that the ldirectord daemon will connect to and attempt to judge your hosts' health. If everything is configured and working right, you should now see the real servers in the output of "ipvsadm" on lbX:

lbX $ sudo ipvsadm
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  lb0.example.net:mysql wrr
  -> db1.example.net:mysql        Route   1      0          0         
  -> db2.example.net:mysql        Route   1      0          0
[...]

You can see the data replication by checking any other node: you should be able to see the monitoring database and its table. But if both your dbX servers are in the IPVS configuration above, you should be good to go! Now you can access the databases, load-balanced between the two dbX VMs, from the VIP address at lb0.example.net. I recommend aliasing/pointing "db.example.net" to "lb0.example.net" now as this will be used as a referenced name later.

A note about filer1: When setting up the DB, we used filer1 as our third, quorum-holding host. However, as that is not a proper "database" server, it is NOT added to the load-balanced cluster. It is, in effect, a write-only copy of the data to preserve quorum. If you are using three physical servers, and hence three dbX servers, you should be able to use just those 3 to maintain quorum, and load-balance over all 3, in which case you can avoid putting any MySQL on the filer1 server.

This concludes the configuration of the database cluster, which is now ready for data to be added from the mailX servers, via the load-balanced VIP address at lb0.example.net.


## Highly-available, LDAP-backed iRedMail e-mail

Chapter source: iRedAdmin Wiki/Existing Tutorials

And now for the Piece de resistance, the whole reason for this tutorial: the HA iRedMail cluster! For this setup, we will be using a multi-master LDAP backend to store user data; each mail server will connect to its own, local, LDAP database and those databases will be synchronized between the two servers. This allows iRedAdmin management, as well as user access, to be passed through the load balancer: if a mail server goes down, regardless of which one, the mail administrator(s) can still make changes and continue working as if nothing happened to the infrastructure backend; let the sysadmins worry about that!

Note that mirrormode LDAP multi-master clusters are ideally used with a "preferred" master. For this reason, I don't recommend *actually* using the VIP address to access iRedAdmin under normal situations: manage from mail1, and if needed, manage from mail2 if mail1 is down. This helps preserve consistency so that you can trust one particular host if an LDAP split-brain happens.


5a) iRedMail installation with the HA MySQL backend

To begin, become root on both mail servers:

mailX $ sudo su
mailX #

Now download and extract the latest version of iRedMail, at the time of writing iRedMail-0.8.7:

mailX # wget iRedMail-0.8.7.tar.bz2
mailX # tar -xvjf iRedMail-0.8.7.tar.bz2

Before we begin installing iRedMail, add a fully-privileged user to the database server that can be used by the install script to set up the databases. This user can be removed after installation; alternatively, you could use root but this is not recommended.

db1 # mysql -u root -p
MariaDB [(none)]> GRANT ALL PRIVILEGES ON *.* TO 'admin_iredmail'@'%' WITH GRANT OPTION IDENTIFIED BY '<password>';

Next, mount the NFS Maildir storage from filer1 on both mailX hosts (I prefer the default "/var/vmail"); ensure you add it to "/etc/fstab" as well:

mailX # mkdir /var/vmail
mailX # chattr +i /var/vmail
mailX # mount -t nfs -o vers=3,noatime,nodiratime,noexec filer1.local:/srv/var/vmail /var/vmail
mailX # echo "filer1.local:/srv/var/vmail /var/vmail nfs vers=3,noatime,nodiratime,noexec 0 0" >> /etc/fstab

Configuration should begin on mail1 first: this will allow us to generate an iRedMail installer 'config' file, which we will then use to ensure mail2 is configured with the same settings.

Start the iRedMail installer with variables specifying the database host, user, and grant host (in our case, '%' for simplicity in our MySQL users):

mail1 # cd iRedMail-0.8.7/
mail1 # MYSQL_SERVER='db.example.net' MYSQL_ROOT_USER='admin_iredmail' MYSQL_GRANT_HOST='%' bash iRedMail.sh

Follow the directions as per the standard iRedMail setup procedure. In particular, choose an LDAP backend, and choose the NFS directory for the Maildir storage. Also ensure that you save any password you entered: these will eventually be the cluster master passwords. During setup, you will be asked for the password for "admin_iredmail" you set above in order for the installer to access the MySQL cluster. Also, don't use an additional domain when asked for your first virtual domain: use "example.net". This will simplify our deployment and allow you to add actual domains to the full cluster later.

Once the iRedMail setup completes, your first node will be operational! Feel free to test it out, and inspect the database servers to confirm that the data for the iRedMail server was properly added to the MySQL cluster backend and is replicating between the hosts as expected.

Next, copy the "config" file from the iRedMail installer directory over to the second server. This will ensure all our passwords and configuration options are synced and everything will work properly within the cluster.

mail1 # cd ~
mail1 # scp iRedMail-0.8.7/config mail2:~/iRedMail-0.8.7/

You are now ready to begin the setup procedure on mail2. Use the same command from mail1 on mail2, and ignore any errors from MySQL about databases already existing (since they do!):

mail2 # cd iRedMail-0.8.7/
mail2 # MYSQL_SERVER='db.example.net' MYSQL_ROOT_USER='admin_iredmail' MYSQL_GRANT_HOST='%' bash iRedMail.sh

You will be informed that a config already exists; would you like to use it? Select "yes" to use the same settings as mail1 on mail2. 

A little bit of setup is required for ldirectord to manage the web page load balancing. Create a text file in the root of the web server (usually "/var/www") called "ldirectord.txt", containing the string "ldirectord"; as before, this was configured in the ldirectord.cf file on lbX:

mailX # echo "ldirectord" > /var/www/ldirectord.txt

As is good practice, drop back out of root to your unprivileged user now:

mailX # exit
mailX $


5b) Setting up LDAP multi-master replication

Chapter source: http://www.openldap.org/doc/admin24/replication.html

Once the install completes on mail2, we can proceed with configuring LDAP in a multi-master replication between mail1 and mail2 (and mail3 if you desire).

Start by stopping the slapd service on both hosts:

mailX $ sudo service slapd stop

Edit the /etc/ldap/slapd.conf file on both hosts:

mailX $ sudo vim /etc/ldap/slapd.conf

Make the following changes:

  i) under the "# Modules." section, add:

moduleload  syncprov

 ii) at the end of the file, add:

```
# Multi master replication
ServerID        1 "ldap://mail1.example.net"
ServerID        2 "ldap://mail2.example.net"
overlay         syncprov
syncprov-checkpoint     10 1
syncprov-sessionlog     100
syncrepl        rid=1
                provider="ldap://mail1.local"
                type=refreshAndPersist
                interval=00:00:00:10
                retry="5 10 60 +"
                timeout=1
                schemachecking=off
                searchbase="dc=bonilan,dc=net"
                scope=sub 
                bindmethod=simple
                binddn="cn=Manager,dc=example,dc=net"
                credentials="<LDAP rootdn password in plaintext>"
syncrepl        rid=2
                provider="ldap://mail2.local"
                type=refreshAndPersist
                interval=00:00:00:10
                retry="5 10 60 +"  
                timeout=1 
                schemachecking=off
                scope=sub 
                searchbase="dc=bonilan,dc=net"
                bindmethod=simple
                binddn="cn=Manager,dc=example,dc=net"
                credentials="<LDAP rootdn password in plaintext>"
MirrorMode      on
```

* All servers are identical.
* Using the "local" addresses in the "provider" lines allows the LDAP replication to occur over the local network for security. LDAP should be blocked at your firewall for the public addresses just like MySQL, unless required; each mailX host will look at its own local LDAP instance when accessing or modifying data.

You can now start slapd on mail1:

```
mail1 $ sudo service slapd start
```

It should start normally; now, start it on mail2:

```
mail2 $ sudo service slapd start
```

Since you used the same "config" file for both, all the data should match up and you will now have a functioning, replicated LDAP setup. Test it out by using iRedAdmin to add data on mail1, and check if it exists on mail2. If it does, congratulations! You have a fully HA iRedMail setup.


## Final notes

You now have a fully-functional cluster. All data is HA, and can tolerate the failure of any one set of nodes without interruption of service, either on the user or administrator side. You can now set up your first virtual domain (example.net) with some users, and configure DNS for it:

```
example.net		IN	MX	1 mail1.example.net
example.net		IN	MX	1 mail2.example.net
mail.example.net	IN	A	1.1.1.12
smtp.example.net	IN	A	1.1.1.12
imap.example.net	IN	A	1.1.1.12
pop.example.net		IN	A	1.1.1.12
```

With this setup, your incoming mail will be redirected to one of either mail1 or mail2, where Postfix will filter and deliver it to the LDAP-backed mailbox of the domain user. Stored on NFS, that user can then access the mail using HTTP/S webmail, IMAPS, or POPS on the VIP, which will redirect to one of the two servers based on load and availability. The Dovecot session will use the syncronized MySQL backend to ensure consistency, and will read the data from the shared Maildir regardless of which real server the user is connected to. Try it out with a few users, and tinker with the settings to get it just perfect for you. And voila! A HA mail solution in under 6000 words!



## Credits and Copyright

 * Joshua Boniface, the tinkerer and homelab geek who set this cluster up and documented the whole thing
 * The iRedMail team for making this fantastic e-mail setup and management system
 * The maintainers of a number of wonderful guides and manuals on how to configure the individual components
 * YOU, for trying this out and leaving me your feedback

```
Copyright (C)  2014  JOSHUA BONIFACE.
Permission is granted to copy, distribute and/or modify this document
under the terms of the GNU Free Documentation License, Version 1.3
or any later version published by the Free Software Foundation;
with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
A copy of the license is included in the section entitled "GNU
Free Documentation License". --- https://gnu.org/licenses/fdl.html
```
	
Joshua Boniface is a Linux system administrator from Burlington, ON, Canada, specializing in Debian-based distributions. He can be found online under the handle "djbon2112", via his e-mail address joshua <at> boniface <dot> me, and at his website (under construction) http://www.boniface.me.
