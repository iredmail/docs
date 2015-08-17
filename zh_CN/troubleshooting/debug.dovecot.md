# 开启 Dovecot 调试模式

> 不知道 Dovecot 的配置文件在哪个目录？请查阅这个教程：
> [iRedMail 主要组件的配置文件和日志文件路径](file.locations.html#dovecot).

要调试 Dovecot，请修改 `dovecot.conf` 的如下参数：

```
mail_debug = yes
```

之后重启 Dovecot 服务。

如果需要查看验证和密码相关的调试信息，请修改如下参数并重启 Dovecot 服务：

```
auth_verbose = yes
auth_debug = yes
auth_debug_passwords = yes
auth_verbose_passwords = yes
```

如果重启 Dovecot 服务时看到很多错误信息（例如：`dovecot fails, spawning too
quickly`），可能是由于 Dovecot 配置文件中有某种错误导致的。请在命令行手动重启
Dovecot 服务，它会报告配置文件的错误：

```
# dovecot -c /etc/dovecot/dovecot.conf
```
