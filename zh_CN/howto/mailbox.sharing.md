# 共享邮箱（和其他用户共享 IMAP 目录）

> 自 iRedMail-`0.7.0` 版起，共享邮箱的相关设置被配置于 Dovecot 中，但是没有启用。
> 以下是开启此 "acl" 插件功能的方法。

> 自 iRedMail-`0.9.0`版起，共享邮箱功能默认开户，用户不需要任何额外的配置。

> 请勿将“共享目录”和“公共目录”的概念混淆。对于共享目录而言，用户必须选择一个要共享的目录并指定共享给谁。Do not mistake "shared folders" for "public folders". For shared folders,
> users must select which folder they want to share and with who, using an
> interface, like IMAP command line or the ones available with Roundcube
> webmail or SOGo and SOGo connectors.

## 开户邮箱共享

要开启邮箱共享功能，请确保 Dovecot 中位于 `/etc/dovecot/dovecot.conf` 路径的配置文件中的  `acl` 插件参数为启用状态，如下所示：

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

例如：将用户 share from@domain.ltd 的 `Sent` 目录共享给用户 `testing@domain.ltd` 。

> 警告：不要遗漏 IMAP 命令前面的点 `.` 号。

```
# telnet localhost 143                # <- Type this.
* OK [...] Dovecot ready.

. login from@domain.ltd passwd        # <- Type this.
                                      # Login with full email address and password
. OK [... ACL ..] Logged in

. SETACL Sent testing@domain.ltd rli  # <- Type this.
                                      # Share folder `Sent` with user testing@domain.ltd,
                                      # with permissions: read (r), lookup (l) and insert (i).
. OK Setacl complete.

^]                                    # <- Press `Ctrl + ]` to exit telnet.
telnet> quit
```

以用户 `testing@domain.ltd` 身份登录 Roundcube 网页邮箱或 SOGo 网页邮箱，即可看到共享的目录。

额外信息：

* 使用 `SETACL` 命令共享目录后， Dovecot 会在 MySQL 数据库中插入一条记录。

    * 对于采用 OpenLDAP 后端的用户，此记录保存在 `iredadmin.share_folder` 中。
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

* Dovecot wiki百科：

    * [用户间共享邮箱 (v2.0+)](http://wiki2.dovecot.org/SharedMailboxes/Shared)
    * [用户间共享邮箱 (v1.2+)](http://wiki.dovecot.org/SharedMailboxes/Shared)

* Roundcubemail 有官方插件 `acl` 用来管理邮箱共享。
* SOGo 邮箱组件默认支持邮箱共享：右击 IMAP 文件夹，选择 `Sharing` 。
* [Imap-ACL-Extension for Thunderbird](https://addons.mozilla.org/en-US/thunderbird/addon/imap-acl-extension/), manage acls/permissions for shared mailboxes/folders on imap servers.
