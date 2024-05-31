# ChangeLog of iRedMail Enterprise Edition

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

| Version | Release Date |
|---|---|
| [v1.0-beta6](#v1.0-beta6) | 2024-05-31 |
| [v1.0-beta5](#v1.0-beta5) | 2024-05-08 |
| [v1.0-beta4](#v1.0-beta4) | 2024-04-26 |


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
