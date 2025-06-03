# ChangeLog of iRedMail Enterprise Edition

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

| Version | Release Date |
|---|---|
| [v1.3.1](#v1.3.1) | 2025-06-03 |
| [v1.3.0](#v1.3.0) | 2025-05-22 |
| [v1.2.1](#v1.2.1) | 2025-04-04 |
| [v1.2.0](#v1.2.0) | 2025-04-03 |
| [v1.1.0](#v1.1.0) | 2025-03-11 |
| [v1.0.2](#v1.0.2) | 2025-02-20 |
| [v1.0.1](#v1.0.1) | 2025-01-26 |
| [v1.0.0](#v1.0.0) | 2025-01-24 |
| [v1.0-beta9](#v1.0-beta9) | 2024-12-12 |
| [v1.0-beta8](#v1.0-beta8) | 2024-09-14 |
| [v1.0-beta7](#v1.0-beta7) | 2024-08-02 |
| [v1.0-beta6](#v1.0-beta6) | 2024-05-31 |
| [v1.0-beta5](#v1.0-beta5) | 2024-05-08 |
| [v1.0-beta4](#v1.0-beta4) | 2024-04-26 |

<br/>

- [iRedMail Enterprise Edition (EE)](https://www.iredmail.org/ee.html)
- [Install iRedMail Enterprise Edition](./install.ee.html)
- [Upgrade iRedMail Enterprise Edition](./upgrade.ee.html)

## v1.3.1, Jun 3, 2025 {: #v1.3.1 }

- Fixed issues:
    - [PostgreSQL] Not set `NOT NULL` for SQL table `vmail.mailbox.employeeid`.
    - Not remove Nginx config snippet files after disabled SOGo.
    - Not properly expire cache of static files (js/css).
    - Not generate file `/opt/iredmail/ssl/cert.pem` after successfully
      requested ssl cert from Let's Encrypt.
    - Not handle error if SOGo user profile is empty.
    - Not upgrade required components while after upgraded EE binary.

- Updated packages:
    - roundcube 1.6.11 (security fix)
    - netdata v2.5.2
    - iRedAPD 5.9.1

## v1.3.0, May 22, 2025 {: #v1.3.0 }

- Supports new distribution releases:
    - OpenBSD 7.7. Drops 7.5.
    - CentOS Stream 10. Note: SOGo Groupware is not available on CentOS 10 yet.

- New features:
    - [SSL certificate management](./ee.cert.html): Request free cert from Let's Encrypt with
      multiple domain names support, renew the cert automatically.
    - View all DNS records of an email domain. Click the "DNS" badge on domain
      list page, or domain profile page.

- Improvements:
    - Show a modal window to select ActiveSync server when enabling or
      disabling SOGo and Z-Push component.
    - Store Z-Push state in SQL db instead of plain files.
    - Rotate Z-Push log file daily and keep for 90 copies (was weekly and 20 copies).
    - Log enabled / disabled components.
    - Able to delete all whitelists or blacklists.
    - Display disk usage on Dashboard page.
    - Always display login username on left sidebar.
    - Cache static files (image / css / js files) for one day by default.
    - Report error if custom locale (JSON) file has invalid format.

- Fixed issues:
    - Not set `Reply-To:` to mailing list address by default.
    - Generate content in wrong format in `/etc/postfix/sasl_passwords`.
      Thanks Fabian Santiago for the report.
    - Not enable IPv6 support in Postfix, Dovecot and Nginx.
      Thanks Fabian Santiago for the report.
    - MariaDB may have improper row format on server upgraded from old OS release.
    - [Amavisd] Do not quarantine detected spam by default.
      If admin chooses to not quarantine detected spams, the setting in Amavisd
      config file will overrides admin's spam policy stored in SQL db, which
      causes improper result.
      Thanks Fabian Santiago for the report.
    - Query parameter `limit` was ignored in several API endpoints.
    - Not correctly activate Z-Push as activesync server.
      Thanks Fabian Santiago for the report.
    - [self-service] Cannot whitelist sender on Quarantined Mails page.
      Thanks Fabian Santiago for the report.
    - Not redirect to correct URL while subscribing to or unsubscribing from
      newsletter.
    - [OpenLDAP] Not correctly update allocated quota size on domain list page.
    - Whitelisted IPs are not written into Fail2ban config file.
    - Not use correct password algorithm for OpenLDAP backend on RHEL-family OS.
      Thanks Laurent DUPIRE for the report.
    - Standalone admin was not recognized as global admin.
      Thanks Stéphane for the feedback.
    - Updating user and admin profiles with invalid password returns unexpected error.

- Updated translations:
    - de_DE (German). Thanks to Jochen Häberle <jh _at_ networkerz.de>.

- Updated packages:
    - adminer v5.3.0
    - netdata v2.5.1
    - mlmmjadmin v3.4.0


## v1.2.1, Apr 4, 2025 {: #v1.2.1 }

- Fixed issues:
    - [SQL backends] Not apply required SQL changes to `vmail.mailbox` table.

## v1.2.0, Apr 2, 2025 {: #v1.2.0 }

- Breaking changes:
    - Storing IMAP metadata in file inside mailboxes instead of SQL database.

        If you have shared folders, or enabled http push notification, you
        have to reset ACL or re-enable http push notification.

- New features:
    - [Z-Push](https://z-push.org) is now available as alternative ActiveSync server.
        - Fail2ban integration for activesync auth failure is enabled by default.
    - __Password recovery__. Allow end user to reset password with a recovery email. Notes:
        - User must login to self-service and add recovery email first, so
          that user can reset password with this recovery email.
        - A SMTP Account is required to send emails while user requests to
          reset password.

- Improvements:
    - [web] Add links to view per-domain, per-user mail activities.
    - [web] Able to disable creating IMAP folder for email address extension.
      When local user `user@domain.com` receives an email sent to
      `user+ExT@domain.com`, do not create mailbox folder `ExT` and deliver
      email to the folder.
    - [web] Able to re-deploy backend database (MariaDB, PostgreSQL, OpenLDAP0.
    - [server] Discard duplicate emails by default in global sieve rule.
    - [server] Supports storing custom Postfix config snippets in
      `/opt/iredmail/custom/postfix/append_main.cf` and `append_master.cf`.
      Full content of these 2 files will be appended to the end of
      `/etc/postfix/main.cf` and `master.cf`.
    - [Fail2ban] Monitoring EE log file for login failures.
    - [SOGo] Re-create SQL VIEW to display more contact info stored in
      newly added SQL columns in `vmail.mailbox`.
    - [SQL backends] Able to manage more info of a mail user: first name, last
      name, mobile numbers, telphone numbers, birthday.

- Fixed issues:
    - [web] Updating `Server Settings` may lose some other settings.
    - [web] Cannot re-upload custom logo image.
    - [web] Typing 2FA security code doesn't work well with numeric keypad.
    - [server] Incorrect firewall rules in some cases.
    - [server] Incorrect sql column in SQL VIEW `sogo.users`.
    - [server] Storing IMAP metadata in SQL is not working well, fallback to
      store in file inside user mailbox instead.
    - [server] Not sync mail attachment size with web upload file size.
    - [server] Incorrect SQL column definitions in table `amavisd.msgs`.
    - [server] Error while setting owner/permission of a lot DKIM keys.
      Thanks subarticThrone@forum for the feedback.

- Updated translations:
    - de_DE (German). Thanks to Jochen Häberle <jh _at_ networkerz.de>.

- Updated packages:
    - adminer v5.1.1
    - iRedAPD 5.9.0
    - netdata 2.3.2

## v1.1.0, Mar 11, 2025 {: #v1.1.0 }

- API:
    - Parameter name changed:
        - User profile (`/api/user/{email}`): `employeeid` -> `employee_id`.
    - URI changed:
        - Release quarantined mails: `/api/activities/msg/{mail_id}` ->
          `/api/activities/msg/{mail_id}`.

- New features:
    - Self service. End users can login to EE to manage personal information,
      whitelists / blacklists, spam policy and more. Defaults to URL
      `https://<your-server>/self-service/`.

- Improvements:
    - Amavisd: Create symbol link `/etc/amavisd.conf` on RHEL-family.
    - netdata: Avoid the login page and splash screen, also disable cloud.

- Fixed issues:
    - [web] Failed in adding whitelisting or blacklisting addresses with leading
      or ending whitespace.
    - [web] Last Logins page may contain non-existing users.
    - [server] Missing required Dovecot (sub-)package on Debian/Ubuntu. fixes #1153
    - [server] Dovecot: Not eanble stats-writer. fixes #1154
    - [server] SOGo: Add missing GroupObjectClasses for OpenLDAP backend. fixes #1155
    - [server] netdata cannot load cloud config '/opt/netdata/var/lib/netdata/cloud.d/cloud.conf'.

- Updated packages:
    - Adminer v5.0.2
    - netdata v2.2.6

## v1.0.2, Feb 20, 2025 {: #v1.0.2 }

- New features:
    - You can now customize branding on web UI directly (Server Settings ->
      Custom Branding), including short and full brand name, website link,
      logo image and favicon icon.

- Improvements:
    - [web] Able to enable LDAP over TLS and SSL.
    - [web] Able to display more accounts on user list page. Defaults to 50.
    - [web] On user list page, it's now able to sort by quota usage pacentage
      or stored size.
    - [web] On `Last Logins` page, it's now able to sort by either IMAP, POP3
      or delivery.
    - Improve performance while deleting multiple mailboxes at the same time.
    - dovecot: Switch to old stats plugin so that netdata can collect metrics.
    - netdata: Switch all Python plugins to Go for better performance.

- Fixed:
    - [web] Not preserve address extension in forwarding address.
      Thanks Jean-lou Schmidt for the feedback.
    - [web] Filter of disabled domains is incorrect.
    - [web] Normal admin was able to update domain quota and account limits.
    - [web] Cannot save max retries and timeout while updating Push Notification
      settings.
    - [server] Amavisd cannot save mail subject longer than 255 characters.
    - [server] Amavisd requires at least 2 child processes (was set to 1).
    - [server] Netdata doesn't collect data for OpenLDAP server.
    - Migrating from non-EE server may take too much time to update existing
      Amavisd SQL tables.
    - Succeeded deployment may be displayed as Aborted in some case.

- Updated packages:
    - mlmmjadmin 3.3.1
    - netdata 2.2.5
    - roundcube 1.6.10

## v1.0.1, Jan 26, 2025 {: #v1.0.1 }

- Improvements:
    - [web] Able to allow users to add auxiliary IMAP accounts
      (`SOGoMailAuxiliaryUserAccountsEnabled=YES`).

- Fixed:
    - [web] Cannot save some checkbox status on `Server Settings` page.

## v1.0.0, Jan 24, 2025 {: #v1.0.0 }

- New features:
    - HTTP Push notification. Send basic info of newly received email message
      to your http endpoint. Note: it does not send full mail headers or body.
      FYI <https://doc.dovecot.org/main/core/plugins/push_notification.html>
    - Enable doveadm http api. FYI
      <https://doc.dovecot.org/main/core/admin/doveadm.html>

- Improvements:
    - [LDAP backend] Able to add and manage (old-style) mailing list account.
    - Able to accept connections from certain source address to any port
      while adding new firewall rule.
      Thanks Ian for the feedback.
    - Supports autoconfig, autodiscover and mobileconfig out of box. Component
      `Autoconfig and Autodiscover` has been removed.
    - [web] Able to filter events on Activities page.
    - [web] Able to redirect to mail alias profile page from user profile page,
      Membership tab.

- Fixed:
    - [server] Not serve ACME challenge over HTTP directly.
      Let's Encrypt cert renewal may fail with error `Connection refused` if
      the HTTP request is redirected to HTTPS.
    - [server] Incorrectly prefix `[Spam]` text in mail subject when option
      `Always insert X-Spam-* headers` is enabled.
    - [server] Not apply default firewall rules while upgrading from v1.0-beta8
      when Firewall component is enabled.
      Thanks Ian for the report.
    - [server] Not install required package for FTS on Ubuntu 24.04.
    - [server] Disable slow query log in mariadb to prevent large log file. 
      Thanks Günther Pfannhauser for the report.
    - [server] Upgrading from v1.0-beta7 or earlier releases fails.
    - [server] Not restart cron job to load newly added tasks.
    - [api] Cannot reset user password with a hashed password.
      Thanks Michael Stamouli for the report.
    - [api] Cannot use "-" (dash) in password.
    - [web] `Statistics` on Dashboard does not reflect the log retention days.
    - [web] `Delete All` button doesn't work on `Sent Mails` page.
      Thanks Justin for the report.
    - [web] OTP doesn't work. (#1037)
      Thanks Sascha Linke for the report.
    - [web] Several web UI minor fixes and tweaks.

- Updated packages:
    - netdata 2.2.0

## v1.0-beta9, Dec 12, 2024 {: #v1.0-beta9 }

- Dropped distribution releases:
    - Debian 10 (buster). Debian 12 is recommended.
    - Ubuntu 18.04 (bionic). Ubuntu 24.04 LTS is recommended.

- New translation: de_DE (German).
  Thanks to Leslie León Sinclair (leslie84 _at_ nauta.cu).

- New features:
    - Full OpenLDAP backend support.
    - [web] Manage firewall rules on web UI.
    - [web] Manage default MTA transport.
    - [web] Email archiving software integration. Currently only Spider Email
      Archiver <https://spiderd.io> is supported. Spider is developed by
      iRedMail team.
    - [server] Add cron job to remove mailboxes from disk after account was
      deleted.

- Improvements:
    - [server] Set SOGoDisableOrganizerEventCheck=YES in SOGo by default.
    - [server] SOGo Groupware is now available on arm64 platform.
    - [server] Increase Amavisd log line length to 2048 characters.
    - [server] Improve SQL performance by extending `amavisd.msgs` table.
    - [server] Block `.F`, `.melt`, `.fcat`, `.zoo` file extensions by default
      in Amavisd due to no decode program available.
    - [web] Able to filter mail alias and mailing lists accounts by first
      char of email address.
    - [web] Display banner on all pages when new version is available for upgrade.
    - [migration] Migrating from iRedMail Easy is even easier now.

- Fixed issues:
    - [server] Not correctly save spam policy.
    - [server] Do not set default mailbox quota in Dovecot config file.
    - [server] SSL cert/key files have loose file permission. Set to 0400 now.
    - [server] Not update iRedAPD config file to whitelist trusted clients.
      Thanks to Peter Radig for the feedback.
    - [server] Not correctly enable / disable per-domain greylisting service.
    - [server] Not preserve display name and managed domains while renaming mail user.
    - [api] Incorrect parameter value types while creating domain.

- Updated packages:
    - mlmmjadmin 3.3.0
    - netdata 2.0.3
    - iRedAPD 5.8.1
    - uwsgi 2.0.28 (OpenBSD only)

## v1.0-beta8, Sep 14, 2024 {: #v1.0-beta8 }

> We're working hard to finish OpenLDAP support in next beta release, v1.0-beta9.

- [NEW] Able to manage global, per-domain and per-user whitelists and
  blacklists on web UI or API interface.
- [NEW] __Two-factor authentication (2FA)__ with TOTP.
    - [web] Global admin can enforce all domain admins to enable 2FA.
- [NEW] New translation: es_ES (Español). Thanks to Leslie León Sinclair [leslie84 _at_ nauta _dot_ cub].
- Improvements:
    - [api] New parameter `maildir` used to customize mailbox path while
      creating new user or updating user profile.
    - [api][web] Optional: Remove data from other applications while removing
      mailbox or domain. Defaults to keep the data.
    - [api][web] No more max password length.
    - [web] Able to disable 2FA for SOGo user.
    - [web] Able to download deployment log.
    - [web] 2 new cards on Dashboard page: `Top Senders`, `Top Recipients`.
    - [web] Display 3 cards on top of domain profile page: `Statistics of
      latest 24 hours`, `Top Senders`, `Top Recipients`.
    - [web] Able to configure the notification of quarantined emails:
      `Quarantined Mails` -> `Quarantine Notify` (the small bell icon).
    - [web] Able to abort the running deployment.
    - [web] Able to subscribe to or unsubscribe from newsletter-style
      mailing list on web UI.
    - [web] Removed all optional settings in setup wizard. Please tune the
      server after initial deployment.
    - [web] Component `Firewall` is disabled during initial setup.
      Setup will restart firewall at the end of deployment, it blocks the
      network port used by setup and causes deployment failure. Feel free
      to enable it after initial setup.
    - [web] Able to filter user accounts by first character of email address.
    - [web] Able to filter disabled user accounts.
    - [server] Disable SpamAssassin rule `RCVD_IN_DNSWL_HI` (Sender listed at
      http://www.dnswl.org/ with high trust) due to too many false positives.
- Fixed issues:
    - [server] Not correctly wrap IPv6 addresses (saved in `Server Settings` ->
      `Trusted Clients`) in Postfix config file.
      Thanks to Peter Radig for the feedback.
    - [server] ClamAV can not scan emails due to permission issue.
      Thanks to Peter Radig for the feedback.
    - [api] Normal domain admin may be able to delete any domain via API calls.
    - [web] Incorrect count while displaying disabled domains.
    - Rotated log files (/opt/iredmail/log/*.log) were not compressed.
- Updated packages:
    - Roundcube 1.6.9, 1.5.9
    - netdata v1.47.1
    - Fail2ban 1.1.0 (OpenBSD only)
    - Adminer has been replaced by AdminerEvo and upgraded to v4.8.4.
      Original Adminer project was abandoned, AdminerEvo is the successor.
      https://github.com/adminerevo/adminerevo
- Known issues:
    - Fail2ban cannot start on OpenBSD after system reboot.

## v1.0-beta7, Aug 2, 2024 {: #v1.0-beta7 }

- [NEW] Full documentation of the RESTful API interface is now embedded and
  accessible by clicking `API Doc` link on page foot after logged in as global
  admin. It's also accessible online: https://www.iredmail.org/ee/api/index.html.
- [NEW] Amavisd integration:
    - View basic info of incoming and outgoing emails.
    - Manage global, per-domain and per-user spam policy.
    - View, release, delete quarantined emails.
    - Add sender or recipient to whitelist or blacklist on different mail list pages.
    - Show statistics of latest 24 hours on Dashboard page.

- Improvements:
    - [server] User password is forced to be at least 8 characters for security concern.
    - [server] Add 5 new columns in SQL table `amavisd.msgs` to simplify SQL
      queries and better performance: `sender_domain`, `sender_mail`, `rid`,
      `rcpt_domain`, `rcpt_mail`.
    - [server] FTS is now available on CentOS / Rocky / AlmaLinux 9.
      Defaults to disabled.
    - [server] Track user last login date:
        - Store user last login time in PostgreSQL backend on Debian 12,
          Ubuntu 22.04 and 24.04, CentOS / Rocky / AlmaLinux 9, OpenBSD 7.3 and later.
          Note: MariaDB / OpenLDAP backends already have this feature.
        - It's now enabled all backends by default if it's supported by Dovecot.
    - [web] Remove duplicate Enable / Disable options in user / list / alias
      account list page.
    - [web] Able to enable / disable account on mailing list and mail alias list
      pages by clicking the account status icon.
    - [web] Many minor UI improvements.

- Fixed issues:
    - [playbook] Postfix config is messed and not enable SMTP smuggling fix.
      Thanks to Ian for the feedback.
    - [web] Cannot update user's employee ID.
    - [web] Cannot view mail alias accounts and mailing lists in SOGo address book.

- Updated packages:
    + netdata v1.46.3
    + Roundcube webmail -> 1.6.8. It fixes 3 security vulnerabilities.
      FYI https://roundcube.net/news/2024/08/04/security-updates-1.6.8-and-1.5.8

## v1.0-beta6, May 31, 2024 {: #v1.0-beta6 }

- A valid license key is now required for installation.
- Improvements:
    - [web] New search bar on top-left of all web pages. You can search
      with domain name, email address, or display name, top 10 results are
      displayed, click item to visit account profile page.
    - [web] Removed component `iRedAdmin` since iRedMail Enterprise Edition
      offers same features as iRedAdmin and iRedAdmin-Pro.
    - [web] Able to set isolation level of the spam/ham auto-learning data.
      Currently 3 options are available: per-user, per-domain or server wide.
      Defaults to server wide (share learning data between all users).
    - [server] If component `BIND DNS Server` is enabled, use localhost as
      DNS server in systemd resolved service.
    - [server] Not use Google DNS servers as default upstream anymore.
      Spamhaus blocks queries from public/open DNS servers.
    - [server] Set default max connections to 1024 for PostgreSQL.
    - [server] Use systemd-timesyncd as ntp client on Ubuntu 24.04.
    - [server] Fail2ban now stores banned IP addresses in SQL database by default.
    - [server] Fail2ban now stores enabled jail names in SQL table `fail2ban.jails`.

- Updated packages:
    - Roundcube 1.6.7
    - Roundcube 1.5.7 (Ubuntu 18.04 only)
    - netdata v1.45.5

## v1.0-beta5, May 8, 2024 {: #v1.0-beta5 }

- New: iRedAPD integration.
    - Global, per-domain, per-user greylisting management.
    - Global, per-domain, per-user throttling management.

- Updated packages:
    - netdata v1.45.4

## v1.0-beta4, April 26, 2024 {: #v1.0-beta4 }

- Supports new distribution releases:
    - Ubuntu 24.04 LTS
    - OpenBSD 7.5

- Improvements:
    - Refactored Components page.

- Fixed issues:
    - [web] Not return valid data after updated per-user alias addresses.
    - [web] Can not toggle on/off password policies.
    - Not set correct owner of SOGo PostgreSQL database.
    - Can not set file permission on symbol link file.
    - Some minor issues.

- Updated packages:
    - iRedAPD v5.6.0
    - netdata v1.45.3
