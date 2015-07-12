# Backup and restore

[TOC]

## Backup
### Backup mail accounts

Mail accounts are stored in SQL/LDAP database. iRedMail provides shell scripts
to backup SQL/LDAP databases, you can find them in downloaded iRedMail release,
or find them in [iRedMail source code repository](https://bitbucket.org/zhb/iredmail/src/default/iRedMail/tools/):

* `iRedMail-[VERSION]/tools/backup_openldap.sh`: used to backup OpenLDAP data.
* `iRedMail-[VERSION]/tools/backup_mysql.sh`: used to backup MySQL/MariaDB databases.
* `iRedMail-[VERSION]/tools/backup_pgsql.sh`: used to backup PostgreSQL databases.

iRedMail will setup a daily cron job to run backup script(s) during
installation, so what you need to do is checking whether or not they're
defined as cron jobs with below commands:

```
# crontab -l -u root
```

Sample output on an iRedMail server with OpenLDAP backend:

```
# iRedMail: Backup OpenLDAP data every day on 03:01 AM
1   3   *   *   *   /bin/bash /var/vmail/backup/backup_openldap.sh

# iRedMail: Backup MySQL databases every day on 03:10 AM
10   3   *   *   *   /bin/bash /var/vmail/backup/backup_mysql.sh
```

Notes:

* Backup files are stored under directory defined in parameter `BACKUP_ROOTDIR`
  in backup scripts, default is `/var/vmail/backup`.
* SQL backup is plain SQL file, LDAP backup is plain LDIF file.
* Backup files are compressed with `bzip2` by default, you can decompress them
  with command `bunzip2`. for example, `bunzip file_name.bz2`.
* It's ok to run the backup scripts manually.

### Backup additional data manually

* DKIM keys. They're stored under `/var/lib/dkim/` by default. If you don't
  backup them, it's ok to generate new keys and you must update DNS record
  (`dkim._domainkey.[YOUR_MAIL_DOMAIN]`) with new DKIM key.

* OpenLDAP backend:

    * If you enabled additional LDAP schema files in OpenLDAP, you should
      backup them, copy them to new server and enable them. Otherwise you
      cannot import backup LDIF file due to missing required LDAP attributes.

## Restore

### How to restore SQL databases

You can simply restore plain SQL files backed up by above backup scripts.

> __WARNING: Do not restore database `mysql` on a new iRedMail server.__
>
> If you're restoring on a __NEW__ iRedMail server, do *NOT*
> restore database `mysql` exported from old server, it contains SQL usernames
> and passwords used in many components (e.g. Postfix, Dovecot, Roundcube
> webmail) on old server. New iRedMail server already has the same SQL accounts
> with different passwords, so please do not restore `mysql` database,
> otherwise almost all services won't work due to incorrect SQL credentials.

### How to restore LDAP backup

Backup script runs command `slapcat` to dump whole LDAP tree as a backup, it
must be so restored with command `slapadd`.

Below example shows how to restore a LDAP backup on RHEL/CentOS 6.x, files and
directories may be different on other Linux/BSD distributions, you can find
the correct ones in this tutorial: 
[Locations of configuration and log files of mojor components](./file.locations.html#openldap).

* LDAP backups are stored under `/var/vmail/backup/ldap/[YEAR]/[MONTH]` by
  default, for example, `/var/vmail/backup/ldap/2015/05/`. And it's compressed
  with `bzip2` command to save disk space. we must decompress it first.

* Go to the backup directory, find the latest backup. here we use backup file
  `2015-05-10-03:01:01.ldif.bz2` for example.

```
# cd /var/vmail/backup/ldap/2015/05/
# bunzip2 2015-05-10-03:01:01.ldif.bz2
# ls -l 2015-05-10-03:01:01.ldif
-rw-r--r-- 1 root root 7352 May 10 03:01 2015-05-10-03:01:01.ldif
```

* Find passwords for `cn=vmail,dc=xx,dc=xx` and `cn=vmailadmin,dc=xx,dc=xx`
  in the root directory of iRedMail installation directory on __NEW__ iRedMail
  server. for example, `/root/iRedMail-0.9.0/iRedMail.tips`. Notes:

    * They're plain passwords, not hashed or encrypted.
    * You can also find `cn=vmail`'s password in Postfix config files under
      `/etc/postfix/mysql` (MySQL/MariaDB backend) or
      `/etc/postfix/pgsql` (PostgreSQL backend).
    * You can also find `cn=vmailadmin`'s password in
      [iRedAdmin config file](./file.locations.html#iredadmin).

Below is sample copy in file `iRedMail.tips`.

```
OpenLDAP:
    ...
    * LDAP bind dn (read-only): cn=vmail,dc=example,dc=com, password: py2BQwM0zoRM5nciK68AlP8dyu2Mq6
    * LDAP admin dn (used for iRedAdmin): cn=vmailadmin,dc=example,dc=com, password: 9wr0mHeVYz2uaxSAGBLucVkOgYPSBB
```

* Now hash them with command `slappasswd`:

```
# slappasswd -h '{ssha}' -s 'py2BQwM0zoRM5nciK68AlP8dyu2Mq6'    # <- cn=vmail's password
{SSHA}eJEO2yGVryVw+mZ/Qd2HMSyrl6u9WDhd

# slappasswd -h '{ssha}' -s '9wr0mHeVYz2uaxSAGBLucVkOgYPSBB'    # <- cn=vmailadmin's password
{SSHA}lWt6zjOOUq+2WUmiAea2FXLB4oHMYvIb
```

* Open the backup file `2015-05-10-03:01:01.ldif` with your favourite text
  editor, find `usePassword` line of `cn=vmail` and `cn=vmailadmin`.
  __Important notes__:

    * A line that begins with a SPACE denotes that the characters following the
      space are part of the previous line.
    * There're two colons after `userPassword` string (`userPassword::`).

Below is a sample copy in `2015-05-10-03:01:01.ldif`:

```
dn: cn=vmail,dc=iredmail,dc=org
...
userPassword:: e1NTSEF7F8AwbjVqeER1R1dXVmREN1RJU8NtdnFHN0hnekdWYzVHSG9iWEE9PQ=  # <- remove this line
 =                                                                              # <- remove this line
...

dn: cn=vmailadmin,dc=iredmail,dc=org
userPassword:: e1NTSEF9alZi8E12dS9FNllaMktteFh7YkZham1mM3Jqc21cdEFsZjJIeEE9PQ=  # <- remove this line
 =                                                                              # <- remove this line
...
```

Replace these two `userPassword` lines by the newly generated ssha passwords,
save your change, exit your text editor.

```
dn: cn=vmail,dc=iredmail,dc=org
...
userPassword: {SSHA}eJEO2yGVryVw+mZ/Qd2HMSyrl6u9WDhd
...

dn: cn=vmailadmin,dc=iredmail,dc=org
userPassword: {SSHA}lWt6zjOOUq+2WUmiAea2FXLB4oHMYvIb
...
```

__Important note__:  There's only __ONE__ colon after `userPassword` string
(`userPassword:`).

* OpenLDAP service must be stopped while restoring backup. So we stop it first:

```
# /etc/init.d/ldap stop
```

* If you enabled additional LDAP schema files on old server, you `MUST` copy
  these schema files to new server, and enable them in OpenLDAP on new server,
  also add new indexes for attributes defined in these additional LDAP schema
  files if necessary. Otherwise you may not be able to import backup LDIF file
  due to missing required attributes.

* Remove all files under OpenLDAP data directory defined in LDAP config file
  `slapd.conf` except one file (`DB_CONFIG`). For example:

```
# File: /etc/openldap/slapd.conf

...
database    bdb
suffix      dc=iredmail,dc=org
directory   /var/lib/ldap/iredmail.org
...
```

So you should remove all files under directory `/var/lib/ldap/iredmail.org`
except `/var/lib/ldap/iredmail.org/DB_CONFIG`.

```
# cd /var/lib/ldap/iredmail.org/
# mv DB_CONFIG ~
# rm -rf /var/lib/ldap/iredmail.org/*
# mv ~/DB_CONFIG .
```

* Start OpenLDAP service immediately, then stop it again. it will help create
  necessary files required by backend db (`dbd` in our case, `database dbd`).

```
# /etc/init.d/slapd start
# /etc/init.d/slapd stop
```

* Make sure OpenLDAP server is __NOT__ running, then restore backup LDIF file
  with command `slapadd`.

```
# slapadd -f /etc/openldap/slapd.conf -l /path/to/backup/backup.ldif
```

* It's OK to start OpenLDAP server now. It may report errors like below:

```
# /etc/init.d/slapd start
Stopping slapd:                                            [  OK  ]
/var/lib/ldap/iredmail.org/mailMessageStore.bdb is not owned[WARNING]"
/var/lib/ldap/iredmail.org/objectClass.bdb is not owned by "[WARNING]
/var/lib/ldap/iredmail.org/mtaTransport.bdb is not owned by [WARNING]
/var/lib/ldap/iredmail.org/cn.bdb is not owned by "ldap"    [WARNING]
/var/lib/ldap/iredmail.org/domainName.bdb is not owned by "l[WARNING]
/var/lib/ldap/iredmail.org/ou.bdb is not owned by "ldap"    [WARNING]
/var/lib/ldap/iredmail.org/uid.bdb is not owned by "ldap"   [WARNING]
/var/lib/ldap/iredmail.org/enabledService.bdb is not owned b[WARNING]
/var/lib/ldap/iredmail.org/homeDirectory.bdb is not owned by[WARNING]
/var/lib/ldap/iredmail.org/domainGlobalAdmin.bdb is not owne[WARNING]p"
/var/lib/ldap/iredmail.org/sn.bdb is not owned by "ldap"    [WARNING]
/var/lib/ldap/iredmail.org/mail.bdb is not owned by "ldap"  [WARNING]
/var/lib/ldap/iredmail.org/accountStatus.bdb is not owned by[WARNING]
/var/lib/ldap/iredmail.org/givenName.bdb is not owned by "ld[WARNING]
Checking configuration files for slapd:  config file testing succeeded
                                                           [  OK  ]
Starting slapd:                                            [  OK  ]
```

If you see above warning about improper file ownership, please set correct file
owner on newly created bdb files immediately, then restart OpenLDAP service:

```
# chown ldap:ldap /var/lib/ldap/iredmail.org/*.bdb
# /etc/init.d/ldap restart
```
