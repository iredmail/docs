# 允许用户无需身份验证发送邮件

## Postfix

创建文本文件 `/etc/postfix/accepted_unauth_senders`，列出无需身份验证就可以
发送邮件的用户邮件地址。下面以用户 `user@example.com` 为例：

```
user@example.com OK
```

使用 `postmap` 命令建立哈希数据库文件：

```
# postmap hash:/etc/postfix/accepted_unauth_senders
```

修改 Postfix 配置文件 `/etc/postfix/main.cf` 以使用该文件：

```
smtpd_sender_restrictions =
    check_sender_access hash:/etc/postfix/accepted_unauth_senders,
    [...OTHER RESTRICTIONS HERE...]
```

重启 postfix 服务以使设置生效：

```
# /etc/init.d/postfix restart
```

## iRedAPD

iRedAPD 插件 `reject_sender_login_mismatch` 会检测伪造的发件人地址。如果发件人
的域名在你的服务器托管，并且邮件不是经由 SMTP 验证发送的，就会被认为是伪造的
发件人。这种情况下 iRedAPD 会直接拒收邮件（拒收提示信息为：`Policy rejection
not logged in`），因此需要在 iRedAPD 里放行将该收件人邮件地址。如果邮件是由
固定的内部网络设备发送（例如，打印机、传真机），可以直接放行 IP 地址。

* 放行发件人邮件地址 `user@example.com`，请在  `/opt/iredapd/settings.py` 里
  加以下参数：

```
ALLOWED_FORGED_SENDERS = ['user@example.com']
```

* 放行发件人 IP 地址，例如, `192.168.0.1`，请在 `/opt/iredapd/settings.py` 里
  加以下参数：

```
MYNETWORKS = ['192.168.0.1']
```

修改后需要重启 iRedAPD 服务。
