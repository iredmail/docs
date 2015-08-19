# 禁用 Clubbringer 提供的灰名单服务

* 先查阅文档确认 Cluebringer 配置文件 `cluebringer.conf` 的具体路径：
  [iRedMail 主要组件的配置文件和日志文件路径](./file.locations.html#cluebringer)
* 在配置文件 `cluebringer.conf` 中查找以下行：

```
[Greylisting]
enable=1
```

要禁用灰名单，把 `enabled=1` 改为 `enabled=0`，并重启 Cluebringer 服务即可。
