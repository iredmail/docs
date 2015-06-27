# Use a bought SSL certificate

[TOC]

iRedMail generates a self-signed SSL certificate during installation, it's
fine if you just want to secure the network connections (POP3/IMAP/SMTP over
TLS, HTTPS), but mail clients or web browsers will promot a annoying message
to warn you this self-signed certificate is not trusted. To avoid this
annoying message, you have to buy a SSL certificate from SSL certificate
provider. Search `buy ssl certificate` in Google will give you many SSL
providers, choose the one you prefer.

> [StartSSL.com offers free one-year certificate](http://www.startssl.com/?app=1).

## Generate SSL private key and buy one SSL certificate

First of all, you need to generate a new SSL certificate on your server
with `openssl` command. __WARNING__: do NOT use key length smaller than `2048` bit,
it's insecure.

```
# openssl req -new -newkey rsa:2048 -nodes -keyout server.key -out server.csr
```

This command will generate two files:

* `server.key`: the private key for the decryption of your SSL certificate.
* `server.csr`: the certificate signing request (CSR) file used to apply
  for your SSL certificate. __This file is required by SSL certificate
  provider.__

The openssl command will prompt for the following X.509 attributes of the
certificate:

* `Country Name (2 letter code)`: Use the two-letter code without punctuation
  for country. for example: US, CA, CN.
* `State or Province Name (full name)`: Spell out the state completely; do not
  abbreviate the state or province name, for example: California.
* `Locality Name (eg, city)`: City or town name, for example: Berkeley.
* `Organization Name (eg, company)`: Your company name.
* `Organizational Unit Name (eg, section)`: The name of the department or 
  organization unit making the request.
* `Common Name (e.g. server FQDN or YOUR name)`: server FQDN or your name.
* `Email Address []`: your full email address.
* `A challenge password []`: type a password for this ssl certificate.
* `An optional company name []`: an optional company name.

NOTE: Some certificates can only be used on web servers using the `Common Name`
specified during enrollment. For example, a certificate for the domain
`domain.com` will receive a warning if accessing a site named `www.domain.com`
or `secure.domain.com`, because `www.domain.com` and `secure.domain.com` are
different from `domain.com`.

Now you have two files: `server.key` and `server.csr`. Go to the website of
your preferred SSL privider, it will ask you to upload `server.csr` file to
issue an SSL certificate.

Usually, SSL provider will give you 2 files:

* server.crt
* server.ca-bundle

We need above 2 files, and `server.key`. Upload them to your server, you can
store them in any directory you like, recommended directories are:

* on RHEL/CentOS: `server.crt` and `server.ca-bundle` should be placed under
  `/etc/pki/tls/certs/`, `server.key` should be `/etc/pki/tls/private/`.
* on Debian/Ubuntu, FreeBSD: `server.crt` and `server.ca-bundle` should be
  placed under `/etc/ssl/certs/`, `server.key` should be `/etc/ssl/private/`.
* on OpenBSD: `/etc/ssl/`.

## Configure Postfix/Dovecot/Apache/Nginx to use bought SSL certificate

We use CentOS for example in below tutorial, please adjust the file to correct
one on your server.

### Postfix (SMTP server)

We can use `postconf` command to update SSL related settings directly:
```
postconf -e smtpd_use_tls='yes'
postconf -e smtpd_tls_cert_file='/etc/pki/tls/certs/server.crt'
postconf -e smtpd_tls_key_file='/etc/pki/tls/private/server.key'
postconf -e smtpd_tls_CAfile='/etc/pki/tls/certs/server.ca-bundle'
```

Restarting Postfix service is required.

### Dovecot (POP3/IMAP server)

SSL certificate settings are defined in Dovecot main config file,
`/etc/dovecot/dovecot.conf` (Linux/OpenBSD) or
`/usr/local/etc/dovecot/dovecot.conf` (FreeBSD):

```
ssl = required
ssl_cert = </etc/pki/tls/certs/server.crt
ssl_key = </etc/pki/tls/private/server.key
ssl_ca = </etc/pki/tls/certs/server.ca-bundle
```

Restarting Dovecot service is required.

### Apache (web server)

* On RHEL/CentOS, SSL certificate is defined in `/etc/httpd/conf.d/ssl.conf`.
* On Debian/Ubuntu, it's defined in `/etc/apache2/sites-available/default-ssl`
  (or `default-ssl.conf`)
* On FreeBSD, it's defined in `/usr/local/etc/apache24/extra/httpd-ssl.conf`. Note:
  if you're running different version of Apache, the path will be slightly
  different (`apache24` will be `apache[_version_]`).
* On OpenBSD, if you're running OpenBSD 5.5 or earlier releases, it's defined
  in `/var/www/conf/httpd.conf`. Note: OpenBSD 5.6 and later releases don't
  ship Apache anymore.

Example:

```
SSLCertificateFile /etc/pki/tls/certs/server.crt
SSLCertificateKeyFile /etc/pki/tls/private/server.key
SSLCertificateChainFile /etc/pki/tls/certs/server.ca-bundle
```

Restarting Apache service is required.

### Nginx (web server)

* On Linux and OpenBSD, it's defined in `/etc/nginx/conf.d/default.conf`.
* On FreeBSD, it's defined in `/usr/local/etc/nginx/conf.d/default.conf`.

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

Some browsers may complain about a certificate signed by a well-known
certificate authority, while other browsers may accept the certificate without
issues. This occurs because the issuing authority has signed the server
certificate using an intermediate certificate that is not present in the
certificate base of well-known trusted certificate authorities which is
distributed with a particular browser. In this case the authority provides a
bundle of chained certificates which should be concatenated to the signed
server certificate. The server certificate must appear before the chained
certificates in the combined file:

```
# cd /etc/pki/tls/certs/
# cat server.crt server.ca-bundle > server.chained.crt
```

Then update `ssl_certificate` parameter in `/etc/nginx/conf.d/default.conf`:
```
    ssl_certificate /etc/pki/tls/certs/server.chained.crt;
```

Restarting Nginx service is required.

## Reference

* [Configuring HTTPS servers](http://nginx.org/en/docs/http/configuring_https_servers.html)
