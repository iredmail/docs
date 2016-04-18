# Install Pure-FTPd with OpenLDAP backend on RHEL/CentOS

[TOC]

## Install Pure-FTPd

Install PureFTPD from EPEL yum repo:

```
# yum install pure-ftpd
```

## Use a proper LDAP bind dn/password to query accounts

iRedMail generates a read-only LDAP bind dn `cn=vmail,dc=xxx,dc=xxx` during
installation, so it's perfect to query user accounts with this dn.

You can find the full dn and password in `/etc/postfix/ldap/catchall_maps.cf`:

```
# grep 'bind_' /etc/postfix/ldap/catchall_maps.cf
bind_dn         = cn=vmail,dc=example,dc=com
bind_pw         = InYTi8qGjamTb6Me2ESwbb6rxQUs5y
```

## Configure the LDAP setting for PureFTPD

* Open `/etc/pure-ftpd/pureftpd-ldap.conf` and update parameters below:

```
LDAPServer      localhost
LDAPPort        389
LDAPBaseDN      o=domains,dc=example,dc=com
LDAPBindDN      cn=vmail,dc=example,dc=com
LDAPBindPW      InYTi8qGjamTb6Me2ESwbb6rxQUs5y   # cn=vmail password 
LDAPDefaultUID  2000                             # <- UID of `vmail` user.
LDAPDefaultGID  2000                             # <- GID of `vmail` user.
LDAPFilter      (&(objectClass=PureFTPdUser)(mail=\L)(FTPStatus=enabled))
LDAPHomeDir     FTPHomeDir                       # <- New LDAP attribute, we will add it later.
LDAPVersion     3
```

## Config OpenLDAP

* Get the schema modified by iredmail, it adds a new attribute `FTPHomeDir` to
  store per-user FTP home directory. Default schema uses `homeDirectory`.

```
# wget https://bitbucket.org/zhb/iredmail/raw/default/extra/samples/pureftpd.schema
# mv pureftpd.schema /etc/openldap/schema/
```

* Update `/etc/openldap/slapd.conf`, include `pureftpd.schema` after `iredmail.schema`:

```
include /etc/openldap/schema/iredmail.schema
include /etc/openldap/schema/pureftpd.schema    # <-- Add this line.
```

* Open `/etc/openldap/slapd.conf`, append required indexes for attributes
  defined in `pureftpd.schema`:

```
# Indexes for Pure-FTPd LDAP attributes.
index FTPQuotaFiles,FTPQuotaMBytes eq,pres
index FTPUploadRatio,FTPDownloadRatio eq,pres
index FTPUploadBandwidth,FTPDownloadBandwidth eq,pres
index FTPStatus,FTPuid,FTPgid,FTPHomeDir eq,pres
```

## Create FTP Home Directory

We're going to store all FTP data under `/home/ftp/` directory, so let's create
`/home/ftp/` first, directory owner MUST be `root` user.

```
# mkdir /home/ftp/
# ls -dl /home/ftp
drwxr-xr-x 3 root root 4096 Jun  7 20:18 /home/ftp/
```

## Restart OpenLDAP and Pure-FTPD Service

Restart Pure-FTPd and OpenLDAP services:

```
# /etc/init.d/ldap restart
# /etc/init.d/pure-ftpd restart 

# netstat -ntlp | grep pure-ftpd
tcp 0   0 0.0.0.0:21    0.0.0.0:*   LISTEN  2062/pure-ftpd (SERVER)
tcp 0   0 :::21         :::*        LISTEN  2062/pure-ftpd (SERVER)
```

## Add LDAP FTP attributes and values for new user

With script shipped in iRedMail, you can quickly create NEW mail user which
has pureftpd service support.

* Open file `tools/create_mail_user_OpenLDAP.sh` under your iRedMail directory
  (e.g. `/root/iRedMail-0.9.4/tools/create_mail_user_OpenLDAP.sh`), update
  paraemters below with correct values:

```
LDAP_SUFFIX="dc=example,dc=com"         # <- Change the LDAP suffix 
BINDPW='passwd'                         # <- Password for the bind dn `cn=Manager,dc=example,dc=com`
PUREFTPD_INTEGRATION='YES'              # <- Set to 'YES' to enable the pureftp inteegration
FTP_STORAGE_BASE_DIRECTORY='/home/ftp'  # <- Change it to the ftp home directory
```

