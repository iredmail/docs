# Manage iRedAPD (white/blacklists, greylisting)

[TOC]

> Note: all iRedAPD features listed in current page can be managed with our
> web-based admin panel - [iRedAdmin-Pro](../admin_panel.html).

## Introduce iRedAPD

iRedAPD is a simple Postfix policy server, written in Python, with plugin
support. it listens on port `7777` by default, and runs as a low-privileged
user `iredapd`.

## Manage white/blacklists

> * White/blacklisting is available in iRedAPD-1.4.4 and later releases.
> * Script `tools/wblist_admin.py` is available in iRedAPD-1.7.0 and later releases.

White/blacklisting is controlled by plugin `amavisd_wblist` (file
`/opt/iredapd/plugins/amavisd_wblist.py`), you can manage it with script
`/opt/iredapd/tools/wblist_admin.py`.

### Available arguments

```
    --outbound
        Manage white/blacklist for outbound messages.

        If no '--outbound' argument, defaults to manage inbound messages.

    --account account
        Add white/blacklists for specified (local) account. Valid formats:

            - a single user: username@domain.com
            - a single domain: @domain.com
            - entire domain and all its sub-domains: @.domain.com
            - anyone: @. (the ending dot is required)

        if no '--account' argument, defaults to '@.' (anyone).

    --add
        Add white/blacklists for specified (local) account.

    --delete
        Delete specified white/blacklists for specified (local) account.

    --delete-all
        Delete ALL white/blacklists for specified (local) account.

    --list
        Show existing white/blacklists for specified (local) account. If no
        account specified, defaults to manage server-wide white/blacklists.

    --whitelist sender1 [sender2 sender3 ...]
        Whitelist specified sender(s). Multiple senders must be separated by a space.

    --blacklist sender1 [sender2 sender3 ...]
        Blacklist specified sender(s). Multiple senders must be separated by a space.

    WARNING: Do not use --list, --add-whitelist, --add-blacklist at the same time.

    --noninteractive
        Don't ask to confirm.
```

### Sample usages

* Show and add server-wide whitelists or blacklists:

```
# python wblist_admin.py --list --whitelist
# python wblist_admin.py --list --blacklist
# python wblist_admin.py --add --whitelist 192.168.1.10 user@domain.com
# python wblist_admin.py --add --blacklist 172.16.1.10 user@domain.com
```

* For per-user or per-domain whitelists and blacklists, please use option
  `--account`. for example:

```
# python wblist_admin.py --account @mydomain.com --add --whitelist 192.168.1.10 user@example.com
# python wblist_admin.py --account user@mydomain.com --add --blacklist 172.16.1.10 baduser@example.com

# python wblist_admin.py --account @mydomain.com --list --whitelist
# python wblist_admin.py --account user@mydomain.com --list --blacklist
```

## Manage greylisting settings

> * Greylisting is available in iRedAPD-1.7.0 and later releases.
> * Script `tools/greylisting_admin.py` is available in iRedAPD-1.8.0 and
>   later releases.

Greylisting is controlled by plugin `greylisting` (file
`/opt/iredapd/plugins/greylisting.py`), you can manage it with script
`/opt/iredapd/tools/greylisting_admin.py`.

### Available arguments

```
    --list
        Show ALL existing greylisting settings.

    --from <from_address>
    --to <to_address>
        Manage greylisting setting from email which is sent from <from_address>
        to <to_address>.
        
        Valid formats for both <from_address> and <to_address>:

            - a single user: username@domain.com
            - a single domain: @domain.com
            - entire domain and all its sub-domains: @.domain.com
            - anyone: @. (the ending dot is required)

        if no '--from' or '--to' argument, defaults to '@.' (anyone).

    --enable
        Explicitly enable greylisting for specified account.

    --disable
        Explicitly disable greylisting for specified account.

    --delete
        Delete specified greylisting setting.
```

### Sample usages

* List all existing greylisting settings

```
# cd /opt/iredapd/tools/
# python greylisting_admin.py --list
```

* Enable greylisting for emails which are sent from anyone to local mail domain `example.com`:

```
# python greylisting_admin.py --enable --to '@example.com'
```

* Disable greylisting for emails which are sent from anyone to local mail user `user@example.com`:

```
# python greylisting_admin.py --disable --to 'user@example.com'
```

* Disable greylisting for emails which are sent from `gmail.com` to local mail user `user@example.com`

```
# python greylisting_admin.py --disable --from '@gmail.com' --to 'user@example.com'
```

* Delete greylisting setting for emails which are sent from anyone to local domain `test.com`

```
# python greylisting_admin.py --delete --to '@test.com'
```

### Additional greylisting whitelist support

Seems many companies setup their mail servers to re-deliver returned email
immediately from another server, this causes trouble with greylisting.

Possible solutions:

1. Disable greylisting on your server completely.
2. Whitelist IP addresses/networks of their mail servers.

For solution #2, you can whitelist those mail servers with script
`/opt/iredapd/tools/spf_to_greylit_whitelists.py`.

> Note: script `tools/spf_to_greylit_whitelists.py` is available in iRedAPD-1.8.0 and later releases.

It queries SPF and MX records of specified mail domain names, then store all
converted IP addresses/networks defined in SPF/MX records in SQL table
`iredapd.greylisting_whitelists`.

To whitelist IP addresses/networks of some mail domain, for example,
`outlook.com`, `microsoft.com`, please run command like below:

```
# cd /opt/iredapd/tools/
# python spf_to_greylit_whitelists.py outlook.com microsoft.com
```

If you want to whitelist more mail domains, just run the command with the
domain names like above sample.

Since iRedAPD-1.8.0, we have SQL table `iredapd.greylisting_whitelist_domains`
to store these mail domain names. if you run `spf_to_greylit_whitelists.py`
without any argument, it will fetch all mail domains stored in sql table 
`greylisting_whitelist_domains` instead of fetching from command line arguments.

```
# python spf_to_greylit_whitelists.py
```

You should setup a cron job to run this script, so that it can keep the IP
addresses/networks up to date. iRedMail sets up the cron job to run every 10
minutes, like below:

```
*/10   *   *   *   *   /usr/bin/python /opt/iredapd/tools/spf_to_greylisting_whitelists.py &>/dev/null
```
