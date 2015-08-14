# 哈希密码

## iRedMail 使用/支持的哈希密码

在 iRedMail 中， Doevcot 被配置为 Postfix 的 SASL（简单认证与安全层）认证服务器，因此，所有被 Dovecot 支持的密码设定都可以在 iRedMail 中使用。 请参考 Dovecot 的 Wiki 页面：[`Password Schemes`](http://wiki2.dovecot.org/Authentication/PasswordSchemes) ，以获取更多的信息。

下列密码设定均可在 iRedMail-Pro 中使用（就是说可以采用其中任意一种方式来添加新邮箱用户）：

* 简单文本。例如： `123456`
* MD5 （salted）。例如：

    * （推荐）带有前缀： `{CRYPT}$1$GfHYI7OE$vlXqMZSyJOSPXAmbXHq250`
    * 没有前缀： `$1$GfHYI7OE$vlXqMZSyJOSPXAmbXHq250`

    __重要提示__: SOGo 组件不支持没有前缀的 MD5 哈希值，因此，当你打算从旧邮件服务器上迁移密码数据时，请预先加上 `{CRYPT}` 前缀。

* PLAIN-MD5 (unsalted MD5)，例如： `0d2bf3c712402f428d48fed691850bfc`
* SSHA，例如： `{SSHA}OuCrqL2yWwQIu8a9uvyOQ5V/ZKfL7LJD`
* SSHA512，例如： `{SSHA512}FxgXDhBVYmTqoboW+ibyyzPv/wGG7y4VJtuHWrx+wfqrs/lIH2Qxn2eA0jygXtBhMvRi7GNFmL++6aAZ0kXpcy1fxag=`
* BCRYPT，例如： `{CRYPT}$2a$05$TKnXV39M3uJ4o.AbY1HbjeAval9bunHbxd0.6Qn782yKoBjTEBXTe`

__注意__:

* `BCRYPT` 仅在 BSD 平台上有效，因数在 Linux 系统上装载的函数库不支持 bcrypt 编码。

## iRedMail 中默认使用的密码设定

* 对于采用 MySQL 和 PostgreSQL 后端而言：

    * iRedMail-0.8.7 及更早版本： `MD5`
    * iRedMail-0.9.0 及更新版本： `SSHA512`

* 对于采用 LDAP 后端而言： `SSHA`.

    OpenLDAP 内建的密码验证并不直接支持 SHA-2 格式密码，因此，如果你采用的第三方程序需要使用 OpenLDAP 内建的密码验证，那么最好使用 `SSHA` 哈希密码。
	如果你没有这方面的问题，那么可使用 `SSHA512/BCRYPT` 哈希码来保存邮箱用户密码，同时，修改配置文件 `/etc/dovecot/dovecot.conf` 中的参数为 `ldap_bind = no` 。至此， SMTP/IMAP/POP3 服务都能良好的工作在此配置下，但是， Apache 的基础认证则不行。

## 如何在 iRedMail 中使用不同的哈希密码

### 对于采用 MySQL 和 PostgreSQL 后端的用户

所有的邮箱用户账户存放于 SQL 数据表 `vmail.mailbox` 中，用户密码则存放于 SQL 列 `mailbox.password` 中。例如：
```
sql> UPDATE mailbox SET password='$1$GfHYI7OE$vlXqMZSyJOSPXAmbXHq250' WHERE username='xx@xx';
sql> UPDATE mailbox SET password='{SSHA}OuCrqL2yWwQIu8a9uvyOQ5V/ZKfL7LJD' WHERE username='xx@xx';
sql> UPDATE mailbox SET password='{SSHA512}FxgXDhBVYmTqoboW+ibyyzPv/wGG7y4VJtuHWrx+wfqrs/lIH2Qxn2eA0jygXtBhMvRi7GNFmL++6aAZ0kXpcy1fxag=' WHERE username='xx@xx';
```

* 要保存 PLAIN-MD5 ，你需要在哈希密码值前加上前缀 `{PLAIN-MD5}` ：

```
sql> UPDATE mailbox SET password='{PLAIN-MD5}0d2bf3c712402f428d48fed691850bfc' WHERE username='xx@xx';
```

* 要保存文本密码，你需要加上 `{PLAIN}` 前缀：

```
sql> UPDATE mailbox SET password='{PLAIN}123456' WHERE username='xx@xx';
```

### 对于采用 LDAP 后端的用户

用户密码被存放于用户对象的 `userPassword` 属性中。

* 要保存文本密码，SSHA，SSHA512哈希密码，只需要直接按原有格式保存即可。例如：

```
userPassword: 123456
userPassword: {SSHA}OuCrqL2yWwQIu8a9uvyOQ5V/ZKfL7LJD
userPassword: {SSHA512}FxgXDhBVYmTqoboW+ibyyzPv/wGG7y4VJtuHWrx+wfqrs...
```

* 要保存标准的 MD5 哈希值密码（salted MD5 hash），请在哈希密码前加上前缀 `{CRYPT}` （不区分大小写）。例如：
```userPassword: {CRYPT}$1$GfHYI7OE$vlXqMZSyJOSPXAmbXHq250```

__重要提示__ ：If you want to input password hash with phpLDAPadmin,
please choose `clear` in the password hash list, then input password hash.

## 另请参阅

* [重置用户密码](./reset.user.password.html)
