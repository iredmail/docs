# Setup DNS records for your iRedMail server (A, PTR, MX, SPF, DKIM, DMARC)

[TOC]

__IMPORTANT NOTE__: `A`, `MX` records are required, `Reverse PTR`, `SPF`,
`DKIM` and `DMARC` are optional but __HIGHLY__ recommended.

## `A` record for server hostname {: id="a" }

### What is an `A` record

`A` records map a FQDN (fully qualified domain name) to an IP address. This is
usually the most often used record type in any DNS system. This is the DNS
record you should add if you want to point a domain name to a web server.

### How to setup an `A` Record

* `Name`: This will be the host for your domain which is actually a computer
  within your domain. Your domain name is automatically appended to your name.
  If you are trying to make a record for the system `www.mydomain.com`. Then all
  you enter in the textbox for the name value is `www`.

    __Note__: If you leave the name field blank it will default to be the record
    for your base domain `mydomain.com`. The record for your base domain is
    called the root record or apex record.

* `IP`: The IP address of your FQDN. An IP address can be thought of as
the telephone number to your computer. It is how one computer knows how to
reach another computer. Similar to the country codes, area codes, and phone
number it is used to call someone.

* `TTL`: The TTL (Time to Live) is the amount of time your record will stay
in cache on systems requesting your record (resolving nameservers, browsers,
etc.). The TTL is set in seconds, so 60 is one minute, 1800 is 30 minutes, etc..

Systems that have a static IP should usually have a TTL of 1800 or higher.
Systems that have a dynamic IP should usually have a TTL of 1800 of less.

The lower the TTL the more often a client will need to query the name servers
for your host's (record's) IP address this will result in higher query traffic
for your domain name. Where as a very high TTL can cause downtime when you
need to switch your IPs quickly.

Sample record:

```
NAME                TTL     TYPE    DATA

www.mydomain.com.   1800    A       192.168.1.2
mail.mydomain.com.  1800    A       192.168.1.5
```

The end result of this record is that `www.mydomain.com` points to
`192.168.1.2`, and `mail.mydomain.com` points to `192.168.1.5`.

## Reverse PTR record for server IP address {: id="ptr" }

### What is a reverse PTR record

PTR record or more appropriately a reverse PTR record is a process of resolving
an IP address to its associated hostname. This is the exact opposite of the
process of resolving a hostname to an IP address (`A` record). Example, when you ping a
name `mail.mydomain.com` it will get resolved to the ip address using the DNS
to something like `192.168.1.5`. Reverse PTR record does the opposite; it looks
up the hostname for the given IP address. In the example above the PTR record
for IP address `192.168.1.5` will get resolved to `mail.mydomain.com`.

### Why do you need a reverse PTR record

The most common use for looking up a PTR record is done by spam filters.
Concept behind this idea is that fly by night spammers who send e-mails out
using fake domains generally will not have the appropriate reverse PTR setup
at the ISP DNS zone. This criterion is used by spam filters to detect spam. If
your domain does not have an appropriate reverse PTR record setup then chances
are email spam filtering softwares __MIGHT__ block e-mails from your mail server.

### How to setup a Reverse PTR record

You would most likely need to contact your ISP and make a request to create a
reverse PTR record for your mail server IP address. For example, if your mail
server hostname is `mail.mydomain.com` then ask your ISP to setup a reverse
PTR record `192.168.1.5` (your internet public IP address) in their reverse DNS
zone. Reverse DNS zones are handled by your ISP even though you may have your
own forward lookup DNS zone that you manage.

## MX record for mail domain name {: id="mx" }

### What is a MX record

Mail Exchanger Record or more commonly known as MX record is an entry in the
DNS server of your domain that tells other mail servers where your mail server
is located. When someone sends an e-mail to a user that exists on your mail
server from the internet, MX provides the location or IP address where to send
that e-mail. MX record is the location of your mail server that you have
provided to the outside world via the DNS.

