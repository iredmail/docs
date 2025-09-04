# Upgrade Debian from 12 (bookworm) to 13 (trixie)

[TOC]

!!! warning

    This is still a DRAFT document, it may miss some other important changes.

## BEFORE OS upgrade

- PostgreSQL backend: Comment out `log_timezone` and `timezone` settings, they
  are not supported by PostgreSQL version 17.

```
perl -pi -e 's#^(log_timezone.*)##g' /etc/postgresql/15/main/postgresql.conf
perl -pi -e 's#^(timezone.*)##g' /etc/postgresql/15/main/postgresql.conf
```

- Set locale for os upgrade:
```
export LANG=en_US.utf8
export LC_ALL=en_US.utf8
export LC_CTYPE=en_US.utf8

export LANG=C
export LC_ALL=C
export LC_CTYPE=C
```

## Upgrade OS

```
apt update
apt full-upgrade -y
perl -pi -e 's#bookworm#trixie#g' /etc/apt/sources.list
perl -pi -e 's#bookworm#trixie#g' /etc/apt/sources.list.d/sogo.list
apt update
apt upgrade --without-new-pkgs -y
apt full-upgrade --autoremove -y
apt --purge autoremove -y
apt autoclean
```

- After upgraded, Apache web server is running by default, we need to disable
  Apache and enable Nginx:

```
systemctl disable apache2
systemctl enable nginx
```

- Reboot the machine to complete the upgrade:

```
reboot
```

## During OS upgrade

- Choose `yes` to migrate PostgreSQL databases (15 -> 17).
- Choose `install the package maintainer's version` while upgrading Dovecot package.

## After OS upgrade

- FIXME [PostgreSQL backend] Migrate PostgreSQL from version 15 to 17.
- Upgrade EE to latest version if you're running an old version: <https://docs.iredmail.org/upgrade.ee.html>
- Login to EE admin panel as global admin, click `Deployments` ->
  `Re-perform full deployment` to generate config files for new software
  offered by Debian 13.

    Note: After logged in to EE admin panel, it may display error messages like
    `Internal server error`, it's safe to ignore them since we didn't
    re-perform full deployment to generate config files for new software yet.
    The error messages will be gone after re-performed full deployment.

- That's all.
