# Install iRedMail with iRedMail Easy (web deployment platform)

[TOC]

## Summary

__iRedMail Easy__ is a web-based deployment and support platform.  With this
platform, it's easy to deploy and keep the iRedMail server up to date, easy to
get the fast and professional technical support from iRedMail team.

We encourage all users to deploy new iRedMail servers with this platform and
keep the servers up to date.

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
Ubuntu | 16.04, 18.04
OpenBSD | 6.4

If you need to install iRedMail on FreeBSD, please follow the installation
guide below:

* [Install iRedMail on FreeBSD](./install.iredmail.on.freebsd.html)
* [Install iRedMail on FreeBSD inside Jail (with ezjail)](./install.iredmail.on.freebsd.with.jail.html)

### Hardware Requirements

* iRedMail requires at least `2 GB` memory for a low traffic production server.
* If you plan to run SOGo Groupware (which offers webmail, calendar (CalDAV),
  contacts (CardDAV) and ActiveSync), you need a lot more memory. Consider 16
  GB memory to support 500 ActiveSync clients.

## Sign up and login

To deploy a mail server, you need to sign up and login with a valid email
address first:

* [Sign Up or Login: https://easy.iredmail.org/](https://eazy.iredmail.org)

We will send you an email to confirm you're the owner of the email address,
please click the link in the email to confirm, then login.

After signed up, you get one-month trial to evaluate this web deployment
platform, if you don't like or need it, feel free to remove your own account in
`Profile` page after login.

Screenshots of login and sign up web pages:

![](./images/iredmail-easy/installation/login.png){: width="350px" }
![](./images/iredmail-easy/installation/signup.png){: width="350px" }

## Add a new mail server

After login, you will be redirected to the `Dashboard` page, please click the
`Add a mail server` button to add a new mail server.

Explanation of the form fields (screenshots attached below):

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

Screenshots:

![](./images/iredmail-easy/installation/add_mailserver.png){: width="600px" }
![](./images/iredmail-easy/installation/added_mailserver.png){: width="600px" }

## Choose preferred backend and softwares

After added mail server, you will be redirected to mail server profile page.
There're few tabs on the page, let's go through them one by one.
Screenshots attached below.

* Tab (mail server) `Profile`.

    We already filled all form fields while creating it, you're free to update
    them here.

* Tab `Backend`.

    A backend is a SQL or LDAP database used to store mail domains and
    accounts. We suggest you choose the one you're familiar with for easier
    maintaince.

* Tab `Components`.

    A component is a software (or software group) used by mail service. On this
    page you can choose the components you want to deploy on your mail server.

* Tab `Settings`.

    Depends on the components you selected, the settings on this page may be
    different. Please fill all required form fields on this page.
    
    Fields with red asterisk are required, others are optional.

* Tab `Deployment`.

    The deployment server will run Ansible to connect to your mail server via
    secure ssh connection, without a password. Please download the prepared
    script and upload it to the mail server, then run it with command below. it will help add ssh public key and
    set correct file permission. If ssh login user is not root, it will help
    setup `sudo` (on Linux) or `doas` (on OpenBSD).

    ```
    bash init_target_server.sh
    ```
    
    After you added ssh public key, click the button `Perform Full Deployment`
    to start the iRedMail deployment.

    Depends on the components you selected, and network connection speed, it
    may take few minutes or even longer to finish. Please be patient.

![](./images/iredmail-easy/installation/backends.png){: width="700px" }
![](./images/iredmail-easy/installation/components.png){: width="700px" }
![](./images/iredmail-easy/installation/settings.png){: width="700px" }
![](./images/iredmail-easy/installation/deployment.png){: width="700px" }

## Get techinical support through the ticket system

If you have any question or issue, feel free to open a new support ticket,
clearly explain the question or issue, support team will try to reply in time.

![](./images/iredmail-easy/installation/support.png){: width="400px" }

## Update account profile

You can update your name, time zone, password on the `Profile` page. If you
do not like this platform, you're free to remove your account here too.

![](./images/iredmail-easy/installation/account_profile.png){: width="800px" }

## See Also

* [Best Practice](./iredmail-easy.best.practice.html)
* [Setup DNS records for your iRedMail server](./setup.dns.html)
* [Request a free cert from Let's Encrypt](./letsencrypt.html)
* [Configure mail client applications](./index.html#mua)
