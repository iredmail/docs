# Process more emails concurrently

__WARNING__: Processing more concurrent emails require more RAM.

Amavisd-new is content filter, it invokes SpamAssassin and ClamAV for
spam/virus scanning, it also offers additional features like DKIM signing and
verification.

In [Amavisd config file](./file.location.html#amavisd), `$max_servers` sets
the number of concurrent Amavisd processes and it must match the number set
in `/etc/postfix/master.cf` `maxproc` column for the `smtp-amavis` service.
Sample settings:

```
# File: /etc/amavisd/amavisd.conf

$max_servers = 4;
```

```
# File: /etc/postfix/master.cf

smtp-amavis unix -  -   -   -   4  smtp
    ...
```

Both values should be identical for two reasons: If Amavisd offers more
processes than Postfix will ever use, Amavisd wastes resources. On the other
hand, if Postfix starts more dedicated transports than amavisd can handle
simultaneously, e-mail transport will be refused and logged as error.

If many emails stalled in mail queue (check with command `postqueue -p`), and
your server has powerful CPU and memory, you can increase the number of
concurrent Amavisd processes, so that it can process more emails at the same
time. Sample setting:

```
# File: /etc/amavisd/amavisd.conf

$max_servers = 10;
```
Restarting Amavisd service is required.

```
# File: /etc/postfix/master.cf

smtp-amavis unix -  -   -   -   10  smtp
    ...
```

Note: If you don't want to modify `/etc/postfix/master.cf`, it's ok to set
`smtp-amavis_destination_concurrency_limit = 10` in `/etc/postfix/main.cf`
instead.

Restarting Postfix service is required if you modified `/etc/postfix/master.cf`,
reloading OR restarting is required if you modified `/etc/postfix/main.cf`.

References:

* [Amavisd web site](http://www.amavis.org)
* [Tuning: Maximum Number of Concurrent Processes](http://www.ijs.si/software/amavisd/README.postfix.html#d0e1231)
* [Integrating amavisd-new in Postfix](http://www.ijs.si/software/amavisd/README.postfix.html)
