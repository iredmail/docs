# Performance tuning

[TOC]

If you're running a busy mail server (many inbound/outbound emails every day),
you can follow below suggestions for better performance.

###  Setup a DNS server in LAN or localhost to cache DNS queries

Mail services heavily rely on DNS service and perform many many DNS queries,
a cache DNS server in LAN or localhost helps a lot:

* It speeds up DNS queries. This helps a lot.
* It reduces DNS queries to DNSBL servers, so that you can continue using their
  excellent service without exceeding the max query limit.

### Enable postscreen service to help reduce spam

* [Enable postscreen service](./enable.postscreen.html)

If you don't want to use postscreen service, you can [enable DNSBL service](./enable.dnsbl.html)
instead, it helps a lot too, but less effective than postscreen service.

postscreen and DNSBL service help catch a lot spam, save much system resource.

###  Update Amavisd + Postfix config files to process more emails concurrently

* [Process more emails concurrently](./concurrent.processing.html)
