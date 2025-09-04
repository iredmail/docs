# Install iRedMail Enterprise Edition

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! attention

    - All account passwords are generated randomly during deployment, stored in
      files under `/root/.iredmail/kv/` on your server, also organized in file
      `/root/iRedMail/iRedMail.tips`.
    - Need to migrate from existing iRedMail server? We have tutorials for you:
        - [Migrate from iRedMail](./iredmail.to.ee.html)
        - [Migrate from iRedMail Easy](./easy.to.ee.html)

## Summary

__iRedMail Enterprise Edition__ is a web-based, on-premises iRedMail server
installer and management admin panel.

With iRedMail Enterprise, it's easy to deploy a full-featured email server,
and keep the server up to date with just few clicks on the web UI, also manage
or tune server settings.

We encourage all users to deploy new iRedMail servers with iRedMail Enterprise
Edition and keep the server up to date.

If you prefer classic downloadable shell-based iRedMail installer, you can
find the installation guides here: [Install iRedMail](./index.html#install).

## System Requirements

!!! warning

    * iRedMail Enterprise Edition is designed to be deployed on a fresh / clean
      server, or migrate from an iRedMail server deployed with iRedMail Easy
      platform. For new installation, it will install and configure required
      components, so you should not have other network services installed or
      running on the server __BEFORE__ installation.
    * iRedMail Enterprise Edition will install and configure all required
      software automatically.
    * Many ISPs block network port 25 by default, it's used for communication
      between mail servers and it must be open, otherwise your server may be
      not able to receive or / and send emails. Please contact your ISP to make
      sure it's not blocked, or ask them to unblock.

          - Amazon AWS EC2. Request to [remove the throttle on port 25](https://aws.amazon.com/premiumsupport/knowledge-center/ec2-port-25-throttle/).
          - Google Cloud Platform.
          - Microsoft Azure.
          - Linode. Explained in the [blog post](https://www.linode.com/blog/linode/a-new-policy-to-help-fight-spam/),
            you can open a support ticket to request the Linode team to open it. If you [sign up to Linode with our reference](https://www.linode.com/?r=b4d04083428fb99ce452d84b57253d11692a0850), iRedMail Team's Linode account will receive a credit of $15-20.00. Thanks.
          - DigitalOcean. According to [a post in their community](https://www.digitalocean.com/community/questions/port-25-465-is-blocked-how-can-i-enable-it), __SEEMS__ impossible to unblock port 25, that means you can __NOT__ run mail server on DigitalOcean VPS.

### Supported Linux and BSD distribution releases

Linux/BSD distribution releases supported by __iRedMail Enterprise Edition__:

Distribution | Release Versions | Notes
--- |--- |---
CentOS Stream | 9, 10 | [SOGo is not available on CentOS 10 yet](https://bugs.sogo.nu/view.php?id=6118)
Rocky Linux | 9, 10 | [SOGo is not available on Rocky 10 yet](https://bugs.sogo.nu/view.php?id=6118)
AlmaLinux | 9, 10 | [SOGo is not available on Alma 10 yet](https://bugs.sogo.nu/view.php?id=6118)
Debian | 11, 12 | 12 is recommended.
Ubuntu | 20.04, 22.04, 24.04 | 24.04 is recommended.
OpenBSD | 7.7 |

If you need to install iRedMail on FreeBSD, please use the [downloadable
installer](https://www.iredmail.org/download.html) instead.

### Hardware Requirements

* iRedMail requires at least `4 GB` memory for a low traffic production server
  with spam/virus scanning enabled.
* If you plan to run SOGo Groupware (which offers webmail, calendar (CalDAV),
  contacts (CardDAV) and ActiveSync), you need a lot more memory. Consider 16
  GB memory to support 500 ActiveSync clients.

## Get a License

iRedMail Enterprise Edition requires a license key, you can request a free
one-month trial license or purchase one by signing up or login to our
[iRedMail Store](https://store.iredmail.org/).

## Download and run the installer

Run commands below on the server to download iRedMail Enterprise Edition on
Linux or OpenBSD, both x86_64/AMD64 and ARM64 are supported:

!!! attention

    Please download it and save to `/usr/local/bin/iredmail`. This path is
    hard-coded in systemd service file to start iRedMail Enterprise.

* For Linux, x86_64 / amd64:

```bash
cd /usr/local/bin/
wget -O iredmail https://dl.iredmail.org/ee/iredmail-enterprise-latest-linux-amd64
chown root:root iredmail
chmod 0500 iredmail
```

* For Linux, ARM64 / aarch64:

```bash
cd /usr/local/bin/
wget -O iredmail https://dl.iredmail.org/ee/iredmail-enterprise-latest-linux-arm64
chown root:root iredmail
chmod 0500 iredmail
```

* For OpenBSD, x86_64 / amd64 (also install required `bash` shell):

```bash
cd /usr/local/bin/
wget -O iredmail https://dl.iredmail.org/ee/iredmail-enterprise-latest-openbsd-amd64
chown root:wheel iredmail
chmod 0500 iredmail
pkg_add bash
```

* For OpenBSD, arm64 aarch64 (also install required `bash` shell too):

```bash
cd /usr/local/bin/
wget -O iredmail https://dl.iredmail.org/ee/iredmail-enterprise-latest-openbsd-amd64
chown root:wheel iredmail
chmod 0500 iredmail
pkg_add bash
```

Launch the installer:

```bash
/usr/local/bin/iredmail
```

- It runs a web server on port `8080` for initial deployment, please visit
  `http://your-server:8080` with your favourite web browser and go through the
  wizard to finish the installation.
- After deployment succeeded, it closes port `8080` and runs on port
  `127.0.0.1:7793`. Nginx is configured to proxy requests to it through URI
  `/admin/` (this URI can be customized on web UI during installation),
  please visit `httpS://your-server/admin/` to access it to manage your
  iRedMail server.

Below are screenshots of the installation wizard.

## Installation

### Choose preferred backend

A backend is a SQL or LDAP database used to store mail domains and
accounts. There're not big differences between them, so we suggest you choose
the one you're familiar with for easier maintenance.

![](./images/ee/setup-backend.png){: width="700px" }

### Choose the components you want to deploy

A component is a software (or software group, service) which implements some
network service(s). On this page you can choose the components you want to
deploy on your mail server.

![](./images/ee/setup-components.png){: width="700px" }

### Required settings

Few settings are required to deploy a mail server.

Note: while typing, it will validate the input value, please fill and wait for
1-3 seconds until it finished the validation.

![](./images/ee/setup-required-settings.png){: width="700px" }

### Review and deploy

!!! attention

    All account passwords are generated randomly during deployment, and stored
    in files under `/root/.iredmail/kv/` on your own server, also organized in
    file `/root/iRedMail/iRedMail.tips` for your reference.

Review the settings:

![](./images/ee/setup-review-and-deploy.png){: width="700px" }

Click `Confirm and Deploy` button to deploy immediately:

![](./images/ee/setup-deploy.png){: width="700px" }

### Setup complete

Once setup finished successfully, you should see info for login to admin panel.
Please visit the URL and login with given username and password.

Note: This is a global admin which has all privileges.

![](./images/ee/setup-complete.png){: width="500px" }

### Login to admin panel

After logged into admin panel, you can manage software components, tune server
settings, manage mail accounts, etc.

![](./images/ee/components.png){: width="700px" }
<br/>
![](./images/ee/server-settings.png){: width="700px" }
<br/>
![](./images/ee/domains.png){: width="700px" }

## See Also

* [Upgrade iRedMail Enterprise Edition](./upgrade.ee.html)
* [ChangeLog of iRedMail Enterprise Edition](./ee.changelog.html)
* [Setup DNS records for your iRedMail server](./setup.dns.html)
* [Request a free cert from Let's Encrypt](./letsencrypt.html)
* [Configure mail client applications](./index.html#mua)
