# Amavisd: Enable per-recipient policy lookup

With per-recipient policy lookup, you can achieve per-recipient white/blacklists,
basic spamassassin preferences, etc. Settings are available as global setting,
or per-domain, per-user settings. iRedMail uses it to reject blacklisted
senders and bypass whitelisted senders during smtp session to save system
resource (implemented via iRedAPD plugin `amavisd_wblist`, new in iRedAPD-1.4.4.).

iRedMail has `@storage_sql_dsn` enabled in Amavisd config file by default, so
it's very easy to enable per-recipient policy lookup. Just add one line after
`@storage_sql_dsn` like below:

```
# Part of file: amavisd.conf

@storage_sql_dsn = [...]
@lookup_sql_dsn = @storage_sql_dsn;
```

Then restart Amavisd serivce.

If you don't know where Amavisd config file is, please refer to our document:
[Locations of configuration and log files of major components](./file.locations.html#amavisd)

## References:

* [Amavisd doc: Uing SQL for lookups, log/reporting and quarantine](http://www.ijs.si/software/amavisd/README.sql.txt)
* [Amavisd doc: Lookup maps (hash, SQL) and access list explained](http://www.ijs.si/software/amavisd/README.lookups.txt)
