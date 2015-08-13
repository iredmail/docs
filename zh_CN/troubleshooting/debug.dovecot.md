# 开启Dovecot服务的调试模式

> 不知道Dovecot的配置文件在哪个目录？请查阅这个教程：
> [iRedMail主要组件配置文件和日志文件存放目录](file.locations.html#dovecot).

要开启Dovecot服务的调试模式，您需要对`dovecot.conf`配置文件做如下更改:

```
mail_debug = yes
```

重启Dovecot服务。

如果您需要开启经授权验证后才能查阅调试日志的功能，请按下方所示更改配置文件并重启Dovecot服务。

```
auth_verbose = yes
auth_debug = yes
auth_debug_passwords = yes
auth_verbose_passwords = yes
```

当您在重启Dovecot服务时看到很多错误信息（比如`dovecot fails, spawning too quickly`），这可能是由于Dovecot配置文件中的某些错误导致的。此时，请以命令行的形式手动重启Dovecot服务，在此模式下，Dovecot会列出重启过程中遇到的所有错误信息，您应当根据这些信息修改配置文件，并重启Dovecot服务：

```
# dovecot -c /etc/dovecot/dovecot.conf
```
