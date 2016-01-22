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
> * Script `wblist_admin.py` is available in iRedAPD-1.7.0 and later releases.

White/blacklisting is controlled by plugin `amavisd_wblist` (file
`/opt/iredapd/plugins/amavisd_wblist.py`), you can manage it with script
`/opt/iredapd/tools/wblist_admin.py`.

Available arguments:

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

Sample usage:

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
> * Script `/opt/iredapd/tools/greylisting_admin.py` is available in
>   iRedAPD-1.8.0 and later releases.

Greylisting is controlled by plugin `greylisting` (file
`/opt/iredapd/plugins/greylisting.py`), you can manage it with script
`/opt/iredapd/tools/greylisting_admin.py`.

Available arguments:

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

Sample usages:

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
