# Migrate from iRedMail Easy to iRedMail Enterprise Edition

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! attention

    iRedMail Team can help migrate your iRedMail server, feel free to
    [Contact Us](https://www.iredmail.org/contact.html).

## Summary

iRedMail Enterprise Edition (`EE` for short) uses almost same deployment code
as iRedMail Easy, migrating from iRedMail Easy to EE is a breeze.

## Notes before getting started

- iRedAdmin and iRedAdmin-Pro are not available after migrated to iRedMail EE,
  because iRedMail EE offers same features as iRedAdmin-Pro, hence
  no need to run iRedAdmin(-Pro) after migrated.
- An EE license is required. Please login or sign up to our website to get
  a trial license or purchase one: <https://store.iredmail.org/>.

## Migrate

- Follow the tutorial to [download and launch the installer of iRedMail Enterprise Edition](./install.ee.html),
  on your server which was deployed with iRedMail Easy platform.

    EE will check server environment and find it's deployed with iRedMail Easy
    platform, then runs http service on port `8080`, please make sure this port
    is open in your firewall, then visit it with a web browser and you should
    see web page like below.

- Login to iRedMail Easy platform: <https://easy.iredmail.org/>
- Click `Mail Servers` on left sidebar.
- Click `Export` to export the server settings.
- Copy the server settings (in JSON format) and paste below, then click
`Migrate` button to import settings and start migration immediately. It should finish in seconds.
- After migrated, access the new web UI `https://your-server/admin/`,
  login with same admin accounts you used to login to iRedAdmin or iRedAdmin-Pro.
- After logged in, click `Deployments` on left sidebar, then click
  `Re-perform full deployment` to apply config file changes to fully migrated
  to iRedMail EE. Usually it finishes in just seconds.
- That's all.

If you experienced any issue, please report via the [Ticket system](https://store.iredmail.org/tickets).

![](./images/ee/easy.to.ee.png){: width="700px" }
