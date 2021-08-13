# Integrate mlmmj mailing list manager in iRedMail (LDAP backends)

[TOC]

## Summary

In iRedMail-0.9.8, we integrate mlmmj (<http://mlmmj.org>) - a simple and slim
mailing list manager. It uses very few resources, and requires no daemons, easy
to install, configure and manage. if offers a great set of features, including:

* Archive
* Subject prefix
* Subscribers only posting
* Moderators only posting
* Moderation functionality
* Custom headers / footer
* Fully automated bounce handling
* Complete requeueing functionality
* Regular expression access control
* Delivery Status Notification (RFC1891) support
* Rich, customisable texts for automated operations
* and more

With mlmmj integration, you can create as many mailing lists as you want. End
user can subscribe to mailing list `listname@domain.dom` by sending email to
`listname+subscribe@domain.com`, unsubscribe from the list by sending email to
`listname+unsubscribe@domain.com`. Of course you can disable the subscription
and unsubscription with a setting.

iRedMail team also developes a simple RESTful API server called `mlmmjadmin`
to help manage mailing lists, it also offers script tool to manage mailing
lists from command line.

We will show you how to integrate both mlmmj and mlmmjadmin in this tutorial.

## Backup LDAP data first

Although we don't modify any existing LDAP data in this tutorial, but it's
a good idea to backup it now before you adding any new mailing lists.

* For OpenLDAP, please run command `bash /var/vmail/backup/backup_openldap.sh` to backup.
* For OpenBSD ldapd, please run command `bash /var/vmail/backup/backup_ldapd.sh` to backup.

## Install mlmmj and other required package

!!! attention

    - `uwsgi` and other Python modules are required by the RESTful API server `mlmmjadmin`.
    - `mlmmjadmin-3.x` and later releases work with only Python 3.

* On RHEL/CentOS, `mlmmj` is available in `EPEL` repo, and it's enabled in
  iRedMail by default. So we can install it directly:

```
# RHEL/CentOS 7
yum install mlmmj uwsgi uwsgi-plugin-python36 uwsgi-logger-syslog python3-requests python3-ldap

# RHEL/CentOS 8
yum install mlmmj python3-pip3 python3-requests python3-ldap
pip3 install uwsgi
```

* On Debian/Ubuntu:

```
# Debian 9
apt-get install mlmmj uwsgi uwsgi-plugin-python3 python3-requests python3-pyldap

# Other Debian/Ubuntu releases
apt-get install mlmmj uwsgi uwsgi-plugin-python3 python3-requests python3-ldap
```

* On FreeBSD:

```
cd /usr/ports/mail/mlmmj
make install clean
cd /usr/ports/www/uwsgi
make install clean
cd /usr/ports/www/py-requests
make install clean
```

* On OpenBSD (iRedMail always installs `uwsgi` during installation, so no need
  to install it here):

```
pkg_add mlmmj altermime py3-ldap
```

## Create required system account

mlmmj will be ran as user `mlmmj` and group `mlmmj`, all mailing list data will
be stored under its home directory `/var/vmail/mlmmj`:

On Linux or OpenBSD:

```
groupadd mlmmj
useradd -m -g mlmmj -d /var/vmail/mlmmj -s /sbin/nologin mlmmj
mkdir /var/vmail/mlmmj-archive
chown -R mlmmj:mlmmj /var/vmail/mlmmj /var/vmail/mlmmj-archive
chmod -R 0700 /var/vmail/mlmmj /var/vmail/mlmmj-archive
chmod 0755 /var/vmail           # Make sure this directory is accessible by other users
```

On FreeBSD:

```
pw groupadd mlmmj
pw useradd mlmmj -m -g mlmmj -s /sbin/nologin -d /var/vmail/mlmmj
mkdir /var/vmail/mlmmj-archive
chown -R mlmmj:mlmmj /var/vmail/mlmmj /var/vmail/mlmmj-archive
chmod -R 0700 /var/vmail/mlmmj /var/vmail/mlmmj-archive
chmod 0755 /var/vmail           # Make sure this directory is accessible by other users
```

## Postfix integration

* Please add lines below in Postfix config file `/etc/postfix/master.cf`:

!!! attention

    * Command `/usr/bin/mlmmj-amime-receive` doesn't exist yet, we will create it
      later.
    * On FreeBSD and OpenBSD, it should be `/usr/local/usr/bin/mlmmj-amime-receive` instead.

```
# ${nexthop} is '%d/%u' in transport ('mlmmj:%d/%u')
mlmmj   unix  -       n       n       -       -       pipe
    flags=ORhu user=mlmmj argv=/usr/bin/mlmmj-amime-receive -L /var/vmail/mlmmj/${nexthop}
```

* Add line below in Postfix config file `/etc/postfix/main.cf`:

```
mlmmj_destination_recipient_limit = 1
```

* Open file `/etc/postfix/ldap/virtual_group_maps.cf`, replace the
  `query_filter` line by below one. It will query old mailing list and new
  mlmmj mailing list.

```
query_filter     = (&(accountStatus=active)(!(domainStatus=disabled))(enabledService=mail)(enabledService=deliver)(|(&(objectClass=mailUser)(|(memberOfGroup=%s)(shadowAddress=%s)))(&(memberOfGroup=%s)(!(shadowAddress=%s))(|(objectClass=mailExternalUser)(&(objectClass=mailList)(!(enabledService=mlmmj)))(objectClass=mailAlias)))(&(objectClass=mailList)(enabledService=mlmmj)(|(mail=%s)(shadowAddress=%s)))))
```

* Open file `/etc/postfix/ldap/transport_maps_user.cf`, make sure no `ou=Users,`
  in `search_base =` line, and change `scope = one` to `scope = sub`:

```
search_base     = domainName=%d,o=domains,dc=xx,dc=xx
scope           = sub
```

* Open file `/etc/postfix/ldap/transport_maps_user.cf`, replace the
  `query_filter` line by below one. It will query both mail user and mlmmj
  mailing list.

```
query_filter    = (&(|(objectClass=mailUser)(&(objectClass=mailList)(enabledService=mlmmj)))(|(mail=%s)(shadowAddress=%s))(accountStatus=active)(!(domainStatus=disabled))(enabledService=mail))
```

* Run commands below to create file `/usr/bin/mlmmj-amime-receive` (Linux) or
  `/usr/local/bin/mlmmj-amime-receive` (FreeBSD/OpenBSD):

!!! attention

    mlmmj doesn't support signature signing very well, so we follow mlmmj
    official document and create this script to sign signature properly with
    command `altermime`. All iRedMail installation should have command
    `altermime` (package `AlterMIME`) available, so you don't need to install
    it manually

On Linux:

```
cd /usr/bin/
wget https://github.com/iredmail/iRedMail/raw/1.0/samples/mlmmj/mlmmj-amime-receive
chown mlmmj:mlmmj mlmmj-amime-receive
chmod 0550 mlmmj-amime-receive
```

On FreeBSD or OpenBSD:

```
cd /usr/local/bin/
wget https://github.com/iredmail/iRedMail/raw/1.0/samples/mlmmj/mlmmj-amime-receive
chown mlmmj:mlmmj mlmmj-amime-receive
chmod 0550 mlmmj-amime-receive
```

## Amavisd Integration

We need Amavisd to listen on one more port `10027`, it will be used to scan
spam/virus for emails posted to mailing list.

* Please open Amavisd config file, find parameter `$inet_socket_port`, add new
  port number `10027` in the list, like below:
    - On RHEL/CentOS, it's `/etc/amavisd/amavisd.conf`.
    - On Debian/Ubuntu, it's `/etc/amavis/conf.d/50-user`.
    - On OpenBSD, it's `/etc/amavisd.conf`.
    - On FreeBSD, it's `/usr/local/etc/amavisd.conf`.

```
$inet_socket_port = [10024, 10026, 10027, 9998];
```

* Add lines below in Amavisd config file. It creates a new policy bank called
  `MLMMJ` for emails submitted by mlmmj from port 10027. The purpose is signing
  DKIM key on outgoing emails sent by mailing list, but disable
  spam/virus/banned/bad-header checks, because emails sent to mailing list will
  be scanned either on port 10024 (incoming email from external senders) or
  10026 (outgoing email sent by smtp authenticated users).

```
$interface_policy{'10027'} = 'MLMMJ';
$policy_bank{'MLMMJ'} = {
    originating => 1,           # declare that mail was submitted by our smtp client
    allow_disclaimers => 0,     # mailing list should use footer text instead.
    enable_dkim_signing => 1,   # sign DKIm signature
    smtpd_discard_ehlo_keywords => ['8BITMIME'],
    terminate_dsn_on_notify_success => 0,  # don't remove NOTIFY=SUCCESS option
    bypass_spam_checks_maps => [1],     # don't check spam
    bypass_virus_checks_maps => [1],    # don't check virus
    bypass_banned_checks_maps => [1],   # don't check banned file names and types
    bypass_header_checks_maps => [1],   # don't check bad header
};
```

Now restart Amavisd and Postfix service, mlmmj mailing list manager is now
fully integrated.

We will setup `mlmmjadmin` program to make managing mailing lists easier.

## Setup mlmmjadmin: RESTful API server used to manage mlmmj mailing lists

* Download the latest mlmmjadmin release: <https://github.com/iredmail/mlmmjadmin/releases>,
  extract downloaded package to `/opt/` directory, and create a symbol link:

    !!! attention

        We use version `3.1.2` for example below.

        - `mlmmjadmin-3.x` and later releases requires Python 3.
        - `mlmmjadmin-2.x` and older releases requires Python 2.

```
cd /root/
wget https://github.com/iredmail/mlmmjadmin/archive/3.1.2.tar.gz
tar zxf 3.1.2.tar.gz -C /opt
rm -f 3.1.2.tar.gz
ln -s /opt/mlmmjadmin-3.1.2 /opt/mlmmjadmin
```

* Generate config file by copying sample file, `settings.py.sample`:

```
cd /opt/mlmmjadmin
cp settings.py.sample settings.py
chown mlmmj:mlmmj settings.py
chmod 0400 settings.py
```

* Generate a random, long string as API auth token, it will be used by your
  API client. For example:

```
# On Linux/FreBSD
$ eval </dev/urandom tr -dc A-Za-z0-9 | (head -c $1 &>/dev/null || head -c 32)
43a89b7aa34354089e629ed9f9be0b3b

# On OpenBSD
$ eval </dev/random tr -cd [:alnum:] | fold -w 32 | head -1
43a89b7aa34354089e629ed9f9be0b3b
```

* Add this string in `/opt/mlmmjadmin/settings.py`, parameter `api_auth_tokens`
  like below:

```
api_auth_tokens = ['43a89b7aa34354089e629ed9f9be0b3b']
```

You can add as many token as you want for different API clients. For example:

```
api_auth_tokens = ['43a89b7aa34354089e629ed9f9be0b3b', '703ed37b20243d7c51c56ce6cd90e94c']
```

* if you manage mail accounts __WITH__ iRedAdmin-Pro, please set values of
  parameters `backend_api` and `backend_cli` in `/opt/mlmmjadmin/settings.py`
  like below:

```
backend_api = 'bk_none'
backend_cli = 'bk_iredmail_ldap'
```

* if you do __NOT__ manage mail accounts with iRedAdmin-Pro, please set values
  of parameters `backend_api` and `backend_cli` in `/opt/mlmmjadmin/settings.py`
  like below:

```
backend_api = 'bk_iredmail_ldap'
backend_cli = 'bk_iredmail_ldap'
```

* Add extra required parameters in `/opt/mlmmjadmin/settings.py`, so that
  mlmmjadmin can manage mailing lists stored in LDAP server.

    !!! attention

        You can find LDAP URI, basedn, bind_dn, bind_password in iRedAdmin
        config file, the bind dn must have both read and write privileges to
        manage LDAP server, iRedMail server usually use bind dn
        `cn=vmailadmin,dc=xx,dc=xx` for this purpose.

```
iredmail_ldap_uri = 'ldap://127.0.0.1'
iredmail_ldap_basedn = 'o=domains,dc=XXX,dc=XXX'
iredmail_ldap_bind_dn = 'cn=vmailadmin,dc=XXX,dc=XXX'
iredmail_ldap_bind_password = 'xxxxxxxx'
```

* Add extra required parameters in `/opt/mlmmjadmin/settings.py` to use the
  directory used to store mailing lists:

```
MLMMJ_SPOOL_DIR = '/var/vmail/mlmmj'
MLMMJ_ARCHIVE_DIR = '/var/vmail/mlmmj-archive'
MLMMJ_DEFAULT_PROFILE_SETTINGS.update({'smtp_port': 10027})
```

* If you're running OpenBSD or FreeBSD, please add parameter `MLMMJ_SKEL_DIR`
  in `/opt/mlmmjadmin/settings.py` to set the directory which stores mlmmj mail
  templates:

```
MLMMJ_SKEL_DIR = '/usr/local/share/mlmmj/text.skel'
```

* Copy rc/systemd scripts for service control:

```
#
# For RHEL/CentOS 6
#
cp /opt/mlmmjadmin/rc_scripts/mlmmjadmin.rhel /etc/init.d/mlmmjadmin
chmod 0755 /etc/init.d/mlmmjadmin
chkconfig --level 345 mlmmjadmin on

#
# For RHEL/CentOS 7
#
cp /opt/mlmmjadmin/rc_scripts/systemd/rhel.service /lib/systemd/system/mlmmjadmin.service
chmod 0644 /lib/systemd/system/mlmmjadmin.service
systemctl daemon-reload
systemctl enable mlmmjadmin

#
# For Debian 8, Ubuntu 14.04 and earlier releases which does NOT use systemd
#
cp /opt/mlmmjadmin/rc_scripts/mlmmjadmin.debian /etc/init.d/mlmmjadmin
chmod 0755 /etc/init.d/mlmmjadmin
update-rc.d mlmmjadmin defaults

#
# For Debian 9 and Ubuntu 16.04 which uses systemd
#
cp /opt/mlmmjadmin/rc_scripts/systemd/debian.service /lib/systemd/system/mlmmjadmin.service
chmod 0644 /lib/systemd/system/mlmmjadmin.service
systemctl daemon-reload
systemctl enable mlmmjadmin

#
# For FreeBSD
#
cp /opt/mlmmjadmin/rc_scripts/mlmmjadmin.freebsd /usr/local/etc/rc.d/mlmmjadmin
chmod 0755 /usr/local/etc/rc.d/mlmmjadmin
echo 'mlmmjadmin_enable=YES' >> /etc/rc.conf.local

#
# For OpenBSD
#
cp /opt/mlmmjadmin/rc_scripts/mlmmjadmin.openbsd /etc/rc.d/mlmmjadmin
chmod 0755 /etc/rc.d/mlmmjadmin
rcctl enable mlmmjadmin
```


* Create directory used to store mlmmjadmin log file. mlmmjadmin is
  configured to log to syslog directly.

```
#
# For RHEL/CentOS
#
mkdir /var/log/mlmmjadmin
chown root:root /var/log/mlmmjadmin
chmod 0755 /var/log/mlmmjadmin

#
# For Debian
#
mkdir /var/log/mlmmjadmin
chown root:adm /var/log/mlmmjadmin
chmod 0755 /var/log/mlmmjadmin

#
# For Ubuntu
#
mkdir /var/log/mlmmjadmin
chown syslog:adm /var/log/mlmmjadmin
chmod 0755 /var/log/mlmmjadmin

#
# For OpenBSD/FreeBSD
#
mkdir /var/log/mlmmjadmin
chown root:wheel /var/log/mlmmjadmin
chmod 0755 /var/log/mlmmjadmin
```

* Update syslog daemon config file to log mlmmjadmin to dedicated log file:

For Linux

```
cp /opt/mlmmjadmin/samples/rsyslog/mlmmjadmin.conf /etc/rsyslog.d/
service rsyslog restart
```

For OpenBSD, please append below lines in `/etc/syslog.conf`:

```
!!mlmmjadmin
local5.*            /var/log/mlmmjadmin/mlmmjadmin.log
```

For FreeBSD, please append below lines in `/etc/syslog.conf`:

```
!mlmmjadmin
local5.*            /var/log/mlmmjadmin/mlmmjadmin.log
```

* Now it's ok to start `mlmmjadmin` service, it listens on `127.0.0.1:7790`
  by default:

```
#
# On Linux/FreeBSD:
#
service mlmmjadmin restart

#
# On OpenBSD
#
rcctl start mlmmjadmin
```

On Linux, you can check the port number with command `netstat` or `ss` like below:

```
netstat -ntlp | grep 7790
ss -ntlp | grep 7790
```

On FreeBSD/OpenBSD, run:

```
netstat -anl -p tcp | grep 7790
```

## Manage subscribeable mailing lists

Please read document [Manage subscribeable mailing lists](./manage.subscribeable.mailing.lists.html).

## References

* Mlmmj:
    * [web site](http://mlmmj.org/)
    * [Tunable parameters](http://mlmmj.org/docs/tunables/)
    * [Postfix integration](http://mlmmj.org/docs/readme-postfix/)
* [mlmmjadmin](https://github.com/iredmail/mlmmjadmin): RESTful API server used to manage mlmmj mailing lists. Developed
  and maintained by iRedMail team.

## See Also

* [Integrate mlmmj mailing list manager in iRedMail (OpenLDAP backend)](./integration.mlmmj.ldap.html)
* [Integrate mlmmj mailing list manager in iRedMail (MySQL/MariaDB backends)](./integration.mlmmj.mysql.html)
* [Integrate mlmmj mailing list manager in iRedMail (PostgreSQL backend)](./integration.mlmmj.pgsql.html)
