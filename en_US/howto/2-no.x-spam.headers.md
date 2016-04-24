# Amavisd + SpamAssassin not working? no mail header (X-Spam-*) inserted

> Amavisd config file is different on different Linux/BSD distributions, you can
> find the correct one for your server in this tutorial:
> [Locations of configuration and log files of major components](./file.locations.html#amavisd)

Amavisd has below setting in its config file `/etc/amavisd/amavisd.conf` by default:

```
$sa_tag_level_deflt  = 2.0;
```

That means Amavisd will insert `X-Spam-Flag` and other `X-Spam-*` headers when
email score >= 2.0. If you want Amavisd always insert these headers, please
set it to a low score, for example:

```
$sa_tag_level_deflt  = -999;
```

Restarting Amavisd service is required after changed setting.
