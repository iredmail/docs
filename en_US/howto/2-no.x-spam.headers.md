# Amavisd + SpamAssassin not working? no mail header (X-Spam-*) inserted

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

Amavisd's main config file is different on different Linux/BSD distributions:

* Red Hat, CentOS, OpenBSD: `/etc/amavisd/amavisd.conf`
* Debian, Ubuntu: `/etc/amavis/conf.d/50-user` (and other config files under `/etc/amavis/conf.d/`)
* FreeBSD: `/usr/local/etc/amavisd/amavisd.conf`
