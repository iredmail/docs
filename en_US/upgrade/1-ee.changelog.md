# ChangeLog of iRedMail Enterprise Edition

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

| Version | Release Date |
|---|---|
| [v1.0-beta9](#v1.0-beta9) | 2024-12-12 |
| [v1.0-beta8](#v1.0-beta8) | 2024-09-14 |
| [v1.0-beta7](#v1.0-beta7) | 2024-08-02 |
| [v1.0-beta6](#v1.0-beta6) | 2024-05-31 |
| [v1.0-beta5](#v1.0-beta5) | 2024-05-08 |
| [v1.0-beta4](#v1.0-beta4) | 2024-04-26 |

## v1.0-beta9, Dec 12, 2024 {: #v1.0-beta9 }

- Dropped distribution releases:
    - Debian 10 (buster). Debian 12 is recommended.
    - Ubuntu 18.04 (bionic). Ubuntu 24.04 LTS is recommended.

- New translation: de_DE (German).
  Thanks to Leslie León Sinclair <leslie84@nauta.cu>.

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
