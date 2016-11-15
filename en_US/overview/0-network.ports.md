# Which network ports are open by iRedMail

Port | Service | Software | Comment | Allow Public Access?
--- |--- |--- |--- |---
25 | smtp | Postfix | Normal smtp service, used for server-to-server communication. | YES
587 | submission | Postfix | a.k.a. SMTP over TLS. Used by end users to send/submit email. | YES (open to your end users)
465 | smtps | Postfix | a.k.a. SMTP over SSL. Deprecated and disabled by default, please use port 587 instead. | YES (open to your end users)
110 | pop3 | Dovecot | Used by end users to retrieve emails via POP3 protocol, secure connection over STARTTLS is available by default. | YES (open to your end users)
995 | pop3s | Dovecot | Used by end users to restrieve emails via POP3 protocol over SSL. Port 110 with STARTTLS is recommended. | YES (open to your rend users)
143 | imap |Dovecot | Used by end users to retrieve emails via IMAP protocol, secure connection over STARTTLS is available by default. | YES (open to your end users)
993 | imaps | Dovecot | Used by end users to restrieve emails via IMAP protocol over SSL. Port 143 with STARTTLS is recommended. | YES (open to your rend users)
4190 | managesieve | Dovecot | Sieve service used by end users to manage mail filters. Note: in old iRedMail releases, it's port 2000 (deprecated and not even listed in `/etc/services` file). | YES (open to your end users, or disabled and force users to manage mail filters with webmail)
80 | http | Apache/Nginx | Web service | YES (open to your webmail users)
443 | https | Apache/Nginx | Web service over over SSL, secure connection. SOGo groupware provides Exchange ActiveSync (EAS) support through port 443. | YES (open to your webmail users)
3306 | mysql | MySQL/MariaDB | MySQL/MariaDB database service | NO (listen on `127.0.0.1` by default)
5432 | postgresql | PostgreSQL | PostgreSQL database service | NO (listen on `127.0.0.1` by default)
389 | ldap | OpenLDAP (or OpenBSD ldapd) | LDAP service, STARTTLS is available for secure connection. | NO (listen on `127.0.0.1` by default)
636 |ldaps | OpenLDAP (or OpenBSD ldapd) | LDAP service over SSL. Deprecated, port 389 with STARTTLS is recommended. | NO (listen on `127.0.0.1` by default)
10024 | | Amavisd-new | Used to scan inbound messages, includes spam/virus scanning, DKIM verification, applying spam policy. | NO (listen on `127.0.0.1` by default)
10026 | | Amavisd-new | Used to scan outbound messages, includes spam/virus scanning, DKIM signing, applying spam policy. | NO (listen on `127.0.0.1` by default)
9998 | | Amavisd-new | Used to manage quarantined emails. | NO (listen on `127.0.0.1` by default)
7777 | | iRedAPD | Postfix policy service for greylisting, whitelisting, blacklists, throttling, etc | NO (listen on `127.0.0.1` by default)

!!! note

    In iRedMail-0.9.2 and earlier releases, Policyd or Cluebringer listens on
    port 10031. They have been removed in iRedMail-0.9.3, and replaced by
    iRedAPD.
