# Sign disclaimer on outgoing mails

!!! note

    If you're not sure which is Amavisd config file on your server, please
    check our document to find it:

    * [Locations of configuration and log files of major components](./file.locations.html)

With iRedMail, it's able to sign disclaimer on outgoing email with Amavisd-new
and alterMIME, it is pre-configured but disabled by default.

To enable the signing, please find setting in Amavisd config file `amavisd.conf`:

```
#$defang_maps_by_ccat{+CC_CATCHALL} = [ 'disclaimer' ];
```

Uncomment the `$defang_maps_by_ccat` line and restart Amavisd service will
enable signing disclaimer on outgoing email, default disclaimer text is stored
in `/etc/postfix/disclaimer/default.txt` (Linux/OpenBSD) or
`/usr/local/etc/postfix/disclaimer/default.txt`.

If you need a per-domain disclaimer, please update setting `@disclaimer_options_bysender_maps`
in Amavisd config file, add your domain name in correct syntax, then create
required file with disclaimer text. For example, for domain `example.com`:


```
@disclaimer_options_bysender_maps = ({
    # domain 'example.com'
    # disclaimer text file: /etc/postfix/disclaimer/example.com.txt
    'example.com' => 'example.com',

    # Catch-all disclaimer setting: /etc/postfix/disclaimer/default.txt
    '.' => 'default',
},);
```

Restarting Amavisd service is required each time you changed its config file.
