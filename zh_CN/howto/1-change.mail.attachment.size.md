# 修改邮件附件大小

[TOC]

要修改邮件附件大小，需要修改三个地方。

## 修改 postfix 中邮件大小的设置

Postfix 是一个邮件传送代理（MTA），因此，要修改配置以使它能传送大附件的邮件。

假设要修改附件大小为 100MB，需对 `message_size_limit` 和 `mailbox_size_limit`
做如下修改：

```
# postconf -e message_size_limit='104857600'
# postconf -e mailbox_size_limit='104857600'
```

之后重启 Postfix 服务，使上述修改生效:

```
# /etc/init.d/postfix restart
```

__注意__:

* `104857600` 是由 100 (MB) x 1024 (KB) x 1024 (Bit) 计算得到的结果。
* 邮件在发送前会被客户端（Outlook，Thunderbird等）重新编码，导致邮件大小会超过
  100MB，所以建议将上述设置中的邮件大小改为 110MB 或 120MB 即可。
* 如果 `mailbox_size_limit` 的值比 `message_size_limit` 小，你会在 Postfix 日志
  文件里看到这样的错误信息：`fatal: main.cf configuration error:
  mailbox_size_limit is smaller than message_size_limit`.

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

重启 Apache 或 php-fpm 服务以使上述修改生效。

## 限制 Nginx 上传文件大小

在配置文件 `/etc/nginx/nginx.conf` 中找到参数 `client_max_body_size`  ，按需要修改大小：

```
http {
    ...
    client_max_body_size 100m;
    ...
}
```

## 限制 SOGo 上传文件大小

SOGo-3.x 引入新参数 `WOMaxUploadSize` 用于限制上传文件的大小，请将它添加到 SOGo
配置文件 `/etc/sogo/sogo.conf` 里并设置一个合适的附件大小。

```
// set the maximum allowed size for content being sent to SOGo using a PUT or
// a POST call. This can also limit the file attachment size being uploaded
// to SOGo when composing a mail.
//
//  - The value is in kilobyte.
//  - By default, the value is 0, or disabled so no limit will be set.
WOMaxUploadSize = 102400;
```

修改后需要重启 SOGo 服务。
