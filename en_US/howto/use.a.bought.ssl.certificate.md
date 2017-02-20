# Use a SSL certificate

[TOC]

iRedMail generates a self-signed SSL certificate during installation, it's
fine if you just want to secure the network connections (POP3/IMAP/SMTP over
TLS, HTTPS), but mail clients or web browsers will promot a annoying message
to warn you this self-signed certificate is not trusted. To avoid this
annoying message, you have to buy a SSL certificate from SSL certificate
provider. Search `buy ssl certificate` in Google will give you many SSL
providers, choose the one you prefer.

## Get a SSL certificate

### Get a free LetsEncrypt ssl cert

["Let's Encrypt"](https://letsencrypt.org) offers free SSL certificate, please
follow its official tutorial to get one: <https://certbot.eff.org>

!!! attention

    The `--apache` option of `certbot` program will modify Apache config
    files, most time it messes up iRedMail configurations, so it's better
    to get the cert with `certonly --webroot` option while requesting cert, then
    follow tutorial below to update config files to use the cert.

### Buy from a trusted SSL vendor

To buy ssl cert from a trusted vendor, you need to generate a new SSL
key and signing request file on your server with `openssl` command:

!!! warning

    Do NOT use key length smaller than `2048` bit, it's insecure.

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

__NOTE__: Some certificates can only be used on web servers using the `Common Name`
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
one on your server according to above description.

### Postfix (SMTP server)

We can use `postconf` command to update SSL related settings directly:
```
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

### MySQL, MariaDB

> If MySQL/MariaDB is listening on localhost and not accessible from external
> network, this is OPTIONAL.

* On Red Hat and CentOS, it's defined in `/etc/my.cnf`
* On Debian and Ubuntu, it's defined in `/etc/mysql/my.cnf`.
    * Since Ubuntu 15.04, it's defined in `/etc/mysql/mariadb.conf.d/mysqld.cnf`.
* On FreeBSD, it's defined in `/usr/local/etc/my.cnf`.
* On OpenBSD, it's defined in `/etc/my.cnf`.

```
[mysqld]

ssl-ca = /etc/pki/tls/certs/server.ca-bundle
ssl-cert = /etc/pki/tls/certs/server.crt
ssl-key = /etc/pki/tls/private/server.key
```

### OpenLDAP

> If OpenLDAP is listening on localhost and not accessible from external
> network, this is OPTIONAL.

* On Red Hat and CentOS, it's defined in `/etc/openldap/slapd.conf`.
* On Debian and Ubuntu, it's defined in `/etc/ldap/slapd.conf`.
* On FreeBSD, it's defined in `/usr/local/etc/openldap/slapd.conf`.
* On OpenBSD, it's defined in `/etc/openldap/slapd.conf`.

```
TLSCACertificateFile /etc/pki/tls/certs/server.ca-bundle
TLSCertificateFile /etc/pki/tls/certs/server.crt
TLSCertificateKeyFile /etc/pki/tls/private/server.key
```

Restarting OpenLDAP service is required.

If you want to connect with TLS (port 389) or SSL (port 636) for secure
connection from command line tools like `ldapsearch`, please update parameter
`TLS_CACERT` in OpenLDAP client config file also, otherwise you will get
error message like `Peer's Certificate issuer is not recognized`.

* On Red Hat and CentOS, it's defined in `/etc/openldap/ldap.conf`.
* On Debian and Ubuntu, it's defined in `/etc/ldap/ldap.conf`.
* On FreeBSD, it's defined in `/usr/local/etc/openldap/ldap.conf`.
* On OpenBSD, it's defined in `/etc/openldap/ldap.conf`.

```
TLS_CACERT /etc/pki/tls/certs/server.ca-bundle
```

To connect with TLS, please run `ldapsearch` with argument `-Z` and use
`ldap://<your_server_name>:389` as ldap host. For example:

```
ldapsearch -x -W -Z \
    -H 'ldap://mail.example.com:389' \
    -D 'cn=vmail,dc=example,dc=com' \
    -b 'o=domains,dc=example,dc=com' mail
```

* To connection with SSL, use `ldaps://<your_server_name>:636` as ldap host.
  for example:

```
ldapsearch -x -W \
    -H 'ldaps://mail.example.com:636' \
    -D 'cn=vmail,dc=example,dc=com' \
    -b 'o=domains,dc=example,dc=com' mail
```

### OpenBSD ldapd(8)

> If ldapd(8) is listening on localhost and not accessible from external
> network, this is OPTIONAL.
>
> For more details about ldapd config file, please check its manual page: ldapd.conf(5).

To make ldapd(8) listening on network interface for external network, please
make sure you have setting in `/etc/ldapd.conf` to listen on the interface. We
use `em0` as external network interface here for example.

```
# Listen on network interface 'em0', port 389, use STARTTLS for secure connection.
listen on em0 port 389 tls
```

If you want to use port 636 with SSL, try this:

```
# Listen on network interface 'em0', port 636, use SSL for secure connection.
listen on em0 port 636 ldaps
```

ldapd(8) will look for SSL cert and key from directory `/etc/ldap/certs/` by
default, the cert file name is `<interface_name>.crt` and `<interface_name>.key`.
In our case, it will look for `/etc/ldap/certs/em0.crt` and `/etc/ldap/certs/em0.key`.

Since iRedMail already generates a cert and key, we can use it directly. If you
have bought SSL cert/key, or requested one from LetsEncrypt, you can use them
too.

```
cd /etc/ldap/certs/
ln -s /etc/ssl/iRedMail.crt em0.crt
ln -s /etc/ssl/iRedMail.key em0.key
```

Now restart ldapd(8) service:

```
rcctl restart ldapd
```

## Reference

* [Configuring HTTPS servers](http://nginx.org/en/docs/http/configuring_https_servers.html)
