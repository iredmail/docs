# Release Notes

[TOC]

## Upcoming: 201907XX (Jul XX, 2019)

* OpenDMARC integration.

    - The integration is enabled by default. To disable it, please go to
      mail server profile page, toggle on option `Disable DMARC` under
      `Settings` tab.
    - Unfortunately, OpenBSD 6.5 and earlier releases don't have such
      integration due to binary package missing. The good news is the latest
      ports tree already has it and binary package is available for OpenBSD
      -snapshot branch.

* Fixed issues of iRedMail Easy platform:
    - Make sure installed services are running while cleaning up the deployment.
    - Removing unused ClamAV log file (/var/log/clamav/clamav.log) causes
      error in cron job added by ClamAV package.

* Package updates:
    - iRedAPD 3.0. It fixes a critical bug of throttle plugin.
    - iRedAdmin-Pro. Note: it requires a valid iRedAdmin-Pro license.

## Version: 20190606 (Jun 06, 2019)

* Fail2ban:
    - Remove jail 'sshd-ddos'. Fail2ban doesn't ship its filter conf anymore.

* Dovecot:
    - Set default client_limit and process_limit based on memory size.

* autoconfig:
    - Fixed: not handle URI `/.well-known/autoconfig/mail/config-v1.1.xml`.

* Improvements of iRedMail Easy platform:
    - Able to ban/unban given file types.
    - Remove deprecated ClamAV parameters.
    - Remove unused ClamAV log file (/var/log/clamav/clamav.log).
    - Able to disable HELO hostname DNS check.
    - Fixed: not always restart iRedAdmin service to reload the code of new version.

* Package updates:
    - iRedAPD 2.9. It fixes 2 bugs.
    - netdata 1.15.0

## Version: 2019042801 (Apr 28, 2019)

* Postfix:
    - Enable header/body checks for email injected by Amavisd.
    - Fixed: not load custom `header_checks` and `body_checks` pcre maps.
    - Fixed: port 1025/10025/10028 are not listening on only 127.0.0.1.
    - Fixed: per-user bcc doesn't work with MySQL/MariaDB backends.

* SOGo:
    - [PostgreSQL backend] Fix incorrect owner of SQL VIEWs used for address
      books.
    - [SQL backends] Fix incorrect SQL VIEWs which causes error to display
      contacts in address books.
    - [SQL backends] Display all contacts directly in per-domain address book.

* Package updates:
    - iRedAPD 2.8
    - iRedAdmin 0.9.7 (open source edition)
    - netdata 1.14.0

* Improvements of iRedMail Easy platform:
    + Supports OpenBSD 6.5.

        WARNING: OpenBSD 6.4 support will be removed when OpenBSD 6.6 is out.
        That means you must upgrade OpenBSD 6.4 to 6.5 before 6.6 is out.

    + Fixed: not enable php ldap extension for Roundcube for OpenLDAP backend.
    + Do not always update SOGo packages.
      We're using SOGo nightly build, it's not always stable, upgrading may
      cause issue.
    + Send `iRedMail.tips` file to postmaster after deployment.

## Version: 2019040201 (Apr 02, 2019)

* Roundcube
    - Upgrade to 1.3.9 ([Detailed ChangeLog](https://github.com/roundcube/roundcubemail/releases/tag/1.3.9).)

* Dovecot:
    - Able to track user last (POP3/IMAP) login for OpenLDAP and MariaDB
      backends. It's disabled by default, you can enable it in iRedMail Easy
      user portal, in mail server profile page, tab "Settings".

          Note: Dovecot doesn't support this with PostgreSQL yet.

          Here's detailed tutorial to show you what changes are applied to Dovecot:
          [Track user last login time](https://docs.iredmail.org/track.user.last.login.html).

* Improvements of iRedMail Easy platform:
    + Send `iRedMail.tips` file to postmaster after deployment.

## Version: 2019032701 (Mar 27, 2019)

* Dovecot:
    - Improve `imapsieve` setting to handle different IMAP command sent by
      Microsoft Outlook (it sometimes uses `APPEND` instead of `COPY` for
      moving message to another folder).

* iRedAPD:
    - Update to version 2.7, with SRS (Sender Rewriting Scheme) support.

        Note: SRS is disabled by default, you can enable it in mail server
        profile page with the iRedMail Easy web UI.

    - Switch logging to syslog (and logrotate).

* iRedAdmin:
    - Update to 0.9.6.

* BIND (local cache-only DNS server):
    - Set syslog facility to 'local5'.

* netdata:
    - Update to version 1.13.0.
    - Switch logging to syslog (and logrotate).
    - Disable sending anonymous statistics to netdata cloud.

* SpamAssassin:
    - Add one custom rule to catch porn spams.
    - Fixed: not create required SQL tables for bayes.

* AutoConfig/AutoDiscover
    - Domain name `autoconfig.<domain>` and `autodiscover.<domain>` are not
      required if the web domain is hosted on iRedMail server, Outlook will
      look for `https://<web-domain>/autodiscover/autodiscover.xml`.

* Fail2ban:
    - Slightly loose filter for postfix to reduce unexpected ban caused by
      Outlook for macOS.

* SOGo:
    - Enable per-domain global address book for OpenLDAP backend by default.
      We sponsored SOGo team to implement this feature:
      https://sogo.nu/bugs/view.php?id=3685
      Note: it requires SOGo nightly build version '4.0.7.20190318' or later,
      OpenBSD 6.4 doesn't support this feature due to old SOGo package.
    - Enable builtin IMAP4 pooling by default. User should notice faster IMAP
      operations.

* Backup:
    + Backup OpenLDAP data with option `-o ldif-wrap=no`, to avoid break long
      line to multiple lines. The dumped LDIF file is easier to work with
      `grep` and other command line tools.

* Improvements of iRedMail Easy platform:
    + Make sure OpenLDAP service is running before populating data.
    + Make Nginx/Dovecot/Postfix not listen on address `::1` if system doesn't
      have IPv6 support.
    + Slightly reduce Amavisd max_servers to same as RAM (GB) for better
      stability.
    + Always check and make sure major components are the latest versions.
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
