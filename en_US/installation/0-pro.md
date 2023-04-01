# iRedMail Pro: Getting started

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! attention

    - All account passwords are generated randomly during deployment, stored in
      files under `/root/.iredmail/kv/` on your server, also organized in file
      `/root/iRedMail/iRedMail.tips`.
    - To migrate your existing iRedMail server to __iRedMail Pro__,
      please check this tutorial:
      [Migrate from iRedMail to iRedMail Easy platform](./migrate.to.iredmail.easy.html).

## Summary

__iRedMail Pro__ is a web-based, on-premises iRedMail server installer and
management admin panel.

With iRedMail Pro, it's easy to deploy (and re-deploy) and keep the server up
to date with just few clicks, you can also manage or tune (mail service
related) server settings on web UI.

We encourage all users to deploy new iRedMail servers with iRedMail Pro and
keep the servers up to date.

If you prefer classic downloadable iRedMail installer, you can find the
installation guides here: [Install iRedMail](./index.html#install).

## System Requirements

!!! warning

    * iRedMail is designed to be deployed on a fresh / clean server, which means you
      can not have other network services running on the server __BEFORE__
      iRedMail installation.
    * iRedMail will install and configure all required softwares automatically.
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

### Supported Linux and BSD distribution releases

Linux/BSD distribution releases supported by __iRedMail Pro__:

Distribution | Release Versions
--- |---
CentOS Stream | 8, 9
Rocky Linux | 8, 9
AlmaLinux | 8, 9
Debian | 11
Ubuntu | 20.04, 22.04
OpenBSD | 7.2

If you need to install iRedMail on FreeBSD, please use the [downloadable
installer](https://www.iredmail.org/download.html) instead.

### Hardware Requirements

* iRedMail requires at least `4 GB` memory for a low traffic production server
  with spam/virus scanning enabled.
* If you plan to run SOGo Groupware (which offers webmail, calendar (CalDAV),
  contacts (CardDAV) and ActiveSync), you need a lot more memory. Consider 16
  GB memory to support 500 ActiveSync clients.

## Download and run the installer

Run commands below on the server to download iRedMail Pro for Linux (x86_64):

```
wget -O /usr/local/bin/iredmail https://dl.iredmail.org/iredmail-2.0-beta1-linux-x86_64
chmod +x /usr/local/bin/iredmail
```

Launch the installer:

```
/usr/local/bin/iredmail
```

It runs a web server on port `8080`, please visit it with a web browser and go
through the wizard to finish the installation.

After installation, it runs on port `7793`.

Below are screenshots of the installation wizard.

## Choose preferred backend

A backend is a SQL or LDAP database used to store mail domains and
accounts. We suggest you choose the one you're familiar with for easier
maintenance.

![](./images/pro/setup-backend.png){: width="700px" }

## Choose the components you want to deploy

A component is a software (or software group, service) which implements some
network service(s). On this page you can choose the components you want to
deploy on your mail server.

![](./images/pro/setup-components.png){: width="700px" }

## Required settings

Few settings are required to deploy a mail server.

![](./images/pro/setup-required-settings.png){: width="700px" }

## Optional settings

Depends on the components you chose to install, the settings on this page may
be different.

![](./images/pro/setup-optional-settings.png){: width="700px" }

## Review and deploy

!!! attention

    All account passwords are generated randomly during deployment, stored in
    files under `/root/.iredmail/kv/` on your server, also organized in file
    `/root/iRedMail/iRedMail.tips`.

Review the settings:

![](./images/pro/setup-review-and-deploy.png){: width="700px" }

And click `Confirm and Deploy` button to deploy immediately:

![](./images/pro/setup-deploy.png){: width="700px" }

## See Also

* [Setup DNS records for your iRedMail server](./setup.dns.html)
* [Request a free cert from Let's Encrypt](./letsencrypt.html)
* [Configure mail client applications](./index.html#mua)
