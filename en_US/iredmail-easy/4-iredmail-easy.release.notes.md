# iRedMail Easy: Release Notes

[TOC]

## Version: 2020021001 (Feb 10, 2020) {: id=20200210 }

* PostgreSQL backend:
    - Fixed: improper index type on SQL table `sender_relayhost`.

* Postfix:
    - Fixed: Backup MX doesn't work.
    - Fixed: [LDAP backend] improper filter which causes missing external
      members while querying (not-subscribeable) mailing list with alias domain.
    - Add 3 files for custom settings:
        - `/opt/iredmail/custom/postfix/aliases`: alias file.
        - `/opt/iredmail/custom/postfix/sender_bcc`: hash file.
        - `/opt/iredmail/custom/postfix/recipient_bcc`: hash file.

* Roundcube:
    - Enable plugin `markasjunk` by default. When message is moved to Junk
      folder, it will be learnt as spam message. When message is moved from
      Junk to any other folder, it will be learnt as clean message.

* Antispam:
    - Explicitly specify (DKIM) signed header fields.
    - Use default Amavisd verbose log template.
    - Add few more custom scores in SpamAssassin to catch spams when `From:`
      equals to `To:` address.
    - Fixed:
        - Don't block attachment with macro in ClamAV.
          Parameter `OLE2BlockMacros` was set to `true`, it's now `false`.
        - Not update apparmor config file to grant privilege for virus scanning
          on Debian 10.

* Nginx:
    - Fixed: make sure log directory is not writable by group or other,
      otherwise logrotate will refuse to rotate log files.

* Firewalll:
    - Correctly disable ping flood with nftables on Debian 10.

* Netdata:
    - Disable checks for energid. It uses port 9998, but it's used by
      Amavisd-new on iRedMail server, this causes error message in
      Amavisd log file each time netdata starts.

* Backup scripts:
    - Backup scripts don't rely on Python to calculate dates anymore.

* Improvements of iRedMail Easy platform:
    - Fixed: Updating MariaDB/PostgreSQL/OpenLDAP/SOGo separatedly didn't
      update their backup scripts.
    - New options for cross-domain user query and global address book in
      SOGo Groupware.
    - Increase php-fpm setting `request_slowlog_timeout` to 60 seconds.
    - Updated Postfix package in iRedMail yum repo for PostgreSQL backend on
      CentOS 7.
    - On OpenBSD system, update the latest errata patch names.

* Package updates:
    - Roundcube-1.4.2
    - iRedAdmin-1.0
    - iRedAPD-3.4
    - adminer-4.7.6

## Version: 2019121301 (Dec 13, 2019) {: id=20191210 }

- Package updates:
    - iRedAdmin-Pro (SQL edition)

## Version: 2019121001 (Dec 10, 2019) {: id=20191210 }

* Fixed issues:
    - Incorrect setting in netdata main config file (netdata.conf).
    - Not remove opendmarc package, config files, SQL db and cron jobs.

## Version: 2019120901 (Dec 09, 2019) {: id=20191209 }

* Firewall:
    - On Debian 10, allow ping in nftables firewall.

* iRedAdmin:
    - Fixed: incorrect syslog id in uwsgi config file.
    - Simplify log format.

- mlmmjadmin:
    - Simplify log format.

- netdata:
    - Replace few Python collectors by Go modules for better performance.
    - Monitor BIND DNS service.
    - Disable email notification since netdata is too sensitive and the
      notification message is "useless".

- Package updates:
    - Roundcube webmail 1.4.1. It offers a shiny new web UI.
    - netdata-1.19.0
    - iRedAPD-3.3
    - iRedAdmin-0.9.9
    - adminer-4.7.5

- Improvements of iRedMail Easy platform:
    - On OpenBSD system, if latest security errata hasn't been applied,
      iRedMail deployment will abort with detailed warning message to remind
      sysadmin to apply the patches with `syspatch` command.

## Version: 2019111201 (Nov 12, 2019) {: id=20191112 class="old_release" }

* iRedMail Easy now supports OpenBSD 6.6.

    Warning: OpenBSD 6.4 and 6.5 support will be dropped when 6.7 is out.

* Dovecot:
    - Create and use custom (empty) global sieve rule file by default.
    - Log more events: save, copy, mailbox_create.

* Netdata:
    - Fixed: incorrect hostname in alarm notification email.

* OpenLDAP:
    - Create directory `/opt/iredmail/custom/openldap/schema/` to store extra
      LDAP schema files.

      Apparmor config file has been updated on Ubuntu to allow `slapd` program
      to read config files from this directory.

    - Use `mdb` database since OpenBSD 6.6. OpenBSD 6.5 uses `hdb`.

* Postfix:
    - Bypass facebook.com HELO hostnames which contain IP addresses.

* Roundcube:
    - Upgrade to version 1.4.0, released on Nov 10, 2019.

* Changes to iRedMail Easy platform:
    - Fix aborted installation if Ansible fact `ansible_all_ipv6_addresses` is
      undefined.
    - Upgrade pip to the latest version before installing web.py on Debian 10.

