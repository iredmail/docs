# Which network ports are open by iRedMail

Port | Service | Software | Comment | Allow Public Access?
--- |--- |--- |--- |---
25 | smtp | Postfix | Used for communication betweem mail servers. __WARNING__: This port __MUST__ be open, otherwise you cannot receive email sent by other mail servers. | __YES (REQUIRED)__{: .red }
587 | submission | Postfix | SMTP over TLS. Used by end users to send/submit email. | YES (open to your end users)
110 | pop3 | Dovecot | Used by end users to retrieve emails via POP3 protocol, secure connection over STARTTLS is enforced by default. | YES (open to your end users)
995 | pop3s | Dovecot | Used by end users to retrieve emails via POP3 protocol over SSL. | YES (open to your end users)
143 | imap |Dovecot | Used by end users to retrieve emails via IMAP protocol, secure connection over STARTTLS is enforced by default. | YES (open to your end users)
993 | imaps | Dovecot | Used by end users to retrieve emails via IMAP protocol over SSL. | YES (open to your end users)
24 | lmtp | Dovecot | Used to deliver email to local mailboxes via LMTP protocol. | No (listen on `127.0.0.1` by default)
4190 | managesieve | Dovecot | Sieve service used by end users to manage mail filters. Note: in old iRedMail releases, it's port 2000 (deprecated and not even listed in `/etc/services` file). | NO (disabled by default and users are forced to manage mail filters with webmail)
80 | http | Apache/Nginx | Web service | YES (open to your webmail users)
443 | https | Apache/Nginx | Web service over over SSL, secure connection. SOGo groupware provides Exchange ActiveSync (EAS) support through port 443. | YES (open to your webmail users)
3306 | mysql | MySQL/MariaDB | MySQL/MariaDB database service | NO (listen on `127.0.0.1` by default)
5432 | postgresql | PostgreSQL | PostgreSQL database service | NO (listen on `127.0.0.1` by default)
389 | ldap | OpenLDAP (or OpenBSD ldapd) | LDAP service, STARTTLS is available for secure connection. | NO (listen on `127.0.0.1` by default)
636 |ldaps | OpenLDAP (or OpenBSD ldapd) | LDAP service over SSL. Deprecated, port 389 with STARTTLS is recommended. | NO (Not enabled by default)
10024 | | Amavisd-new | Used to scan inbound messages, includes spam/virus scanning, DKIM verification, applying spam policy. | NO (listen on `127.0.0.1` by default)
10025 | smtp | Postfix | Used by Amavisd to inject scanned emails back to Postfix queue. | NO (listen on `127.0.0.1` by default)
10026 | | Amavisd-new | Used to scan outbound messages, includes spam/virus scanning, DKIM signing, applying spam policy. | NO (listen on `127.0.0.1` by default)
10027 | | Amavisd-new | Used by mlmmj mailing list manager, it bypasses spam/virus/header/banned checks by default, but have DKIM signing enabled. | NO (listen on `127.0.0.1` by default)
10028 | | Postfix | Used by Amavisd-new to handle email message sent by mlmmj mailing list manager. Introduced in iRedMail-0.9.9. | NO (listen on `127.0.0.1` by default)
9998 | | Amavisd-new | Used to manage quarantined emails. | NO (listen on `127.0.0.1` by default)
7777 | | iRedAPD | Postfix policy service for greylisting, whitelisting, blacklists, throttling, etc | NO (listen on `127.0.0.1` by default)
7778 | | iRedAPD | [SRS](https://en.wikipedia.org/wiki/Sender_Rewriting_Scheme) sender address rewritting. | NO (listen on `127.0.0.1` by default)
7779 | | iRedAPD | [SRS](https://en.wikipedia.org/wiki/Sender_Rewriting_Scheme) recipient address rewritting. | NO (listen on `127.0.0.1` by default)
7790 | http | mlmmjadmin | RESTful API server used to manage mlmmj mailing lists. Introduced in iRedMail-0.9.8. | NO (listen on `127.0.0.1` by default)
7791 | http | iredadmin | iRedAdmin (standalone uwsgi instance). Introduced in iRedMail-0.9.9. | NO (listen on `127.0.0.1` by default)
20000 | | SOGo | SOGo groupware  | NO (listen on `127.0.0.1` by default)
11211 | | Memcached | A distributed, high performance memory object caching system. Currently used by only SOGo Groupware. | No (listen on `127.0.0.1` by default)
24242 | | Dovecot | Dovecot service status. Introduced in iRedMail-0.9.8. | NO (listen on `127.0.0.1` by default)
19999 | | Netdata | Netdata monitor. Introduced in iRedMail-0.9.8. | NO (listen on `127.0.0.1` by default)

!!! note

    * In iRedMail-0.9.2 and earlier releases, Policyd or Cluebringer listens on
      port 10031. They have been removed in iRedMail-0.9.3, and replaced by
      iRedAPD.

    * Port 465, a.k.a. SMTP over SSL, has been deprecated for years. Please use
      port 587 instead.
