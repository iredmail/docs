# Release Notes

[TOC]

## Upcoming release (Mar X, 2019)

* netdata:
    - Update to version 1.12.1.
    - Disable sending anonymous statistics to netdata cloud.

* Fail2ban:
    - Slightly loose filter for postfix to reduce unexpected ban caused by
      Outlook for macOS.

* Backup:
    + Backup OpenLDAP data with option `-o ldif-wrap=no`, to avoid break long
      line to multiple lines. The dumped LDIF file is easier to work with
      `grep` and other command line tools.

* Improvements of iRedMail Easy platform:
    + Always update major components (postfix/dovecot/sogo/fail2ban/...) to the
      latest stable release.
    + Always print command output of `nginx -t` for troubleshooting before
      restart nginx servvice, it's very useful for troubleshooting.
    + New option `Trusted clients` in mail server profile page, under tab
      `Settings`. You can list all trusted IP addresses or CIDR networks here,
      they will be whitelisted by few components:
        - Postfix: parameter `mynetworks` in `/etc/postfix/main.cf`
        - iRedAPD: parameter `MYNETWORKS` in `/opt/iredapd/settings.py`
        - Fail2ban: parameter `ignoreip` in `/etc/fail2ban/ignoreip.local`

* Fixed issues of iRedMail Easy platform:
    - Incorrect permission of directories used to store prosody custom modules
      and config files.

## Version: 2019021901 (Feb 19, 2019)

* Improvements:
    + Able to remove ssh public key on target server.
    + SSH keys which were generated 7 days ago will be removed automatically
      from iRedMail Easy platform.

* Fixed issues:
    - php-fpm: not reopen log file after rotation.
    - mlmmjadmin:
        - Incorrect LDAP base dn in config file.
        - Do not return error if mailing list directory doesn't exist.
    - Incorrect iRedAPD plugin name for OpenLDAP backend.
    - Few bugs with in Ansible deployment code.

* Package updates:
    + mlmmjadmin -> 2.1
    + iRedAdmin (open source edition) -> 0.9.5

## Version: 2019013001 (Jan 30, 2019)

* Set max open file limit by SOGo daemon to unlimited.
* Able to set memcached cache size (in MB).
* Able to disable spam/virus scanning.
* Able to deploy iRedAdmin-Pro with your license key.
* Able to custom http/https network ports, max file size of (web) upload file.
* Enable bayes auto-learn in SpamAssassin, and store bayes in SQL db.
* Increase scores of DNSBL relevant spamassassin rules to catch more spams.
* Enable imapsieve plugin in Dovecot by default.

    Message moved to Junk folder will be copied to a directory for spam
    learning later, vice verse, message moved out of Junk will be copied
    for ham learning later.

    The spam/ham learning will be performed every 10 minutes with a cron job.

    __Now encourage your users to report spams by moving spams to `Junk` folder. :)__

* Fixed issues:
    - Can not login to XMPP service (Prosody) due to incorrect permission of
      auth module files.
    - ip6tables failed to start on server which doesn't have IPv6 address.

* Updated packages:
    - mlmmjadmin-2.0
    - adminer-4.7.1

## Version: 2019010201 (Jan 2, 2019)

> Hello, 2019. :)

* Updated packages:
    - iRedAPD-2.4. Fixed a greylisting issue.
* Fixed issues:
    - Not correctly set owner and permission of custom Postfix config files
      and hash db files.
    - Not remove unused modular nginx config file for iredadmin.

## Version: 2018122301 (Dec 23, 2018)

* Fixed:
    - Improper dovecot ldap/sql queries which doesn't convert upper cases of
      maildir to lower cases.

## Version: 2018121701 (Dec 17, 2018)

!!! attention

    * This is the first public release. :)
    * The version number is the date when it's released, it's easier to
      understand whether you're running the latest stable release. It's also
      stored in file `/etc/iredmail-release` on your server.

* New directory `/opt/www/well-known`, mostly used for Let's Encrypt cert
  request.
* Download source tarball of web applications to iRedMail deploy server first,
  then upload it to target host. If target host can not access website like
  github.com, we can still download required packages for iRedMail deployment.
* Firewall:
    + Add rc script and firewall rule for ipv6 on Debian/Ubuntu:
        - `/etc/init.d/ip6tables`
        - `/etc/default/ip6tables`
* OpenLDAP backend:
    + Do not enable TLS/SSL support in OpenLDAP by default.
    + Add database `monitor` by default.
    + Include calresource.schema and calentry.schema by default. Required
      by SOGo for resource management.
    + Index attribute `departmentNumber`.
* Fail2ban:
    - Remove duplicate filter rules for Postfix postscreen service.
* SOGo:
    + Add new parameters to support resource management.
    + Add mail aliases and mailing lists as address book.
    + Fix incorrect column name in SQL views.
* netdata:
    + Supports monitoring OpenLDAP.
* Fixed:
    - Ubuntu: Missing apparmor rule to allow ClamAV to scan emails.
    - not enable php-fpm status support in Nginx and netdata.
    - not load rsyslog module `imjournal` for rate limit control.
* Package update:
    - netdata -> 1.11.1
    - adminer -> 4.7.0
