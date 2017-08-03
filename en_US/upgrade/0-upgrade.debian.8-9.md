# Fixes you need after upgrading Debian from 8 to 9

[TOC]

## Dovecot

Please remove `!SSLv2` from parameter `ssl_protocols`, and restart Dovecot service:

```
ssl_protocols = !SSLv3
```
