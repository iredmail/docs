# Explanation of Amavisd SQL database

[TOC]

## Summary

Amavisd has two settings to use its SQL tables:

* `@storage_sql_dsn`: used to store:

    * basic info of inbound and outbound message. e.g. mail subject,
      sender address, recipient address, timestamp, etc. Note: no mail body.
    * quarantined mails. Note: it stores full message of quarantined mail,
      including mail body.

    `@storage_sql_dsn` uses 4 sql tables:
    
    * `msgs`
    * `msgrcpt`
    * `maddr`
    * `quarantine`

* `@lookup_sql_dsn`: used to store:

    * per-account spam policy
    * per-account white/blacklists

    `@lookup_sql_dsn` uses 4 sql tables:
    
    * `mailaddr`
    * `policy`
    * `users`
    * `wblist`

## Details

### `@lookup_sql_dsn`

* Table `amavisd.mailaddr` stores email addresses __NOT__ hosted on your server.

    Note: value of column `mailaddr.email` could be something like below:
  
    * `@.`: a catch-all address.
    * `@domain.com`: entire domain.
    * `@.domain.com`: entire domain and all its sub-domains.
    * `user@domain.com`: a single email address.
    * `user@*`: email addresses start with `user@`. Note: This is used by iRedAPD, not Amavisd.
    * `192.168.1.2`: a single IP address. Note: This is used by iRedAPD, not Amavisd.
    * `192.168.*.2`: wildcard IP address. Note: This is used by iRedAPD, not Amavisd.

    The addresses are used in several tables:
  
    * `amavisd.wblist`: used by Amavisd. If sender (of inbound message) is
      blacklisted, Amavisd will quarantine this email. But if you have iRedAPD
      plugin `amavisd_wblist` enabled, this smtp session will be rejected before
      queued by Postfix, so Amavisd doesn't know this rejected message at all.
    * `amavisd.outbound_wblist`. New in iRedMail-0.9.3, used by iRedAPD plugin
      `amavisd_wblist` for white/blacklisting for outbound message.

* `amavisd.users` stores mail addresses hosted on your server. __NOTE__: you
  don't need to sync all existing mail users in this table, just add mail users
  you want to define a per-account spam policy in this table.

    Value of column `users.email` uses same format as `amavisd.mailaddr` mentioned above.

* `amavisd.wblist` stores white/blacklists for inbound message. `wblist.sid`
  (sender id) refers to `mailaddr.id`, `wblist.rid` (recipient id) refers to
  `users.id`.

* `amavisd.outbound_wblist` stores white/blacklists for outbound message.
  `outbound_wblist.sid` (sender id) refers to `users.id`, `outbound_wblist.rid`
  (recipient id) refers to `mailaddr.id`.

    Note: this table is used by iRedAPD, not Amavisd.

* `amavisd.policy`: used to define per-recipient spam policy, and max message
  size limit.

### TODO: `@storage_sql_dsn`

* `maddr`
* `msgs`
* `msgrcpt`
* `quarantine`

Since Amavisd will store basic info of every inbound/outbound email, the SQL
database will grow bigger and bigger, iRedMail setups a daily cron job to
clean up old records with script shipped in iRedAdmin (available in both
iRedAdmin open source edition and iRedAdmin-Pro): `tools/cleanup_amavisd_db.py`.
