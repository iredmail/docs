# Which network ports are open by iRedMail

[TOC]

## SMTP (Postfix)

* 25: normal smtp port, used for server-to-server communication.
* 587: Submission (SMTP over TLS), used for mail clients to send email.
* 465: smtps (SMTP over SSL). Deprecated, and disabled by default, please use
  port 587 instead.

## POP3/IMAP (Dovecot)

* 110: POP3 service, insecure connection. Supports STARTTLS for secure connection.
* 995: POP3S (Secure POP3 over SSL). Deprecated, recommended to use port 110 with STARTTLS.
* 143: IMAP service, insecure connection. Supports STARTTLS for secure connection.
* 993: IMAPS (Secure IMAP over SSL). Deprecated,  recommended to use port 143 with STARTTLS.
* 4190: managesieve service. (Refuse connections from external network in iptables by default). Note: in old iRedMail releases, it's port 2000, it's deprecated and not even listed in `/etc/services` file.

## Web server (Apache or Nginx)

* 80: normal web service port
* 443: HTTPS (http over SSL, secure connection)

SOGo groupware provides Exchange ActiveSync (EAS) support through port 443.

## MySQL

* 3306: default listen port. Listening on IP address `127.0.0.1` by default.

## PostgreSQL

* 5432: default listen port. Listening on IP address `127.0.0.1` by default.

## OpenLDAP

* 389: normal LDAP port, supports STARTTLS for secure connection.
* 636: LDAP over SSL. Deprecated, recommended to use port 387 with STARTTLS for
  secure connection.

Listening on all available network interfaces by default, but access from
external network is blocked by firewall (iptables, pf).

## Amavisd-new

* 10024: port used for inbound messages, includes spam/virus scanning, DKIM
  verification, applying spam policy.
* 10026: port used for outbound messages, includes spam/virus scanning, DKIM
  signing, apply spam policy.
* 9998: port used to manage quarantined emails.

All ports are listening on `127.0.0.1` by default.

## iRedAPD (Postfix policy server)

* 7777: default listen port. Listening on IP address `127.0.0.1` by default,
  offers greylisting, whitelisting, blacklists, throttling, and other features.

## Policyd or Cluebringer (Postfix policy server)

!!! note

    Policyd and Cluebringer were removed since iRedMail-0.9.3, they're replaced
    by iRedAPD.

* 10031: default listen port. Listening on IP address `127.0.0.1` by default.
