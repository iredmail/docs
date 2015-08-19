# 允许用户无需身份验证发送邮件

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
