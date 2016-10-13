# Amavisd + SpamAssassin not working? no mail header (X-Spam-*) inserted

> Amavisd config file is different on different Linux/BSD distributions, you can
> find the correct one for your server in this tutorial:
> [Locations of configuration and log files of major components](./file.locations.html#amavisd)

If you just want to know whether Amavisd + SpamAssassin are working, you can
add setting below to Amavisd config file, then restart Amavisd service. Amavisd
will log verbose message for each processed message in its log file.

```
$log_templ = $log_verbose_templ;
```

Sample log:

```
Oct 12 21:26:34 d8 amavis[1389]: (01389-01) Passed CLEAN {RelayedInternal},
ORIGINATING/MYNETS LOCAL [172.16.100.1]:54180 ESMTP/ESMTP <postmaster@a.cn> ->
<amavis@d8.iredmail.org>, (), Queue-ID: 2F322E003E, mail_id: 47G-u3kjLkOz, b:
3tnIDXRGW, Hits: -0.428, size: 316, queued_as: 58A90DFC34, Subject: "mail subject",
From: <postmaster@a.cn>, helo=test.com, Tests: [ALL_TRUSTED=-1,INVALID_DATE=0.432,
MISSING_MID=0.14], autolearn=no autolearn_force=no, autolearnscore=0.572,
dkim_new=dkim:a.cn, 19162 ms
```

The "Tests:" flag includes spam scanning result from SpamAssassin.

If you want Amavisd to insert `X-Spam-*` headers in each email, please decrease
Amavisd setting `$sa_tag_level_deflt` (in Amavisd config file )to a very low
score, e.g. `-999`, then restart Amavisd service:

```
$sa_tag_level_deflt  = -999;
```

That means Amavisd will insert `X-Spam-Flag` and other `X-Spam-*` headers when
email score >= `-999`.
