# Release Notes

[TOC]

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
