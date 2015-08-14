# 禁用 Clubbringer 灰名单

* 通过查阅后方教程来确认 Cluebringer 配置文件 `cluebringer.conf` 的所在路径： [iRedMail 主要组件的配置文件和日志文件路径](./file.locations.html#cluebringer)

* 在配置文件 `cluebringer.conf` 中查找以下行：

```
[Greylisting]
enable=1
```

要禁用灰名单，把 `enabled=1` 改为 `enabled=0` 即可，之后重启 Cluebringer 服务。