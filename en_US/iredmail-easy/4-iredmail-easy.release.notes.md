# iRedMail Easy: Release Notes

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

## Version: 2024071701 (Jul 17, 2024) {: id=2024071701 }

* Ubuntu 24.04 LTS is now supported.
* Improvements:
    - SOGo is now available on Debian 12 (bookworm).
    - Use systemd-timesyncd as ntp client on Ubuntu 24.04.
    - Fail2ban now stores enabled/started jail names in SQL table `jails`.

* Fixed:
    - [SOGo] Cannot view mailing lists and aliases in address book.
    - Since Spamhaus blocks queries from public/open DNS servers, we don't use
      Google DNS servers as default upstream from now on.

* Updated packages:
    - netdata v1.46.2
    - iRedAPD 5.6.0
    - iRedAdmin 2.6. It addresses 2 possible XSS vulnerabilities.
    - fail2ban 1.1.0 (OpenBSD only)

## Version: 2024052101 (May 21, 2024) {: id=2024052101 }

* Updated packages:
    - Roundcube 1.6.7 and 1.5.7, both contain fixes for 3 security vulnerabilities.
      FYI <https://roundcube.net/news/2024/05/19/security-updates-1.6.7-and-1.5.7>

## Version: 2024050801 (May 8, 2024) {: id=2024050801 }

* Improvements:
    - Disable multi-threaded database reload in ClamAV (with
      parameter "ConcurrentDatabaseReload no").

* Updated packages:
    - iRedAPD 5.5.0
    - mlmmjadmin 3.2.1
    - netdata 1.45.4

## Version: 2024030401 (March 4, 2024) {: id=2024030401 }

* Improvements:
    - Add new parameter `OCSAdminURL` in sogo.conf for the new SQL table
      `sogo_admin` introduced in SOGo v5.10.0.

* Fixed issues:
    - Tune FTS xapian to reduce the size of index data.
    - Not set correct compatibility_level for Postfix. #233
    - Not prevent invalid address rewritten in `From:` header in custom
      Postfix transports.

## Version: 2023122901 (Dec 29, 2023) {: id=2023122901 }

* Fixed issues:
    - Postfix:
        - Mitigate SMTP smuggling attack.
          Details: https://www.postfix.org/smtp-smuggling.html
        - [LDAP Backend] Can not use (mlmmj) mailing list as member of another
          mailing list.
    - CentOS: mlmmjadmin: Incorrect config on CentOS / Rocky / Alma 9.
    - CentOS: Not enable daily cron job to update SpamAssassin rules.
      Thanks to forum user `roccoro` for the report.

* Updated packages:
    - mlmmjadmin 3.1.9
    - netdata 1.44.1

## Version: 2023102301 (Oct 23, 2023) {: id=2023102301 }

