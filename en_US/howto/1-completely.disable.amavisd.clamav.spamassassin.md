# Completely disable Amavisd + ClamAV + SpamAssassin

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

You may want to stop and disable ClamAV service too since it's not
called by Amavisd or other programs anymore:

    On CentOS, the systemd script for Amavisd service
    (`/lib/systemd/system/amavisd.service`) has line
    `Wants=clamd@amavisd.service`, this makes systemd to start `clamd@amavisd`
    service each time before starting `amavisd` service, so you have to comment
    out this line to disable clamav service.

```
# Debian/Ubuntu
systemctl disable --now clamav-daemon
systemctl restart amavis

# FreeBSD
sysrc -f /etc/rc.conf.local clamd=no
systemctl restart amavisd

# OpenBSD
rcctl disable clamd
rcctl restart amavisd
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
