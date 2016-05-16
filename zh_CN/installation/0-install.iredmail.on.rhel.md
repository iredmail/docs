# 在 Red Hat Enterprise Linux 或 CentOS 系统上安装 iRedMail

[TOC]

## 系统要求

!!! warning

    iRedMail 只针对全新安装的操作系统设计，它要求你的操作系统上 __没有__ 事先
    安装邮件服务相关的组件，例如 MySQL，OpenLDAP，Postfix，Amavisd，等。
    iRedMail 会自动安装和配置邮件服务所需的组件，因此如果操作系统上已有相关
    组件，iRedMail 可能会打乱你的配置并造成服务无法正常启动。

要在 Red Hat Enterprise Linux （以下简称 RHEL）或 CentOS 上安装 iRedMail，你需要：

* 一个全新安装的 RHEL 或 CentOS 系统。支持的版本号在[下载](../download.html)页面有注明。
* 要运行一个低流量的邮件服务器，要求至少`2 GB` 内存才能使用完整的垃圾邮件和病毒扫描功能。

## 准备

### 为服务器设置一个完整域名（FQDN）的主机名

不管你的服务器将用于实际运行还是仅仅用作测试，都建议设置一个完整域名（FQDN）的主机名。

输入命令 `hostname -f` 查看当前的主机名

```shell
$ hostname -f
mx.example.com
```

在 RHEL/CentOS 系统上，主机名需要在两个文件里设置：

* 对于 RHEL/CentOS 6，主机名定义在 `/etc/sysconfig/network`:

```
HOSTNAME=mx.example.com
```

对于 RHEL/CentOS 7，主机名定义在 `/etc/hostname`.

```
mx.example.com
```

* 在 `/etc/hosts` 里定义主机名和 IP 地址的对应关系。注意：一定要将 FQDN 主机名列在第一个。

```
127.0.0.1   mx.example.com mx localhost localhost.localdomain
```

确认系统已使用设置好的 FQDN 作为主机名。如果没有生效，请重启系统。

```
$ hostname -f
mx.example.com
```

### 禁用 SELinux

iRedMail 不支持 SELinux，所以需要在 `/etc/selinux/config` 文件里禁用它。

```
SELINUX=disabled
```

如果不希望禁用 SELinux，可以设置为让它打印警告信息但不强制限制：

```
SELINUX=permissive
```

也可以无须重启服务就禁用它：

```
# setenforce 0
```

### 启用必须的 yum 仓库

* 对于 CentOS 系统，必须启用 `/etc/yum.repos.d/CentOS-Base.repo` 里定义的所有
  CentOS 官方 yum 仓库。同时 __禁用__ 所有第三方yum 仓库，以避免软件包冲突。

* 对于 RHEL，请启用 Red Hat Network 以便安装软件包。

### 下载最新的 iRedMail

* 访问[下载页面](../download.html)下载最新的版本。
* 上传 iRedMail 到服务器上。假设上传后的路径是 `/root/iRedMail-x.y.z.tar.bz2`
  （这里以 `x.y.z` 代替实际的版本号）。
* 解压缩 iRedMail 安装包：

```
# cd /root/
# tar xjf iRedMail-x.y.z.tar.bz2
```

## 运行 iRedMail 安装程序

现在可以运行 iRedMail 安装程序了，它会问你几个简单的问题，仅此而已。

```
# cd /root/iRedMail-x.y.z/
# IREDMAIL_MIRROR='http://42.159.241.31' IREDMAIL_EPEL_MIRROR='http://mirrors.aliyun.com/epel' bash iRedMail.sh
```

> 由于 iredmail.org 域名在国内无法访问，所以需要指定 `IREDMAIL_MIRROR` 参数使用
> 国内镜像站点。`IREDMAIL_EPEL_MIRROR` 则是为了加快安装速度而选择的国内的阿里云
> 提供的 EPEL 软件包仓库镜像。

## 安装过程的截图

* 欢迎和感谢使用

![](./images/installation/welcome.png){: width="700px" }

* 指定用于存储用户邮箱的路径。默认是 `/var/vmail/`。

![](./images/installation/mail_storage.png){: width="700px" }

* 选择用于存储邮件账号的数据库。

!!! note

    各个数据库之间没有太大区别，建议使用自己熟悉的数据库，便于后期维护。

![](./images/installation/backends.png){: width="700px" }

* 如果选择 OpenLDAP 数据库用于存储邮件账号，安装程序会要求你输入 LDAP 前缀：

![](./images/installation/ldap_suffix.png){: width="700px" }

!!! note "MySQL/MariaDB/PostgreSQL 用户"

    如果选择 MySQL/MariaDB/PostgreSQL 用于存储邮件账号, 安装程序会为数据库的
    root 用户生成一个随机的强密码，安装完成后可以在 `iRedMail.tips` 文件里找到。

* 添加第一个邮件域名

![](./images/installation/first_domain.png){: width="700px" }

* 设置邮件管理员的密码

!!! note

    该账号即是邮件管理员，也是普通的邮件账号，可以登录管理后台和 webmail。

![](./images/installation/admin_pw.png){: width="700px" }

* 可选的组件

![](./images/installation/optional_components.png){: width="700px" }


回答完上面的几个问题之后，安装程序给出本次安装的基本信息并要求确认是否实际
执行安装，请输入 `y` 或 `Y` 并按回车键确认，或 `n`, `N` 并按回车键中止安装。

![](./images/installation/review.png){: width="700px" }

## 安装完成后你必须知道的几个重要事项

* 邮件服务器最薄弱的环节是用户的弱密码，所以请一定强制你的用户使用强度高的密码。
* 阅读 `/root/iRedMail-x.y.z/iRedMail.tips` 文件，它包含了：

    * 各个 web 程序的访问地址（URL），用户名和密码。
    * 各个组件的配置文件路径。除此之外还应该阅读文档：[Locations of configuration and log files of major components](../file.locations.html).
    * 以及其它一些重要和敏感信息

* [设置 DNS 记录](../setup.dns.html)
* [如何配置邮件客户端程序](../index.html#configure-mail-client-applications)
* 强烈建议获取 SSL 证书以避免每次访问 web 程序时烦人的自签名 SSL 证书警告，
  [Let's Encrypt 提供免费的 SSL 证书](https://letsencrypt.org)。可根据该文档
  配置获取的证书：[use a SSL certificate](../use.a.bought.ssl.certificate.html).
* 如果需要批量添加邮件账号，可以参考以下针对不同数据库的批量建账号的文档：
  [OpenLDAP](../ldap.bulk.create.mail.users.html)，
  [MySQL/MariaDB/PostgreSQL](../sql.bulk.create.mail.users.html)。
* 如果这是一台繁忙的服务器，这里有[一些提升性能的建议](../performance.tuning.html)。

## 访问 webmail 和其它 web 程序

安装完成后，可以通过以下 URL 访问相关程序。注意：请将 `<server\>` 替换为实际的
服务器地址。

* __Roundcube webmail__: <https://your_server/mail/>
* __SOGo Groupware__: <https://your_server/SOGo>
* __Web 管理后台__: <httpS://your_server/iredadmin/>
* __Awstats__: <httpS://your_server/awstats/awstats.pl?config=web> (or `?config=smtp` for SMTP log)

## 技术支持

* 遇到问题、疑问，或有建议、功能需求，都可以发到活跃的在线论坛：
    * [英文论坛](http://www.iredmail.org/forum/)
    * [中文论坛](http://www.iredmail.com/bbs/)
* 如需及时快速的专业技术支持，请查看网页：[获取专业的技术支持](../support.html).
