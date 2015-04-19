# iRedAPD release notes and upgrade tutorials

[TOC]

> iRedAPD source code is hosted on [BitBucket](https://bitbucket.org/zhb/iredapd/).

> Download the [latest iRedAPD stable release](https://bitbucket.org/zhb/iredapd/downloads).

## Upgrade iRedAPD

[How to upgrade iRedAPD-1.4.0 or later versions to the latest stable release](./upgrade.iredapd.html)

## Release Notes

### 1.4.5

* Improvements:

    * Log non-DUNNO actions in iredadmin database (with setting
      `log_action_in_db = True` in iRedAPD config file).
    * plugin/amavisd_wblist.py: able to use `user@*` as white/blacklist sender.
    * plugin/sql_alias_access_policy.py, plugin/ldap_maillist_access_policy:
      able to use `*@domain.com` (all senders from `domain.com`) as moderator.
    * plugin/reject_sender_login_mismatch.py:

        * New optional setting `ALLOWED_LOGIN_MISMATCH_LIST_MEMBER`, used to
          allow member of mail list/alias to send as mail list/alias.
          Default is False.

        * Setting `ALLOWED_LOGIN_MISMATCH_SENDERS` is now optional.

    * Log smtp protocol state in log file.

* Fixed issues:
    * plugin/amavisd_message_size_limit.py: just use the first valid
      policy (with highest priority) and skip rest.
    * plugin/reject_sender_login_mismatch.py: not reject email if sender
      is forged address (sender domain is hosted locally).
    * Not close sql connection explicitly.