Most mail servers generally have more than one MX record, meaning you could
have more than one mail server setup to receive e-mails. Each MX record has a
priority number assigned to it in the DNS. The MX record with __lowest number
has the highest priority__ and that is considered your primary MX record or
your main mail server. The next lowest mx number has the next highest primary
and so on. You generally have more than one mail server, one being the primary
and the others as backups, only one MX for mail server is OK too.

### How to setup the MX record

If your ISP or domain name registrar is providing the DNS service, you can
request them to set one up for you. If you manage your own DNS servers then
you need to create the MX records in your DNS zone yourself.

Sample MX record:

```
NAME            PRIORITY    TYPE    DATA

mydomain.com.   10          mx      mail.mydomain.com
```

The end result of this record is, emails sent to `[user]@mydomain.com` will
be delivered to server `mail.mydomain.com`.

## SPF record for the mail domain name {: id="spf" }

### What is a SPF record

SPF is a spam and phishing scam fighting method which uses DNS SPF-records to
define which hosts are permitted to send e-mails for a domain. For details on
SPF, please check [wikipedia](https://en.wikipedia.org/wiki/Sender_Policy_Framework).

This works by defining a DNS SPF-record for the e-mail domain name specifying
which hosts (e-mail servers) are permitted to send e-mail from the domain name.

Other e-mail servers can lookup this record when receiving an e-mail from this
domain name to verify that sending e-mail server is connecting from a permitted
IP address.

### How to setup the SPF record

SPF is a TXT type DNS record, you can list IP address(es) or MX domains in it.
For example:

```
mydomain.com.   3600    IN  TXT "v=spf1 mx -all"
```

This SPF record means emails sent from all servers defined in MX record of
`mydomain.com` are permitted to send as `someone@mydomain.com`.

`-all` means prohibit emails sent from all other servers. If it's too strict
for you, you can use `~all` instead which means soft fail (uncertain).

You can specify IP address(es) directly too:

```
mydomain.com.   3600    IN  TXT "v=spf1 ip4:111.111.111.111 ip4:111.111.111.222 -all"
```

Of course you can have them both or more in same record:

```
mydomain.com.   3600    IN  TXT "v=spf1 mx ip4:111.111.111.222 -all"
```

There're more valid mechanisms available, please check
[wikipedia](https://en.wikipedia.org/wiki/Sender_Policy_Framework) for more details.

## DKIM record for the mail domain name {: id="dkim" }

### What is a DKIM record

DKIM allows an organization to take responsibility for a message in a way that
can be verified by a recipient. The organization can be a direct handler of
the message, such as the author's, the originating sending site's, or an
intermediary's along the transit path. However, it can also be an indirect
handler, such as an independent service that is providing assistance to a
direct handler. DKIM defines a domain-level digital signature authentication
framework for email through the use of public-key cryptography and using the
domain name service as its key server technology
([RFC4871](http://www.dkim.org/specs/rfc5585.html#RFC4871)). It permits
verification of the signer of a message, as well as the integrity of its
contents. DKIM will also provide a mechanism that permits potential email
signers to publish information about their email signing practices; this will
permit email receivers to make additional assessments of unsigned messages.
DKIM's authentication of email identity can assist in the global control of
"spam" and "phishing".

A person or organization has an "identity" -- that is, a constellation of
characteristics that distinguish them from any other identity. Associated
with this abstraction can be a label used as a reference, or "identifier".
This is the distinction between a thing and the name of the thing. DKIM uses
a domain name as an identifier, to refer to the identity of a responsible
person or organization. In DKIM, this identifier is called the Signing Domain
IDentifier (SDID) and is contained in the DKIM-Signature header fields `d=`
tag. Note that the same identity can have multiple identifiers.

### How to setup the DKIM record

* Run command in terminal to show your DKIM keys:

    !!! attention

        * On some Linux/BSD distribution, you should use command `amavisd-new`
          instead of `amavisd`.
        * If it complains `/etc/amavisd.conf not found`, please
          run the command with path to its config file. For example:

            `amavisd -c /etc/amavisd/amavisd.conf showkeys`

```bash
# amavisd showkeys
dkim._domainkey.mydomain.com.   3600 TXT (
  "v=DKIM1; p="
  "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDYArsr2BKbdhv9efugByf7LhaK"
  "txFUt0ec5+1dWmcDv0WH0qZLFK711sibNN5LutvnaiuH+w3Kr8Ylbw8gq2j0UBok"
  "FcMycUvOBd7nsYn/TUrOua3Nns+qKSJBy88IWSh2zHaGbjRYujyWSTjlPELJ0H+5"
  "EV711qseo/omquskkwIDAQAB")
```

* Copy output of command above into one line like below, remove all quotes, but
  keep `;`. __we just need strings inside the `()` block__, it's the value of
  DKIM DNS record.

```
v=DKIM1; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDYArsr2BKbdhv9efugBy...
```

__Note__: BIND ([The most widely used Name Server Software](http://www.isc.org/downloads/bind/))
can handle this kind of multi-line format, so you can paste it in your domain
zone file directly.

* Add `TXT` type DNS record for domain name `dkim._domainkey.mydomain.com`,
  set value to the line you copied above: `v=DKIM1; p=...`.

    > WARNING: A usual mistake is adding this DKIM record to domain name
    > `mydomain.com`, this is wrong. Please make sure you added to domain name
    > `dkim._domainkey.mydomain.com`.

* After you added this in DNS, verify it with `dig` or `nslookup`:

```
$ dig -t txt dkim._domainkey.mydomain.com

$ nslookup -type=txt dkim._domainkey.foodmall.com
```

Sample output:

```
dkim._domainkey.mydomain.com. 600 IN TXT	"v=DKIM1\;p=..."

```

And verify it with Amavisd:

```shell
# amavisd testkeys
TESTING: dkim._domainkey.mydomain.com       => pass
```

If it shows `pass`, it works.

__Note__: If you use DNS service provided by ISP, new DNS record might take
some hours to be available.

If you want to re-generate DKIM key, or need to generate one for new mail
domain, please check our another tutorial:
[Sign DKIM signature on outgoing emails for new mail domain](./sign.dkim.signature.for.new.domain.html).

## DMARC record for the mail domain name {: id="dmarc" }

### What is DMARC, and how does it combat phishing?

Quote from [FAQ page on dmarc.org website](https://dmarc.org/wiki/FAQ) (it's
strongly recommended to read the full FAQ page):

> DMARC is a way to make it easier for email senders and receivers to determine
> whether or not a given message is legitimately from the sender, and what to
> do if it isn’t. This makes it easier to identify spam and phishing messages,
> and keep them out of peoples’ inboxes.
>
> DMARC is a proposed standard that allows email senders and receivers to
> cooperate in sharing information about the email they send to each other.
> This information helps senders improve the mail authentication infrastructure
> so that all their mail can be authenticated. It also gives the legitimate
> owner of an Internet domain a way to request that illegitimate messages –
> spoofed spam, phishing – be put directly in the spam folder or rejected
> outright.

Some useful documents from <https://dmarc.org>:

* [DMARC FAQ](https://dmarc.org/wiki/FAQ)
    * [Why is DMARC Important?](https://dmarc.org/wiki/FAQ#Why_is_DMARC_important.3F)
* [How Does DMARC Work?](https://dmarc.org/overview/)
* [Specifications](https://dmarc.org/resources/specification/)

### How to setup the DMARC record

!!! attention

    DMARC heavily relies on SPF and DKIM records, please make sure you have
    correct and up to date SPF and DKIM records published.

DMARC record is a TXT type DNS record.

A simplified record looks like this:

```
v=DMARC1; p=none; rua=mailto:dmarc@mydomain.com
```

A detailed sample record looks like this:

```
v=DMARC1; adkim=s; aspf=s; p=reject; sp=none; rua=mailto:dmarc@mydomain.com; ruf=mailto:dmarc@mydomain.com
```

* `v=DMARC1` identifies the DMARC protocol version, currently only `DMARC1` is
  available, and `v=DMARC1` must appear first in a DMARC record.
* `adkim` specifies alignment mode for DKIM. 2 options are available:
    * `r`: relax mode (`adkim=r`)
    * `s`: strict mode (`adkim=s`)
* `aspf` specifies aligment mode for SPF. 2 options are available:
    * `r`: relax mode (`aspf=r`)
    * `s`: strict mode (`aspf=s`)
* `p` specifies the policy for organizational domain. It tells the recipient
  server what to do if received email fails DMARC mechanism check. 3 options
  are available:

    * `none` (`p=none`): The domain owner requests no specific action be taken regarding
      delivery of messages.
    * `quarantine` (`p=quarantine`): The domain owner wishes to have email that fails the DMARC
      mechanism check be treated by Mail Receivers as suspicious. Depending on
      the capabilities of the Mail Receiver, this can mean "place into spam
      folder", "flag as suspicious", or "quarantine toe email somewhere", maybe more.
    * `reject` (`p=reject`): The domain owner wishes for Mail Receivers to reject
      email that fails the DMARC mechanism check during the SMTP transaction.

    !!! attention

        If you're sure all your emails are sent by the server(s) listed in SPF
        record, or have correct DKIM signature signed, `p=reject` is strongly
        recommended.

* `sp` specifies policy for all subdomains. This is optional. Available options
  are same as `p`.
* `rua` specifies a transport mechanism to deliver aggregate feedback. Currently
  only `mailto:` is supported. This is optional.
* `ruf` specifies a transport mechanism which message-specific failure
  information is to be reported. Currently only `mailto:` is supported. This is
  optional.

## SRV record for Jabber/XMPP service

If you install Prosody (with iRedMail Easy platform) as Jabber/XMPP server,
2 SRV records are required.

If your mail domain name is `mydomain.com` and server hostname is
`mail.mydomain.com`, you should add 2 SRV type DNS records:

- `_xmpp-client._tcp.mydomain.com`
- `_xmpp-server._tcp.mydomain.com`

Sample records:

```
_xmpp-client._tcp.mydomain.com 18000 IN SRV 0 5 5222 mail.mydomain.com
_xmpp-server._tcp.example.com. 18000 IN SRV 0 5 5269 mail.mydomain.com
```

The target domain `mail.mydomain.com` __MUST__ be an existing A record, it
cannot be an IP address or a CNAME record.

## Register your mail domain in Google Postmaster Tools

This step is __optional__, but __highly recommended__.

Google Postmaster Tools web site: <https://postmaster.google.com>, and
[Postmaster Tools FAQs](https://support.google.com/mail/answer/6258950).

It's very simple: just register your mail domain there, and they'll give you a
text record for your DNS so that they can validate the ownership of the domain.

Why use Google Postmaster Tools? Quote from
[Google Postmaster Tools help page](https://support.google.com/mail/answer/6227174):

> If you send a large volume of emails to Gmail users, you can use Postmaster Tools to see:
>
> * If users are marking your emails as spam
> * Whether you’re following Gmail's best practices
> * Why your emails might not be delivered
> * If your emails are being sent securely

It *__MIGHT__* also help to get you out of the `Junk` mailbox.

If you have trouble in sending email to Gmail (or Google Apps), Google offers
some information on best practices to ensure that their mail is delivered to
Gmail users: [Bulk Senders Guidelines](https://support.google.com/mail/answer/81126?hl=en).

You may also submit this form to contact Google:
[Bulk Sender Contact Form](https://support.google.com/mail/contact/bulk_send_new?rd=1)

## Check Outlook.com Postmaster site

Outlook Postmaster site provides some useful information for mail server
administrators, if the email you sent to Outlook.com is marked as spam, please
take a look:

- [Outlook.com Postmaster](https://sendersupport.olc.protection.outlook.com/pm/)
- [Smart Network Data Service](https://sendersupport.olc.protection.outlook.com/snds/)

## References

* [wikipedia: Sender Policy Framework](https://en.wikipedia.org/wiki/Sender_Policy_Framework)
* [http://www.dkim.org/](http://www.dkim.org/)
