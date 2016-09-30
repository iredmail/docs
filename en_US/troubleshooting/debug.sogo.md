# Turn on debug mode in SOGo

In [SOGo config file](./file.locations.html#sogo), you can find several debug
options, like below:

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

Please uncomment the one you need, then restart SOGo service. You can find
debug log in its log file `/var/log/sogo/sogo.log`.
