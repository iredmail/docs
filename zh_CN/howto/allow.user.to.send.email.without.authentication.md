# 允许用户无需身份验证发送邮件

创建一个文本文件 `/etc/postfix/accepted_unauth_senders` :

```
fax-machine-12@mydomain.tld OK
```

使用 postmap 命令建立一个哈希库文件：

```
# postmap hash:/etc/postfix/accepted_unauth_senders
```

修改 Postfix 服务调用此文件： `/etc/postfix/main.cf`

```
smtpd_sender_restrictions = 
    check_sender_access hash:/etc/postfix/accepted_unauth_senders,
    [...OTHER RESTRICTIONS HERE...]
```

重启/重新装载 postfix 服务，以使设置生效：

```
# /etc/init.d/postfix restart
```
