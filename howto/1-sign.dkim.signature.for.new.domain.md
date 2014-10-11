# Sign DKIM signature on outgoing emails for new mail domain

> Don't know where Amavisd config file is? check this tutorial:
> [Locations of configuration and log files of mojor components](file.locations.html#amavisd).

iRedMail configures Amavisd to sign outgoing emails for the first mail domain
you added during iRedMail installation. If you added new mail domain, you
should update Amavisd config file to sign DKIM signature for it.

Let's say your first mail domain added during iRedMail installation is
`mydomain.com`, and new mail domain is `newdomain.com`, please follow below
steps to enable DKIM signing for outgoing emails of this domain.

* Generate new DKIM key for new domain.

```shell
# amavisd-new genrsa /var/lib/dkim/newdomain.com.pem
```

* Find below setting in Amavisd config file `amavisd.conf`:

```
dkim_key('mydomain.com', "dkim", "/var/lib/dkim/mydomain.com.pem");
```

Add one line after above line like below:

```
dkim_key('newdomain.com', "dkim", "/var/lib/dkim/newdomain.com.pem");
```

* Find below setting in Amavisd config file `amavisd.conf`:

```
@dkim_signature_options_bysender_maps = ( {
    ...
    "mydomain.com"  => { d => "mydomain.com", a => 'rsa-sha256', ttl => 10*24*3600 },
    ...
});
```

Add one line after `"mydomain.com"` line like below:

```
@dkim_signature_options_bysender_maps = ( {
    ...
    "mydomain.com"  => { d => "mydomain.com", a => 'rsa-sha256', ttl => 10*24*3600 },
    "newdomain.com"  => { d => "newdomain.com", a => 'rsa-sha256', ttl => 10*24*3600 },
    ...
});
```

* Restart Amavisd service.

## Use one DKIM key for all mail domains

For compatibility with dkim_milter the signing domain can include a '*'
as a wildcard - this is not recommended as this way amavisd could produce
signatures which have no corresponding public key published in DNS.
The proper way is to have one dkim_key entry for each mail domain.

If you still want to try this, please follow below steps:

* Find below setting in Amavisd config file `amavisd.conf`:

```
dkim_key('mydomain.com', "dkim", "/var/lib/dkim/mydomain.com.pem");
```

* Replace it by below line:

```
dkim_key('*', "dkim", "/var/lib/dkim/mydomain.com.pem");
```

* Restart Amavisd serivce.

With above setting, all outbound emails with be signed with this dkim key.
And Amavisd will show a warning message when start amavisd service:

> dkim: wildcard in signing domain (key#1, *), may produce unverifiable
> signatures with no published public key, avoid!

## See also

* Don't know what DKIM is? Check our tutorial here:
  [What is a DKIM DNS record](setup_dns.html#dkim-record-for-your-mail-domain-name).
