# Install iRedMail on FreeBSD inside Jail (with ezjail)

[TOC]

## Summary

* This tutorial describes how to create a FreeBSD Jail with ezjail, then
  install the latest iRedMail in Jail.
* We use hostname `mx.example.com` and IP address `172.16.122.244` for our Jail server.

Notes:

* This tutorial was tested with FreeBSD 9 and the latest ports tree, but it
  should work on FreeBSD 8 and 10 too.
* All backends available in iRedMail (OpenLDAP, MySQL/MariaDB, PostgreSQL) were
  tested, work like a charm. :)

## System Requirements

__IMPORTANT WARNING__: iRedMail is designed to be deployed on a FRESH server system,
which means your server does __NOT__ have mail related components installed,
e.g. MySQL, OpenLDAP, Postfix, Dovecot, Amavisd, etc. iRedMail will install
and configure them for you automatically. Otherwise it may override your
existing files/configurations althought it will backup files before modifing,
and it may not be working as expected.

* The latest stable release of iRedMail. You can download it here: http://www.iredmail.org/download.html
* Port `sysutils/ezjail` for FreeBSD.

## Preparations

### Set a proper hostname and IP address for Jail server

We use hostname `mx.example.com` and internal IP address `172.16.122.244` for
example. We created an alias IP address on network interface `em0`, so we have
below setting in `/etc/rc.conf` for this IP address like below:

```
# Part of file: /etc/rc.conf

ifconfig_em0_alias0="inet 172.16.122.244 netmask 255.255.255.0"

# Settings for our Jail: mx.example.com.
jail_mx_example_com_hostname="mx.example.com"
jail_mx_example_com_ip="172.16.122.244"

# Required by PostgreSQL, otherwise initializing database will fail.
jail_mx_example_com_parameters='allow.sysvipc=1'
```

### Install sysutils/ezjail and add required settings

* Install ezjail with ports tree:

```
# cd /usr/ports/sysutils/ezjail/
# make install clean
```

* Enable Jail by adding below setting in `/etc/rc.conf`:

```
# Part of file: /etc/rc.conf

# Start ezjail while system start up
ezjail_enable="YES"
```

* [OPTIONAL] Allow to use `ping` command inside Jail by adding below line in
  `/etc/sysctl.conf`:

```
# Part of file: /etc/sysctl.conf
security.jail.allow_raw_sockets=1
```

* Rebooting system is required after changing `/etc/rc.conf`.

```
# reboot
```

### Create Jail

* After server reboot, create the base jail that all jails we created later will use:

```
# ezjail-admin install -p
```

* Create Jail for domain name `mx.example.com`, bound to internal IP address
  `172.16.122.244`. All files are placed under `/jails/mx.example.com`:

```
# ezjail-admin create -r /jails/mx.example.com mx.example.com 172.16.122.244
```

* Set hostname of Jail in `/jails/mx.example.com/etc/rc.conf`:

```
# File: /jails/mx.example.com/etc/rc.conf
hostname="mx.example.com"
```

* [OPTIONAL] Share /usr/ports/distfiles/ with Jail by adding below line in
  `/etc/fstab.mx_example_com`:

    * NOTE: Jail will set ports tree directory to `/var/ports` instead of
      `/usr/ports` in `/jails/mx.example.com/etc/make.conf`, you can either
      use this default setting or change it to `/usr/ports`.

```
# Part of file: /etc/fstab.mx_example.com
/usr/ports/distfiles /jails/mx.example.com/basejail/usr/ports/distfiles nullfs rw 0 0
```

* Start Jail.

```
# /usr/local/etc/rc.d/ezjail restart
```

* List all Jails:

```
# ezjail-admin list
STA JID  IP               Hostname                          Root Directory
--- ---- ---------------- --------------------------------- ------------------------
DS  1    172.16.122.244   mx.example.com                    /jails/mx.example.com
```

## Install iRedMail

We can now enter this Jail with below command:

```
# ezjail-admin console mx.example.com
```

* In Jail, update `/etc/resolv.conf` with valid DNS server address(es). For example:

```
# File: /etc/resolv.conf
nameserver 172.16.122.2
```

* In Jail, install binary package `bash-static`, it's required by iRedMail.

```
# pkg_add -r bash-static
```

## Start iRedMail installer

