# 修改邮件附件大小

[TOC]

要修改邮件附件大小，需要修改三个地方。

## 修改 postfix 中邮件的大小

Postfix 是一个邮件传送代理（MTA），因此，要修改配置以使它能传送大附件的邮件。

假设要修改附件大小为100MB，只需对 'message_size_limit' 做如下修改：

```
# postconf -e message_size_limit='104857600'
```

之后重启 Postfix 服务，使上述修改生效:

```
# /etc/init.d/postfix restart
```

__注意__:

* `104857600` 是由 100 (MB) x 1024 (KB) x 1024 (Bit) 计算得到的结果。
* 邮件在发送前会被客户端（Outlook，Thunderbird等）重新编码，导致邮件大小会超过 100MB，你只需将上述设置中的大小改为 110MB 或 120MB 即可。

这样你就可以通过客户端正常发送邮件了。

## 修改 Roundcube 网页邮箱的附件上传大小

如果使用 Roundcube 网页邮箱，需要额外更改两个地方：

### 修改 PHP 设置允许上传大附件

修改 PHP 配置文件 `/etc/php.ini` 中的 `memory_limit`， `upload_max_filesize` 和 `post_max_size` 三个参数：

* 在 RHEL/CentOS 系统上: 配置文件路径是 `/etc/php.ini`
* 在 Debian/Ubuntu 系统上，配置文件路径是 `/etc/php5/apache2/php.ini`
* 在 FreeBSD 系统上，配置文件路径是 `/usr/local/etc/php.ini` （Apache），或者是 `/etc/php5/fpm/php.ini` （Nginx）。
* 在 OpenBSD 系统上，配置文件路径是 `/etc/php-5.4.ini`。如果你运行的 PHP 版本号为 5.4 ，路径将会不一样。

```
memory_limit = 200M;
upload_max_filesize = 100M;
post_max_size = 100M;
```

### 修改 Roundcube 网页邮箱设置以允许上传大附件

修改 roundcube 目录下的 `.htaccess` 文件:

* 在 RHEL/CentOS 系统上，此文件路径为 `/var/www/roundcubemail/.htaccess`
* 在 Debian/Ubuntu 系统上，此文件路径为 `/usr/share/apache2/roundcubemail/.htaccess` 或者
  `/opt/www/roundcubemail/.htaccess`.
* 在 FreeBSD 系统上，此文件路径为 `/usr/local/www/roundcubemail/.htaccess`
* 在 OpenBSD 系统上，此文件路径为 `/var/www/roundcubemail/.htaccess`

注意:某些 Linux/BSD 发行版本可能没有 `.htaccess` 文件，此时你可以忽略此步骤。

```
php_value    memory_limit   200M
php_value    upload_max_filesize    100M
php_value    post_max_size  100M
```

至此，重启 Apache 或 Nginx 服务以使上述修改生效。

## 修改 Nginx 上传大小

在配置文件 `/etc/nginx/nginx.conf` 中找到参数 `client_max_body_size`  ，按需要修改大小：

```
http {
    ...
    client_max_body_size 100m;
    ...
}
