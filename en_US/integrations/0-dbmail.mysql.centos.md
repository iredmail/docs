# Integrate DBMail with iRedMail (MySQL backend) on CentOS

[TOC]

## ChangeLog

* 2011-10-26: Cleanup unnecessary process for installing DBMail.
* 2011-08-27: Initial release.

## Requirements

This tutorial is written for:

* Red Hat Enterprise Linux 5.x, 6.x
* CentOS 5.x, 6.x
* Scientific Linux 6.x

## Introduce DBMail

### What DBMail is

DBMail is an open-source project that enables storage of mail messages in a relational database. Currently MySQL, PostgreSQL and SQLite can be used as storage backends. Web site: [http://www.dbmail.org/](http://www.dbmail.org/).

### Why DBMail

Quote from DBMail web site:

> * __Scalability__. DBMail is as scalable as the database system used for storage.
> * __Manageability__. DBMail can be managed by updating the relational database or directory service - without shell access.
> * __Speed__. Dbmail uses very efficient, database specific queries for retrieving mail information.
> * __Security__. Dbmail doesn't require filesystem access. It's as secure as the database and directory server used. 
> * __Flexibility__. Changes in a Dbmail system (adding of users, changing passwords etc.) are effective immediately. Users can be stored in the database, or managed separately in an LDAP server such as OpenLDAP or Active Directory.

Notes:

* For RHEL/CentOS/Scientific Linux 5.x, we will install DBMail-2.2.17 from [yum repo `EPEL`](http://fedoraproject.org/wiki/EPEL).
* For RHEL/CentOS/Scientific Linux 6.x, we will install DBMail-3.0.0-rc from [yum repo `EPEL`](http://fedoraproject.org/wiki/EPEL).
* DBMail-2.x doesn't provide native TLS/SSL support.

##  Preparations

* OS:

    * Red Hat Enterprise Linux 5.x or 6.x
    * CentOS 5.x or 6.x
    * Scientific Linux 5.x or 6.x

* A running iRedMail server. MySQL server is installed by default in both OpenLDAP and MySQL backends, so either backend is OK. If you don't have a running iRedMail server, please follow our installation guide here: [http://www.iredmail.org/doc.html](http://www.iredmail.org/doc.html).

* DBMail version:

    * 3.0.0 serial: 3.0.0-rc2 or later versions. There's a compatibility issue in DBMail-3.0.0-rc1, it won't work with Cyrus-SASL for SMTP AUTH.
    * 2.2.x.

## DBMail, IMAP/POP3 Server

### Preparations

Before installing DBMail software, we need to create necessary system user and
group to run DBMail daemons, and create necessary MySQL database which used to
store mail accounts and messages.

* Create necessary system user (dbmail) and group (dbmail).

```
# useradd -s /sbin/nologin -m dbmail
```

Above command will create group `dbmail` and system user `dbmail`. You can verify it with command `id`:

```
# id dbmail
uid=504(dbmail) gid=504(dbmail) groups=504(dbmail)
```

* Create MySQL database `dbmail` to store mail accounts and mail messages. Replace `password_of_dbmail` below with your password.

```sql
$ mysql -uroot -p
mysql> CREATE DATABASE dbmail DEFAULT CHARACTER SET utf8;
mysql> GRANT ALL ON dbmail.* TO dbmail@localhost IDENTIFIED BY 'password_of_dbmail';
mysql> FLUSH PRIVILEGES;
```

We now have a MySQL database `dbmail`, you can access it with MySQL user `dbmail` and password `password_of_dbmail`. You can verify it with MySQL command line:

```sql
$ mysql -udbmail -p
Enter password:                # <- Type password of MySQL user dbmail here.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| dbmail             |      # <- Database 'dbmail' is available.
+--------------------+
2 rows in set (0.04 sec)
```

* Stop Dovecot daemon. Since Dovecot will be replaced by DBMail, we must stop it:

```
# /etc/init.d/dovecot stop
# chkconfig --level 345 dovecot off
```

### Install DBMail

DBMail is available in [EPEL repository](http://fedoraproject.org/wiki/EPEL#How_can_I_use_these_extra_packages.3F), we will use this yum repository to install DBMail.

It's now ready to install DBMail core component and library used to connect MySQL.

```
#
# ---- For RHEL/CentOS/Scientific Linux 5.x ----
#
# rpm -ivh http://download.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm
# yum clean all
# yum install dbmail dbmail-mysql

#
# ---- For RHEL/CentOS/Scientific Linux 6.x ----
#
# rpm -ivh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-5.noarch.rpm
# yum clean all
# yum install dbmail
```

On RHEL/CentOS/Scientific Linux 6.x, please make sure you have DBMail 3.0.0-rc3 or later version installed:

```
# rpm -q dbmail
dbmail-3.0.0-0.6.rc3.el6.x86_64
```

Main configure file of DBMail is `/etc/dbmail.conf` by default, we will configure it later.

DBMail provides a MySQL template file `/usr/share/doc/dbmail-x.y.z/sql/mysql/create_tables.mysql` (replace 'x.y.z' by real version number on your server), we should import it to create necessary MySQL tables to store mail accounts and messages. Here we use 'dbmail-3.0.0' for example.

```shell
# rpm -ql dbmail | grep 'create_tables.mysql'
/usr/share/doc/dbmail-3.0.0/sql/mysql/create_tables.mysql

# mysql -udbmail -p
mysql> USE dbmail;
mysql> SOURCE /usr/share/doc/dbmail-3.0.0/sql/mysql/create_tables.mysql;
mysql> SHOW TABLES;               # < See what tables were created.
```

### Configure DBMail

Now open configure file of DBMail, `/etc/dbmail.conf`, update below settings:

```
[DBMAIL]
# Store mail messages in which kind of database. We use MySQL here.
driver                = mysql

# Authenticate mail users from SQL database or LDAP server. We use SQL (MySQL) here.
authdriver            = sql

# Host for database.
host                 = 127.0.0.1
sqlport              = 3306
sqlsocket            = /var/lib/mysql/mysql.sock

# Database username.
user                 = dbmail

# Database password.
pass                 = password_of_dbmail

# Database name.
db                   = dbmail

# Table prefix. Defaults to "dbmail_" if not specified.
table_prefix         = dbmail_

# ---- For DBMail-2.2.x ----
# Debug level. 0 for production use, 511 for debug.
#TRACE_SYSLOG          = 32
#TRACE_STDERR          = 32
# ---- For DBMail-3.0.0 ----
file_logging_levels       = 32
syslog_logging_levels     = 32

# ---- For DBMail-2.2.x ----
# Run DBMail services as which system user and group.
#EFFECTIVE_USER        = dbmail
#EFFECTIVE_GROUP       = dbmail
# ---- For DBMail-3.0.0 ----
effective_user        = dbmail
effective_group       = dbmail

# directory for storing PID files.
pid_directory         = /var/run/dbmail

# Where we have DBMail libraries installed.
# It's /usr/lib/dbmail on i386 system, /usr/lib64/dbmail on x86_64 system.
library_directory     = /usr/lib64/dbmail

###########################################
# Below settings are DBMail-3.0.0 special #
###########################################
#
# SSL/TLS certificates
#
# A file containing a list of CAs in PEM format
tls_cafile            = /etc/pki/tls/certs/iRedMail_CA.pem

# A file containing a PEM format certificate
tls_cert              = /etc/pki/tls/certs/iRedMail_CA.pem

# A file containing a PEM format RSA or DSA key
tls_key               = /etc/pki/tls/private/iRedMail.key

hash_algorithm = SHA1

[POP]
tls_port              = 995

[IMAP]
tls_port              = 993

[SIEVE]
# Note: Please set it to 2000 on RHEL/CentOS 5.x, 4190 on RHEL/CentOS 6.x.
port                  = 4190
```

Create directory to store PID files:

```
# mkdir /var/run/dbmail
# chown dbmail:dbmail /var/run/dbmail
```

It's ready to start DBMail daemons:
```
# for i in dbmail-imapd dbmail-lmtpd dbmail-pop3d dbmail-timsieved; do /etc/init.d/$i restart; done
```

Make sure DBMail daemons will start when system startup:

```
# for i in dbmail-imapd dbmail-lmtpd dbmail-pop3d dbmail-timsieved; do chkconfig --level 345 $i on; done
```

Check status of DBMail daemons:

```
# netstat -ntlp | grep dbmail
tcp        0      0 0.0.0.0:110                 0.0.0.0:*                   LISTEN      1747/dbmail-pop3d   
tcp        0      0 0.0.0.0:143                 0.0.0.0:*                   LISTEN      1710/dbmail-imapd   
tcp        0      0 0.0.0.0:24                  0.0.0.0:*                   LISTEN      1734/dbmail-lmtpd   
tcp        0      0 0.0.0.0:4190                0.0.0.0:*                   LISTEN      1760/dbmail-timsiev 
tcp        0      0 0.0.0.0:993                 0.0.0.0:*                   LISTEN      1710/dbmail-imapd   
tcp        0      0 0.0.0.0:995                 0.0.0.0:*                   LISTEN      1747/dbmail-pop3d
```

### Create testing account

DBMail daemons are running, let's create a testing account to test POP3/POP3S/IMAP/IMAPS/Managesieve services.

* Create a testing account `test@domain.ltd`, with password `mypass`:

```
# dbmail-users -p md5 -a test@domain.ltd -w mypass -s test@domain.ltd
Adding INBOX for new user... ok.
[test@domain.ltd]
Done
test@domain.ltd:x:5:0:0.00:0.00:test@domain.ltd
```

Refer to DBMail wiki site for more information about managing users: http://dbmail.org/dokuwiki/doku.php/manage_users

### Test POP3/IMAP/Managesieve services with telnet

It's OK to test POP3/POP3S/IMAP/IMAPS services with telnet, mutt or Roundcube webmail, here we use telnet and mutt instead. After testing, you can login to Roundcube Webmail directly.

#### Testing POP3 service

```
$ telnet localhost 110
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
+OK DBMAIL pop3 server ready to rock <e2ef9332465296ebd4ec7ae5828d9cc3@c60.iredmail.org>   # <-- DBMail response

USER test@domain.ltd                # <- Type this command to login
+OK Password required for test@domain.ltd

PASS mypass                      # <-- Type your password
+OK test@domain.ltd has 0 messages (0 octets)

LIST                   # <-- Check mailbox.
+OK 0 messages (0 octets)
.

QUIT                 # <-- DIsconnect
+OK see ya later
Connection closed by foreign host.
```

Telnet doesn't support SSL service, so we test POP3S with `mutt` (a console based mail client application) instead.

```
$ mutt -f pops://"test@domain.ltd":mypass@localhost
```

If POP3S works well, mutt will show you an empty mailbox. Then type 'q' to exit mutt.

#### Testing IMAP service

```
$ telnet localhost 143
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
* OK [CAPABILITY IMAP4rev1 AUTH=LOGIN AUTH=CRAM-MD5 STARTTLS ID] dbmail 3.0.0-rc1 ready.       # <-- DBMail response.

. LOGIN test@domain.ltd mypass                # <-- Login. Don't forget the leading dot in command.
* CAPABILITY IMAP4rev1 STARTTLS ID ACL RIGHTS=texk NAMESPACE CHILDREN SORT QUOTA THREAD=ORDEREDSUBJECT UNSELECT IDLE
. OK LOGIN completed

. LIST '' '*'                  # <-- Check mailbox.
* LIST (\hasnochildren) "/" "INBOX"
. OK LIST completed

. LOGOUT               # <-- Disconnect.
* BYE
. OK LOGOUT completed
Connection closed by foreign host.
```

Telnet doesn't support SSL service, so we test IMAPS with `mutt` instead.

```
$ mutt -f imaps://"test@domain.ltd":mypass@localhost
```

If IMAPS works well, mutt will show you an empty mailbox. Then type 'q' to exit mutt.

#### Testing Managesieve service

Before testing managesieve service, we have to encode username and password first.

* Download a small perl script here: http://www.rename-it.nl/dovecot/utilities/sieve-auth-command.pl
* Run this script to encode your username and password:

```
$ perl sieve-auth-command.pl test@domain.ltd mypass
AUTHENTICATE "PLAIN" "AHRlc3RAZG9tYWluLmx0ZABteXBhc3M="
```

The command output is what we need.

Now start to test managesieve service:

```
$ telnet localhost 4190
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
"IMPLEMENTATION" "DBMail timsieved 3.0.0-rc1"
"SASL" "PLAIN"
"SIEVE" "regex imap4flags relational subaddress fileinto reject envelope vacation notify "
OK


AUTHENTICATE "PLAIN" "AHRlc3RAZG9tYWluLmx0ZABteXBhc3M="               # <-- Type this command.
OK

^]              # <-- Press Ctrl + ] to exit telnet session.
telnet> quit          # <-- Type 'quit' to quit telnet program.
Connection closed.
```

### Integrate DBMail in Postfix

Backup Postfix config files before we go further:

```
# cp /etc/postfix/main.cf /etc/postfix/main.cf.bak
# cp /etc/postfix/master.cf /etc/postfix/master.cf.bak
```

* Add below line in `/etc/postfix/master.cf`, it's new transport provided by DBMail.

```
dbmail-lmtp     unix    -       -       n       -       -       lmtp
```

* Since DBMail uses different SQL structure from iRedMail, we have to disable some iRedMail special features in Postfix first.

```
# postconf -e recipient_bcc_maps='' relay_domains='$mydestination' sender_bcc_maps='' transport_maps='' virtual_alias_maps=''
```

* Update postfix setting to use DBMail transport:

```
# postconf -e virtual_transport='dbmail-lmtp:127.0.0.1:24'
```

* Update postfix setting in `/etc/postfix/main.cf`, remove `reject_unknown_sender_domain` in `smtpd_recipient_restrictions` setting.

* Update postfix setting to lookup mail users and aliases from DBMail MySQL database:

```
# postconf -e smtpd_sender_login_maps='proxy:mysql:/etc/postfix/dbmail_recipients.cf'
# postconf -e virtual_mailbox_domains='proxy:mysql:/etc/postfix/dbmail_domains.cf'
# postconf -e virtual_mailbox_maps='proxy:mysql:/etc/postfix/dbmail_mailboxes.cf'
```

Content of file `/etc/postfix/dbmail_recipients.cf`:

```
hosts = 127.0.0.1
dbname = dbmail
user = dbmail
password = password_of_dbmail
query = SELECT alias FROM dbmail_aliases WHERE alias='%s' LIMIT 1
```

Content of file `/etc/postfix/dbmail_domains.cf`:

```
hosts = 127.0.0.1
dbname = dbmail
user = dbmail
password = password_of_dbmail
query = SELECT DISTINCT 1 FROM dbmail_aliases WHERE SUBSTRING_INDEX(alias, '@', -1) = '%s'
```

Content of file `/etc/postfix/dbmail_mailboxes.cf`:

```
hosts = 127.0.0.1
dbname = dbmail
user = dbmail
password = password_of_dbmail
query    = SELECT 1 FROM dbmail_aliases WHERE alias='%s' LIMIT 1
```

* Test MySQL queries:

```
# postmap -q 'test@domain.ltd' mysql:/etc/postfix/dbmail_recipients.cf
test@domain.ltd

# postmap -q 'domain.ltd' mysql:/etc/postfix/dbmail_domains.cf 
1

# postmap -q 'test@domain.ltd' mysql:/etc/postfix/dbmail_mailboxes.cf 
1
```

* It's now OK to send a test email with command `mail` (provided by package `mailx`) after restarting Postfix service:

```
# /etc/init.d/postfix restart
# mail -s "test" test@domain.ltd < /etc/hosts
```

Log in Postfix log file /var/log/maillog:

> Aug 14 06:40:20 c60 postfix/pickup[6017]: B89A141FAD: uid=0 from=<root>
> Aug 14 06:40:20 c60 postfix/cleanup[6022]: B89A141FAD: message-id=<20110814104020.B89A141FAD@c60.iredmail.org>
> Aug 14 06:40:20 c60 postfix/qmgr[6016]: B89A141FAD: from=<root@c60.iredmail.org>, size=566, nrcpt=1 (queue active)
> Aug 14 06:40:20 c60 postfix/lmtp[6025]: B89A141FAD: to=<test@domain.ltd>, relay=127.0.0.1[127.0.0.1]:24, delay=0.15, delays=0.05/0.02/0/0.09, dsn=2.0.0, status=sent (215 Recipient <test@domain.ltd> OK)
> Aug 14 06:40:20 c60 postfix/qmgr[6016]: B89A141FAD: removed

### Configure Roundcube to work with DBMail

Change below setting in `/var/www/roundcubemail/config/main.inc.php`:

```php
$rcmail_config['imap_auth_type'] = "LOGIN";
```

Restart Apache, you can now view sent email after logging into Roundcube webmail:

```
# /etc/init.d/httpd restart
```

## Replace Dovecot with Cyrus-SASL as SMTP SASL auth daemon

Postfix uses `dovecot` as SASL type in iRedMail by default, since Dovecot will be replaced by DBMail, we cannot use Dovecot anymore. So we're going to install Cyrus-SASL libraries, and use daemon 'saslauthd' for SMTP SASL auth.

In this section, we will:

* Install Cyrus-SASL libraries.
* Configure Cyrus-SASL.
* Running and testing Cyrus-SASL auth daemon 'saslauthd' immediately.

### Install Cyrus-SASL libraries
Cyrus-SASL libraries are available in default yum repositories.
* For RHEL, they're available in yum repository `rhn` or CD/DVD images.
* For CentOS and Scientific Linux, they're available in default yum repositories.

```
# yum install cyrus-sasl cyrus-sasl-lib cyrus-sasl-sql cyrus-sasl-plain cyrus-sasl-md5
```

### Configure Cyrus-SASL

Configure Cyrus-SASL daemon config file:

* On RHEL/CentOS/Scientific Linux 5.x:

    * On i386, it's /usr/lib/sasl2/smtpd.conf
    * On x86_64, it's /usr/lib64/sasl2/smtpd.conf

* On RHEL/CentOS/Scientific Linux 6.x, it's `/etc/sasl2/smtpd.conf`.

```
pwcheck_method: saslauthd
mech_list: plain login
auxprop_plugin: sql
sql_engine: mysql
sql_hostnames: 127.0.0.1
sql_user: dbmail
sql_passwd: password_of_dbmail
sql_database: dbmail
sql_verbose: no
sql_select: SELECT passwd FROM dbmail_users WHERE userid = '%u'
```

Update `/etc/sysconfig/saslauthd` (refer to manual page saslauthd(8) for more information):

```
SOCKETDIR=/var/spool/postfix/var/run/saslauthd
MECH=rimap
FLAGS='-O 127.0.0.1 -r'
```

Notes:

* We set `SOCKETDIR` to `/var/spool/postfix/var/run/saslauthd/` so that Postfix works fine under chroot.
* Don’t forget `-r` in `FLAGS`. It will force saslauthd daemon uses full email address as user name.

Create directory used to store saslauthd daemon socket file:

```
# mkdir -p /var/spool/postfix/var/run/saslauthd/
```

Start service saslauthd now, and make it auto start when system boot:

```
# /etc/init.d/saslauthd restart
# chkconfig --level 345 saslauthd on
```

### Test saslauthd and troubleshooting

```
# testsaslauthd -f /var/spool/postfix/var/run/saslauthd/mux -u 'test@domain.ltd' -p 'mypass'
0: OK "Success."
```

Note: If you're running DBMail-3.0.0-rc1, you will always get `0: NO "authentication failed"`, because DBMail-3.0.0-rc1 has a compatibility issue with Cyrus-SASL.

### Enable Cyrus-SASL in Postfix

```
# postconf -e smtpd_sasl_path='smtpd' smtpd_sasl_type='cyrus'
```

Restarting Postfix service to make it work:

```
# /etc/init.d/postfix restart
```

You can now send email with Roundcube webmail.
