# Which network ports are open by iRedMail

| Port | Service | Software | Comment | Allow Public Access? |
|-----:|:--------|:---------|:--------|:---------------------|
| 25 | smtp | Postfix | Used for server-to-server mail delivery. **WARNING**: this port **MUST** be open, otherwise you cannot receive email sent by other mail servers. | **YES (REQUIRED)**{: .red } |
| 24 | lmtp | Dovecot | Local delivery to mailboxes via LMTP. | NO (127.0.0.1 only) |
| 80 | http | Apache/Nginx | HTTP; redirects to HTTPS by default. | YES (webmail users) |
| 110 | pop3 | Dovecot | POP3 retrieval. STARTTLS is enforced. | YES (end users) |
| 143 | imap | Dovecot | IMAP retrieval. STARTTLS is enforced. | YES (end users) |
| 389 | ldap | OpenLDAP (or OpenBSD ldapd) | LDAP directory service; STARTTLS is available for a secure connection. | NO (127.0.0.1 only) |
| 443 | https | Apache/Nginx | HTTPS for webmail and ActiveSync. | YES (webmail and ActiveSync users) |
| 465 | smtps (submissions) | Postfix | SMTP submission with implicit TLS. End users use it to submit outgoing mail. | YES (end users) |
| 587 | submission | Postfix | SMTP submission with STARTTLS. End users use it to submit outgoing mail. | YES (end users) |
| 636 | ldaps | OpenLDAP (or OpenBSD ldapd) | LDAP with implicit TLS (LDAPS). Not enabled by default; STARTTLS on port 389 is recommended instead. | NO (not enabled by default) |
| 993 | imaps | Dovecot | IMAP retrieval with implicit TLS. | YES (end users) |
| 995 | pop3s | Dovecot | POP3 retrieval with implicit TLS. | YES (end users) |
| 3306 | mysql | MySQL/MariaDB | Database service. | NO (127.0.0.1 only) |
| 4190 | managesieve | Dovecot | ManageSieve: end users manage mail filters. Old releases used port 2000 (deprecated, not listed in `/etc/services`). | NO (disabled by default; filters are managed in webmail) |
| 5432 | postgresql | PostgreSQL | Database service. | NO (127.0.0.1 only) |
| 7777 | — | iRedAPD | Postfix policy service: greylisting, whitelisting, blacklists, throttling, etc. | NO (127.0.0.1 only) |
| 7778 | — | iRedAPD | SRS sender address rewriting. | NO (127.0.0.1 only) |
| 7779 | — | iRedAPD | SRS recipient address rewriting. | NO (127.0.0.1 only) |
| 7790 | http | mlmmjadmin | RESTful API for managing mlmmj mailing lists (since iRedMail-0.9.8). | NO (127.0.0.1 only) |
| 7791 | http | iRedAdmin | iRedAdmin standalone uWSGI instance (since iRedMail-0.9.9). | NO (127.0.0.1 only) |
| 9998 | — | Amavisd-new | Quarantine management. | NO (127.0.0.1 only) |
| 10024 | — | Amavisd-new | Scans inbound messages: spam/virus scanning, DKIM verification, spam policy. | NO (127.0.0.1 only) |
| 10025 | smtp | Postfix | Amavisd re-injects scanned inbound messages into the Postfix queue. | NO (127.0.0.1 only) |
| 10026 | — | Amavisd-new | Scans outbound messages: spam/virus scanning, DKIM signing, spam policy. | NO (127.0.0.1 only) |
| 10027 | — | Amavisd-new | Amavisd listener used by mlmmj; bypasses spam/virus/header/banned checks by default, but has DKIM signing enabled. | NO (127.0.0.1 only) |
| 10028 | — | Amavisd-new | Amavisd listener for mail sent by the mlmmj mailing list manager (since iRedMail-0.9.9). | NO (127.0.0.1 only) |
| 11211 | — | Memcached | Memory object cache; currently used only by SOGo. | NO (127.0.0.1 only) |
| 12340 | — | Dovecot | Dovecot quota status (since iRedMail-1.0). | NO (127.0.0.1 only) |
| 19999 | — | Netdata | Netdata monitoring (since iRedMail-0.9.8). | NO (127.0.0.1 only) |
| 20000 | — | SOGo | SOGo groupware. | NO (127.0.0.1 only) |
| 24242 | — | Dovecot | Dovecot service status (since iRedMail-0.9.8). | NO (127.0.0.1 only) |

**Notes**

- **YES** ports must be reachable from the Internet for your users. Port 25 must be reachable by any mail server; the submission and retrieval ports can be restricted by firewall if your users connect from known networks.
- **NO (127.0.0.1 only)** means the service listens on the loopback interface in the default configuration. Open it to the network only if you know why.
- **TLS** terminology: *implicit TLS* means the TLS handshake starts immediately on that port (443, 465, 636, 993, 995); *STARTTLS* means a plaintext connection is upgraded to TLS (110, 143, 389, 587). TLS 1.2 or newer is required on all encrypted ports.
- Empty Service means the port has no IANA or `/etc/services` name; it is a product-specific port.
