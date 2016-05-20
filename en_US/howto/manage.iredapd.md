# Manage iRedAPD (white/blacklists, greylisting, and more)

[TOC]

!!! note

    All iRedAPD features listed in current page can be managed with our
    web-based admin panel - [iRedAdmin-Pro](../admin_panel.html).

## Introduce iRedAPD

iRedAPD is a simple Postfix policy server, written in Python, with plugin
support. it listens on port `7777` by default, and runs as a low-privileged
user `iredapd`.

## How to disable iRedAPD service

To disable iRedAPD service:

1. please remove all `check_policy_service inet:127.0.0.1:7777` in Postfix config file
`/etc/postfix/main.cf` (Linux/OpenBSD) or `/usr/local/etc/postfix/main.cf`
(FreeBSD).
1. Restart or reload Postfix service.
1. Disable iredapd service.

## How to enable or disable iRedAPD plugins

iRedAPD plugin is Python file under `/opt/iredapd/plugins/` directory. To
enable a plugin, please find line `plugins =` in iRedAPD config file
`/opt/iredapd/settings.py`, for example:

```
plugins = ['reject_null_sender', 'amavisd_wblist', 'greylisting', 'throttle']
```

If you want to enable plugin `reject_sender_login_mismatch` (file
`/opt/iredapd/plugins/reject_sender_login_mismatch.py`), please add the plugin
name in `plugins =` like below, and restart iRedAPD service:

```
plugins = ['reject_null_sender', 'amavisd_wblist', 'greylisting', 'throttle', 'reject_sender_login_mismatch']
```

The priorities of plugins shipped in iRedAPD are hard-coded, so the order of
plugin name in `plugins =` doesn't matter.

To disable a plugin, just remove the plugin name and restart iRedAPD service.

## How to add custom settings

iRedAPD has some default settings in file
`/opt/iredapd/libs/default_settings.py`, but you should never modify it.
Instead, you should copy the settings you want to modify from
`/opt/iredapd/libs/default_settings.py` to `/opt/iredapd/settings.py`, then
update it with new values. This way you will keep custom settings after
upgrading iRedAPD -- because iRedAPD upgrade tool will copy
`/opt/iredapd/settings.py` to new iRedAPD release during upgrading.

## Feature: Sender address control

Plugin `reject_sender_login_mismatch` will reject emails if:

