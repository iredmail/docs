# 使用购买的 SSL 凭据

[TOC]

iRedMail 在安装期间会自动生成一个自签名的 SSL 凭据，该凭据可以有效保护网络链接的安全（POP3/IMAP/SMTP 基于 TLS, HTTPS）。但是某些邮件客户端或浏览器会弹出一个烦人警示：此链接不受信任。为了避免这种提示，需要从 SSL 凭据服务提供商处购买 SSL凭据。在 Google 中搜索 “buy ssl certificate” ，可以搜索到许多 SSL 凭据服务提供商，选择一个你认为靠谱即可。

> [StartSSL.com 提供免费的一年期 SSL 凭据](http://www.startssl.com/?app=1).

## 生成 SSL 私钥以及购买 SSL 凭据

首先，在服务器上使用 `openssl` 命令来生成一个新的 SSL 凭据。 __警告__ ：请【不要】使用长度小于2048位的密钥，那是不安全的。

```
# openssl req -new -newkey rsa:2048 -nodes -keyout server.key -out server.csr
```

该命令的结果是将产生两个文件：

* `server.key`: 一个描述你的 SSL 凭据的私钥文件the private key for the decryption of your SSL certificate.
* `server.csr`: CSR（证书签名请求）文件是用来验证你的 SSL 凭据的。 __SSL 凭据服务提供商需要此文件。__

openssl 命令会依据 X.509 规范的要求提示输入凭据信息：

* `Country Name (2 letter code)`: 使用两个不带标点符号的字母来表示国别。例如： US，CA，CN。
* `State or Province Name (full name)`: 地区或省份全称。例如： California。
* `Locality Name (eg, city)`: 城市或城镇名称。例如： Berkeley.
* `Organization Name (eg, company)`: 组织名、公司名。
* `Organizational Unit Name (eg, section)`: 申请此凭据的部门或单位。
* `Common Name (e.g. server FQDN or YOUR name)`: 服务器域名或申请人名字。
* `Email Address []`: 申请人邮箱地址。
* `A challenge password []`: 为该 SSL 凭据设置一个密码。
* `An optional company name []`: 一个可选的备用公司名。
注意：在网页服务器上，某些凭据在认证有效期内只能指定使用 `Common Name` 列明的项目。例如，为 `domain.com` 申请凭据后，用户访问 `www.domain.com` 或者 `secure.domain.com` 域名，依然会收到警告，因为 `www.domain.com` 和 `secure.domain.com` 不同于 `domain.com` 。

至此，你有了两个文件： `server.key` 和 `server.csr` 。前往选定的 SSL 凭据服务提供商处，上传 `server.csr` 文件以获取凭据授权。

通常情况下， SSL 服务提供商将会给你两个文件：

* server.crt
* server.ca-bundle

将上述两个文件和 `server.key` 文件上传到服务器的任意目录即可，以下是建议存放这些文件的路径：

* 在 RHEL/CentOS 系统上： `server.crt` 和 `server.ca-bundle` 上传至 `/etc/pki/tls/certs/` ， `server.key` 上传至 `/etc/pki/tls/private/` 。
* 在 Debian/Ubuntu， FreeBSD 系统上： `server.crt` 和 `server.ca-bundle` 上传至 `/etc/ssl/certs/`， `server.key` 上传至 `/etc/ssl/private/` 。
* 在 OpenBSD 系统上：上传至 `/etc/ssl/` 。

## 配置 Postfix/Dovecot/Apache/Nginx 使用购买的 SSL 凭据

下列教程中我们使用 CentOS 系统为例，请按照你的实际情况更改相关文件路径。

### Postfix (SMTP 服务器)

直接使用 `postconf` 命令来更新 SSL 凭据相关的设置：

```
postconf -e smtpd_use_tls='yes'
postconf -e smtpd_tls_cert_file='/etc/pki/tls/certs/server.crt'
postconf -e smtpd_tls_key_file='/etc/pki/tls/private/server.key'
postconf -e smtpd_tls_CAfile='/etc/pki/tls/certs/server.ca-bundle'
```

修改后需重启 Postfix 服务。

### Dovecot (POP3/IMAP 服务器)

Dovecot 的 SSL 凭据设置保存在主配置文件 `/etc/dovecot/dovecot.conf` (Linux/OpenBSD) 或者 `/usr/local/etc/dovecot/dovecot.conf` (FreeBSD) 之中:

```
ssl = required
ssl_cert = </etc/pki/tls/certs/server.crt
ssl_key = </etc/pki/tls/private/server.key
ssl_ca = </etc/pki/tls/certs/server.ca-bundle
```

修改后需重启 Dovecot 服务。

### Apache (网页服务器)

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

即便在大部分浏览器能正常进行 SSL 凭据认证的情况下，依然会有某些浏览器只认可知名度高的 SSL 授权机构颁发的证书。This occurs because the issuing authority has signed the server certificate using an intermediate certificate that is not present in the certificate base of well-known trusted certificate authorities which is distributed with a particular browser. 
In this case the authority provides a
bundle of chained certificates which should be concatenated to the signed
server certificate. The server certificate must appear before the chained
certificates in the combined file:

```
# cd /etc/pki/tls/certs/
# cat server.crt server.ca-bundle > server.chained.crt
```

然后更新 `/etc/nginx/conf.d/default.conf` 文件中的 `ssl_certificate` 参数：
```
    ssl_certificate /etc/pki/tls/certs/server.chained.crt;
```

修改后需重启 Nginx 服务。

## 参数资料

* [HTTPS 服务器配置](http://nginx.org/en/docs/http/configuring_https_servers.html)
