# 禁用发件的垃圾邮件、病毒扫描功能

要禁用发件时的垃圾邮件、病毒扫描功能，可以在 Amavisd 配置文件 `/etc/amavisd/amavisd.conf` (RHEL/CentOS/Scientific Linux) 或 `/etc/amavis/conf.d/50-user` (Debian/Ubuntu) 或 `/usr/local/etc/amavisd.conf` (FreeBSD) 中增加分流设置。

* bypass_spam_checks_maps
* bypass_virus_checks_maps
* bypass_header_checks_maps
* bypass_banned_checks_maps

这些设置可以以设置块的形式进行添加 `$policy_bank{'MYUSERS'}` ，例如：

```perl
$policy_bank{'MYUSERS'} = {
    [...OMIT OTHER SETTINGS HERE...]

    # don't perform spam/virus/header check.
    bypass_spam_checks_maps => [1],
    bypass_virus_checks_maps => [1],
    bypass_header_checks_maps => [1],

    # allow sending any file names and types
    bypass_banned_checks_maps => [1],
}
```

更改设置后，需要重启 Amavisd 服务，以使更改生效。
