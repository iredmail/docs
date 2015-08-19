# 共享邮箱（将 IMAP 目录共享给其他用户）

> 自 iRedMail-`0.9.0`版起，共享邮箱功能默认开户，用户不需要任何额外的配置。

> 自 iRedMail-`0.7.0` 版起，Dovecot 已包含共享邮箱的相关设置，但没有启用。
> 只需要按照以下文档中启用 `acl` 插件的步骤即可启用该功能。

> 请勿将`共享目录`误理解为`公共目录`的概念混淆。对于共享目录而言，用户必须
> 选择一个要共享的目录并指定共享给谁。

## 共享邮箱

要开启邮箱共享功能，请确保 `acl` 插件已在Dovecot 的配置文件
`/etc/dovecot/dovecot.conf` 里启用。以下是配置示例：

* Dovecot-1.2 版：

```
# Part of file: /etc/dovecot/dovecot.conf

protocol lda {
    mail_plugins = ... acl
}

protocol imap {
    mail_plugins = ... acl imap_acl
}
```

* Dovecot-2.x 版：

```
# Part of file: /etc/dovecot/dovecot.conf

mail_plugins = ... acl

protocol imap {
    mail_plugins = ... imap_acl
}
```

修改后需重启 Dovecot 服务，以使配置生效。

## 测试共享目录

示例：将用户 `from@domain.ltd` 的 `Sent` 目录共享给用户 `testing@domain.ltd` 。

> 注意：不要遗漏 IMAP 命令前面的点 `.` 号。

```
# telnet localhost 143                # <- 输入此命令
* OK [...] Dovecot ready.

. login from@domain.ltd passwd        # <- 输入此命令
                                      # 使用完整邮件地址和密码登陆
. OK [... ACL ..] Logged in

. SETACL Sent testing@domain.ltd rli  # <- 输入此命令
                                      # 将 Sent 目录共享给 testing@domain.ltd，
                                      # 具体权限为：读(r, read)，查询(l, lookup)，插入新邮件(i, insert)。
. OK Setacl complete.

^]                                    # <- 按 `Ctrl + ]` 组合键退出 telnet 程序。
telnet> quit
```

以用户 `testing@domain.ltd` 身份登录 Roundcube 或 SOGo webmail，即可看到共享的目录。

额外信息：

* 使用 `SETACL` 命令共享目录后， Dovecot 会在 MySQL 数据库中插入一条记录。

    * 对于采用 OpenLDAP 后端的用户，此记录保存在 SQL 表 `iredadmin.share_folder` 中。
    * 对于采用 MySQL/MariaDB/PostgreSQL 后端的用户，此记录保存在 `vmail.share_folder` 中。

```
# mysql -uroot -p
mysql> USE vmail;
mysql> SELECT * FROM share_folder;
+-----------------+--------------------+-------+
| from_user       | to_user            | dummy |
+-----------------+--------------------+-------+
| from@domain.ltd | testing@domain.ltd | 1     |
+-----------------+--------------------+-------+
```

## 参考资料

* Dovecot wiki：

    * [共享邮箱 (v2.0+)](http://wiki2.dovecot.org/SharedMailboxes/Shared)
    * [共享邮箱 (v1.2+)](http://wiki.dovecot.org/SharedMailboxes/Shared)

* Roundcubemail 有官方插件 `acl` 用来管理邮箱共享。
* SOGo 邮箱组件默认支持邮箱共享：右击 IMAP 文件夹，选择 `Sharing` 。
* Thunderbird 客户端可以使用 [Imap-ACL-Extension 插件](https://addons.mozilla.org/en-US/thunderbird/addon/imap-acl-extension/)管理共享邮箱
