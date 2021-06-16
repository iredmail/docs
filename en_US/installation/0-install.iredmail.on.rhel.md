# Install iRedMail on Red Hat Enterprise Linux, CentOS

[TOC]

!!! attention

    It's recommended to use the new __iRedMail Easy__ deployment and support
    platform to deploy and keep your mail server up to date, technical support
    is available through the ticket system.

    Read more: [iRedMail Easy - Meet our new deployment and support platform](./iredmail-easy.getting.start.html)

## System Requirements

!!! warning

    * iRedMail is designed to be deployed on a __FRESH__ server system, which
      means your server does __NOT__ have mail related components installed,
      e.g. MySQL, OpenLDAP, Postfix, Dovecot, Amavisd, etc. iRedMail will install
      and configure them for you automatically. Otherwise it may override your
      existing files/configurations although it will backup files before
      modifying, and it may not be working as expected.
    * Many ISPs block port 25 by default, it's used for communication between
      mail servers, it must be open, otherwise your server may be not able to
      receive or / and send emails. Please contact your ISP to make sure it's
      not blocked, or ask them to unblock.

          - Amazon AWS EC2. Request to [remove the throttle on port 25](https://aws.amazon.com/premiumsupport/knowledge-center/ec2-port-25-throttle/).
          - Google Cloud Platform.
          - Microsoft Azure.
          - Linode. Explained in the [blog post](https://www.linode.com/blog/linode/a-new-policy-to-help-fight-spam/),
            you can open a support ticket to request the Linode team to open it. If you [sign up to Linode with our reference](https://www.linode.com/?r=b4d04083428fb99ce452d84b57253d11692a0850), iRedMail Team's Linode account will receive a credit of $15-20.00. Thanks.
          - DigitalOcean. According to [a post in their community](https://www.digitalocean.com/community/questions/port-25-465-is-blocked-how-can-i-enable-it), __SEEMS__ impossible to unblock port 25, that means you can __NOT__ run mail server on DigitalOcean VPS.

To install iRedMail on RHEL or CentOS Linux, you need:

* A __FRESH__, working RHEL or CentOS system. Supported releases are listed on
  [Download](https://www.iredmail.org/download.html) page.
* At least `4 GB` memory is required for a low traffic production mail server
  with spam/virus scanning enabled..
* Make sure 3 UID/GID are not used by other user/group: 2000, 2001, 2002.

## Preparations

### Set a fully qualified domain name (FQDN) hostname on your server

No matter your server is a testing machine or production server, it's strongly
recommended to set a fully qualified domain name (FQDN) hostname.

Enter command `hostname -f` to view the current hostname:

```shell
$ hostname -f
mx.example.com
```

On RHEL/CentOS Linux, hostname is set in two files:

1. `/etc/hostname`:

    ```
    mx.example.com
    ```

1. `/etc/hosts`: hostname <=> IP address mapping. Warning: List the FQDN hostname as first item.

    ```
    127.0.0.1   mx.example.com mx localhost localhost.localdomain
    ```

Verify the FQDN hostname. If it wasn't changed, please reboot server to make it work.

```
$ hostname -f
mx.example.com
```

### Disable SELinux.

iRedMail doesn't work with SELinux, so please disable it by setting below
value in its config file `/etc/selinux/config`. After server reboot, SELinux
will be completely disabled.

```
SELINUX=disabled
```

If you prefer to let SELinux prints warnings instead of enforcing, you can
set below value instead:

```
SELINUX=permissive
```

Disable it immediately without rebooting your server.

```
# setenforce 0
```

### Enable yum repositories for installing new packages

* On CentOS:
    - Enable official yum repositories. On CentOS 8 and CentOS 8 Stream, please
      make sure repo `appstream` and `powertools` are enabled.
    - Enable repo `epel`.
    - __DISABLE__ all other third-party yum repositories to avoid package conflict.

* On Red Hat Enterprise Linux:
    - Enable Red Hat Network to install packages, or create a local yum
      repository with DVD/CD ISO images.
    - Enable `epel` repo (you can enable it by installing package `epel-release`)
    - On Red Hat Enterprise Linux, please enable repository `codeready-builder-for-rhel-8-x86_64-rpms`
      and `epel` with commands below:

```
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
subscription-manager repos --enable codeready-builder-for-rhel-8-x86_64-rpms
```

!!! attention

    Since official RHEL/CentOS and EPEL repositories don't have all
    required packages with the needed features, iRedMail team has built these
    packages and made them available trough the iRedMail repository enabled by
    default at installation time. You can view all available packages
    [here](https://dl.iredmail.org/yum/rpms/), please check `README` and
    `ChangeLog` files under each directory for more details. Source RPMs (srpm)
    used by iRedMail team to build the binary packages are available
    [here](https://dl.iredmail.org/yum/srpms/).

### Download the latest release of iRedMail

* Visit [Download page](https://www.iredmail.org/download.html) to get the
  latest stable release of iRedMail.

* Upload iRedMail to your mail server via ftp or scp or whatever method you
  can use, login to the server to install iRedMail. We assume you uploaded
  it to `/root/iRedMail-x.y.z.tar.gz` (replace x.y.z by the real version number).

* Uncompress iRedMail tarball:

```
# cd /root/
# tar zxf iRedMail-x.y.z.tar.gz
```

## Start iRedMail installer

It's now ready to start iRedMail installer, it will ask you several simple
questions, that's all required to setup a full-featured mail server.

```
# cd /root/iRedMail-x.y.z/
# bash iRedMail.sh
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
* __Web admin panel (iRedAdmin)__: <httpS://your_server/iredadmin/>

## Get technical support

* You are welcome to post issues, feedbacks, feature requests, suggestions in
  our [online support forum](https://forum.iredmail.org/), it's more
  responsive than you expected.
* We offer paid professional support service too, check our web site for more
  details: [Get Professional Support from iRedMail Team](https://www.iredmail.org/support.html).
