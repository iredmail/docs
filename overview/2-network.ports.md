# Which network ports are open by iRedMail

[TOC]

## Web server (Apache or Nginx)

* 80: normal web service port
* 443: HTTPS (http over SSL, secure connection)

SOGo groupware provides Exchange ActiveSync (EAS) support through port 443.

## SMTP (Postfix)

* 25: normal smtp port, used for server-to-server communication.
* 587: Submission (SMTP over TLS), used for mail clients to send email.
* 465: smtps (SMTP over SSL). Deprecated, and disabled by default, please use
  port 587 instead.

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

## POP3/IMAP (Dovecot)

* 110: POP3 service, insecure connection. Supports STARTTLS for secure connection.
* 995: POP3S (Secure POP3 over SSL). Deprecated, recommended to use port 110 with STARTTLS.
* 143: IMAP service, insecure connection. Supports STARTTLS for secure connection.
* 993: IMAPS (Secure IMAP over SSL). Deprecated,  recommended to use port 143 with STARTTLS.
* 2000: managesieve service. (Refuse connections from external network in iptables be default)

## Amavisd-new

* 10024: main port used for Postfix to inject incoming/outgoing
  emails for spam/virus scanning, DKIM signing/verification, etc.
* 9998: port used to manage quarantined emails.

All ports are listening on `127.0.0.1` by default.

## Policyd or Cluebringer (Postfix policy server)

* 10031: default listen port. Listening on IP address `127.0.0.1` by default.

## iRedAPD (Postfix policy server)

* 7777: default listen port. Listening on IP address `127.0.0.1` by default.
