# Per-user inbound and outbound restrictions

> There's another way to achieve per-user inbound/outbound restriction, it's
> called per-user white/blacklists (stored in SQL table `amavisd.wblist`,
> implemented by iRedAPD plugin `amavisd_wblist`), but per-user white/blacklists
> are manageable by user themselves.

iRedAPD (a simple Postfix policy server developed by iRedMail team) provides
for per-user plugin `sql_user_restrictions` for per-user inbound/outbound
restrictions.

Please make sure plugin `sql_user_restrictions` is enabled in iRedAPD config
file `/opt/iredapd/settings.py` like below:

```
# Part of file: /opt/iredapd/settings.py

plugins = [..., 'sql_user_restrictions']
```

Restarting iRedAPD service is required if you modified `/opt/iredapd/settings.py`.

You can store allowed or disallowed senders in 4 SQL columns in `vmail` database:

* `mailbox.rejectedsenders`: disallowed to receive email from listed senders.
* `mailbox.allowedsenders`: allowed to receive email from listed senders.
* `mailbox.rejectedrecipients`: disallow user to send email to listed recipients.
* `mailbox.allowedrecipients`: allow user to send email to listed recipients.

Valid sender/recipient formats are:

* `@.`: all addresses (user, domain, sub-domain). Be careful: There's a dot after `@`.
* `@domain.com`: entire domain.
* `@.domain.com`: entire domain and all its sub-domains. Be careful: There's a dot after `@`.
* `user@domain.com`:  single email address
* empty value means no restriction.

NOTES:

* Multiple senders/recipients must be separated by comma (`,`).
* `mailbox.allowedsenders` has higher priority than `mailbox.rejectedsenders`.
* `mailbox.allowedrecipients` has higher priority than `mailbox.rejectedrecipients`.

Sample usage:

* allow local mail user `user@example.com` to send to and receive from the same
  domain (`example.com`) and `gmail.com`, but not others.

```
sql> USE vmail;
sql> UPDATE mailbox \
     SET \
         rejectedsenders='@.', \
         allowedsenders='@example.com,@gmail.com', \
         rejectedrecipients='' \
         allowedrecipients='@example.com,@gmail.com', \
     WHERE \
          username='user@example.com';
```

## OpenLDAP backend special

OpenLDAP backend requires iRedAPD plugin `ldap_amavisd_block_blacklisted_senders`.

* If you have iRedAdmin-Pro, you can manage this restriction in user profile page.

* If you don't have iRedAdmin-Pro, you can manage it with phpLDAPadmin or other
  LDAP management tools. Related LDAP attributes are:

    * `mailWhitelistRecipient`: same as SQL `mailbox.allowedrecipients`
    * `mailBlacklistRecipient`: same as `mailbox.rejectedrecipients`
    * `amavisWhitelistSender`: same as `mailbox.allowedsenders`
    * `amavisBlacklistSender`: same as `mailbox.rejectedsenders`

Values for these LDAP attributes use the same format as mentioned above.
