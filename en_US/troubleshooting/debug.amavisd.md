# Turn on debug mode in Amavisd and SpamAssassin

In [Amavisd config file](./file.locations.html#amavisd), change `$log_level`,
then restart amavis service.

```
$log_level = 5;              # verbosity 0..5, -d
```

If you want to debug SpamAssassin, please update `$sa_debug` also:

```
$sa_debug = 1;
```

Amavisd is configured by iRedMail to log to [Postfix log file](./file.locations.html#postfix).
