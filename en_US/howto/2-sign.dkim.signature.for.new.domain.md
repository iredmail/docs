# Sign DKIM signature on outgoing emails for new mail domain

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

> Don't know what DKIM is? Check our tutorial here:
>  [What is a DKIM DNS record](./setup.dns.html#dkim-record-for-your-mail-domain-name).


> Don't know where Amavisd config file is? check this tutorial:
> [Locations of configuration and log files of major components](file.locations.html#amavisd).

iRedMail configures Amavisd to sign outgoing emails for the first mail domain
you added during iRedMail installation. If you added new mail domain, you
should update Amavisd config file to sign DKIM signature for it.

Let's say your first mail domain added during iRedMail installation is
`mydomain.com`, and new mail domain is `new_domain.com`, please follow below
steps to enable DKIM signing for outgoing emails of this domain.

## Use existing DKIM key for new mail domain

if you already have a working DKIM and valid DKIM DNS record, it's ok to
use this existing DKIM key to sign emails sent by other hosted mail domains.
This way, you don't need to ask your customer who owns this new domain to add
DKIM DNS record.

* Find below setting in Amavisd config file `amavisd.conf` (find its [location
  on different Linux/BSD distributions](./file.locations.html)):

```
dkim_key('mydomain.com', "dkim", "/var/lib/dkim/mydomain.com.pem");

@dkim_signature_options_bysender_maps = ( {
    ...
    "mydomain.com"  => { d => "mydomain.com", a => 'rsa-sha256', ttl => 10*24*3600 },
    ...
});
```

Copy the `dkim_key('mydomain.com........` line, changing to new hostname, but keep same cert path.  You should now have 2 lines starting with `dkim_key` with differetent domains, but same file path.

Next, add one line in `@dkim_signature_options_bysender_maps`, after `"mydomain.com"`
line like below:

```
@dkim_signature_options_bysender_maps = ( {
    ...
    "mydomain.com"  => { d => "mydomain.com", a => 'rsa-sha256', ttl => 10*24*3600 },
    "new_domain.com"  => { d => "mydomain.com", a => 'rsa-sha256', ttl => 10*24*3600 },
    ...
});
```

* Restart Amavisd service.
* Test with `amavisd testkeys` and both domains should print with a `pass`

## Generate new DKIM key for new mail domain

If you or your customer prefer to use their own DKIM key, you can generate
a new DKIM key and ask your customer to add DKIM DNS record. Refer to our
tutorial to [add DKIM DNS record](setup.dns.html#dkim-record-for-your-mail-domain-name).

* Generate new DKIM key (key length `1024`) for new domain, and set correct
  file owner and permission

    * on RHEL/CentOS, the command is `amavisd`, user/group is `amavis:amavis`.
    * on Debian/Ubuntu, the command is `amavisd-new`, user/group is `amavis:amavis`.
    * on FreeBSD, the command is `amavisd`, user/group is `vscan:vscan`.
    * on OpenBSD, the command is `amavisd`, user/group is `_vscan:_vscan`.

```shell
amavisd-new genrsa /var/lib/dkim/new_domain.com.pem 1024
chown amavis:amavis /var/lib/dkim/new_domain.com.pem
chmod 0400 /var/lib/dkim/new_domain.com.pem
```

!!! note

    * on different Linux/BSD distributions, the command may be `amavisd`
    * on RHEL/CentOS, you must specify the config file on command line like this:

    ```# amavisd -c /etc/amavisd/amavisd.conf genrsa /var/lib/dkim/new_domain.com.pem```

    * Not all DNS vendors support 2048-bit key length as TXT type record, so
      iRedMail generates the key in 1024-bit. If you want to use 2048-bit
      instead, please specify the key length on command line:

    ```# amavisd -c /etc/amavisd/amavisd.conf genrsa /var/lib/dkim/new_domain.com.pem 2048```

* Find below setting in Amavisd config file `amavisd.conf`:

```
dkim_key('mydomain.com', "dkim", "/var/lib/dkim/mydomain.com.pem");
```

Add one line after above line like below:

```
dkim_key('new_domain.com', "dkim", "/var/lib/dkim/new_domain.com.pem");
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
    "new_domain.com"  => { d => "new_domain.com", a => 'rsa-sha256', ttl => 10*24*3600 },
    ...
});
```

* Restart Amavisd service.

Again, don't forget to add DKIM DNS record for this new domain. The value of
DKIM record can be checked with command below:

```shell
# amavisd-new showkeys
```

After added DKIM DNS record, please verify it with command:

```shell
# amavisd-new testkeys
```

Note: DNS vendor usually cache DNS records for 2 hours, so if above command
shows "invalid" instead of "pass", you should try again later.

## Use one DKIM key for all mail domains

If you want to use one DKIM key for all mail domains, please follow steps below:

* Make sure you have at least one DKIM key configured like below in Amavisd
  config file (`amavisd.conf`):

```
dkim_key('mydomain.com', "dkim", "/var/lib/dkim/mydomain.com.pem");
```

* Find parameter `@dkim_signature_options_bysender_maps`, and set it to:

```
@dkim_signature_options_bysender_maps = ({
    # catch-all (one dkim key for all domains)
    '.' => {d => 'mydomain.com',
            a => 'rsa-sha256',
            c => 'relaxed/simple',
            ttl => 30*24*3600 },
});
```

* Restart Amavisd serivce.

## References

* Amavisd official document: [Setting up DKIM mail signing and verification](http://www.ijs.si/software/amavisd/amavisd-new-docs.html#dkim)
