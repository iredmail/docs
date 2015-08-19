# 对外发邮件禁用垃圾扫描、病毒扫描

要对外发邮件禁用垃圾扫描、病毒扫描功能，可以在 Amavisd 配置文件
`/etc/amavisd/amavisd.conf` (RHEL/CentOS) 或 `/etc/amavis/conf.d/50-user`
(Debian/Ubuntu) 或 `/usr/local/etc/amavisd.conf` (FreeBSD) 中增加 bypass 设置。

* bypass_spam_checks_maps
* bypass_virus_checks_maps
* bypass_header_checks_maps
* bypass_banned_checks_maps

这些设置可以添加到 `$policy_bank{'MYUSERS'}` 配置里。例如：

```perl
$policy_bank{'MYUSERS'} = {
    [...此处省略其它配置参数...]

    # 不执行垃圾扫描、病毒扫描、邮件头检测
    bypass_spam_checks_maps => [1],
    bypass_virus_checks_maps => [1],
    bypass_header_checks_maps => [1],

    # 不检查被禁止的文件名和文件类型
    bypass_banned_checks_maps => [1],
}
```

更改设置后需要重启 Amavisd 服务以使更改生效。
