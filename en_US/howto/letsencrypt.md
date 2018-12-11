# Request a free cert from Let's Encrypt

[TOC]

iRedMail generates a self-signed SSL certificate during installation, it's
strongly recommended to use an valid ssl cert.

You can either request free cert, or buy one from ssl cert vendors. In this
tutorial, we will show you how to request a free cert for host name
`mail.mydomain.com` from __[Let's Encrypt](https://letsencrypt.org)__, and ssl
related configurations in relevant softwares running on iRedMail server.

Let's Encrypt supports wildcard host names, but it's not covered in this
tutorial, please read its [User Guide](https://certbot.eff.org/docs/using.html)
instead.

We use Let's Encrypt official tool named `certbot` to request cert, there're
some other third-party tools you can use. On OpenBSD, you can use command
`acme-client` which is in base system (check its manual page here:
[acme-client(1)](https://man.openbsd.org/acme-client). To get a list of other
tools, please visit Let's Encrypt website: [ACME Client
Implementations](https://letsencrypt.org/docs/client-options/).

## Before requesting a cert

### Which host names should be supported in the SSL cert?

You must understand which host names you need to support in the SSL cert:

1. __The full hostname of your mail server.__

    Server hostname is usually used as SMTP/IMAP/POP3 server address in user's
    mail client application like Outlook, Thunderbird.

    You can get full hostname with command `hostname -f` on Linux, or
    `hostname` on OpenBSD.

1. __The web host names you need to access via https.__

    For example, `https://mydomain.com`, `https://support.mydomain.com`, then
    you need to support both `mydomain.com` and `support.mydomain.com` in ssl
    cert.

1. __NO__ need to support mail domain name in SSL cert, __except it's a web
   host name also__.

### One cert for all host names, or one cert for each host name?

Dovecot and Nginx support reading/loading multiple ssl certs (for different
host names), but Postfix doesn't (except running multiple Postfix instances and
each instance uses one (different) ssl cert). so we recommend to use one cert
for all host names which are used by SMTP and IMAP/POP3 services.

### Make sure you have correct DNS record for the host names

The way we request free Let's Encrypt cert requires correct A type DNS record
for the host name, because Let's Encrypt organization needs to make sure that
you actually control the domain name and server.  We will describe the detail
later.

To check the DNS record, you can use `dig` command like below:

```
dig +short -t a mail.mydomain.com
```

It should return the (public) IP address of your server.

## Request a free cert from Let's Encrypt

* Follow Let's Encrypt official tutorial to install required `certbot` package:
  <https://certbot.eff.org>. it's used to request cert.

    !!! warning

        `certbot` program offers argument `--apache` and `--nginx` to modify
        Apache/Nginx config files directly, they mess up iRedMail
        configurations, please do not use these 2 arguments.

* Let's Encrypt has request rate limit control, you can request limited times
  for same domain in one day, but the verification process doesn't have such
  limit. We suggest run verification process first to make sure we fully match
  its requirements.

    Run command below as root user to verify the request process with
    `--dry-run` argument. It will print some text on console to ask you few
    simple questions, please read carefully and answer them.

```
certbot certonly --webroot --dry-run -w /var/www/html -d mail.mydomain.com
```

What's happening after you typed this command? you may ask.

!!! note "Things happening right behind the command"

    1. `certbot` program creates a temporary plain text file locally under
       `/var/www/html/.well-known/acme-challenge/`. We use file name
       `35c9406f6b63bd18fa626e5bd9d0ea8b` for example in this tutorial
       (`/var/www/html/.well-known/acme-challenge/35c9406f6b63bd18fa626e5bd9d0ea8b`).
    1. `certbot` program sends the request to Let's Encrypt organization's
       server, including the temporary file name.
    1. Let's Encrypt organization's server will perform http request to your
       server by visiting URL
       `http://mail.mydomain.com/.well-known/acme-challenge/35c9406f6b63bd18fa626e5bd9d0ea8b`
       to make sure the file actually exist on your server. This step is used
       to verify A type DNS record of the host name and the domain name
       ownership (you actually control this domain name and server).
    1. `certbot` program remove temporary file locally.
    1. if no error was reported by `certbot` program on console, and you run
       above command without `--dry-run` argument (described later in this
       tutorial), certbot will obtain ssl cert files and store them under
       `/etc/letsencrypt/` directory.

    For more details, please read Let's Encrypt official document: [How it
    works](https://letsencrypt.org/how-it-works/).

!!! warning

    We assume the web document root directory for web host name
    `mail.mydomain.com` is `/var/www/html` (this is default path configured
    by iRedMail). In new iRedMail releases, the path `/.well-known/` is
    defined in Nginx config file `/etc/nginx/templates/misc.tmpl`, if you
    have hard-coded directory for it with Nginx directive `root
    /path/to/somewhere;`, you need to replace `/var/www/html` by
    `/path/to/somewhere` in commands. For example:

    ```
    certbot certonly --webroot -w /path/to/somewhere -d mail.mydomain.com
    ```

    And sample Nginx configuration:

    ```
    location ~ ^/.well-known/ { allow all; root /path/to/somewhere; }
    ```

* If everything went well and no error was reported by `certbot` program on
  console, that means we fully match the requirements, and it's ok to
  actually request the cert by running above command again but without
  `--dry-run` argument:

```
certbot certonly --webroot -w /var/www/html -d mail.mydomain.com
```

If the command finished successfully, it will create and store cert files under
`/etc/letsencrypt/live/mail.mydomain.com/` (You may have different host name
instead of `mail.mydomain.com` in this sample path).

Created cert files:

* `cert.pem`: Server certificate.
* `chain.pem`: Additional intermediate certificate or certificates that web
  browsers will need in order to validate the server certificate.
* `fullchain.pem`: All certificates, including server certificate (aka leaf
  certificate or end-entity certificate). The server certificate is the first
  one in this file, followed by any intermediates.
* `privkey.pem`: Private key for the certificate.

Directory `/etc/letsencrypt/live/` and `/etc/letsencrypt/archive` are owned by
root user and group, with permission 0700 (set by `certbot` program) by
default, it means other users can not access them -- including the daemon users
used to run network services like Postfix/Dovecot/OpenLDAP/MariaDB/PostgreSQL.
It's necessary to set the permission to 0644 for other applications to access them.

```
chmod 0644 /etc/letsencrypt/{live,archive}
```

## Use Let's Encrypt cert

The easiest and quickest way to use Let's Encrypt cert is creating symbol links
to the self-signed SSL cert generated by iRedMail installer, then
restart services which use the cert files.

### Create symbol links

* On RHEL/CentOS:

```
mv /etc/pki/tls/certs/iRedMail.crt{,.bak}       # Backup. Rename iRedMail.crt to iRedMail.crt.bak
mv /etc/pki/tls/private/iRedMail.key{,.bak}     # Backup. Rename iRedMail.key to iRedMail.key.bak
ln -s /etc/letsencrypt/live/mail.mydomain.com/fullchain.pem /etc/pki/tls/certs/iRedMail.crt
ln -s /etc/letsencrypt/live/mail.mydomain.com/privkey.pem /etc/pki/tls/private/iRedMail.key
```

* On Debian/Ubuntu, FreeBSD and OpenBSD:

```
mv /etc/ssl/certs/iRedMail.crt{,.bak}       # Backup. Rename iRedMail.crt to iRedMail.crt.bak
mv /etc/ssl/private/iRedMail.key{,.bak}     # Backup. Rename iRedMail.key to iRedMail.key.bak
ln -s /etc/letsencrypt/live/mail.mydomain.com/fullchain.pem /etc/ssl/certs/iRedMail.crt
ln -s /etc/letsencrypt/live/mail.mydomain.com/privkey.pem /etc/ssl/private/iRedMail.key
```

### Restart network services

Required services:

* Postfix
* Dovecot
* Nginx or Apache

Depends on the backend you chose during iRedMail installation, you may need to
restart:

* MySQL or MariaDB
* PostgreSQL
* OpenLDAP

## Verify the cert

* To verify ssl cert used in Postfix (SMTP server) and Dovecot, please launch a
  mail client application (MUA, e.g. Outlook, Thunderbird) and create an email
  account, make sure you correctly configured the MUA to connect to mail
  server. If SSL cert is not valid, MUA will warn you.
* For Apache / Nginx web server, you can access your website with favourite web
  browser, the browser should show you the ssl cert status. Or, use other
  website to help test it, for example:
  <https://www.ssllabs.com/ssltest/index.html> (input your web host name, then
  submit and wait for a result).

## FAQ

### Renew the cert

Let's Encrypt cert will expire in 90 days, you must renew it before expired.
After renewed, don't forget to restart Postfix/Dovecot/Nginx/Apache to load the
new cert files.

For more details, please read Let's Encrypt official document: [Renewing certificates](https://certbot.eff.org/docs/using.html#renewing-certificates).

### How to check cert status

Run command:

```
certbot certificates
```

It will show you all existing certs and expiry date.

### How to request one cert with multiple host names

If you need to support multiple host names, you can specify multiple `-w`
and `-d` arguments like below:

```
certbot certonly \
    --webroot \
    --dry-run \
    -w /var/www/html \
    -d mail.mydomain.com \
    -w /var/www/vhosts/2nd-domain.com \
    -d 2nd-domain.com \
    -w /var/www/vhosts/3rd-domain.com \
    -d 3rd-domain.com
```

## SSL cert relevant settings in Postfix/Dovecot/Apache/Nginx

In sample settings below, file paths are for Debian/Ubuntu.

### Postfix

File `/etc/postfix/main.cf` (on Linux/OpenBSD) or `/usr/local/etc/postfix/main.cf` (on FreeBSD):

```
smtpd_tls_cert_file = /etc/ssl/certs/iRedMail.crt
smtpd_tls_key_file = /etc/ssl/private/iRedMail.key
smtpd_tls_CAfile = /etc/ssl/certs/iRedMail.crt
```

### Dovecot

File `/etc/dovecot/dovecot.conf` (on Linux/OpenBSD) or `/usr/local/etc/dovecot/dovecot.conf` (on FreeBSD):

```
ssl = required
ssl_cert = </etc/ssl/certs/iRedMail.crt
ssl_key = </etc/ssl/private/iRedMail.key
ssl_ca = </etc/ssl/certs/iRedMail.crt
```

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
SSLCertificateFile /etc/ssl/certs/iRedMail.crt
SSLCertificateKeyFile /etc/ssl/private/iRedMail.key
SSLCertificateChainFile /etc/ssl/certs/iRedMail.crt
```

Restarting Apache service is required.

### Nginx

File `/etc/nginx/templates/ssl.tmpl` (on Linux/OpenBSD) or `/usr/local/etc/nginx/templates/ssl.tmpl` (on FreeBSD):

```
ssl_certificate /etc/ssl/certs/iRedMail.crt;
ssl_certificate_key /etc/ssl/private/iRedMail.key;
```

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

ssl-ca = /etc/ssl/certs/iRedMail.crt
ssl-cert = /etc/ssl/certs/iRedMail.crt
ssl-key = /etc/ssl/private/iRedMail.key
```

### OpenLDAP

> If OpenLDAP is listening on localhost and not accessible from external
> network, this is OPTIONAL.

* On Red Hat and CentOS, it's defined in `/etc/openldap/slapd.conf`.
* On Debian and Ubuntu, it's defined in `/etc/ldap/slapd.conf`.
* On FreeBSD, it's defined in `/usr/local/etc/openldap/slapd.conf`.
* On OpenBSD, it's defined in `/etc/openldap/slapd.conf`.

```
TLSCACertificateFile /etc/ssl/certs/iRedMail.crt
TLSCertificateKeyFile /etc/ssl/private/iRedMail.key
TLSCertificateFile /etc/ssl/certs/iRedMail.crt
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
ln -s /etc/letsencrypt/live/mail.mydomain.com/fullchain.pem em0.crt
ln -s /etc/letsencrypt/live/mail.mydomain.com/privkey.pem em0.key
```

Now restart ldapd(8) service:

```
rcctl restart ldapd
```

## See Also

* [Use a bought SSL certificate](./use.a.bought.ssl.certificate.html)