## Version: 2019102201 (Oct 22, 2019) {: id=20191022 class="old_release" }

* OpenLDAP:
    - Remove 2 unused LDAP schema files: `calentry.schema`, `calresource.schema`.

* Postfix:
    - Fixed incorrect CA file on OpenBSD.
    - Add `LIMIT 1` in SQL queries for better performance.

* Dovecot:
    - Log ssl protocol and cipher information for login session.
      e.g. "TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits)"

* Firewall:
    - Fixed: not filter IPv4/IPv6 addresses while generating iptables rules.
    - Fixed: not enable ipv6-icmp in firewall.

* Nginx:
    - Make sure Apache/Lighttpd service is not enabled, otherwise Nginx may
      not be able to start due to 80/443 ports are used by them.

* AntiSpam:
    - OpenDMARC has been removed due to internal bug which caused incorrect
      email rejection. Bug reported to upstream:
      https://github.com/trusteddomainproject/OpenDMARC/issues/50

* autodiscover:
    - Fixed the `Undefined offset` php error.
    - Log the schema data sent by remote MUA, also the settings sent to MUA.
    - Log file is now `/var/log/autoconfig/autoconfig.log`.

* netdata:
    - If component `Nginx` was not chosen, netdata is inaccessible although
      Nginx is actually deployed as dependent component.
    - Move http auth file to `/opt/iredmail/custom/netdata/`.

        Since netdata-1.17.0, netdata sets permission of directory
        `/opt/netdata/etc/netdata/` to 0700, this causes Nginx can not read
        the http auth file.

* Backup scripts:
    - It now removes old empty backup directories.

* Changes to iRedMail Easy platform:
    - Not add `priority` parameter in iRedMail yum repo. (CentOS 7 only)
    - Able to whitelist IP or CIDR newtorks in fail2ban.
    - Do not forward systemd journald log to syslog.
    - Run shell script `/opt/iredmail/custom/openldap/custom.sh` while
      deploying or upgrading OpenLDAP. You can write shell commands in this
      file to update other config files for advanced customization. for
      example, updating `/etc/sysconfig/slapd` (CentOS) or
      `/etc/ldap/slapd` (Debian/Ubuntu) to make OpenLDAP listening on all
      available network interfaces and IP addresses.
    - Add Fail2ban related info in `/root/iRedMail/iRedMail.tips`.
    - Make sure no SysV script and rule files for 'iptables' service on
      Debian 10.

* Package updates:
    - netdata -> 1.18.1
    - iredapd -> 3.2

## Version: 2019090601 (Sep 06, 2019) {: id=20190906 class="old_release" }

* Postfix:
    - Sign DKIM signature for locally generated emails, like auto-reply (a.k.a
      vacation) message.

* Nginx:
    - Redirect URI `/adminer/` to `/adminer`.

* Dovecot:
    - Add setting `sieve_redirect_envelope_from=recipient`. It's used to
      rewrite sender address in redirected message (with sieve directive
      `redirect`) to the final recipient address of the message.

          For example, `someone@gmail.com` sends an email to `user@domain.com`
          which is hosted on your server, and this user has sieve rule to
          redirect received message to `forward@3rd-domain.com`, with default
          Dovecot setting (`sieve_redirect_envelope_from=sender`), user
          `forward@3rd-domain.com` will receive this email with sender address
          `someone@gmail.com` in mail header, but with
          `sieve_redirect_envelope_from=recipient`, the sender address will
          be `user@domain.com`.

    - Log `delivery_time` of LDA/LMTP.

* php-fpm:
    - Set value of `post_max_size` 1MB larger than `upload_max_filesize`, so
      that Roundcube can successfully upload mail attachment.

* OpenDMARC:
    - Add shell script and cron job to update `public_suffix_list.dat` every
      2 days.

* SpamAssassin:
    - Set 3 custom scores in SpamAssassin to catch more spams.
        - `score SPF_FAIL 5`: sender does not match SPF record (fail)
        - `score TO_EQ_FM_SPF_FAIL 5`: To == From and external SPF failed
        - `score TO_EQ_FM_DOM_SPF_FAIL 5`: To domain == From domain and external SPF failed

* ClamAV:
    - Increase systemd timeout value to avoid startup failure on low memory
      server.

* Fixed issues:
    - Improper postrotate command for logrotate program on Linux.

* Package updates:
    - roundcube -> 1.3.10
    - adminer -> 4.7.3
    - iRedAPD -> 3.1
    - netdata -> 1.17.0
    - iRedAdmin -> 0.9.8

* Changes to iRedMail Easy platform:
    - Firewall rule always opens port 22 for ssh.
    - Add `curl` as required packages.
    - Use package branch (`%7.3`) instead of version number for php on OpenBSD.

## Version: 2019080201 (Aug 02, 2019) {: id=20190802 class="old_release" }

* Dovecot:
    - Fixed: not add required SQL column `mailbox.enablequota-status`. This
      will cause mail rejection.

* Firewall:
    - Run `/opt/iredmail/custom/firewall/custom.sh` after each deployment.


