# 使用购买的 SSL 证书

[TOC]

iRedMail 在安装期间会自动生成一个自签名的 SSL 证书，如果你只是要确保有安全的
网络服务（如基于 SSL/TLS 之上的 POP3/IMAP/SMTP 服务），该证书足以。但某些邮件
客户端或浏览器会弹出一个烦人的警示框，提示你该证书不受信任。为了避免这种提示，
必须从 SSL 证书供应商那里购买 SSL 证书。在 Google 中搜索 `buy ssl certificate`
会列出许多 SSL 证书供应商，选择你信任的那一家即可。

> [Let's Encrypt 提供免费的 SSL 证书](https://letsencrypt.org).

## 生成 SSL 密钥并购买 SSL 证书

首先，你需要在服务器上使用 `openssl` 命令生成一个新的 SSL 证书。__警告__ ：请
__不要__使用长度小于 2048 位的密钥，那是不安全的。

```
# openssl req -new -newkey rsa:2048 -nodes -keyout server.key -out server.csr
```

该命令会生成两个文件：

* `server.key`：密钥文件。可用于解密 SSL 证书。必须保护好这个文件。
* `server.csr`：用于申请证书的前面请求文件。__购买 SSL 证书时服务商需要此文件。__

openssl 命令会依据 X.509 规范的要求提示输入凭据信息：

* `Country Name (2 letter code)`: 使用两个不带标点符号的字母来表示国别。例如： US，CA，CN。
* `State or Province Name (full name)`: 地区或省份全称。例如：California。
* `Locality Name (eg, city)`: 城市或城镇名称。例如：Berkeley。
* `Organization Name (eg, company)`: 组织名、公司名。
* `Organizational Unit Name (eg, section)`: 申请此凭据的部门或单位。
* `Common Name (e.g. server FQDN or YOUR name)`: 服务器域名或申请人名字。
* `Email Address []`: 申请人邮箱地址。
* `A challenge password []`: 为该 SSL 证书设置一个密码。
* `An optional company name []`: 一个可选的备用公司名。

__注意__：有一些 web 服务器只能识别 `Common Name` 里指定的服务器地址。例如，使用为
`domain.com` 申请的证书，用户在访问 `www.domain.com` 或者 `secure.domain.com`
的网页时，会被警告当前网站使用的证书不可信，因为 `www.domain.com`、
`secure.domain.com` 与证书的域名 `domain.com` 是不同的。

现在有了 `server.key` 和 `server.csr` 两个文件，前往选定的 SSL 证书供应商
的网站购买证书，它会要求你上传 `server.csr` 文件或输入该文件的内容，然后就可以
获得签发的 SSL 证书了。

通常情况下， SSL 服务提供商将会给你两个文件：

* server.crt
* server.ca-bundle

我们需要着两个文件，以前之前生成的 `server.key`。将它们上传到服务器，以下是
推荐的存放路径：

* 在 RHEL/CentOS 系统上：`server.crt` 和 `server.ca-bundle` 上传至
  `/etc/pki/tls/certs/` ，`server.key` 上传至 `/etc/pki/tls/private/`。
* 在 Debian/Ubuntu， FreeBSD 系统上： `server.crt` 和 `server.ca-bundle` 上传至
  `/etc/ssl/certs/`， `server.key` 上传至`/etc/ssl/private/`。
* 在 OpenBSD 系统上：上传至 `/etc/ssl/`。

## 配置 Postfix/Dovecot/Apache/Nginx 使用购买的 SSL 证书

下面示例中我们以 CentOS 系统为例，请根据你的发行版调整相关文件路径（已在上面注明）。

### Postfix (SMTP 服务器)

直接使用 `postconf` 命令来更新 SSL 证书相关的设置：

```
postconf -e smtpd_use_tls='yes'
postconf -e smtpd_tls_cert_file='/etc/pki/tls/certs/server.crt'
postconf -e smtpd_tls_key_file='/etc/pki/tls/private/server.key'
postconf -e smtpd_tls_CAfile='/etc/pki/tls/certs/server.ca-bundle'
```

修改后需重启 Postfix 服务。

### Dovecot (POP3/IMAP 服务器)

Dovecot 的 SSL 证书设置定义在主配置文件 `/etc/dovecot/dovecot.conf`
(Linux/OpenBSD) 或 `/usr/local/etc/dovecot/dovecot.conf` (FreeBSD) 里:

```
ssl = required
ssl_cert = </etc/pki/tls/certs/server.crt
ssl_key = </etc/pki/tls/private/server.key
ssl_ca = </etc/pki/tls/certs/server.ca-bundle
```

修改后需重启 Dovecot 服务。

### Apache 网页服务器

* 在 RHEL/CentOS 系统上，配置文件为 `/etc/httpd/conf.d/ssl.conf` 。
* 在 Debian/Ubuntu 系统上，配置文件为 `/etc/apache2/sites-available/default-ssl` 。
  （或者是 `default-ssl.conf` ）
* 在 FreeBSD 系统上，配置文件为 `/usr/local/etc/apache24/extra/httpd-ssl.conf` 。注意：取决于运行的 Apache 版本，右侧路径会有所不同（`apache24` 将会是 `apache[_version_]` ）。
* 在 OpenBSD 系统，如果是 OpenBSD 5.5 或更早的版本，配置文件为 `/var/www/conf/httpd.conf` 。注意： OpenBSD 5.6 以及之后的版本不再装置 Apache 。

示例：

```
SSLCertificateFile /etc/pki/tls/certs/server.crt
SSLCertificateKeyFile /etc/pki/tls/private/server.key
SSLCertificateChainFile /etc/pki/tls/certs/server.ca-bundle
```

修改后需重启 Apache 服务。

### Nginx (网页服务器)

* 在 Linux 和 OpenBSD 系统上, 配置文件为 `/etc/nginx/conf.d/default.conf` 。
* 在 FreeBSD 系统上，配置文件为 `/usr/local/etc/nginx/conf.d/default.conf` 。

```
server {
    listen 443;
    ...
    ssl on;
    ssl_certificate /etc/pki/tls/certs/server.crt;
    ssl_certificate_key /etc/pki/tls/private/server.key;
    ...
}
```

大部分浏览器能识别 SSL 证书，但可能有小部分浏览器无法正确识别。这种情况可以
将 `server.crt` 和 `server.ca-bundle` 的内容追加到一个新文件里，然后以这个
新文件作为 SSL 证书。注意：`server.crt` 的内容要在前面。

```
# cd /etc/pki/tls/certs/
# cat server.crt server.ca-bundle > server.chained.crt
```

更新 `/etc/nginx/conf.d/default.conf` 文件中的 `ssl_certificate` 参数：

```
    ssl_certificate /etc/pki/tls/certs/server.chained.crt;
```

修改后需重启 Nginx 服务。

### OpenLDAP

* Red Hat/CentOS，配置文件为 `/etc/openldap/slapd.conf`。
* Debian/Ubuntu，配置文件为 `/etc/ldap/slapd.conf`。
* FreeBSD，配置文件为 `/usr/local/etc/openldap/slapd.conf`。
* OpenBSD，配置文件为 `/etc/openldap/slapd.conf`。

```
TLSCACertificateFile /etc/pki/tls/certs/server.ca-bundle
TLSCertificateFile /etc/pki/tls/certs/server.crt
TLSCertificateKeyFile /etc/pki/tls/private/server.key
```

修改后需重启 OpenLDAP 服务。

## 参考资料

* [HTTPS 服务器配置](http://nginx.org/en/docs/http/configuring_https_servers.html)
