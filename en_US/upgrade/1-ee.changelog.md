# ChangeLog of iRedMail Enterprise Edition

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]


## v1.0-beta5, May 8, 2024

- New: iRedAPD integration.
    - Global, per-domain, per-user greylisting management.
    - Global, per-domain, per-user throttling management.

- Updated packages:
    - netdata v1.45.4

## v1.0-beta4, April 26, 2024

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
