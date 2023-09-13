# Zet debug modus aan in SOGo

In het [SOGo configuratiebestand](./file.locations.html#sogo) vind je meerdere debug opties, zoals hieronder:

```
    // Enable verbose logging. Reference:
    // http://www.sogo.nu/nc/support/faq/article/how-to-enable-more-verbose-logging-in-sogo.html
    //SOGoDebugRequests = YES;
    //SOGoEASDebugEnabled = YES;
    //ImapDebugEnabled = YES;
    //LDAPDebugEnabled = YES;
    //MySQL4DebugEnabled = YES;
    //PGDebugEnabled = YES;
```

Uncomment diegene(n) die je nodig hebt, herstart dan SOGo service. Je kunt de debug log
vinden in zijn logbestand `/var/log/sogo/sogo.log`.

Als je debugging nodig hebt op het niveau van de source code, lees dan alstublieft deze tutorial:
[Hoe debug ik SOGo?](https://sogo.nu/support/faq/how-do-i-debug-sogo.html).
