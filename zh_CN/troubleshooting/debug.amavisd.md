# 调试 Amavisd 和 SpamAssassin

找到[Amavisd 配置文件](./file.locations.html#amavisd)，修改 `$log_level` 参数，
然后重启 amavisd 服务。

```
$log_level = 5;              # 日志等级：0 到 5，或 -d
```

如果需要调试 SpamAssassin，请同时修改 `$sa_debug` 参数：

```
$sa_debug = 1;
```

在 iRedMail 里，Amavisd 会记录日志到 [Postfix 日志文件](./file.locations.html#postfix)。
