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

- Login to iRedMail Easy platform: <https://easy.iredmail.org/>
- Click `Mail Servers` on left sidebar.
- Click `Export` button right beside the server hostname you want to migrate. It will display a modal window to show you the server settings.
- Click `Copy` on the modal window to copy server settings in JSON format.
- Follow [the iRedMail EE installation tutorial](./install.ee.html) to download
  and launch the installer on the server you're going to migrate.

    EE launches the http service on port `8080`, please stop the firewall temporarily:

    - on RHEL/CentOS/Rocky/Alma, run: `service firewalld stop`
    - on Debian/Ubuntu, run: `service nftables stop`
    - on OpenBSD, run: `pfctl -d`

- Paste the copied server settings and paste below, then click `Migrate` button
  to import settings.
- Click `Next` to review the settings.
- Click `Migrate` to start the migration immediately. It should finish in seconds.
- After migrated, access the new web UI `https://your-server/admin/`,
  login with same admin accounts you used to login to iRedAdmin or iRedAdmin-Pro.
- After logged in, click `Deployments` on left sidebar, then click
  `Re-perform full deployment` to apply config file changes to fully migrated
  to iRedMail EE. Usually it finishes in just seconds.

That's all.

If you experienced any issue, please report via the [Ticket system](https://store.iredmail.org/tickets).

![](./images/ee/easy.to.ee-1.png){: width="700px" }
![](./images/ee/easy.to.ee-2.png){: width="700px" }
![](./images/ee/easy.to.ee-3.png){: width="700px" }
