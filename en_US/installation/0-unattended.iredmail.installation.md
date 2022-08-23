# Perform silent/unattended iRedMail installation

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

## Summary

iRedMail installer stores its own configrations in file named `config` during
installation. For example, if you downloaded iRedMail-1.2 under `/root`, then
then file path is `/root/iRedMail-1.2/config`.

While launching the iRedMail installer, it detects whether there's an existing
config file, and asks for your confirmation to use it if found one. You can use
this procedure to perform unattended iRedMail installation.

## Generate a sample config file

To generate a sample config file, just run the installer:

```bash
bash iRedMail.sh
```

After finished the configuration dialog, iRedMail installer prints your
configuration and ask for your confirmation to perform the actual installation.
You should abort it here since you just want to generate a sample config file.

Feel free to open this `config` file, change the settings to match your real
deployment if you want.

## Deploy a new server with a prepared config file

To deploy a new server with a prepared config file:

* Download iRedMail installer from website: [Download](https://www.iredmail.org/download.html).
* Upload iRedMail installer to new server and uncompress it. We assume the
  uncompress directory is `/root/iRedMail-1.2/`.
* Upload the prepared config file to `/root/iRedMail-1.2/config` on new server.
* Now launch iRedMail installer with some environment variables:

```bash
AUTO_USE_EXISTING_CONFIG_FILE=y \
    AUTO_INSTALL_WITHOUT_CONFIRM=y \
    AUTO_CLEANUP_REMOVE_SENDMAIL=y \
    AUTO_CLEANUP_REPLACE_FIREWALL_RULES=y \
    AUTO_CLEANUP_RESTART_FIREWALL=y \
    AUTO_CLEANUP_REPLACE_MYSQL_CONFIG=y \
    bash iRedMail.sh
```

It's easy to understand what the variable names are used for:

* `AUTO_USE_EXISTING_CONFIG_FILE=y`: Use existing `config` file without asking for confirmation.
* `AUTO_INSTALL_WITHOUT_CONFIRM=y`: Start the installation without asking for confirmation.
* `AUTO_CLEANUP_REMOVE_SENDMAIL=y`: Remove `sendmail` package without asking for confirmation.
* `AUTO_CLEANUP_REPLACE_FIREWALL_RULES=y`: Copy and use the firewall rules shipped in iRedMail installer.
* `AUTO_CLEANUP_RESTART_FIREWALL=y`: Restart firewall service without asking for confirmation.
* `AUTO_CLEANUP_REPLACE_MYSQL_CONFIG=y`: Copy and use the MySQL (server) config file shipped in iRedMail installer.