* Updated packages:
    - netdata 1.43.1
    - __SECURITY UPDATE__: Roundcube [v1.6.5 and 1.5.6](https://roundcube.net/news/2023/11/05/security-updates-1.6.5-and-1.5.6). Both fix a new cross-site scripting (XSS) vulnerability.

        > NOTES:
        >
        > - __Ubuntu 18.04__ gets Roundcube v1.5.6 instead of v1.6.5 due to old
        >   php version, v1.5.6 contains the security fix too. Anyway, please
        >   consider upgrade OS to at least 20.04 LTS as soon as possible.
        > - __CentOS / Rocky 7__ gets Roundcube v1.5.2 due to old php version, this
        >   version does __NOT contain the security fix__ which is fixed in
        >   v1.5.4, v1.5.5, v1.5.6, or v1.6.3, v1.6.4, v1.6.5. Please upgrade
        >   OS to at least CentOS Stream 8 / Rocky 8 and switch php to v8
        >   immediately by following [this tutorial](./upgrade.php.v8.0.on.centos.8.html).

## Version: 2023102301 (Oct 23, 2023) {: id=2023102301 }

- Fail2ban: Do not ban client which triggers `lost connection after UNKNOWN` error.

* Updated packages:
    - netdata 1.43.0
    - __SECURITY UPDATE__: Roundcube [v1.6.4](https://roundcube.net/news/2023/10/16/security-update-1.6.4-released) and [1.5.5](https://roundcube.net/news/2023/10/16/security-updates-1.5.5-and-1.4.15). Both fix a new cross-site scripting (XSS) vulnerability.

        > NOTES:
        >
        > - __Ubuntu 18.04__ gets Roundcube v1.5.5 instead of v1.6.4 due to old
        >   php version, v1.5.5 contains the security fix too. Anyway, please
        >   consider upgrade OS to at least 20.04 LTS as soon as possible.
        > - __CentOS / Rocky 7__ gets Roundcube v1.5.2 due to old php version, this
        >   version does __NOT contain the security fix__ which is fixed in
        >   v1.5.4, v1.5.5, v1.6.3, v1.6.4. Please upgrade OS to at least
        >   CentOS / Rocky 8 and switch php to v8 immediately by following
        >   [this tutorial](./upgrade.php.v8.0.on.centos.8.html).

## Version: 2023092001 (Sep 20, 2023) {: id=2023092001 }

* Fixed issues:
    - Not switch to nftables on Ubuntu 22.04.

        > Note: If you have custom firewall rules in
        > `/opt/iredmail/custom/firewall/custom.sh` with `iptables` command,
        > you must switch to nftables manually.

    - Not disable cron job used to clean up Amavisd SQL db when Amavisd is not
      enabled.
    - Duplicate firewall entry in `/opt/iredmail/bin/apply_all_custom_settings`.
    - Not disable `spamd` service on Debian/Ubuntu.
    - Not enable php function `proc_get_status` required by Roundcube plugin `enigma`.

* Updated packages:
    - iRedAdmin 2.5.
    - netdata 1.42.4
    - __SECURITY UPDATE__: roundcube [v1.6.3](https://roundcube.net/news/2023/09/15/security-update-1.6.3-released) and [1.5.4](https://roundcube.net/news/2023/09/18/security-update-1.5.4-released). Both fix the cross-site scripting (XSS) vulnerability.

        > NOTES:
        >
        > - __Ubuntu 18.04__ gets Roundcube v1.5.4 instead of v1.6.3 due to old
        >   php version, v1.5.4 contains the security fix too. Anyway, please
        >   consider upgrade OS to 20.04 LTS as soon as possible.
        > - __CentOS / Rocky 7__ gets Roundcube v1.5.2 due to old php version, this
        >   version does __NOT contain the security fix__ which is fixed in v1.5.4 and
        >   v1.6.3, please upgrade OS to at least CentOS / Rocky 8 and switch
        >   php to v8 immediately by following
        >   [this tutorial](./upgrade.php.v8.0.on.centos.8.html).

## Version: 2023072801 (Jul 28, 2023) {: id=2023072801 }

* Supports new distribution releases:
    * Debian 12 (Bookworm). Notes:
        - Both Debian 11 and 12 are supported, but 12 is now recommended.
        - SOGo Groupware is not yet available on Debian 12 because SOGo
          team does not offer binary packages for Debian 12 yet
* Switch php to 8.0 on CentOS Stream 8, Rocky 8, AlmaLinux 8.
      Note: php v8 is offered by official yum repository of Linux vendors, no
      third-party yum repo introduced.
* SOGo Groupware is now available on CentOS Stream 9, Rocky Linux 9, AlmaLinux
  9. Thanks to SOGo team.
* Disable IDN support in Postfix (`smtputf8_enable = no`).
* Fixed issues:
    - PostgreSQL backend: Incorrect database owner of "iredadmin" database.
* Updated packages:
    - Roundcube webmail 1.6.2
    - netdata 1.41.0
    - iRedAPD 5.3.3

## Version: 2023052301 (May 23, 2023) {: id=2023052301 }

* Supports new distribution releases:
    + OpenBSD 7.3

* Improvements:
    + SOGo Groupware is now available on Ubuntu 22.04 LTS. Thanks to SOGo team.
    + Disable TLSv1 and TLSv1.1 in Postfix.
    + Full-text search is now available on Debian 11 (bullseye).
    + New fail2ban jail: nginx-403. It scans Nginx error log and bans clients
      which triggered error "access forbidden by rule".

* Fixed issues:
    - Amavisd is not listening on only 127.0.0.1.
    - Use Roundcube 1.5.3 on CentOS Stream / Rocky / Alma 8.
    - [CentOS] Not rotate system log files (missing package `rsyslog-rotate`).
    - [CentOS] Can not run chronyd on CentoS 9.
    - [Debian/Ubuntu] ClamAV log files may be changed to incorrect owner after
      log rotation.
    - [Firewall] Not open TCP port 5281 in firewall for XMPP file transfer.
    - [Nginx] Not remove config file for autoconfig if it's not enabled.
    - [Nginx] Exactly match URI prefix `/SOGo/`. This avoid accessing to URI
      with `/SOGo` prefix like `/SOGotesting`.
    - [Nginx] Not remove config snippet files for php web application when
      php is not enabled.
    - [Nginx] Not support WebSocket in http header Content-Security-Policy.

* Updated packages:
    + mlmmjadmin 3.1.7
    + netdata 1.39.1
    + iRedAPD 5.3
    + iRedAdmin 2.3
    + Roundcube 1.6.1. Note: CentOS 7 stays with Roundcube 1.5.3 due to old php packages.

## Version: 2022121901 (Dec 19, 2022) {: id=2022121901 }

* Supports new distribution releases:
    + CentOS Stream 9
    + Rocky Linux 9
    + AlmaLinux 9
    + OpenBSD 7.2

* Improvements:
    - Dovecot: Do not enable quota-status service if mailboxes are stored in
      NFS storage.

* Fixed issues:
    - [SpamAssassin] Use default score of rule `URIBL_BLACK`.
    - Can not enable Bind DNS server on Ubuntu 22.04.
    - [CentOS] Missing cyrus-sasl packages which causes Postfix doesn't
      support PLAIN auth.
    - [SOGo] Disable SOGo on Ubuntu 22.04 (no binary packages from upstream).
    - [Roundcube] Enables separate management interface for mail forwardings.
    - [Roundcube] Incorrect DES key length (was 32 characters, now 24).

* Updated packages:
    - iRedAdmin 2.1
    - iRedAPD 5.1.2
    - Fail2ban 1.0.2 (OpenBSD)
    - netdata 1.37.1

## Version: 2022082201 (Aug 22, 2022) {: id=2022082201 }

* Improvements:
    - [Postfix] Bypass more facebook mail server HELOs.
      Thanks `damiandabrowski5`@GitHub for the contribution.
    - Tune SpamAssassin rules to catch more spams from free email providers.
    - Nginx: Increase `uwsgi_read_timeout` to 900 seconds for iRedAdmin-Pro,
      so that exporting massive accounts can finish in time not cause the
      famous '504 gateway timeout' error. Tested with 50000 mail accounts.

* Fixed issues:
    - Duplicate line in Postfix helo_access.pcre file.
    - Default uwsgi buffer size (4096) for iRedAdmin may be too small if
      iRedAdmin is running behind a proxy server. Increased to 8192 now.
      Thanks Marcel for the feedback.
    - Not remove logrotate config file for old php version. This may cause
      logrotate fail to rotate log files.
    - Fix bind9 service name on Ubuntu 20.04: bind9 -> named.
    - SOGo: Use new official yum/apt repository and GPG key.

* Updated packages:
    - Roundcube webmail 1.5.3. Notes:

        - 1.6.0 doesn't work very well with PHP-8, mostly compatibility
          warnings, to avoid confusion for sysadmins, we decided to postpone it.
        - CentOS 7 ships PHP 5.4 but not supported by Roundcube 1.5.3, so we
          it has to stick to Roundcube 1.5.2.

    - mlmmjadmin 3.1.5
    - netdata 1.36.1
    - iRedAPD 5.1
    - iRedAdmin 1.8

## Version: 2022052001 (May 20, 2022) {: id=2022052001 }

* Supports new distribution releases:
    + Ubuntu 22.04 LTS

* Improvements:
    - [Fail2ban] Shorten jail name to avoid nftables failure:
      postfix-pregreet -> pregreet.
    - [CentOS/Rocky 8] Install uwsgi from official yum repo instead of pip.
    - [Rocky Linux 8] Build dovecot-fts-xapian for Rocky for full-text search
      in IMAP mailbox.
    - [SOGo] PostgreSQL backend: Allow end users to change their own passwords.

* Fixed issues:
    - [Postfix] Incorrect permission on /opt/iredmail/custom/postfix/main.cf
      and master.cf.
      Thanks Marcin Wisniowski for the report.

* Updated packages:
    - iRedAdmin 1.7
    - netdata 1.34.1
    - SOGo 5.6.0
    - mlmmjadmin 3.1.4

## Version: 2022031601 (March 16, 2022) {: id=2022031601 }

* Fixed issues:
    - Can not login to SOGo webmail due to small (Nginx) proxy buffer size.
      Thanks to Sysadminfromhell for the report in https://forum.iredmail.org/.
    - Set correct owner and permission for all existing DKIM keys instead of
      the newly generated one. This is helpful for migrated iRedMail server.
    - [Debian, Ubuntu] Change clamav socket path to `/var/run/clamav/clamd.ctl`.
      Amavisd on some system may fail to connect to `/tmp/clamd.socket`.
    - Make sure clamscan is NOT called when clamav socket is gone.
      clamscan uses too much CPU/Memory resource and may cause system hangs.

* Updated packages:
    - netdata 1.33.1

## Version: 2021123101 (Dec 31, 2021) {: id=2021123101 }

* Package updates:
    + Roundcube webmail 1.5.2. It addresses one XSS security vulnerability,
      also fixes few minor issues.

## Version: 2021122701 (Dec 27, 2021) {: id=2021122701 }

* Supports new distribution release:
    + OpenBSD 7.0

* Dovecot:
    - Enable new ssl cipher `EECDH+CHACHA20` and remove weak `AES256+EDH`.

* Fail2ban:
    - Add one more rule to catch auth error in Postfix log file.

* Nginx:
    - Greatly improve the performance of keep-alive connections over SSL by
      enabling `ssl_session_cache` parameter. See iredmail/iRedMail#136.
    - Enable TLSv1.3 by default (except Debian 9). See iredmail/iRedMail#137.
    - Enable new ssl cipher: EECDH+CHACHA20. See iredmail/iRedMail#138.
    - Remove weak ssl cipher: AES256+EDH. See iredmail/iRedMail#138.

* SOGo:
    - Able to disable ActiveSync completely (by disabling URI
      `/Microsoft-Server-ActiveSync` in Nginx).
    - [SQL Backends] Allow cross-domain global address book.
    - Now available on Debian 11 (bullseye). Thanks to SOGo team.

* Fixed issues:
    - If php application was enabled but removed later, Nginx can not start
      due to not remove php related config files.

* Package updates:
    + Roundcube webmail 1.5.1
    + mlmmjadmin 3.1.3
    + netdata 1.32.1
    + iRedAPD 5.0.4
    + [OpenBSD] fail2ban 0.11.2

## Version: 2021091301 (Sep 13, 2021) {: id=2021091301 }

- Remove unused LDAP attributes: lastLoginDate, lastLoginIP, lastLoginProtocol.
- Remove unused sql columns in `vmail.mailbox`:
    - lastlogindate
    - lastloginipv4
    - lastloginprotocol

- Fix improper SQL column types in `vmail` and `sogo` databases:
    - mailbox.enablesogowebmail
    - mailbox.enablesogocalendar
    - mailbox.enablesogoactivesync

## Version: 2021090801 (Sep 8, 2021) {: id=2021090801 }

+ Debian Linux 11 (Bullseye) is now supported.
- Debian 9 will be dropped in 3 months.
* SOGo:
    + Able to enable or disable per-user SOGo webmail, calendar and activesync
      services.

* Amavisd:
    + Add some useful ban rules. You can assign them in per-user,
      per-domain or global spam policy page with iRedAdmin-Pro.
        + ALLOW_MS_OFFICE: Allow all Microsoft Office documents.
        + ALLOW_MS_WORD: Allow Microsoft Word documents (.doc, .docx).
        + ALLOW_MS_EXCEL: Allow Microsoft Excel documents (.xls, .xlsx).
        + ALLOW_MS_PPT: Allow Microsoft PowerPoint documents (.ppt, .pptx).

* php-fpm:
    - Log slow process if doesn't finish in 20 seconds.

* Fixed issues:
    - Security vulnerability: It generates same random passwords for different
      hosts in some cases.
    - Minor issue while setting up MariaDB on CentOS 8.

* Package updates:
    - iRedAdmin-1.5
    - iRedAPD-5.0.3

## Version: 2021062401 (Jun 24, 2021) {: id=2021062401 }

+ Rocky Linux 8 is now supported.
+ OpenBSD 6.9 is now supported, 6.5, 6.6, 6.7, 6.8 are all dropped.
* Dovecot:
    - Optional setting to enable FTS (full-text search) integration.
      Notes:
        - This setting is __NOT enabled by default__. You can go to mail
          server profile page, tab "Settings", find setting
          "Enable FTS (Full-Text Search)" under section "POP3/IMAP services"
          and enable it.
        - Currently this option is available on CentOS 8, Debian 10, OpenBSD.
        - FTS backend is xapian, no daemon service is running.
* mlmmjadmin:
    - Fixed: tools/maillist_admin.py: don't call `add_subscribers()` and
      `remove_subscribers()` for backends.
* Nginx:
    - Do not enable `multi_accept on;`. Thanks jinleileiking@GitHub.
* Fail2ban:
    - Use builtin filter file for Dovecot jail.
* Fixed issues:
    - Anonying logwatch warning about freshclam log file.
    - logwatch can not detect and check clamav log files.
    - Allow more sendgrid HELO hostnames.
      Thanks to Jim Nelin for the feedback.
    - Allow HELO hostnames used by Amazon EC2 and QQ.com (Tencent).
    - Do not enable iRedAPD pulgin `amavisd_wblist` if antispam component is
      not enabled.

* Package updates:
    - adminer 4.8.1
    - iRedAPD 5.0.2
    - mlmmjadmin 3.1.2
    - netdata 1.31.0

## Version: 2021041301 (Apr 13, 2021) {: id=2021041301 }

- CentOS 8 Stream is now supported.
* MariaDB and PostgreSQL backends:
    - New SQL table: `maillist_owners`. Used to store owner of (subscribable)
      mailing lists.

* OpenLDAP:
    - New LDAP attributes for objectClass `mailList`:
        - `listOwner`: used to store owner(s) of (subscribable) mailing list.
        - `listModerator`: used to store moderator(s) of (subscribable) mailing list.

* Dovecot:
    - Log the time of last received message.

* Postfix:
    - Remove blacklist of reverse DNS name for `ddXX.kasserver.com`.
    - Whitelist HELO hostname used by Microsoft Outlook/Hotmail servers.

* Fail2ban:
    - Stores (base64) encoded log lines in SQL database, it also helps avoid
      possible SQL injection.

* ClamAV:
    - CentOS: ClamAV database is now updated by daemon service
      `clamav-freshclam`, not cron job anymore.

* Fixed issues:
    - Not apply all custom settings defined in
      `/opt/iredmail/custom/<PROGRAM>/custom.sh` after system reboot.
      Note: it's now done by a cron job with special time `@reboot` for root user.
    - `/opt/iredmail/bin/create_user`: not set correct password and quota size.

* Package updates:
    - adminer-4.8.0
    - iRedAPD-5.0
    - netdata-1.30.1
    - mlmmjadmin-3.1
    - iRedAdmin-1.3

## Version: 2021020401 (Feb 4, 2020) {: id=2021020401 }

* iRedAPD:
    - Fixed: not enable plugin `sql_ml_access_policy` by default.

* Postfix:
    - Update rdns match rule to block `static.X.X.X.X.clients.your-server.de`.

* Package update:
    - netdata-1.29.0

## Version: 2020122801 (Dec 28, 2020) {: id=20201228 }

* Package updates:
    - Roundcube webmail -> 1.4.10. It's a security and bug fix release, all
      users are encouraged to upgrade as soon as possible. Check [official
      release page](https://github.com/roundcube/roundcubemail/releases/tag/1.4.10)
      for more details.
    - netdata-1.28.0
    - web.py-0.62

## Version: 2020121101 (Dec 11, 2020) {: id=20201211 }

* Postfix:
    - If logwatch is installed, enable long queue id support in logwatch.

* SpamAssassin:
    - Remove rules which caused too many incorrect quarantining:
      `URIBL_SBL`, `URIBL_SBL_A`.

* Fail2ban:
    - It now works on OpenBSD 6.8.
    - Fixed: Can not store banned IP address when country name contains quotes.
    - Fixed: possible SQL injection in shell script used by `banned_db` action.

* Fixed issues:
    - Not install uwsgi for Python 3 on CentOS 8.
    - Not backup Postfix config files `main.cf` and `master.cf` if they're
      regular files.
    - Not always install the latest Python module `web.py`.

* Package updates:
    - adminer-4.7.8
    - iRedAPD-4.7
    - iRedAdmin-Pro-LDAP-4.8, iRedAdmin-Pro-SQL-4.7
    - mlmmjadmin-3.0.7

## Version: 2020102801 (Oct 28, 2020) {: id=20201028 }

* Supports now distribution release:
    * OpenBSD 6.8. All 3 backends (MariaDB, PostgreSQL, OpenLDAP) are available.
      __NOTE__:
        - Support for OpenBSD 6.6 will be dropped in 6 months.
        - Support for OpenBSD 6.7 will be dropped after 6.9 is out.
        - Fail2ban (0.11.1) is not available due to not fully compatible with
          the Python 3.8.6 offered by OpenBSD 6.8.

* Add `/opt/iredmail/custom/custom.sh`. It will be ran at the end of EACH
  deployment.

* Postfix:
    - Revert the block of default reverse hostnames offered by OVH.com.

* Amavisd:
    - Log matched virus database name.
    - Update regex to match SecuriteInfo virus signature names.

* Fixed issues:
    - Failed to upgrade ClamAV database on CentOS 7.
    - Incorrect rsyslog pid file path on CentOS 7.
    - Not upgrade `sope*` packages while upgrading SOGo packages.
    - Can not create PostgreSQL database if locale doesn't match LC_CTYPE.

* Package updates:
    - iRedAPD-4.6. __Python 3.5+ is required.__
    - mlmmjadmin-3.0.4. __Python 3.5+ is required.__
    - iRedAdmin-1.1. __Python 3.5+ is required.__
    - netdata-1.26.0
    - Roundcube webmail 1.4.9

## Version: 2020082501 (Aug 25, 2020) {: id=20200825 }

* SOGo:

    !!! warning

        SOGo may not successfully kill all its child processes and causes sogo
        service failed to start. If it occurs, please stop SOGo service manually
        (`service sogo stop`), kill orphan processes (`pkill -9 sogod`), then start
        it manually (`service sogo restart`).

    - Upgrade SOGo to the latest v5 branch (nightly bulid) on Linux.
    - With SOGo v5, it now send email via submission service (port 587) without
      ssl cert verification.

* Nginx:
    - Enable http2 for https sites by default.

* Amavisd:
    - Fix improper SQL column type for column `msgs.from_address` (changed
      from `VARCHAR` to `VARBINARY`) for MariaDB and OpenLDAP backends.

* Dovecot:
    - Logrotate config file for Dovecot uses incorrect pid file name on CentOS.
      Thanks Igor Cej for the report and help.
    - Fixed: do not enable spam/ham auto learning if Amavisd + SpamAssassin
      are not installed.

* Postfix:
    - Block default reverse hostnames (format `(ns|ip)XXXX.ip-XX-XX-XX.eu`,
      "XX" is digit numbers) offered by OVH.com.
      Note: If you run mail server on OVH platform with a fixed hostname and
      valid PTR DNS record, it's not impacted.
    - Fixed: incorrect SMTP action code for whitelisted HELO hostnames.

* Chronyd (`ntp` alternative on CentOS 8):
    - Add `-x` option for chronyd if system is running in a LXC container.

* Package updates:
    - netdata-1.24.0
    - Roundcube webmail 1.4.8

## Version: 2020070701 (Jul  7, 2020) {: id=20200707 }

* BIND (cache-only) DNS server:
    - Fixed: Set DNS server to only `127.0.0.1` in ifcfg-XXX scripts on CentOS.
      Thanks Igor Cej for the feedback and help.

* Postfix:
    - Bypass Facebook mail server HELO hostname pattern:
      `<ip>.mail-campmail.facebook.com`.

* Roundcube:
    - Add `/opt/iredmail/custom/roundcube/custom.sh` for advance customization.
      It will be ran each time you (re-)deploy Roundcube or upgrade.
    - Connect to local (`127.0.0.1`) IMAP server without TLS on Ubuntu 20.04
      and CentOS 8. This is also considered as secure by Dovecot.

* SOGo:
    - Connect to local (`127.0.0.1`) IMAP server without TLS on Ubuntu 20.04
      and CentOS 8. This is also considered as secure by Dovecot.

        We received reports that Roundcube and SOGo have problem when TLS
        is explicitly enabled for IMAP service, unfortunately we didn't figure
        out what causes the issue yet. As a temporary fix, we choose to
        disable TLS for local connection.

* Fail2ban:
    - Suppress fail2ban-client output in cron job to avoid annoying mail
      notification.
    - Fixed: incorrect match rule. Thanks for Igor Cej for the feedback.

* Package updates:
    - Roundcube webmail 1.4.7, with a security fix.
    - netdata-1.23.1

## Version: 2020062601 (Jun 26, 2020) {: id=20200626 }

* Possible issue after upgraded on CentOS 8:

    Old CentOS 8 releases shipped Dovecot-2.2.x, but the new `8.2.2004` release
    suprisely ships Dovecot-2.3.8 which has some backward-incompatible settings.
    iRedMail Easy will upgrade it from old version `2.2.36` and re-generates
    its config files, it MAY fail to (re)start if you have unsupported
    customized parameters set in config file under
    `/opt/iredmail/custom/dovecot/conf-enabled/`.

    Mostly customized parameter is `ssl_protocols`, it should be replace by
    `ssl_min_protocol`.

    For example, if you still need to support TLSv1, please set
    `ssl_min_protocol = TLSv1` instead. Default value is TLSv1.2.

    - For more details, please check [official Dovecot upgrade
      tutorial](https://doc.dovecot.org/installation_guide/upgrading/from-2.2-to-2.3/).
    - If you have issue after upgraded, feel free to create a support
      ticket on the iRedMail Easy platform.

* Supports now distribution releases:
    * Ubuntu 20.04. All 3 backends (MariaDB, PostgreSQL, OpenLDAP) are available.
    * OpenBSD 6.7. All 3 backends (MariaDB, PostgreSQL, OpenLDAP) are available.
      __NOTE__: support for OpenBSD 6.6 will be dropped after 6.8 is out.

* Postfix:
    - Fixed: not wrap IPv6 addresses inside `[]` in `mynetworks`.
    - Fixed: not bypass HELO identities used by pinterest.com mail server.
    - Fixed: not add alias for `postmaster` (system) user which is used as
      2bounce recipient.

* Fail2ban:
    - It now stores more info in SQL db, you can view them with iRedAdmin-Pro:
        - Number of times the failure occurred in log files
        - The log lines which triggerred the ban
        - Reverse DNS of banned IP address
    - Fixed: specify `backend = pooling` and `journalmatch =` (empty value)
      to avoid performance issue and startup warnings in fail2ban log file.
    - Fixed: inconsistent jail name for jail `nginx-http-auth`.

* Antispam:
    - [Debian/Ubuntu] Fixed: not add user `debian-spamd` to `amavis` group.
    - [OpenLDAP/MariaDB] Add missing INDEX for SQL column `msgs.time_iso`.

* Adminer:
    - Improve Nginx configuration to loading custom CSS file `adminer.css`
      in same directory (`/opt/www/adminer/`).

* Improvements of iRedMail Easy platform:
    - Make sure all 3 required official apt repositories are enabled on Ubuntu.
    - Make sure iRedMail yum repository has higher priority on CentOS.

* Package updates:
    - roundcube webmail-1.4.6. It includes few security fixes.
    - adminer-4.7.7
    - netdata-1.23.0

## Version: 2020043001 (Apr 30, 2020) {: id=20200430 }

* Antispam:
    - Fixed: incorrect regular expression rules which caused unbanning based
      on file types doesn't work.
    - Fixed: incorrect file owner and permission for SpamAssassin config files:
      `/etc/mail/spamassassin/local.cf` and `razor.conf`, must be owned by
      user/group which is running Amavisd service, with permission 0640.
    - Add `/opt/iredmail/custom/spamassassin/custom.cf` for custom SpamAssassin
      rules.

* Dovecot:
    - Fixed: improper permission on file
      `/etc/dovecot/dovecot-{mysql,pgsql,ldap}.conf`.
    - Add `/opt/iredmail/custom/dovecot/master-users` for custom master users.
      Please do not modify `/etc/dovecot/dovecot-master-users`.

* Firewall:
    - [Debian 10] Fixed: Not open ports for XMPP service (5222, 5269) if
      Prosody is deployed.

* Nginx:
    - Fixed: improper http code `301` (permanent redirect) causes incorrect
      redirection after switching homepage application from SOGo to other
      web application. It's now replaced by `302` (temporarily redirect).

* Roundcube:
    - Fixed: not load custom config file for plugin `markasjunk`.

* Improvements of iRedMail Easy platform:
    - Switch self-signed SSL cert key length to 4096, also DKIM key length to
      2048. Note: Only new initial installation is affected, also if you
      already have those files, it won't re-generate them.
    - Able to customize http and https ports.
    - Add Prosody related info in `/root/iRedMail/iRedMail.tips`.

* Package updates:
    - Roundcube webmail 1.4.4 (includes few security fixes)

## Version: 2020041601 (Apr 16, 2020) {: id=20200416 }

* CentOS 8 is now supported, all 3 backends (MariaDB, PostgreSQL, OpenLDAP)
  are available.

    Note: RedHat dropped OpenLDAP server in RHEL 8, iRedMail Easy installs the
    OpenLDAP server packages (`symas-openldap-*`) from yum repository offered
    by Symas (the company behind OpenLDAP), package `symas-openldap` conflicts
    with the `openldap` package available in official RHEL/CentOS 8 yum repo.

* Drop support for OpenBSD 6.4, 6.5.
* New script `/opt/iredmail/bin/create_user`: create single user with quota
  support. Note: available for SQL backends.

* Dovecot:
    - TLSv1 is now disabled by default.
    - It now tracks last login of both POP3 and IMAP logins. In early releases,
      either POP3 or IMAP was tracked.

* Nginx:
    - New directory `/opt/iredmail/custom/nginx/webapps/` used to store custom
      settings for web applications,  it should be useful if sysadmin wants to
      add ACL control for the web application.

      Currently only 3 applications are supported: iRedAdmin, Roundcube, Adminer.

      For example, Nginx loads `/etc/nginx/templates/iredadmin.tmpl` for
      iRedAdmin, also loads extra settings from
      `/opt/iredmail/custom/nginx/webapps/iredadmin.conf`. If you want to
      limit the access to network `192.168.0.0/24`, you can create file
      `/opt/iredmail/custom/nginx/webapps/iredadmin.conf` with content below
      and reload Nginx service:

        ```
        allow 192.168.0.0/24;
        deny all;
        ```

    - Cache fonts used by web applications for 30 days.
    - Fixed: can not request Let's Encrypt cert with default config file
      for web domain `autoconfig.*` and `autodiscover.*`.

* Roundcube:
    - Use `pspell` as default spell check engine.

* Amavisd:
    - Fixed: SQL column `msgs.subject` doesn't support storing emoji characters.

* ClamAV:
    - Fixed: incorrect permission of database directory on RHEL/CentOS.
    - Fixed: not install package `libclamavunrar9` on Ubuntu for rar files.

* mlmmj (Mailing list manager):
    - Fixed: do not abort if `altermime` program is not available.

* Fail2ban:
    - It now works on OpenBSD.
    - Improve rsyslog config file to catch all fail2ban log.
    - Improve ban action to query and store country of IP address in SQL db.
    - Enable jail to catch iRedAdmin-Pro login failures.
    - Add cron job to unban IP addresses which are pending for removal.

* Package updates:
    - Roundcube webmail 1.4.3
    - iRedAPD-3.6
    - netdata-1.21.1

* Improvements of iRedMail Easy platform:
    - Fixed: file `/etc/rsyslog.d/1-iredmail-iredapd.conf` was incorrectly
      rewritten by Prosody component.
    - Fixed: there's incorrect rsyslog setting in file
      `/etc/rsyslog.d/0-iredmail-misc.conf`, this file is now removed.

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