## Version: 2019080101 (Aug 01, 2019) {: id=20190801 class="old_release" }

* It now supports Debian 10.
* Dovecot:
    - Enable quota-status service used to query mailbox quota.
    - Fixed: Not install package `dovecot-mysql` for OpenLDAP backend on CentOS.

* Postfix:
    - Lookup user's mailbox quota status from Dovecot quota-status service,
      reject email if mailbox is over quota. This will help save system
      resources used for spam/virus scanning, avoids "sender non-delivery
      notification" bounce message.
    - Fixed: not copy `/etc/resolv.conf` to `/var/spool/postfix/etc/`.

* Nginx:
    - Fixed: improper order while loading modular config files.
    - __ATTENTION__: directive `ssl on;` has been removed (in
      `/etc/nginx/templates/ssl.tmpl`) due to it's deprecated by Nginx itself.
      If you have custom web host, please use `listen <port> ssl;` in the
      `server {}` block (in `/etc/nginx/sites-enabled/*.conf`) instead.

        For example:

        * Old config file `/etc/nginx/sites-enabled/00-default-ssl.conf`:

            ```
            server {
                listen 443;
                ...
            }
            ```

        * New directive:

            ```
            server {
                listen 443 ssl;
                ...
            }
            ```

* Firewall:
    - Port 465 (SMTP over SSL) is not open in firewall when the service is
      enabled.

* Package updates:
    - adminer -> 4.7.2

## Version: 2019071501 (Jul 15, 2019) {: id=20190715 class="old_release" }

* OpenDMARC integration.

    - The integration is enabled by default. To disable it, please go to
      mail server profile page, toggle on option `Disable DMARC` under
      `Settings` tab.
    - Unfortunately, OpenBSD 6.5 and earlier releases don't have such
      integration due to binary package missing. The good news is the latest
      ports tree already has it and binary package is available for OpenBSD
      -snapshot branch.

* Roundcube:
    - New config files used to store custom settings for official plugins:
        - `password` plugin: `/opt/iredmail/custom/roundcube/config_password.inc.php`
        - `managesieve` plugin: `/opt/iredmail/custom/roundcube/config_managesieve.inc.php`

* Postfix:
    - Fixed: improper order of restriction rules in `smtpd_sender_restrictions`.

        File `/etc/postfix/sender_access.pcre` is not used anymore, all content
        in this file should be moved to
        `/opt/iredmail/custom/postfix/sender_access.pcre` instead.

* Nginx:
    - Compress more file types with gzip module (`/etc/nginx/conf-available/gzip.conf`).

* Few programs moved and/or renamed:
    - `/opt/iredmail/bin/fail2ban_unbanip` -> `/opt/iredmail/bin/fail2ban/unbanip`.
    - `/opt/iredmail/bin/generate_password_hash.py` -> `/opt/iredmail/bin/generate_password_hash`.
    - `/opt/iredmail/bin/dovecot/scan_reported_mails.sh` -> `/opt/iredmail/bin/dovecot/scan_reported_mails`

* Fixed issues of iRedMail Easy platform:
    - If IPv6 is disabled, installation will be abort due to Nginx is
      configured (by Debian/Ubuntu packaging) to listen on IPv6 address.
    - If no PHP applications are going to be installed, no php-fpm related
      configuration should be enabled (`/etc/nginx/templates/misc.tmpl`).
    - Make sure installed services are running while cleaning up the deployment.
    - Not run `freshclam` immediately to fetch/update ClamAV virus database.
    - Removing unused ClamAV log file (/var/log/clamav/clamav.log) causes
      error in cron job added by ClamAV package.

* Package updates:
    - iRedAPD 3.0. It fixes a critical bug of throttle plugin.
    - iRedAdmin-Pro. Note: it requires a valid iRedAdmin-Pro license.

## Version: 2019060601 (Jun 06, 2019) {: id=20190606 class="old_release" }

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

## Version: 2019042801 (Apr 28, 2019) {: id=20190428 class="old_release" }

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

## Version: 2019040201 (Apr 02, 2019) {: id=20190402 class="old_release" }

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

## Version: 2019032701 (Mar 27, 2019) {: id=20190327 class="old_release" }

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

## Version: 2019021901 (Feb 19, 2019) {: id=20190219 class="old_release" }

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

## Version: 2019013001 (Jan 30, 2019) {: id=20190130 class="old_release" }

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

## Version: 2019010201 (Jan 2, 2019) {: id=20190102 class="old_release" }

> Hello, 2019. :)

* Updated packages:
    - iRedAPD-2.4. Fixed a greylisting issue.
* Fixed issues:
    - Not correctly set owner and permission of custom Postfix config files
      and hash db files.
    - Not remove unused modular nginx config file for iredadmin.

## Version: 2018122301 (Dec 23, 2018) {: id=20181223 class="old_release" }

* Fixed:
    - Improper dovecot ldap/sql queries which doesn't convert upper cases of
      maildir to lower cases.

## Version: 2018121701 (Dec 17, 2018) {: id=20181217 class="old_release" }

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
