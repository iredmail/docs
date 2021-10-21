# 允许用户在不使用 smtp 验证的情况下发送邮件

[TOC]

!!! attention

    此教程只适用于 iRedMail-0.9.9 以及更早的发行版。如果
    你正在使用一个更新的版本，请参照
    [这个教程](./allow.send.without.smtp.auth.html)。

## Postfix

创建一个纯文本文件： `/etc/postfix/sender_access.pcre` ，并在此文件中列出
所有允许不使用 smtp 验证发送邮件的用户邮箱地址。
在这里我们使用用户邮件地址 `user@example.com` 作为范例：

```
\^user@example\.com$/ OK
```

另外也可以使用 IP 地址

> 关于更多接受的的发件人地址格式，请参照 Postfix 使用手册网站： [access(5)](http://www.postfix.org/access.5.html) 。

```
/^192\.168\.1\.1$/ OK
/^192\.168\.2\./   OK
/^172\.16\./       OK
```

更新 Postfix 配置文件 `/etc/postfix/main.cf` 来使用此 pcre 文件。

```
smtp_sender_restrictions = 
    check_sender_access pcre:/etc/postfix/sender_access.pcre,
    [...OTHER RESTRICTIONS HERE...]
```

重启或重新加载 postfix 来应用此更改：

```
# /etc/init.d/postfix restart
```

# iRedAPD

iRedAPD 插件 `reject_sender_login_mismatch` 会检查伪造的发件人地址。
如果说某发件人地址的域名是你的服务器上，但又没有 smtp 验证，任何携带此地址的邮件
将会被认为是一个伪造的邮件。在此情况下，iRedAPD 会拦截此邮件
（并输出拦截消息： `Policy rejection not logged in` )，所以说我们需要
使其插件忽略某些发信人邮件地址。如果说某邮件是从一个类似于打印机或传真机的内网
设备发出，我们则可以直接使用其 IP 地址来进行忽略。

* 要忽略发信人地址 `user@example.com` ，请在 
  `/opt/iredapd/settings.py` 中添加以下配置：

```
ALLOWED_FORGED_SENDERS = ['user@example.com']
```

* 要忽略某发信人的 IP 地址或网域，比如说 `192.168.0.1` 或 
  `192.168.1.0/24` ，请在 `/opt/iredapd/settings.py` 中添加以下配置：

```
MYNETWORKS = ['192.168.0.1', '192.168.1.0/24']
```

更改 `/opt/iredapd/settings.py` 了以后，你必须重新启动 iRedAPD 服务。

## 参考文献

* Postfix 文档:
    * [check_sender_access](http://www.postfix.org/postconf.5.html#check_sender_access)
    * Manual page: [access(5)](http://www.postfix.org/access.5.html)
    * Manual page: [pcre_table(5)](http://www.postfix.org/pcre_table.5.html)
