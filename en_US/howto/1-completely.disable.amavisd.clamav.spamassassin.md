# Completely disable Amavisd + ClamAV + SpamAssassin

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

In iRedMail, Amavisd provides below features:

* content-based spam scanning (invoke SpamAssassin)
* Virus scanning (invoke ClamAV)
* DKIM signing
* DKIM verification (through SpamAssassin + Perl module)
* SPF verification (through SpamAssassin + Perl module)
* Disclaimer (throught AlterMIME)

### Stop virus/spam scanning, keep DKIM signing/verification and Disclaimer

If you want to disable virus and spam scanning, but keep DKIM signing and disclaimer, please try this:

* Keep `content_filter = smtp-amavis:[127.0.0.1]:10024` in Postfix config file `/etc/postfix/main.cf`.

* Find below lines in Amavisd config file:
    - On RHEL/CentOS, it's `/etc/amavisd/amavisd.conf`
    - On Debian/Ubuntu, it's `/etc/amavis/conf.d/50-user`
    - On FreeBSD, it's `/usr/local/etc/amavisd.conf`
    - On OpenBSD, it's `/etc/amavisd.conf`

```perl
# @bypass_virus_checks_maps = (1);  # controls running of anti-virus code
# @bypass_spam_checks_maps  = (1);  # controls running of anti-spam code
```

Uncomment above lines (removing "# " at the beginning of each line), and restart Amavisd service.

You may want to stop and disable ClamAV service, then remove clamav packages
since it's not called by Amavisd or other programs anymore:

!!! attention

    On Linux system with systemd support, you can keep the packages but `mask`
    the clamav service to prevent it started by other applications with command
    below:

        # CentOS
        systemctl mask clamd@amavisd

        # Debian/Ubuntu
        systemctl mask clamav-daemon clamav-freshclam

```
# CentOS
systemctl disable --now clamd@amavisd
systemctl restart amavisd
yum remove clamav clamav-lib

# Debian/Ubuntu
systemctl disable --now clamav-daemon
systemctl restart amavis
apt remove clamav-base

# FreeBSD
sysrc -f /etc/rc.conf.local clamd=no
service restart amavisd
pkg remove clamav

# OpenBSD
rcctl disable clamd
rcctl restart amavisd
pkg_delete clamav
```

### Completely disable all features

If you want to completely disable spam and virus scanning services, steps:

* Comment out below two lines in Postfix config file `/etc/postfix/main.cf`:

```cfg
content_filter = smtp-amavis:[127.0.0.1]:10024
receive_override_options = no_address_mappings  # <- it's ok if you don't have this line
```

* Comment out below line in Postfix config file `/etc/postfix/master.cf`,

```cfg
  -o content_filter=smtp-amavis:[127.0.0.1]:10026
```

* Restarting Postfix service is required.
* Disable network services: Amavisd, ClamAV.

Notes:

* ClamAV and SpamAssassin will be invoked by Amavisd, so if you disable Amavisd, those two are disabled too.
* SpamAssassin doesn't have daemon service running in iRedMail solution, so there's no need to stop SpamAssassin service.

#### Update mailing list settings

mlmmj is configured to connect to port `10027` which is served by Amavisd for
spam/virus scanning, you should update config files to tell mlmmj not to
connect to this port anymore.

- Comment out below line in `/opt/mlmmjadmin/settings.py` and restart
  `mlmmjadmin` service.

    Note: it affects newly created mailing lists.

```
MLMMJ_DEFAULT_PROFILE_SETTINGS.update({'smtp_port': 10027})
```

- Remove all `control/smtpport` file under `/var/vmail/mlmmj/<domain>/<list-name>/`.
  For example, for mailing list `mygroup@domain.com`, the file is
  `/var/vmail/mlmmj/domain.com/mygroup/control/smtpport`.

    Note: it affects all existing mailing lists.
