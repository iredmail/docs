# 密码

[TOC]

## iRedMail 支持的密码

在 iRedMail 中，Doevcot 被配置为 Postfix 的 SASL 认证服务器，因此，Dovecot 支持
的所有密码格式都可以在 Postfix (SMTP 服务）中使用。 查看 Dovecot 的 wiki 页面
[Password Schemes](http://wiki2.dovecot.org/Authentication/PasswordSchemes)
获取更多信息。

iRedAdmin-Pro 支持以下密码格式，因此你可以使用给用户使用下列任意一种。

1. SSHA512，例如： `{SSHA512}FxgXDhBVYmTqoboW+ibyyzPv/wGG7y4VJtuHWrx+wfqrs/lIH2Qxn2eA0jygXtBhMvRi7GNFmL++6aAZ0kXpcy1fxag=`
1. BCRYPT，例如： `{CRYPT}$2a$05$TKnXV39M3uJ4o.AbY1HbjeAval9bunHbxd0.6Qn782yKoBjTEBXTe`
1. SSHA，例如： `{SSHA}OuCrqL2yWwQIu8a9uvyOQ5V/ZKfL7LJD`
1. MD5（salted）。例如：

    * 带有前缀：`{CRYPT}$1$GfHYI7OE$vlXqMZSyJOSPXAmbXHq250`
    * 不带前缀：`$1$GfHYI7OE$vlXqMZSyJOSPXAmbXHq250`

    __重要提示__: SOGo 不支持不带前缀的 MD5 密码，因此，当你打算从旧邮件服务器
    上迁移密码数据时，请预先加上 `{CRYPT}` 前缀。

1. PLAIN-MD5 (不带 salt)，例如：`0d2bf3c712402f428d48fed691850bfc`
1. 明文密码。例如： `123456`

__警告__：MD5, PLAIN-MD5 和明文密码都不安全，请尽可能不要使用它们。

__注意__:

* `BCRYPT` 目前仅在 BSD 平台上有效，因为 Linux 系统带的 `libc` 函数库不支持 bcrypt。

## iRedMail 中默认使用的密码

* 对于采用 MySQL 和 PostgreSQL 后端而言：

    * iRedMail-0.9.0 及后续新版本：`SSHA512`
    * iRedMail-0.8.7 及更早版本：`MD5`

* LDAP 后端：`SSHA`.

    OpenLDAP 内建的密码验证不支持直接验证 SHA-2 格式密码，因此，如果你有第三方
    程序需要使用 OpenLDAP 内建的密码验证机制，建议使用 `SSHA`。

	如果你没有这方面的顾虑，可以使用 `SSHA512/BCRYPT` 来保存用户密码，同时
    在 `/etc/dovecot/dovecot.conf` 里设置 `ldap_bind = no`。SMTP/IMAP/POP3
    服务都能正常工作，但是，Apache 的基础认证（basic auth）则不行。

## 如何在 iRedMail 中使用不同的哈希密码

### 对于采用 MySQL 和 PostgreSQL 后端的用户

所有的邮箱用户账户存放于 SQL 表 `vmail.mailbox` 中，用户密码则存放于
`mailbox.password` 字段中。例如（注意：你需要将 `xx@xx` 替换为实际的邮件地址）：

```
sql> USE vmail;
sql> UPDATE mailbox SET password='$1$GfHYI7OE$vlXqMZSyJOSPXAmbXHq250' WHERE username='xx@xx';
sql> UPDATE mailbox SET password='{SSHA}OuCrqL2yWwQIu8a9uvyOQ5V/ZKfL7LJD' WHERE username='xx@xx';
sql> UPDATE mailbox SET password='{SSHA512}FxgXDhBVYmTqoboW+ibyyzPv/wGG7y4VJtuHWrx+wfqrs/lIH2Qxn2eA0jygXtBhMvRi7GNFmL++6aAZ0kXpcy1fxag=' WHERE username='xx@xx';
```

* 要保存 PLAIN-MD5 ，需要加上 `{PLAIN-MD5}` 前缀：

```
sql> USE vmail;
sql> UPDATE mailbox SET password='{PLAIN-MD5}0d2bf3c712402f428d48fed691850bfc' WHERE username='xx@xx';
```

* 要保存明文密码，需要加上 `{PLAIN}` 前缀：

```
sql> USE vmail;
sql> UPDATE mailbox SET password='{PLAIN}123456' WHERE username='xx@xx';
```

### 对于采用 OpenLDAP 后端的用户

用户密码存储于用户的 `userPassword` 属性中。

* 要保存明文密码，SSHA，SSHA512 哈希密码，只需要直接按原有格式保存即可。例如：

```
userPassword: 123456
userPassword: {SSHA}OuCrqL2yWwQIu8a9uvyOQ5V/ZKfL7LJD
userPassword: {SSHA512}FxgXDhBVYmTqoboW+ibyyzPv/wGG7y4VJtuHWrx+wfqrs...
```

* 要保存标准的 MD5 哈希值密码（salted MD5 hash），请在密码前加上 `{CRYPT}`
前缀（不区分大小写）。例如：

```
userPassword: {CRYPT}$1$GfHYI7OE$vlXqMZSyJOSPXAmbXHq250
```

__重要提示__ ：If you want to input password hash with phpLDAPadmin,
please choose `clear` in the password hash list, then input password hash.

## 参考资料

* [重置用户密码](./reset.user.password.html)
