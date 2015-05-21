# Upgrade iRedMail from 0.9.1 to 0.9.2

[TOC]


## ChangeLog

> We provide remote upgrade service, check [the price](../support.html) and [contact us](../contact.html).

* 2015-05-16: [All backends][RHEL/CentOS] Don't ban 'application/octet-stream,
              dat' files in Amavisd. It catches too many normal file types.
* 2015-05-16: [OPTIONAL][All backends] Update one Fail2ban filter regular
              expressio to help catch DoS attacks to SMTP service

## General (All backends should apply these steps)

### Don't ban 'application/octet-stream, dat' files in Amavisd

Note: This is only applicable to RHEL/CentOS.

* Find below lines in Amavisd config file `/etc/amavisd/amavisd.conf`:

```
$banned_namepath_re = new_RE(
    # Unknown binary files.
    [qr'M=application/(zip|rar|arc|arj|zoo|gz|bz2|octet-stream)(,|\t).*T=dat(,|\t)'xmi => 'DISCARD'],
    ...
);
```

* Remove `|octet-stream` in 3rd line. After modified, it's:

```
$banned_namepath_re = new_RE(
    # Unknown binary files.
    [qr'M=application/(zip|rar|arc|arj|zoo|gz|bz2)(,|\t).*T=dat(,|\t)'xmi => 'DISCARD'],
    ...
);
```

* Restart Amavisd service.

```
# service amavisd restart
```

### [OPTIONAL] Update one Fail2ban filter regular expressio to help catch DoS attacks to SMTP service

1. Open file `/etc/fail2ban/filters.d/postfix.iredmail.conf` or
`/usr/local/etc/fail2ban/filters.d/postfix.iredmail.conf` (on FreeBSD), find
below line under `[Definition]` section:

```
            lost connection after AUTH from (.*)\[<HOST>\]
```

Update above line to below one:

```
            lost connection after (AUTH|UNKNOWN|EHLO) from (.*)\[<HOST>\]
```

Restarting Fail2ban service is required.
