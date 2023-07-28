# Install iRedMail on FreeBSD inside Jail (with ezjail)

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

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

!!! warning

    * iRedMail is designed to be deployed on a __FRESH__ server system, which
      means your server does __NOT__ have mail related components installed,
      e.g. MySQL, OpenLDAP, Postfix, Dovecot, Amavisd, etc. iRedMail will install
      and configure them for you automatically. Otherwise it may override your
      existing files/configurations although it will backup files before
      modifying, and it may not be working as expected.
    * __Port 25 is required__ by mail server but many ISPs block it by default.

        Port 25 is used for communication between mail servers, __it must be open__,
        otherwise your mail server won't be able to receive and send emails.
        Please contact your ISP to make sure it's not blocked, or ask them to
        unblock it.

          - Linode. Explained in the [blog post](https://www.linode.com/blog/linode/a-new-policy-to-help-fight-spam/),
            you can open a support ticket to ask the Linode team to open it. If you [sign up to Linode with our reference](https://www.linode.com/?r=b4d04083428fb99ce452d84b57253d11692a0850), iRedMail Team's Linode account will receive a credit of $15-20.00. Thanks.
          - Vultr. [Port 25 is blocked by default](https://www.vultr.com/docs/what-ports-are-blocked/), you may request these blocks be removed by [opening a support ticket](https://my.vultr.com/support/create_ticket/).
          - Amazon AWS EC2. Request to [remove the throttle on port 25](https://aws.amazon.com/premiumsupport/knowledge-center/ec2-port-25-throttle/).
          - Google Cloud Platform.
          - Microsoft Azure.
          - DigitalOcean. According to [a post in their community](https://www.digitalocean.com/community/questions/port-25-465-is-blocked-how-can-i-enable-it), __SEEMS__ impossible to unblock port 25, that means you can __NOT__ run mail server on DigitalOcean VPS.

* The latest stable release of iRedMail. You can download it here: <https://www.iredmail.org/download.html>
* Port `sysutils/ezjail` for FreeBSD.
* Make sure 3 UID/GID are not used by other user/group: 2000, 2001, 2002.

## Preparations

### Install sysutils/ezjail and add required settings

* Install ezjail with ports tree:

```
# cd /usr/ports/sysutils/ezjail/
# make install clean
```

* Enable ezjail service and sysvipc by appending lines below to `/etc/rc.conf`:

```
# Start ezjail while system start up
ezjail_enable="YES"

# Enable sysvipc. Required by PostgreSQL.
jail_sysvipc_allow="YES"
```

* Add parameter in `/etc/sysctl.conf`, this is required if you're
  going to install iRedMail with PostgreSQL backend.

```
security.jail.sysvipc_allowed=1
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

* Create a new jail

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

## Screenshots of installation:

* Welcome and thanks for your use

![](./images/installation/welcome.png){: width="700px" }

* Specify location to store all mailboxes. Default is `/var/vmail/`.

![](./images/installation/mail_storage.png){: width="700px" }

* Choose backend used to store mail accounts. You can manage mail accounts
with iRedAdmin, our web-based iRedMail admin panel.

!!! note

    There's no big difference between available backends, so
    it's strongly recommended to choose the one you're familiar with for easier
    management and maintenance after installation.

![](./images/installation/backends.png){: width="700px" }

* If you choose to store mail accounts in OpenLDAP, iRedMail installer will
  ask to set the LDAP suffix.

![](./images/installation/ldap_suffix.png){: width="700px" }

!!! note "To MySQL/MariaDB/PostgreSQL users"

    If you choose to store mail accounts in MySQL/MariaDB/PostgreSQL, iRedMail
    installer will generate a random, strong password for you. You can find it
    in file `iRedMail.tips`.

* Add your first mail domain name

![](./images/installation/first_domain.png){: width="700px" }

* Set password of admin account of your first mail domain.

__Note__: This account is an admin account and a mail user. That means you can
login to webmail and admin panel (iRedAdmin) with this account, login username
is full email address.

![](./images/installation/admin_pw.png){: width="700px" }

* Choose optional components

    !!! attention

        __Which webmail should you choose?__ Roundcube or SOGo?

        - Roundcube is a fast and lightweight webmail, and webmail only.
          If all you need is a webmail to access mailbox and manage mail
          filters, then Roundcube is the best option.
        - SOGo offers webmail, calendar (CalDAV), contacts (CardDAV) and
          ActiveSync. If you need calendar and contacts support, also syncing
          them to mobile or PC mail client applications, then SOGo is the one
          to go. Note: If you have many ActiveSync clients, it requires a lot RAM.
        - It's ok to install both, but you can only manage mail filters with
          Roundcube in this case, because the filter rules generated by
          Roundcube and SOGo are not compatible. You can [force to enable it in
          SOGo](./why.no.sieve.support.in.sogo.html), but please inform end
          users and ask them to stick to one of them for managing mail filters.

![](./images/installation/optional_components.png){: width="700px" }


After answered above questions, iRedMail installer will ask you to review and
confirm to start installation. It will install and configure required packages
automatically. Type `y` or `Y` and press `Enter` to start.

![](./images/installation/review.png){: width="700px" }

## Important things you __MUST__ know after installation

!!! warning

    The weakest part of a mail server is user's weak password. Spammers don't
    want to hack your server, they just want to send spam from your server.
    Please __ALWAYS ALWAYS ALWAYS__ force users to use a strong password.

* Read file `/root/iRedMail-x.y.z/iRedMail.tips` first, it contains:

    * URLs, usernames and passwords of web-based applications
    * Location of mail service related software configuration files. You can
      also check this tutorial instead:
      [Locations of configuration and log files of major components](./file.locations.html).
    * Some other important and sensitive information

* [Setup DNS records for your mail server](./setup.dns.html)
* [How to configure your mail clients](./index.html#configure-mail-client-applications)
* [Locations of configuration and log files of major components](./file.locations.html)
* It's highly recommended to get a SSL cert to avoid annonying warning
  message in web browser or mail clients when accessing mailbox via
  HTTPS/IMAPS/POP3/SMTPS. [Let's Encrypt offers __FREE__ SSL certificate](https://letsencrypt.org).
  We have a document for you to
  [use a SSL certificate](./use.a.bought.ssl.certificate.html).
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
* __Web admin panel (iRedAdmin)__: <https://your_server/iredadmin/>

## Get technical support

Please post all issues, feedbacks, feature requests, suggestions in our [online
support forum](https://forum.iredmail.org/), it's more responsible than you
expected.

## Some Tips for FreeBSD Jail

### Allow `ping` in Jail

* Append below line in `/etc/sysctl.conf` to allow to use `ping` command
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
