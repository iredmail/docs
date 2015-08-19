# Amavisd + SpamAssassin 无效，邮件头无 X-Spam-* 信息插入

在 Amavisd 的配置文件 `/etc/amavisd/amavisd.conf` 中有如下默认设置：

```
$sa_tag_level_deflt  = 2.0;
```

该设置表示 Amavisd 在邮件评分 >= 2.0 时会在邮件头（mail header）里插入
`X-Spam-Flag` 及其它的 `X-Spam-*` 信息。要让 Amavisd 总是插入 `X-Spam-*` 邮件头，
将上面的参数设成一个更低的值即可。例如：

```
$sa_tag_level_deflt  = -999;
```

修改后需要重启 Amavisd 服务。

Amavisd 的主配置文件在不同的 Linux/BSD 系统上路径不同：

* Red Hat, CentOS, OpenBSD: `/etc/amavisd/amavisd.conf`
* Debian, Ubuntu: `/etc/amavis/conf.d/50-user` （其它配置文件均在 `/etc/amavs/conf.d/` 目录下)
* FreeBSD: `/usr/local/etc/amavisd/amavisd.conf`
