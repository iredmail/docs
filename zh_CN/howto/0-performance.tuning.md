# 性能优化

[TOC]

如果你运行的是一台高负载的邮件服务器（每天都需要处理大量的收发件请求），可以
参考下面建议调整服务器以达到更好的性能。

###  在局域网或本机上搭建一个 DNS 缓存服务器

邮件服务需要频繁、大量地执行 DNS 查询，所以非常依赖 DNS 服务。因此在局域网或
本机搭建 DNS 缓存服务器将有以下好处：

* 加快 DNS 查询，这对邮件的流转起到极大加速作用。
* 极大地减少了对 DNSBL 服务器的查询请求。这可以确保在不超出服务商的查询
  次数限制的前提下，稳定地使用 DNSBL 服务。

### 启用 postscreen 服务以帮助减少垃圾邮件

* [启用 postscreen 服务](./enable.postscreen.html)

如果你不想启用 postscreen 服务，可以尝试 [启用 DNSBL 服务](./enable.dnsbl.html)
作为替代，它同样能极大地减少垃圾邮件。虽然 postscreen 和单纯的 DNSBL 服务都
使用相同的 DNSBL 服务商，但 postscreen 有额外的机制来帮助阻挡垃圾邮件，因此
postscreen 有更好的反垃圾效果。

postscreen 和 DNSBL 服务都在 smtp 会话阶段就拦下垃圾邮件，因此可以极大地节省
系统资源。

### 更改 Amavisd + Postfix 的配置文件以便同时处理更多的邮件

* [同时处理更多邮件](./concurrent.processing.html)
