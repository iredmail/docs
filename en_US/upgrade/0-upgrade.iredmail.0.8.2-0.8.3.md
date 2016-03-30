# Upgrade iRedMail from 0.8.2 to 0.8.3

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](../support.html) and [contact us](../contact.html).

## ChangeLog

* 2012-10-16: [ldap] Fix incorrect LDAP URI in Cluebringer config file.
* 2012-10-16: [Optional] Send an email to postmaster@ if user's mailbox is larger than or equal to 95% full.
* 2012-10-10: Upgrade iRedAdmin (open source edition).
* 2012-10-10: [RHEL/CentOS/Scientific 6 only] Fix incorrect path in cron job.
* 2012-10-10: [Debian/Ubuntu only] Fix incorrect SQL table name in /etc/apache2/conf.d/cluebringer.conf

## General (All backends should apply these steps)

### Update /etc/iredmail-release with iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
# File: /etc/iredmail-release

0.8.3
```

### Upgrade Roundcube webmail to the latest stable release

Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release immediately: [How to upgrade Roundcube](http://trac.roundcube.net/wiki/Howto_Upgrade)

### Upgrade iRedAPD (Postfix policy server) to the latest stable release

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

### Upgrade iRedAdmin (open source edition) to the latest stable release

Please follow this tutorial to upgrade iRedAdmin open source edition to the
latest stable release: [Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html)

## Fix incorrect path in cron job

__Note__: This is applicable to Red Hat Enterprise Linux 6, CentOS 6,
Scientific Linux 6. If you're running other distributions or releases, please
skip this step.

iRedMail uses incorrect path (`/`) in user `amavis`'s cron job, please change
it to `/var/spool/amavisd/quarantine/` instead. Steps:

* Execute command `crontab` like below to edit user amavis's cron job:

```
# crontab -e -u amavis
```

* Find below line:

```
# Delete virus mails which created 15 days ago.
1   5   *   *   *   find / -ctime +15 | xargs rm -rf {}
```

* Change the path `/` to `/var/spool/amavisd/quarantine/` like below:

```
1   5   *   *   *   find /var/spool/amavisd/quarantine/ -ctime +15 | xargs rm -rf {}
```

* Save your changes and exit editor.

### [Optional] Notify postmaster@ if user's mailbox is larger than or equal to 95% full

__Note__: This update is optional but strongly recommended, so that you, mail
server administrator, can deal with mailbox quota exceed issue in time.

* Append below text into `/usr/local/bin/dovecot-quota-warning.sh`:

```
# Send a copy to postmaster@ if mailbox is greater than or equal to 95% full.
if [ ${PERCENT} -ge 95 ]; then
    DOMAIN="$(echo ${USER} | awk -F'@' '{print $2}')"
    cat << EOF | PH_DOVECOT_DELIVER -d postmaster@${DOMAIN} -o "plugin/quota=dict:User quota::noenforcing:proxy::quota"
From: no-reply@PH_HOSTNAME
Subject: Mailbox Quota Warning: ${PERCENT}% full, ${USER}

Your mailbox is now ${PERCENT}% full, please clean up some mails for
further incoming mails.
EOF
fi
```

* Replace `PH_DOVECOT_DELIVER` above by the real path of Dovecot deliver
  program, you can find the path in the same file: `/usr/local/bin/dovecot-quota-warning.sh`.

    * On RHEL/CentOS/Scientific Linux/Gentoo, it's `/usr/libexec/dovecot/deliver`.
    * On Debian/Ubuntu/openSUSE, it's `/usr/lib/dovecot/deliver`.
    * On FreeBSD/OpenBSD, it's `/usr/local/libexec/dovecot/deliver`.

* Replace 'PH_HOSTNAME' above by your server hostname. You can get it with below command:

```
# hostname --fqdn
```

## OpenLDAP backend special

### Fix incorrect LDAP URI in Cluebringer config file

Note: This step is applicable if you have Cluebringer installed, which means
you're running PostgreSQL backend, or running Debian 7 (wheezy), Ubuntu 11.10
and later releases.

* Open Apache config file of Cluebringer

    * on RHEL/CentOS/Scientific Linux 6, it's `/etc/httpd/conf.d/cluebringer.conf`.
    * on Debian 7 (wheezy), or Ubuntu 11.10 or later releases, it's `/etc/apache2/conf.d/cluebringer.conf`.
    * on FreeBSD, it's `/usr/local/etc/apache22/Includes/cluebringer.conf`.

* Find parameter `AuthLDAPUrl` and update it:

    * replace `o=domainAdmins` by `o=domains`
    * replace `objectclass=mailAdmin` by `objectclass=mailUser`

* Save changes and restarting Apache web server.

## MySQL backend special

### Fix incorrect SQL table name in `/etc/apache2/conf.d/cluebringer.conf`

__Note__: This is applicable to Debian and Ubuntu only.

iRedMail uses incorrect SQL table name `admin` in
`/etc/apache2/conf.d/cluebringer.conf`, please change it to `mailbox` like below:

```
# Part of file: /etc/apache2/conf.d/cluebringer.conf

    AuthMySQL_Password_Table mailbox
```

Restarting Apache service is required.
