# Amavisd + SpamAssassin 失效，邮件头无 (X-Spam-*) 信息插入

在 Amavisd 的配置文件 `/etc/amavisd/amavisd.conf` 中有如下默认设置：

    $sa_tag_level_deflt  = 2.0;

即 Amavisd 将在邮件评分 >= 2.0 时在邮件头插入 `X-Spam-Flag` 及其他的 `X-Spam-*` 信息。假如想让 Amavisd 总是在邮件头插入前述信息，将参数评分设成一个更低的值即可，例如：

    $sa_tag_level_deflt  = -999;

Amavisd 的主配置文件在不同版本的 Linux/BSD 系统上分布路径如下：

* Red Hat, CentOS, OpenBSD: `/etc/amavisd/amavisd.conf`
* Debian, Ubuntu: `/etc/amavis/conf.d/50-user` (and other config files under `/etc/amavs/conf.d/`)
* FreeBSD: `/usr/local/etc/amavisd/amavisd.conf`
