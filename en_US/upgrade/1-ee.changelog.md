# ChangeLog of iRedMail Enterprise Edition

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

| Version | Release Date |
|---|---|
| [v1.0-beta7](#v1.0-beta7) | 2024-08-02 |
| [v1.0-beta6](#v1.0-beta6) | 2024-05-31 |
| [v1.0-beta5](#v1.0-beta5) | 2024-05-08 |
| [v1.0-beta4](#v1.0-beta4) | 2024-04-26 |

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
