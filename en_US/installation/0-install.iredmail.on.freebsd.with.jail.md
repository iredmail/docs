# Install iRedMail on FreeBSD inside Jail (with ezjail)

[TOC]

## Summary

* This tutorial describes how to create a FreeBSD Jail with ezjail, then
  install the latest iRedMail in Jail.
* We use hostname `mx.example.com` and IP address `172.16.244.254` for our Jail server.

Notes:

* This tutorial was tested with FreeBSD 10 and the latest ports tree, but it
  should work on FreeBSD 9 and other releases.
* All backends available in iRedMail (OpenLDAP, MySQL/MariaDB, PostgreSQL) were
  tested, work like a charm. :)
* For more details about ezjail, please check FreeBSD Handbook:
  [Managing Jails with ezjail](https://www.freebsd.org/doc/handbook/jails-ezjail.html).

## System Requirements

__IMPORTANT WARNING__: iRedMail is designed to be deployed on a FRESH server system,
which means your server does __NOT__ have mail related components installed,
e.g. MySQL, OpenLDAP, Postfix, Dovecot, Amavisd, etc. iRedMail will install
and configure them for you automatically. Otherwise it may override your
existing files/configurations althought it will backup files before modifying,
and it may not be working as expected.

* The latest stable release of iRedMail. You can download it here: http://www.iredmail.org/download.html
* Port `sysutils/ezjail` for FreeBSD.

## Preparations

### Install sysutils/ezjail and add required settings

* Install ezjail with ports tree:

```
# cd /usr/ports/sysutils/ezjail/
# make install clean
```

* Enable ezjail service by appending below line in `/etc/rc.conf`:

```
# Start ezjail while system start up
ezjail_enable="YES"
```

* Rebooting system is required after changing `/etc/rc.conf`.

```
# reboot
```

### Create Jail

* After server reboot, populate the Jail with FreeBSD-RELEASE

```
# ezjail-admin install -p
```

* Create Jail

    * hostname `mx.example.com`
    * bound IP address `172.16.244.254` to network interface `em0`
    * Jail is placed under `/jails/mx.example.com`

```
# ezjail-admin create -r /jails/mx.example.com mx.example.com 'em0|172.16.244.254'
```

* Start Jail.

```
# service ezjail restart
```

* List all Jails:

```
# ezjail-admin list
STA JID  IP               Hostname                          Root Directory
--- ---- ---------------- --------------------------------- ------------------------
DS  1    172.16.244.254   mx.example.com                    /jails/mx.example.com
```

## Install iRedMail

We can now enter this Jail with below command:

```
# ezjail-admin console mx.example.com
```

* In Jail, update `/etc/resolv.conf` with valid DNS server address(es). For example:

```
# File: /etc/resolv.conf
nameserver 172.16.244.2
```

* In Jail, install binary package `bash-static`, it's required by iRedMail.

```
# -- For FreeBSD 9 or earlier releases --
# pkg_add -r bash-static

# -- For FreeBSD 10 or later releases --
# pkg install bash-static
```

## Start iRedMail installer

It's now ready to start iRedMail installer inside Jail, it will ask you several simple
questions, that's all required to setup a full-featured mail server.

```
# bash          # <- start bash shell, REQUIRED
# cd /root/iRedMail/
# LOCAL_ADDRESS='172.16.244.254' bash iRedMail.sh
```

!!! note "Note to Chinese users"

    Our domain name `iredmail.org` has been blocked in mainland China for
    years (since Jun 04, 2011), please run command below to finish the
    installation:

    `IREDMAIL_MIRROR='http://42.159.241.31' bash iRedMail.sh`

## Screenshots of installation:

* Welcome and thanks for your use

![](../images/installation/iredmail/welcome.png)

* Specify location to store all mailboxes. Default is `/var/vmail/`.

![](../images/installation/iredmail/location_to_store_mailboxes.png)

* Choose backend used to store mail accounts. You can manage mail accounts
with iRedAdmin, our web-based iRedMail admin panel.

!!! note

    There's no big difference between available backends, so
    it's strongly recommended to choose the one you're familiar with for easier
    management and maintenance after installation.

![](../images/installation/iredmail/backend.png)

* If you choose to store mail accounts in OpenLDAP, iRedMail installer will
ask you two questions about OpenLDAP.

LDAP suffix.

![](../images/installation/iredmail/ldap_suffix.png)

Password of LDAP root dn.

![](../images/installation/iredmail/pw_of_ldap_root_dn.png)

!!! note "To MySQL/MariaDB/PostgreSQL users"

    If you choose to store mail accounts in MySQL/MariaDB/PostgreSQL, iRedMail
    installer will generate a random, strong password for you. You can find it
    in file `iRedMail.tips`.

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

> The weakest part of a mail server is user's weak password. Spammers don't
> want to hack your server, they just want to send spam from your server.
> Please __ALWAYS ALWAYS ALWAYS__ force users to use a strong password.

* Read file `/root/iRedMail-x.y.z/iRedMail.tips` first, it contains:

    * URLs, usernames and passwords of web-based applications
    * Location of mail service related software configuration files. You can
      also check this tutorial instead:
      [Locations of configuration and log files of major components](./file.locations.html).
    * Some other important and sensitive information

* [Setup DNS records for your mail server](./setup.dns.html)
* [How to configure your mail clients](./index.html#configure-mail-client-applications)
* It's highly recommended to get a SSL cert to avoid annonying warning
  message in web browser or mail clients when accessing mailbox via
  HTTPS/IMAPS/POP3/SMTPS. [Let's Encrypt offers __FREE__ SSL certificate](https://letsencrypt.org).
  We have a document for you to
  [use a SSL certificate](http://www.iredmail.org/docs/use.a.bought.ssl.certificate.html).
* If you need to bulk create mail users, check our document for
  [OpenLDAP](./ldap.bulk.create.mail.users.html) and
  [MySQL/MariaDB/PostgreSQL](./sql.bulk.create.mail.users.html).
* If you're running a busy mail server, we have [some suggestions for better
  performance](./performance.tuning.html).

## Access webmail and other web applications

After installation successfully completed, you can access web-based programs
if you choose to install them. Replace `your_server` below by your real server
hostname or IP address.

* __Roundcube webmail__: <https://your_server/mail/>
* __SOGo Groupware__: <https://your_server/SOGo>
* __Web admin panel (iRedAdmin)__: <httpS://your_server/iredadmin/>
* __Awstats__: <httpS://your_server/awstats/awstats.pl?config=web> (or `?config=smtp` for SMTP log)

## Get technical support

Please post all issues, feedbacks, feature requests, suggestions in our [online
support forum](http://www.iredmail.org/forum/), it's more responsible than you
expected.

## Some Tips for FreeBSD Jail

### Allow `ping` in Jail

* Appending below line in `/etc/sysctl.conf` to allow to use `ping` command
  inside Jail:

```
security.jail.allow_raw_sockets=1
```

* Update `/usr/local/etc/ezjail/mx_example_com` to allow `ping` inside Jail:

```
export jail_mx_example_com_parameters="allow.raw_sockets=1"
```

### Share `/usr/ports/distfiles` with Jail

To share `/usr/ports/distfiles/` with Jail, please append below line in
  `/etc/fstab.mx_example_com`:

> Jail will set ports tree directory to `/var/ports` instead of
> `/usr/ports` in `/jails/mx.example.com/etc/make.conf` by default, you can
> either use this default setting or change it to `/usr/ports`.

```
# Part of file: /etc/fstab.mx_example.com
/usr/ports/distfiles /jails/mx.example.com/basejail/var/ports/distfiles nullfs rw 0 0
```

Create directory `/usr/jails/basejail/var/ports/distfiles`:

```
# mkdir /usr/jails/basejail/var/ports/distfiles
```
