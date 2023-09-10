# Zet debug modus aan in Amavisd en SpamAssassin

In [Amavisd config file](./file.locations.html#amavisd), verander `$log_level`,
herstart daarna amavisd service.

```
$log_level = 5;              # verbosity 0..5, -d
```

Als je SpamAssassin wilt debuggen, update dan ook `$sa_debug`:

```
$sa_debug = 1;
```

Amavisd is geconfigureerd door iRedMail om te loggen naar het [Postfix logbestand](./file.locations.html#postfix).
