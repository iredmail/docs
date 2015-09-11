# 重置用户密码

> * SQL 版本推荐使用 SSHA512 密码。没有特殊情况请不要使用 MD5 密码。
> * BSD 系统的 SQL 后端推荐使用 BCRYPT 密码。

对于 MySQL 或者 PostgreSQL 后端，可以使用 `openssl` 或 `doveadm` 命令来生成
密码，然后用它替换掉旧密码。

例如：使用 `doveadm` 命令生成一个 SSHA512 密码：

```
$ doveadm pw -s 'ssha512' -p '123456'
{SSHA512}jOcGSlKEz95VeuLGecbL0MwJKy0yWY9foj6UlUVfZ2O2SNkEExU3n42YJLXDbLnu3ghnIRBkwDMsM31q7OI0jY5B/5E=
```

要生成 MD5 密码，可以使用 `doveadm` 或 `openssl` 命令：

```
# doveadm pw -s 'MD5' -p '123456' | awk -F'{MD5}' '{print $2}'
$1$TDG8oXHb$6YB9NO5NZaZxku0xv6RsW0

# openssl passwd -1 123456
$1$TDG8oXHb$6YB9NO5NZaZxku0xv6RsW0
```

> __注意__: SOGo groupware 不支持不带前缀的 md5 密码，所以如果要兼容 SOGo，
> 请在 MD5 密码前添加一个 `{CRYPT}` 前缀。例如：
> `{CRYPT}$1$TDG8oXHb$6YB9NO5NZaZxku0xv6RsW0`.

* 为用户 `user@domain.ltd` 重置密码：

```
sql> USE vmail;
sql> UPDATE mailbox SET password='{SSHA512}jOcGSlKEz95VeuLGecbL0MwJKy0yWY9foj6UlUVfZ2O2SNkEExU3n42YJLXDbLnu3ghnIRBkwDMsM31q7OI0jY5B/5E=' WHERE username='user@domain.ltd';
```

OpenLDAP 后端用户可以使用 phpLDAPadmin 或其它 LDAP 客户端工具。如果有其它
程序需要通过 LDAP 做验证，建议使用 `SSHA` 密码以保证通用性，不是所有程序都支持
SSHA512。

作为一种临时方案，可以重置为明文密码，然后立即登录 Roundcube webmail 或
启用了自助服务 (self-service) 功能的 iRedAdmin-Pro 修改密码。
例如：

```
sql> USE vmail;
sql> UPDATE mailbox SET password='{PLAIN}123456' WHERE username='user@domain.ltd';
```

## 参考资料

* [iRedMail 支持的哈希密码](./password.hashes.html)