> For Chinese users: Our domain name "iredmail.org" is blocked in China mainland since Jun 04, 2011, please replace all 'iredmail.org' by its IP address "106.187.51.47" (without quotes) in /root/iRedMail-x.y.z/pkgs/get_all.sh BEFORE executing "iRedMail.sh". This is a Linode VPS hosted in Tokyo, Japan.


It's now ready to start iRedMail installer inside Jail, it will ask you several simple
questions, that's all steps to setup a full-featured mail server.

```
# bash          # <- start bash shell, REQUIRED
# cd /root/iRedMail/
# LOCAL_ADDRESS='172.16.122.244' bash iRedMail.sh
```

## Screenshots of installation:

* Welcome and thanks for your use

![](../images/installation/iredmail/welcome.png)

* Specify location to store all mailboxes. Default is `/var/vmail/`.

![](../images/installation/iredmail/location_to_store_mailboxes.png)

* Choose backend used to store mail accounts. You can manage mail accounts
with iRedAdmin, our web-based iRedMail admin panel.

__IMPORTANT NOTE__: There's no big difference between available backends, so
it's strongly recommended to choose the one you're familiar with for easier
management and maintenance after installation.

![](../images/installation/iredmail/backend.png)

* If you choose to store mail accounts in OpenLDAP, iRedMail installer will
ask you two questions about OpenLDAP.

LDAP suffix.

![](../images/installation/iredmail/ldap_suffix.png)

Password of LDAP root dn.

![](../images/installation/iredmail/pw_of_ldap_root_dn.png)

* Set password of MySQL or PostgreSQL admin user.

__NOTE__: MySQL is used to store data of other applications (e.g. Roundcube
webmail, Cluebringer, Amavisd-new) if you choose OpenLDAP or MySQL as backend.

![](../images/installation/iredmail/pw_of_mysql_root_user.png)

* Add your first mail domain name

![](../images/installation/iredmail/first_mail_domain.png)

* Set password of admin account of your first mail domain.

__Note__: This account is an admin account and a mail user. That means you can
login to webmail and admin panel (iRedAdmin) with this account, login username
is full email address.

![](../images/installation/iredmail/pw_of_domain_admin.png)

* Choose optional components

![](../images/installation/iredmail/optional_components.png)


After answered above questions, iRedMail installer will ask your confirm to
start installation. It will install and configure required packages
automatically. Type `y` or `Y` and press `Enter` to start.

```
Configuration completed.

*************************************************************************
**************************** WARNING ***********************************
*************************************************************************
*                                                                       *
* Please do remember to *REMOVE* configuration file after installation  *
* completed successfully.                                               *
*                                                                       *
*   * /root/iRedMail-x.y.z/config
*                                                                       *
*************************************************************************
<<< iRedMail >>> Continue? [Y|n]        # <- Type 'Y' or 'y' here, and press 'Enter' to continue
```

## Important things you __MUST__ know after installation

* Read file `/root/iRedMail-x.y.z/iRedMail.tips` first, it contains:

    * URLs, usernames and passwords of web-based applications
    * Location of mail service related software configuration files. You can
      also check this tutorial instead:
      [Locations of configuration and log files of mojor components](./file.locations.html).
    * Some other important and sensitive information

* [Setup DNS records for your mail server](./setup.dns.html)
* [How to configure your mail clients](./index.html#configure-mail-client-applications)
* It's highly recommended to purchase a SSL cert to avoid annonying warning
  message in web browser or mail clients when accessing mailbox via
  HTTPS/IMAPS/POP3/SMTPS. Or, you can use
  [free SSL cert offerred by StartSSL.com](http://www.startssl.com/?app=1).
  We have a document for you to [use a bought SSL certificate](http://www.iredmail.org/docs/use.a.bought.ssl.certificate.html).
* If you're running a busy mail server, we have [some suggestions for better
  performance](./performance.tuning.html).

## Access webmail and other web applications

After installation successfully completed, you can access web-based programs
if you choose to install them. Replace `your_server` below by your real server
hostname or IP address.

* __Roundcube webmail__: [https://your_server/mail/](https://your_server/mail/)
* __Web admin panel (iRedAdmin)__: [httpS://your_server/iredadmin/](httpS://your_server/iredadmin/)
* __Awstats__: [httpS://your_server/awstats/awstats.pl?config=web](httpS://your_server/awstats/awstats.pl?config=web) (or ?config=smtp)

## Get technical support

Please post all issues, feedbacks, feature requests, suggestions in our [online
support forum](http://www.iredmail.org/forum/), it's more responsible than you
expected.
