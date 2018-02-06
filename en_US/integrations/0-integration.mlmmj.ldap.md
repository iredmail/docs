# Integrate mlmmj mailing list manager in iRedMail (LDAP backends)

[TOC]

## Summary

In iRedMail-0.9.8, we integrate [mlmmj](http://mlmmj.org) - a simple and slim
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

iRedMail team also developes a simple RESTful API server called `mlmmjadmin`
to help manage mailing lists, it also offers script tool to manage mailing
lists from command line.

We will show you how to integrate both mlmmj and mlmmjadmin in this tutorial.

## Backup LDAP data first

Although we don't modify any existing LDAP data in this tutorial, but it's
a good idea to backup it now before you adding any new mailing lists.

* For OpenLDAP, please run command `bash /var/vmail/backup/backup_openldap.sh` to backup.
* For OpenBSD ldapd, please run command `bash /var/vmail/backup/backup_ldapd.sh` to backup.

## Create required system account

mlmmj will be ran as user `mlmmj` and group `mlmmj`, all mailing list data will
be stored under its home directory `/var/vmail/mlmmj`:

On Linux or OpenBSD:

```
groupadd mlmmj
useradd -m -d /var/vmail/mlmmj -s /sbin/nologin mlmmj
chown -R mlmmj:mlmmj /var/vmail/mlmmj
chmod -R 0700 /var/vmail/mlmmj
```

On FreeBSD:

```
pw groupadd mlmmj
pw useradd -m -g mlmmj -s /sbin/nologin -d /var/vmail/mlmmj mlmmj
chown -R mlmmj:mlmmj /var/vmail/mlmmj
chmod -R 0700 /var/vmail/mlmmj
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

* Open file `/etc/postfix/ldap/transport_maps_user.cf`, replace the 
  `query_filter` line by below one. It will query both mail user and mlmmj
  mailing list.

```
query_filter    = (&(|(objectClass=mailUser)(&(objectClass=mailList)(enabledService=mlmmj)))(|(mail=%s)(shadowAddress=%s))(accountStatus=active)(!(domainStatus=disabled))(enabledService=mail))
```

* Run commands below to create file `/usr/bin/mlmmj-amime-receive` (Linux) or
  `/usr/local/bin/mlmmj-amime-receive` (Linux/FreeBSD):

!!! attention

    mlmmj doesn't support signature signing very well, so we follow mlmmj
    official document and create this script to sign signature properly with
    command `altermime`. All iRedMail installation should have command
    `altermime` (package `AlterMIME`) available, so you don't need to install
    it manually

On Linux:

```
cd /usr/bin/
wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/mlmmj/mlmmj-amime-receive
chown mlmmj:mlmmj mlmj-amime-receive
chmod 0550 mlmmj-amime-receive
perl -pi -e 's#PH_CMD_MLMMJ_RECEIVE#/usr/bin/mlmmj-receive#g' mlmmj-amime-receive
perl -pi -e 's#PH_CMD_ALTERMIME#/usr/bin/altermime#g' mlmmj-amime-receive
```

On FreeBSD or OpenBSD:

```
cd /usr/local/bin/
wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/mlmmj/mlmmj-amime-receive
chown mlmmj:mlmmj mlmj-amime-receive
chmod 0550 mlmmj-amime-receive
perl -pi -e 's#PH_CMD_MLMMJ_RECEIVE#/usr/local/bin/mlmmj-receive#g' mlmmj-amime-receive
perl -pi -e 's#PH_CMD_ALTERMIME#/usr/local/bin/altermime#g' mlmmj-amime-receive
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

Now restart Amavisd and Postfix servivce, mlmmj mailing list manager is now
fully integrated. We will setup `mlmmjadmin` to make managing mailing lists easier.

## Setup mlmmjadmin: a RESTful API server used to manage mlmmj mailing lists

* Download the latest mlmmjadmin release: <https://github.com/iredmail/mlmmjadmin/releases>,
  upload to iRedMail server. We assume it's uploaded to `/root/` directory.

    !!! attention

        We use `mlmmjadmin-1.0` for example below.

* Extract downloaded mlmmjadmin package to `/opt/` directory, and create a
  symbol link:

```
tar xjf /root/mlmmjadmin-1.0.tar.bz2 -C /opt
ln -s /opt/mlmmjadmin-1.0 /opt/mlmmjadmin
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
$ echo $RANDOM | md5sum
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

* Copy rc/systemd scripts for service control:

```
#
# For RHEL/CentOS
#
cp /opt/mlmmjadmin/rc_scripts/systemd/rhel.service /lib/systemd/system/mlmmjadmin.service
chmod 0644 /lib/systemd/system/mlmmjadmin.service
systemctl daemon-reload
systemctl enable mlmmjadmin

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
# For Debian/Ubuntu
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

* Now it's ok to start `mlmmjadmin` service:

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

## Manage mailing lists with mlmmjadmin command line tool

mlmmjadmin ships script `tools/maillist_admin.py` to help you manage mailing
lists. You can find this script under directory `/opt/mlmmjadmin/tools/`.

!!! attention

    All settings used to create or update mailing list profiles are listed on
    [mlmmjadmin document](https://github.com/iredmail/mlmmjadmin/blob/master/docs/API.md).

* Create a new mailing list account with additional setting:

```python maillist_admin.py create list@domain.com only_subscriber_can_post=yes disable_archive=no```

* Get settings of an existing mailing list account

```python maillist_admin.py info list@domain.com```

* Update an existing mailing list account

```python maillist_admin.py update list@domain.com only_moderator_can_post=yes disable_subscription=yes```

* Delete an existing mailing list account

```python maillist_admin.py delete list@domain.com archive=yes```

* List all subscribers:

```python maillist_admin.py subscribers list@domain.com```

* Show subscribed lists of a given subscriber:

```python maillist_admin.py subscribed subscriber@domain.com```

* Check whether mailing list has given subscriber:

```python maillist_admin.py has_subscriber list@domain.com subscriber@gmail.com```

## References

* iRedMail: <http://www.iredmail.org>
* Mlmmj: <http://mlmmj.org/>
    * Tunable parameters: <http://mlmmj.org/docs/tunables/>
    * Postfix integration: <http://mlmmj.org/docs/readme-postfix/>
* mlmmjadmin: RESTful API server used to manage mlmmj mailing lists. Developed
  and maintained by iRedMail team. <https://github.com/iredmail/mlmmjadmin>
