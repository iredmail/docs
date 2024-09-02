# Migrate from iRedMail Easy to iRedMail Enterprise Edition

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! attention

    iRedMail Team can help migrate your iRedMail server, feel free to
    [Contact Us](https://www.iredmail.org/contact.html).

## Summary

iRedMail Enterprise Edition (EE) offers easy deployment, one-click upgrade
support and technical support for your iRedMail server. It's very easy to keep
your server up to date with the ease to use web UI, and get issues solved by
iRedMail Team quickly.

For more details about iRedMail EE, please
[check our website](https://www.iredmail.org/ee.html).

iRedMail EE uses almost same deployment code as iRedMail Easy, so migrating
from iRedMail Easy is a breeze.

## Notes before getting started

- iRedAdmin and iRedAdmin-Pro are not available after migrated to iRedMail EE,
  because iRedMail EE offers same features as iRedAdmin-Pro, hence
  no need to run iRedAdmin(-Pro) after migrated.

## Migrate

- Follow the tutorial to [install and run iRedMail Enterprise Edition](./install.ee.html),
  on your server which was deployed with iRedMail Easy platform.

    EE will check server environment and find it's deployed with iRedMail Easy
    platform, then runs http service on port `8080`, please make sure this port
    is open in your firewall, then visit it with a web browser and you should
    see web page like below.

    Since HSTS is enabled by default in iRedMail, web browser may refuse to
    access port `8080` with server hostname and `http` protocol, for example,
    `http://mail.domain.com:8080`, please visit server IP address instead in
    this case: `http://x.x.x.x:8080`.

- Login to iRedMail Easy platform: <https://easy.iredmail.org/>
- Click `Mail Servers` on left sidebar.
- Click `Export` to export the server settings.
- Copy the server settings (in JSON format) and paste below, then click
`Migrate` button to import settings and start migration immediately. It should finish in seconds.

After migrated, you can access new admin UI: `https://your-server/admin/`.
Login with same accounts you used to login to iRedAdmin or iRedAdmin-Pro.

If you experienced any issue, please report via the [Ticket system](https://store.iredmail.org/tickets).

![](./images/ee/easy.to.ee.png){: width="700px" }
