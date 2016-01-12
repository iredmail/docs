# Disable spam virus scanning for outgoing mails

To disable spam/virus scanning for outgoing mails, you can add bypass settings
in Amavisd config file: `/etc/amavisd/amavisd.conf` (RHEL/CentOS) or
`/etc/amavis/conf.d/50-user` (Debian/Ubuntu) or `/usr/local/etc/amavisd.conf`
(FreeBSD).

* bypass_spam_checks_maps
* bypass_virus_checks_maps
* bypass_header_checks_maps
* bypass_banned_checks_maps

These settings can be added in setting block `$policy_bank{'ORIGINATING'}`:

```perl
$policy_bank{'ORIGINATING'} = {
    [...OMIT OTHER SETTINGS HERE...]

    # don't perform spam/virus/header check.
    bypass_spam_checks_maps => [1],
    bypass_virus_checks_maps => [1],
    bypass_header_checks_maps => [1],

    # allow sending any file names and types
    bypass_banned_checks_maps => [1],
}
```

Restarting Amavisd service is required after changing settings.
