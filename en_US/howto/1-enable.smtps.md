# Enable SMTPS service (SMTP over SSL, port 465)

[TOC]

### Why iRedMail doesn't enable SMTPS (SMTP over SSL) by default

SMTPS is deprecated, so iRedMail disable it by default.
Quote from [wikipedia.org](http://en.wikipedia.org/wiki/SMTPS)

> Originally, in early 1997, the Internet Assigned Numbers Authority registered 465 for SMTPS. By the end of 1998, this was revoked when STARTTLS has been specified. With STARTTLS, the same port can be used with or without TLS. SMTP was seen as particularly important, because clients of this protocol are often other mail servers, which can not know whether a server they wish to communicate with will have a separate port for TLS. The port 465 is now registered for Source-Specific Multicast audio and video.

### Why enable SMTPS since it's depreciated

Unfortunately, there're some popular mail clients don't support submission (SMTP over STARTTLS, port 587), the famous one is Microsoft Outlook. Quote from wikipedia.org:

> Even in 2013, there are still services that continue to offer the deprecated SMTPS interface on port 465 in addition to (or instead of!) the RFC-compliant message submission interface on the port 587 defined by RFC 6409. Service providers that maintain port 465 do so because older Microsoft applications (including Entourage v10.0) do not support STARTTLS, and thus not the smtp-submission standard (ESMTPS on port 587). The only way for service providers to offer those clients an encrypted connection is to maintain port 465.

### How to enable SMTPS

To enable SMTPS, you should configure Postfix to listen on port 465 first, then open port 465 in iptables.

Please append below lines in Postfix config file `/etc/postfix/master.cf` (Linux/OpenBSD) or `/usr/local/etc/postfix/master.cf` (FreeBSD):

```
465     inet  n       -       n       -       -       smtpd
  -o syslog_name=postfix/smtps
  -o smtpd_tls_wrappermode=yes
  -o smtpd_sasl_auth_enable=yes
  -o smtpd_client_restrictions=permit_sasl_authenticated,reject
  -o content_filter=smtp-amavis:[127.0.0.1]:10026
```

Restart Postfix service to enable SMTPS.

__WARNING__: Please make sure you have Amavisd listening on port 10026 (and 10024, 9998).

### Open port `465` in firewall

#### On RHEL/CentOS

* on RHEL/CentOS 6, please update iptables rule file `/etc/sysconfig/iptables`, add one rule (third line in below code) for port 465, then restart iptables service.

```
# Part of file: /etc/sysconfig/iptables
-A INPUT -p tcp --dport 25 -j ACCEPT
-A INPUT -p tcp --dport 587 -j ACCEPT
-A INPUT -p tcp --dport 465 -j ACCEPT
```

* on RHEL/CentOS 7, please add file `/etc/firewalld/services/smtps.xml`, with content below

```
<?xml version="1.0" encoding="utf-8"?>
<service>
  <short>Enable SMTPS</short>
  <description>Enable SMTPS.</description>
  <port protocol="tcp" port="465"/>
</service>
```

Update file `/etc/firewalld/zones/iredmail.xml`, enable smtps service by
inserting line `<service name="smtps"/>` inside `<zone></zone>` block like
below:

```
<zone>
    ...
    <service name="smtps"/>
</zone>
```

Restart firewalld service:

```
# firewall-cmd --complete-reload
```

#### on Debian/Ubuntu

On Debian/Ubuntu, if you use iptables rule file provided by iRedMail, please update `/etc/default/iptables`, add one rule (third line in below code) for port 465, then restart iptables service.

```
# Part of file: /etc/default/iptables
-A INPUT -p tcp --dport 25 -j ACCEPT
-A INPUT -p tcp --dport 587 -j ACCEPT
-A INPUT -p tcp --dport 465 -j ACCEPT
```

#### on OpenBSD

On OpenBSD, please append service `smtps` in `/etc/pf.conf`, parameter `mail_services=`:

```
# Part of file: /etc/pf.conf
mail_services="{www, https, submission, imap, imaps, pop3, pop3s, ssh, smtps}"
```

Reload PF rule file:

```
# pfctl -f /etc/pf.conf
```
