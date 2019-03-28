# Enable SRS (Sender Rewriting Scheme) support

[TOC]

!!! attention

    If you deploy iRedMail server with the
    [iRedMail Easy](https://www.iredmail.org/easy.html) platform, you can
    simply enable or disable it by toggling on/off a checkbox on the mail
    server profile page, then apply the change.

## What SRS is

It's recommended to read links below to understand what SRS is:

* [WikiPedia: Sender Rewriting Scheme](https://en.wikipedia.org/wiki/Sender_Rewriting_Scheme)
* [The original SRS paper (PDF)](http://www.libsrs2.org/srs/srs.pdf)

## Upgrade iRedAPD to 2.6 or later release

We implemented SRS support since iRedAPD-2.6, please make sure you're running
2.6 or later release. You can check its version by running command below:

```
ls -dl /opt/iredapd
```

To upgrade iRedAPD, please follow this tutorial:
[Upgrade iRedAPD](./upgrade.iredapd.html).

iRedAPD will listen on 3 network ports by default:

* `7777`: for general smtp access policy, including greylisting, throttling,
  white/blacklisting, etc.
* `7778`: for SRS forward rewriting.
* `7779`: for SRS reverse rewriting.

!!! warning

    Server hostname is used as srs domain (the mail domain name in rewritten
    addresses) by default, it's configureable by updating parameter
    `srs_domain =` in iRedAPD config file `/opt/iredapd/settings.py`. You are
    free to use a separated (sub-)domain name as srs domain, for example,
    if you own domain name `example.com`, you can use `srs.example.com` as
    srs domain.

    The srs domain must be resolveable by DNS query and pointed to your
    iRedMail server. MX type DNS record is the best option, although it works
    with just A type DNS record (because MTA falls back to A if no MX record).

## Test SRS

You can use `telnet` or netcat (command `nc`) to test it. We use `nc` for
example here.

Connect to port `7778` first:

```
nc localhost 7778
```

Then type command:

```
get user@gmail.com
```

Since `gmail.com` is an external domain, you should get a rewritten address
returned like this:

```
200 SRS0=XsrM=R5=gmail.com=a@<HOSTNAME>
```

The placholder `<HOSTNAME>` will be replaced by your server hostname.

Then try with your mail domain name (replace `mydomain.com` below by your real
mail domain name):

```
get user@mydomain.com
```

You should get this:

```
500 Domain is a local mail domain, bypassed.
```

If you get same/similar output, the SRS feature is working fine.

## Enable SRS integration in Postfix

Please add 4 new parameters in Postfix config file `/etc/postfix/main.cf` (on
Linux/OpenBSD) or `/usr/local/etc/postfix/main.cf` (on FreeBSD):

```
sender_canonical_maps = tcp:127.0.0.1:7778
sender_canonical_classes = envelope_sender
recipient_canonical_maps = tcp:127.0.0.1:7779
recipient_canonical_classes= envelope_recipient,header_recipient
```

Restarting or reloading Postfix service is required. After restarted/reloaded,
please monitor its log file (`/var/log/maillog`) and pay close attention to the
sender address.

## Known issues of SRS support

* Sender addresses will always be rewritten even if the mail is not
  forwarded at all, except locally hosted mail domains. This is because
  Postfix sends minimal info to iRedAPD via the tcp table lookup, and it
  performs address rewritten at the very beginning before any routing
  decision is made.

* Postfix will rewrite the address in the `Return-Path:` header, if you
  have any sieve rules based on `Return-Path:`, it MAY not work anymore.
  In this case, you need to update your sieve rules to match the rewritten
  address.

* Postfix logs rewritten addresses in its log file, so it may confuse you
  while troubleshooting.

* Amavisd stores rewritten addresses in its SQL database, so the
  `Top 10 Senders` and `Top 10 Recipients` in iRedAdmin-Pro Dashboard page
  may not work well.
