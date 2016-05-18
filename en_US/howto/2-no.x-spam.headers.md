# Amavisd + SpamAssassin not working? no mail header (X-Spam-*) inserted

> Amavisd config file is different on different Linux/BSD distributions, you can
> find the correct one for your server in this tutorial:
> [Locations of configuration and log files of major components](./file.locations.html#amavisd)

To understand whether Amavisd + SpamAssassin are working, you can add this
setting to Amavisd config file:

```
$log_templ = $log_verbose_templ;
```

Then restart Amavisd service, it will log verbose message in log file. For
example:

> May 18 09:54:15 ob amavis[24548]: (24548-01) Passed CLEAN {RelayedInbound}, [127.0.0.1] /ESMTP <root@...mail.org> -> <bugs@...bsd.org>, (), Message-ID: <20160518015301.B2A741344D@...mail.org>, mail_id: JcfAanaWAP-2, b: efIM2W-Q-, Hits: -, size: 161634, queued_as: 4756B13453, Subject: "ldapd(8) doesn't correctly handle MOD_DELETE operation", From: <zhb@...mail.org>, helo=...mail.org, 160 ms
```

If you really want `X-Spam-*` headers in email, please decrease Amavisd setting
`$sa_tag_level_deflt` to a very low score, e.g. `-999`, then restart Amavisd
service. it will always insert `X-Spam-*` headers in email:

```
$sa_tag_level_deflt  = -999;
```

That means Amavisd will insert `X-Spam-Flag` and other `X-Spam-*` headers when
email score >= `-999`.
