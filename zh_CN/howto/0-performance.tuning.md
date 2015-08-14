# 性能优化

[TOC]

如果你运行的是一台高负载的邮件服务器（每天都需要处理大量的收发件请求），可以跟随以下列明的指南操作以使服务器有更好的性能。

###  在局域网或本地主机上设置一个 DNS 解析的缓存

邮件服务器的运行严重依赖 DNS 服务，它频繁的执行 DNS 解析请求，一个位于局域网或本地主机上的 DNS 缓存将助益良多：

* 它将加速邮件服务器对 DNS 解析队列的处理。
* 它能减少 DNS 解析对 DNSBL 服务的请求次数，这样你在享受同样优质服务的同时，能有效避免出现超出解析上限的问题。

### 启用 postscreen 服务帮助减少垃圾邮件

* [启用 postscreen 服务](./enable.postscreen.html)

如果你不想启用 postscreen 服务，可以尝试 [启用 DNSBL 服务](./enable.dnsbl.html)
来替代，该服务同样对邮件服务助益良多，但是效率略低于 postscreen 服务。

postscreen 和 DNSBL 服务在帮助拦截大量垃圾邮件的同时节省了大量的服务器资源。

###  更改 Amavisd + Postfix 的配置文件以便同时处理更多的邮件

* [同时处理更多邮件](./concurrent.processing.html)
