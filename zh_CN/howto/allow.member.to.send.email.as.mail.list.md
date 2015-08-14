# Allow member to send email as mailing list or mail alias

To allow member of mailing list (or mail alias) account to send email as this
mailing list (or mail alias), please follw steps below:

* 将参数 `reject_sender_login_mismatch` 从 Postfix 配置文件 `/etc/postfix/main.cf` 中移除。
* 更改 iRedAPD 配置文件 `/opt/iredapd/settings.py` 中的参数 `reject_sender_login_mismatch` ，以启用 iRedAPD 插件。
* 在配置文件 `/opt/iredapd/settings.py` 中添加如下参数，允许成员按发件列表或者邮件别名来发送邮件：

```
ALLOWED_LOGIN_MISMATCH_LIST_MEMBER = True
```

* 之后重启 Postfix 和 iRedAPD 服务器。
