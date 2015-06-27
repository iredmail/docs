# Per-user outbound restrictions

> Note: if you're looking for whitelisting or blacklisting incoming email,
> please use iRedAPD plugin `amavisd_wblist` instead.

## SQL backends

iRedAPD (a simple Postfix policy server developed by iRedMail team) provides
plugin `sql_user_restrictions` for per-user inbound/outbound restrictions.

Please make sure plugin `sql_user_restrictions` is enabled in iRedAPD config
file `/opt/iredapd/settings.py` like below:

```python
# Part of file: /opt/iredapd/settings.py

plugins = [..., 'sql_user_restrictions']
```

Restarting iRedAPD service is required if you modified `/opt/iredapd/settings.py`.

You can store allowed or disallowed recipient in 2 SQL columns in `vmail` database:

* `mailbox.rejectedrecipients`: disallow user to send email to listed recipients.
* `mailbox.allowedrecipients`: allow user to send email to listed recipients.

Valid sender/recipient formats are:

* `@.`: all addresses (user, domain, sub-domain). Be careful: There's a dot after `@`.
* `@domain.com`: entire domain.
* `@.domain.com`: entire domain and all its sub-domains. Be careful: There's a dot after `@`.
* `user@domain.com`:  single email address
* empty value means no restriction.

NOTE: Multiple recipients must be separated by comma (`,`).

Sample usage:

* allow local mail user `user@example.com` to send to domain (`example.com`)
  and `gmail.com`, but not others.

```sql
sql> USE vmail;
sql> UPDATE mailbox
     SET
         rejectedrecipients='@.',
         allowedrecipients='@example.com,@gmail.com'
     WHERE
          username='user@example.com';
```

## OpenLDAP backend special

OpenLDAP backend requires iRedAPD plugin `ldap_amavisd_block_blacklisted_senders`.

* If you have iRedAdmin-Pro, you can manage this restriction in user profile page.

* If you don't have iRedAdmin-Pro, you can manage it with phpLDAPadmin or other
  LDAP management tools. Related LDAP attributes are:

    * `mailWhitelistRecipient`: same as SQL `mailbox.allowedrecipients`
    * `mailBlacklistRecipient`: same as `mailbox.rejectedrecipients`

Values for these LDAP attributes use the same format as mentioned above.

Note: multiple recipients must be stored in multiple attributes like below:

```
mailWhitelistRecipient: @example.com
mailWhitelistRecipient: @gmail.com
mailWhitelistRecipient: @iredmail.org
```
