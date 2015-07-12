# iRedAPD (Postfix Access Policy Daemon) release notes and upgrade tutorials

> iRedAPD source code is hosted on [BitBucket](https://bitbucket.org/zhb/iredapd/).

> Download the [latest iRedAPD stable release](https://bitbucket.org/zhb/iredapd/downloads).

> If you want to develop your own plugin for iRedAPD, please read document
> [README_PLUGINS.md](https://bitbucket.org/zhb/iredapd/src/default/README_PLUGINS.md?at=default) in iRedAPD source code.

## Upgrade iRedAPD

[How to upgrade iRedAPD-1.4.0 or later versions to the latest stable release](./upgrade.iredapd.html)

## ChangeLog

### 1.6.0

* New setting: `MYNETWORKS`. used to set trusted or internal networks.
* Plugin `ldap_domain_wblist` was removed, we didn't use it at all.
* Fixed issues:

    * plugin/ldap_maillist_access_policy.py: not use correct ldap
      connection cursor. this causes access policy not work.
    * plugin/reject_sender_login_mismatch.py: Not return correct value for
      allowed senders.
    * Not correctly fetch SQL query result with SQLAlchemy.
    * Doesn't work with PostgreSQL backend.
    * iRedAPD daemon exits with error (9, 'Bad file descriptor').

### 1.5.0

* Improvements:

    * Use sql connection pool provided by SQLAlchemy for better performance.
    * Log reject and other non-DUNNO actions in iredadmin database (`log_action_in_db = True`).
    * Plugin `amavisd_wblist`: able to use `user@*` as white/blacklist sender.
    * Plugin `sql_alias_access_policy` and `ldap_maillist_access_policy`:
      able to use `*@domain.com` (all senders from `domain.com`) as
      moderator.
    * Plugin `reject_sender_login_mismatch`:

        * New optional setting `ALLOWED_LOGIN_MISMATCH_LIST_MEMBER`, used to
          allow member of mail list/alias to send as mail list/alias.
          Default is False.
        * Setting `ALLOWED_LOGIN_MISMATCH_SENDERS` is now optional.

    * Log smtp protocol state in log file (`RCPT`, `END-OF-MESSAGE`).

* Fixed issues:

    * Plugin `amavisd_message_size_limit`: just use the first valid
      policy (with highest priority) and skip rest.
    * Plugin `reject_sender_login_mismatch`: not reject email if sender
      is forged address (sender domain is hosted locally).
    * Not close sql connection explicitly.

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