* smtp authentication username (`sasl_username`) is different than than sender address (`From:`). This is usually called `sender login mismatch`. Note: This can be performed by Postfix with restriction rule `reject_sender_login_mismatch` in `smtpd_sender_restrictions =`.
* sender address is forged (sender doesn't perform smtp auth and sender domain is hosted on localhost)

It offers some parameters to control whether or not to reject email:

* for forged sender address checking:

```
# Check whether sender is forged in message sent without smtp auth.
CHECK_FORGED_SENDER = True

# If you allow someone or some service providers to send email as forged
# (your local) address, you can list all allowed addresses in this parameter.
# For example, if some ISPs may send email as 'user@mydomain.com' (mydomain.com
# is hosted on your server) to you, you should add `user@mydomain.com` as one
# of forged senders.
# Sample: ALLOWED_FORGED_SENDERS = ['user@mydomain.com', 'mydomain.com']
ALLOWED_FORGED_SENDERS = []

```

* for sender login mismatch:

```
# Allow sender login mismatch for specified senders or sender domains.
#
# Sample setting: allow local user `user@local_domain_1.com` and all users
# under `local_domain_2.com` to send email as other users.
#
#   ALLOWED_LOGIN_MISMATCH_SENDERS = ['user@local_domain_1.com', 'local_domain_2.com']
ALLOWED_LOGIN_MISMATCH_SENDERS = []

# Strictly allow sender to send as one of user alias addresses. Default is True.
ALLOWED_LOGIN_MISMATCH_STRICTLY = True

# Allow member of mail lists/alias account to send email as mail list/alias
# ('From: <email_of_mail_list>' in mail header). Default is False.
ALLOWED_LOGIN_MISMATCH_LIST_MEMBER = False
```

## Feature: White/Blacklisting

### How to disable white/blacklists completely

To disable white/blacklists completely, please remove plugin name
`amavisd_wblist` in iRedAPD config file `/opt/iredapd/settings.py`,
parameter `plugins =`:

```
plugins = [..., 'amavisd_wblist', ...]
```

Restarting iRedAPD service is required.

### Manage white/blacklists

> * White/blacklisting is available in iRedAPD-1.4.4 and later releases.
> * Script `tools/wblist_admin.py` is available in iRedAPD-1.7.0 and later releases.

White/blacklisting is controlled by plugin `amavisd_wblist` (file
`/opt/iredapd/plugins/amavisd_wblist.py`), you can manage it with script
`/opt/iredapd/tools/wblist_admin.py`.

#### Available arguments

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
```

#### Sample usages

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

## Feature: Greylisting

!!! attention

    Greylisting is available in iRedAPD-1.7.0 and later releases.

For technical details about greylisting, please visit <http://greylisting.org/>

### How to disable greylisting completely

To disable greylisting completely, please remove plugin name `greylisting`
in iRedAPD config file `/opt/iredapd/settings.py`, parameter `plugins =`:

```
plugins = [..., 'greylisting', ...]
```

Restarting iRedAPD service is required.

### General settings

There're several settings for greylisting behaviour, default values are defined
in `/opt/iredapd/libs/default_settings.py`. If you want to modify them, please
add the settings with custom values in `/opt/iredapd/settings.py`.

* `GREYLISTING_MESSAGE`: the rejection message which will be sent to sender
  server. Default is `Intentional policy rejection, please try again later`.
* `GREYLISTING_BLOCK_EXPIRE`: Time (in MINUTES) to wait before client retrying,
  client will be rejected if retires too soon (in less than specified minutes).
  Defaults to `15` minutes.
* `GREYLISTING_AUTH_TRIPLET_EXPIRE`: Disable greylisting for how long (in DAYS)
  for clients which passed greylisting (retried and delivered). It's also used
  to clean up old greylisting tracking records. Defaults to `30` days.
* `GREYLISTING_UNAUTH_TRIPLET_EXPIRE`: Time (in DAYS) to keep tracking records
  if client didn't pass the greylisting, and no further deliver attempts.
  Defaults to `2` days.

### Manage greylisting settings

> * Script `tools/greylisting_admin.py` is available in iRedAPD-1.8.0 and
>   later releases.

Greylisting is controlled by plugin `greylisting` (file
`/opt/iredapd/plugins/greylisting.py`), you can manage it with script
`/opt/iredapd/tools/greylisting_admin.py`.

#### Available arguments

```
    --list-whitelist-domains
        Show ALL whitelisted sender domain names (in `greylisting_whitelist_domains`)

    --list-whitelists
        Show ALL whitelisted sender addresses (in `greylisting_whitelists`)

    --whitelist-domain
        Whitelist the IP addresses/networks in SPF record of specified sender
        domain for greylisting service. Whitelisted domain is stored in sql
        table `greylisting_whitelist_domains`.

    --remove-whitelist-domain
        Remove whitelisted sender domain

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

#### Sample usages

* List all existing greylisting settings:

```
python greylisting_admin.py --list
```

* List all whitelisted sender domain names (in SQL table `greylisting_whitelist_domains`):

```
python greylisting_admin.py --list-whitelist-domains
```

* List all whitelisted sender addresses (in SQL table `greylisting_whitelists`):

```
python greylisting_admin.py --list-whitelists
```

* Whitelist IP networks/addresses specified in sender domain:

```
python greylisting_admin.py --whitelist-domain --from '@example.com'
```

This is same as:

```
python spf_to_whitelist_domains.py --submit example.com
```

* Remove a whitelisted sender domain:

```
python greylisting_admin.py --remove-whitelist-domain --from '@example.com'
```

* Enable greylisting for emails which are sent from anyone to local mail domain `example.com`:

```
python greylisting_admin.py --enable --to '@example.com'
```

* Disable greylisting for emails which are sent from anyone to local mail user `user@example.com`:

```
python greylisting_admin.py --disable --to 'user@example.com'
```

* Disable greylisting for emails which are sent from `gmail.com` to local mail user `user@example.com`:

```
python greylisting_admin.py --disable --from '@gmail.com' --to 'user@example.com'
```

* Delete greylisting setting for emails which are sent from anyone to local domain `test.com`:

```
python greylisting_admin.py --delete --to '@test.com'
```

#### RECOMMENDED: Additional greylisting whitelist support

Seems many companies setup their mail servers to re-deliver returned email
immediately from another server, this causes trouble with greylisting.

Possible solutions:

1. Disable greylisting on your server completely.
1. [Recommended] Whitelist IP addresses/networks of their mail servers.

For solution #2, you can whitelist those mail servers with script
`/opt/iredapd/tools/spf_to_greylist_whitelists.py`.

!!! attention

    Script `tools/spf_to_greylist_whitelists.py` is available in iRedAPD-1.8.0 and later releases.

It queries SPF and MX records of specified mail domain names, then store all
converted IP addresses/networks defined in SPF/MX records in SQL table
`iredapd.greylisting_whitelists`.

To whitelist IP addresses/networks of some mail domain, for example,
`outlook.com`, `microsoft.com`, please run command like below:

```
# cd /opt/iredapd/tools/
# python spf_to_greylist_whitelists.py outlook.com microsoft.com
```

If you want to whitelist more mail domains, just run the command with the
domain names like above sample.

Since iRedAPD-1.8.0, we have SQL table `iredapd.greylisting_whitelist_domains`
to store these mail domain names. if you run `spf_to_greylist_whitelists.py`
without any argument, it will fetch all mail domains stored in sql table 
`greylisting_whitelist_domains` instead of fetching from command line arguments.

```
# python spf_to_greylist_whitelists.py
```

You should setup a cron job to run this script, so that it can keep the IP
addresses/networks up to date. iRedMail sets up the cron job to run every 10 or
30  minutes, like below:

```
*/30   *   *   *   *   /usr/bin/python /opt/iredapd/tools/spf_to_greylist_whitelists.py &>/dev/null
```
