# 允许列表成员以列表邮件地址作为发件人发送邮件

要允许列表成员以列表邮件地址作为发件人发送邮件，请按照以下步骤操作：

* 在 Postfix 配置文件 `/etc/postfix/main.cf` 中移除参数 `reject_sender_login_mismatch`。
* 在 iRedAPD 配置文件 `/opt/iredapd/settings.py` 中启用插件 `reject_sender_login_mismatch`。
* 在 iRedAPD 配置文件 `/opt/iredapd/settings.py` 中添加如下参数，允许列表成员
  以列表邮件地址作为发件人发送邮件：

```
ALLOWED_LOGIN_MISMATCH_LIST_MEMBER = True
```

* 修改后需要重启 Postfix 和 iRedAPD 服务。
