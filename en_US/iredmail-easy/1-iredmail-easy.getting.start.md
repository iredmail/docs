# iRedMail Easy: Getting start

[TOC]

!!! warning

    __iRedMail Easy__ does __NOT__ (yet) support upgrading existing server
    which was deployed with any downloadable iRedMail installer (e.g.
    iRedMail-0.9.9, iRedMail-0.9.8 and earlier releases).

## Summary

__iRedMail Easy__ is a web-based deployment and support platform.  With this
platform, it's easy to deploy and keep the iRedMail server up to date, easy to
get the fast and professional technical support from iRedMail team.

We encourage all users to deploy new iRedMail servers with this platform and
keep the servers up to date.

* Please also read [Best Practice](./iredmail-easy.best.practice.html) to
  understand how to achieve fearless one-click upgrade with iRedMail Easy.
* Read [Release Notes](./iredmail-easy.release.notes.html) to track changes in
  each release.

If you prefer classic downloadable iRedMail installer, you can find the
installation guides here: [Install iRedMail](./index.html#install).

## System Requirements

!!! warning

    * iRedMail is designed to be deployed on a dedicated server, which means you
      can not have other network services running on the server __BEFORE__
      iRedMail installation.
    * iRedMail will install and configure all required softwares automatically.

### Supported Linux and BSD distribution releases

Linux/BSD distribution releases supported by __iRedMail Easy__:

Distribution | Release Versions
--- |---
CentOS | 7
Debian | 9
Ubuntu | 18.04
OpenBSD | 6.4, 6.5

If you need to install iRedMail on FreeBSD, please use the [downloadable
installer](https://www.iredmail.org/download.html) instead.

### Hardware Requirements

* iRedMail requires at least `2 GB` memory for a low traffic production server.
* If you plan to run SOGo Groupware (which offers webmail, calendar (CalDAV),
  contacts (CardDAV) and ActiveSync), you need a lot more memory. Consider 16
  GB memory to support 500 ActiveSync clients.

## Sign up and login

To deploy a mail server, you need to sign up with a valid email
address first:

* [Sign Up or Login: https://easy.iredmail.org/](https://easy.iredmail.org)

It will send you an email to confirm you're the owner of the email address,
please click the link in the email to confirm, then login.

After signed up, you get one-month trial for free to evaluate the iRedMail Easy
platform, if you don't like it, or don't need it, feel free to remove your own
account in `Profile` page on the left sidebar after logged in.

Screenshots of Sign Up and Login pages:

![](./images/iredmail-easy/installation/signup.png){: width="350px" }
![](./images/iredmail-easy/installation/login.png){: width="350px" }

## Add a new mail server

After login, you will be redirected to the `Dashboard` page, please click the
`Add a mail server` button to add a new mail server.

![](./images/iredmail-easy/installation/add_mailserver.png){: width="600px" }

Explanation of the form fields:

* `Hostname (FQDN)`: This is the server hostname you want to set for the mail server.

    * It must be a fully qualified domain name (FQDN), for example,
      `mail.example.com`, `mx.example.com`.
    * This hostname can __NOT__ be used as a virtual mail domain (used in email
      address like `user@example.com`) because it's used to accept email sent
      to Linux/BSD system account like `root` user.

* `IP Address`: Public or private IP address of your mail server.

    If this mail server is in internal network and can not be accessed directly
    from external network, you need a Jump Server (or, Bastion Server) so that
    our deployment server can connect to your mail server. For more details
    about Jump Server, please read this short tutorial: [What is SSH jump
    server](./iredmail-easy.what.is.ssh.jump.server.html).

* `SSH Port`: SSH service port number. Defaults to 22.
* `SSH User`: The login username for ssh secure connection. Defaults to `root`.

    If you use a non-root user, `sudo` on Linux or `doas` on OpenBSD is
    required to gain root privilege.

* `SSH Key`: The SSH key used to login to your mail server.

    If you choose option `Generate one for me`, after submitted this form,
    our system will generate a strong (4096 bits) SSH key for you.

* `OS`: Choose the Linux/BSD distribution and release version of your mail
  server.
* `Deployment Server`: Please choose one deployment server from the list.

    A deployment server connects to your mail server to deploy or upgrade,
    please choose the nearest one for faster network connection.

    If your mail server sits behind a firewall, please whitelist the IP address
    of selected deployment server.

* `Comment`: Add some text to help you identify this mail server.

Click the button to create mail server, after created, page will be redirected
to mail server profile page.  You're free to update profile here.

![](./images/iredmail-easy/installation/added_mailserver.png){: width="600px" }

## Choose preferred backend

Click tab `Backend` on the mail server profile page.

A backend is a SQL or LDAP database used to store mail domains and
accounts. We suggest you choose the one you're familiar with for easier
maintenance.

![](./images/iredmail-easy/installation/backends.png){: width="700px" }

## Choose the components you want to deploy

Click tab `Components` on the mail server profile page.

A component is a software (or software group) which implements some network
service(s). On this page you can choose the components you want to deploy on
your mail server.

![](./images/iredmail-easy/installation/components.png){: width="700px" }

## Component settings

Click tab `Settings` on the mail server profile page.

Depends on the components you selected, the settings on this page may be
different. Please fill all required form fields on this page.

Fields with red asterisk are required, others are optional.

![](./images/iredmail-easy/installation/settings.png){: width="700px" }

## Deploy

Click tab `Deployment` on the mail server profile page.

Please run the commands displayed on this page on your mail server, it will
download a shell script to simplify ssh public key setup. If ssh login user is
not `root`, it will help setup `sudo` (on Linux) or `doas` (on OpenBSD) also.

![](./images/iredmail-easy/installation/deployment.png){: width="900px" }

After you ran the commands, it's ready to deployment. Click the button `Perform Full Deployment` to start the deployment.

Depends on the components you selected, and network connection speed between
your server and our deployment server, it may take few minutes or even longer
to finish. Please be patient.

It will refresh the page every 5 seconds and show you the latest output of
deployment task, you can watch and (hopefully) have some fun. :)

## Get techinical support through the ticket system

If you have any question or issue, feel free to open a new support ticket,
clearly explain the question or issue, support team will try to reply as soon
as possible.

![](./images/iredmail-easy/installation/support.png){: width="600px" }

## Update account profile

You can update the account profile on the `Profile` page:

- name
- time zone
- password
- subscribe to notification when new version is available

If you do not like this platform, you can find a button on this page to remove
your account.

![](./images/iredmail-easy/installation/account_profile.png){: width="800px" }

## See Also

* [Best Practice](./iredmail-easy.best.practice.html)
* [Setup DNS records for your iRedMail server](./setup.dns.html)
* [Request a free cert from Let's Encrypt](./letsencrypt.html)
* [Configure mail client applications](./index.html#mua)
