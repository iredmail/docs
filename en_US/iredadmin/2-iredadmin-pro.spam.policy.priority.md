# iRedAdmin-Pro: Priority of spam policy used in iRedMail & iRedAdmin-Pro

With `@lookup_sql_dsn =` enabled in Amavisd config file, Amavisd will lookup
spam policies from SQL database `amavisd` for different accounts. The
priorities of different spam policies are:

1. Highest: per-user spam policy set in user profile page
1. Lower: per-domain spam policy set in domain profile page
1. Even lower: global spam policy set in iRedAdmin-Pro: "System -> Anti Spam -> Global Spam Policy"
1. Lowest: server wide spam policy defined in Amavisd config file.

References:

* [Explanation of Amavisd SQL database](./amavisd.sql.db.html)
