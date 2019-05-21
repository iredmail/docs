# Setup DNS records for autoconfig and autodiscover

[TOC]

[iRedMail Easy](https://www.iredmail.org/easy.html) offers component
`Autoconfig and Autodiscover` to help end users
setup their MUA like Thunderbird and Outlook which supports autoconfig and
autodiscover protocol.

This tutorial explains how autoconfig and autodiscover works, and how to
setup required DNS records to get them working. In this tutorial, we use:

* `customer.com` is your customer's mail domain name.
* `mail.host.com` is the hostname of your mail server deployed with iRedMail
  Easy platform, it's public IPv4 address is `a.b.c.d`. IP can be either IPv4
  or IPv6, we use IPv4 for example in this tutorial.

    It's ok to use a separated DNS name like `autoconfig.host.com` for
    autoconfig and autodiscover service, don't forget to setup https for it
    with a valid ssl cert (it's required by autodiscover).

## How autoconfig works in Thunderbird

To setup email account `user@customer.com`, Thunderbird performs the
lookups below in particular order to get pre-defined server settings:

1. It checks `http://autoconfig.customer.com/mail/config-v1.1.xml?emailaddress=user@customer.com`
1. if failed, checks `http://customer.com/.well-known/autoconfig/mail/config-v1.1.xml?emailaddress=user@customer.com`
1. If failed, try to find the config of mail domain at the Mozilla ISP database (ISPDB).

    For more details about ISPDB, or you're a big ISP and want to add your
    domain in ISPDB, please read [this tutorial](https://developer.mozilla.org/en-US/docs/Mozilla/Thunderbird/Autoconfiguration#ISPDB).

1. Look up DNS MX record of `customer.com`. If the server specified in
  DNS MX record is `mx1.mail.host.com`, look up `host.com` in the ISPDB.
1. If all mechanisms failed, Thunderbird tries to guess the server
  address, by trying common server names like `imap.customer.com`,
  `smtp.customer.com`, `mail.customer.com`, etc. and, when a mail server
  answers, checking whether it supports SSL, STARTTLS and encrypted passwords
  (CRAM-MD5).

We don't control Mozilla ISPDB, and most times web site is hosted on another
server, so the ideal solution is setting DNS record `autoconfig.customer.com`
and pointed to your mail server. We will show you how to setup this DNS record
later.

The autoconfig component configured by iRedMail Easy supports URLs:

- `https://mail.host.com/mail/config-v1.1.xml`
- `https://mail.host.com/.well-known/autoconfig/mail/config-v1.1.xml`
- `https://autoconfig.host.com/mail/config-v1.1.xml` (DNS A record of `autoconfig.host.com` must be pointed to IP of your mail server `a.b.c.d`.)
- `https://autoconfig.host.com/.well-known/autoconfig/mail/config-v1.1.xml` (DNS A record of `autoconfig.host.com` must be pointed to IP of your mail server `a.b.c.d`.)

## How auto-discover works in Microsoft Outlook

!!! warning

    Outlook requires a valid ssl cert, a self-signed ssl cert may fail.

Without Microsoft Exchange, the order of logic that Outlook 2007 and newer
releases use when trying to figure out where to get server settings is as
follows:

1. HTTPS root domain query. Outlook uses the domain part of user email address
   to do this query, so it's `https://customer.com/autodiscover/autodiscover.xml`.
1. If above failed, try HTTPS autodiscover domain: 
   `https://autodiscover.customer.com/autodiscover/autodiscover.xml`.
1. If above failed, try same URL but HTTP instead:
   `http://autodiscover.customer.com/autodiscover/autodiscover.xml`
1. If all failed, try DNS SRV record: `_autodiscover._tcp.customer.com`. If it
   returns a web host name and port number, for example, `mail.host.com` and 
   port number 443, then try
   `https://mail.host.com:443/autodiscover/autodiscover.xml`

The ideal solution is setting DNS SRV record `_autodiscover._tcp.customer.com`
and point to your server `mail.host.com`.

The autodiscover component configured by iRedMail Easy supports URLs:

- `https://mail.host.com/autodiscover/autodiscover.xml`
- `https://autodiscover.host.com/autodiscover/autodiscover.xml` (DNS A record of `autodiscover.host.com` must be pointed to IP of your mail server `a.b.c.d`.)

## Setup DNS record for autoconfig

Please create either a DNS A or CNAME record `autoconfig.customer.com` for
your customer's domain name:

* For DNS A record, please point to your mail server IP address `a.b.c.d`.
* For DNS CNAME record, please point to your mail server hostname `mail.host.com`.

After created, you may need to wait for 2 or more hours until your DNS vendor
flush the DNS cache. Then you can test the autoconfig with curl commands below:

```
curl -k http://autoconfig.customer.com/.well-known/autoconfig/mail/config-v1.1.xml?emailaddress=user@customer.com
curl -k http://mail.host.com/mail/config-v1.1.xml?emailaddress=user@customer.com
curl -k http://mail.host.com/.well-known/autoconfig/mail/config-v1.1.xml?emailaddress=user@customer.com
```

It should print a XML format content on console.

## Setup DNS record for autodiscover

Please create a DNS SRV record for your customer's domain name `customer.com`:

- `Service`: _autodiscover
- `Protocol`: _tcp
- `Port Number`: 443
- `Host`: mail.host.com

Outlook will query DNS SRV record `_autodiscover._tcp.customer.com` first, then
fetch pre-defined server settings from URL
`https://mail.host.com/autodiscover/autodiscover.xml`.

After created, you may need to wait for 2 or more hours until your DNS vendor
flush the DNS cache. Then try to query it with `dig` command like below:

```
# dig +short -t srv _autodiscover._tcp.customer.com
1 1 443 mail.host.com.
```

Create temporary text file `/tmp/outlook.xml` with content below:

```
<?xml version="1.0" encoding="utf-8" ?>
<Autodiscover xmlns="http://schemas.microsoft.com/exchange/autodiscover/outlook/requestschema/2006">
    <Request>
        <AcceptableResponseSchema>http://schemas.microsoft.com/exchange/autodiscover/outlook/responseschema/2006a</AcceptableResponseSchema>

        <!-- EMailAddress: indicates the user's email address. OPTIONAL -->
        <EMailAddress>user@customer.com</EMailAddress>
    </Request>
</Autodiscover>
```

Create temporary text file `/tmp/eas.xml` with content below:

```
<?xml version="1.0" encoding="utf-8"?>
<Autodiscover xmlns="http://schemas.microsoft.com/exchange/autodiscover/mobilesync/requestschema/2006">
    <Request>
        <EMailAddress>user@customer.com</EMailAddress>
        <AcceptableResponseSchema>http://schemas.microsoft.com/exchange/autodiscover/mobilesync/responseschema/2006</AcceptableResponseSchema>
    </Request>
</Autodiscover>
```

Now run `curl` commands to verify it:

```
curl -k -X POST -d @/tmp/outlook.xml https://autodiscover.customer.com/autodiscover/autodiscover.xml
curl -k -X POST -d @/tmp/eas.xml https://autodiscover.customer.com/autodiscover/autodiscover.xml

curl -k -X POST -d @/tmp/outlook.xml https://mail.host.com/autodiscover/autodiscover.xml
curl -k -X POST -d @/tmp/eas.xml https://mail.host.com/autodiscover/autodiscover.xml
```

It should print XML format content on console.