* Run the script to create a new user `user1@example.com`. The default
  password is same as user name (`user1`) by default.

```
# bash create_mail_user_OpenLDAP.sh example.com user1

adding new entry "ou=Users,domainName=example.com,o=domains,dc=example,dc=com"
ldapadd: Already exists (68)
adding new entry "ou=Groups,domainName=example.com,o=domains,dc=example,dc=com"
ldapadd: Already exists (68)
adding new entry "ou=Aliases,domainName=example.com,o=domains,dc=example,dc=com"
ldapadd: Already exists (68)
adding new entry "mail=user1@example.com,ou=Users,domainName=example.com,o=domains,dc=example,dc=com"
```

You can now login to both webmail and FTP service as this user.

## Configure iptables

iRedMail doesn't open port 20 and 21 by default, you must open them first.

* Open `/etc/sysconfig/iptables` and set correct values:

```
-A INPUT -p tcp --dport 20 -j ACCEPT
-A INPUT -p tcp --dport 21 -j ACCEPT
```

* Restart the iptables service

```
# service iptables restart 
```

## Testing

You can use windows FTP client or Linux ftp client (e.g. command line ftp
client `lftp` or GUI client [`FileZilla`](https://filezilla-project.org)) for
testing.

We use `lftp` for testing below:

```
$ lftp localhost
localhost:~> debug 4
localhost:~> login user1@example.com user1 # <-- input the username and password
user1@example.com@localhost:~> ls 
---- Connecting to localhost (127.0.0.1) port 21
<--- 220---------- Welcome to Pure-FTPd [privsep] [TLS] ----------
<--- 220-You are user number 1 of 50 allowed.
<--- 220-Local time is now 16:25. Server port: 21.
<--- 220-IPv6 connections are also welcome on this server.
<--- 220 You will be disconnected after 15 minutes of inactivity.
<--- 211-Extensions supported:
<---  EPRT
<---  IDLE
<---  MDTM
<---  SIZE
<---  REST STREAM
<---  MLST type*;size*;sizd*;modify*;UNIX.mode*;UNIX.uid*;UNIX.gid*;unique*;
<---  MLSD
<---  ESTP
<---  PASV
<---  EPSV
<---  SPSV
<---  ESTA
<---  AUTH TLS
<---  PBSZ
<---  PROT
<---  UTF8
<--- 211 End.
<--- 500 This security scheme is not implemented
<--- 200 OK, UTF-8 enabled
<--- 200  MLST OPTS type;size;sizd;modify;UNIX.mode;UNIX.uid;UNIX.gid;unique;
<--- 331 User user1@example.com OK. Password required
<--- 230-Your bandwidth usage is restricted
<--- 230-User user1@example.com has group access to:  vmail   
<--- 230-You must respect a 1:5 (UL/DL) ratio
<--- 230-OK. Current restricted directory is /
<--- 230-0 files used (0%) - authorized: 50 files
<--- 230 0 Kbytes used (0%) - authorized: 10240 Kb
<--- 257 "/" is your current location
<--- 227 Entering Passive Mode (127,0,0,1,32,58)
<--- 150 Accepted data connection
drwxr-xr-x    2 500      vmail        4096 Jun 10 16:16 .
drwxr-xr-x    2 500      vmail        4096 Jun 10 16:16 ..
-rw-------    1 500      vmail           0 Jun 10 16:16 .ftpquota
```

## Troubleshooting

Enable verbose log in pure-ftpd

* Open `/etc/pure-ftpd/pure-ftpd.conf`  and set correct values:

```
VerboseLog                  yes # <-- change from no to yes
```

* Open `/etc/rsyslog.conf` and set correct values:

```
ftp.*                       -/var/log/pureftpd.log # <-- Add entry
```

* Restart services

```
# service pure-ftpd restart
# service rsyslog restart
```

Monitor `/var/log/pureftpd.log` for troubleshooting:

```
# tail -0f /var/log/pureftpd.log
```

If you need to debug OpenLDAP, please refer to another document:  [Debug OpenLDAP](./debug.openldap.html).
