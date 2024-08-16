# Request a free cert from Let's Encrypt (for servers deployed with downloadable iRedMail installer)

!!! attention

    This tutorial is for servers deployed with downloadable iRedMail installer,
    if you're looking for tutorial for servers deployed with 
    [iRedMail Easy platform](https://www.iredmail.org/easy.html),
    plase check [this one](./letsencrypt-easy.html) instead.

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

iRedMail generates a self-signed SSL certificate during installation, it's
strongly recommended to use a valid ssl cert.

You can either request free cert, or buy one from ssl cert vendors. In this
tutorial, we will show you how to request a free cert for host name
`mail.mydomain.com` from __[Let's Encrypt](https://letsencrypt.org)__, and ssl
related configurations in relevant software running on iRedMail server.

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

1. No need to support mail domain name in SSL cert, __unless__ it's also a web
   host name.

### One cert for all domain names, or one cert for each domain name?

Dovecot and Nginx support reading/loading multiple ssl certs (for different
host names), but old Postfix software doesn't, so we recommend to use one cert
for all host names which are used by SMTP and IMAP/POP3 services.

### Make sure you have correct DNS record for the host names

The way we request free Let's Encrypt cert requires correct A type DNS record
for the host name, because Let's Encrypt organization needs to make sure
you actually own or control the domain name.

To check the DNS record, you can use `dig` command like below:

```
dig +short -t a mail.mydomain.com
```

It should return the (public) IP address of your server.

## Request cert

* Install the `certbot` package first:
    * on CentOS/Rocky/AlmaLinux: `yum install -y certbot` (offered by EPEL repo)
    * on Debian/Ubuntu: `apt install -y certbot`

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

    If you need to support multiple domain names in one cert, please append them
    with `-d` arguments like this:

    ```
    certbot certonly --webroot --dry-run \
        -w /var/www/html \
        -d mail.mydomain.com \
        -d 2nd-domain.com \
        -d 3rd-domain.com \
        -d 4th-domain.com
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

Directory `/etc/letsencrypt/live/` and `/etc/letsencrypt/archive/` are owned by
root user and group, with permission 0700 (set by `certbot` program) by
default, it means other users can not access them -- including the daemon users
used to run network services like Postfix/Dovecot/OpenLDAP/MariaDB/PostgreSQL.
It's necessary to set the permission to 0755 for other applications to access them.

```
chmod 0755 /etc/letsencrypt/{live,archive}
```

## Use Let's Encrypt cert

The easiest and quickest way to use Let's Encrypt cert is creating symbol links
to the self-signed SSL cert generated by iRedMail installer, then
restart services to load the cert files.

* On RHEL/CentOS:

```
mv /etc/pki/tls/certs/iRedMail.crt{,.bak}       # Backup
mv /etc/pki/tls/private/iRedMail.key{,.bak}     # Backup
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

Now restart Postfix / Dovecot / Nginx services to use the cert:

```
systemctl restart postfix dovecot nginx
```

### Verify the cert

* To verify ssl cert used in Postfix (SMTP server) and Dovecot, please launch a
  mail client application (MUA, e.g. Outlook, Thunderbird) and create an email
  account, make sure you correctly configured the MUA to connect to mail
  server. If SSL cert is not valid, MUA will warn you.
* For Apache / Nginx web server, you can access your website with favourite web
  browser, the browser should show you the ssl cert status. Or, use other
  website to help test it, for example:
  <https://www.ssllabs.com/ssltest/index.html> (input your web host name, then
  submit and wait for a result).

## Renew the cert automatically

Cert can be renewed manually with command `certbot renew`, or run same command
in a daily or weekly cron job to renew automatically. Only those certs which
expires in less than 30 days will be renewed. Applications use ssl cert must
be restarted to load renewed cert files.

If cert was renewed, private key `/etc/letsencrypt/live/<domain>/privkey.pem`
is re-created and linked to file under `/etc/letsencrypt/archive/<domain>/privkey<X>.pem`
(`<X>` is a digit number), but all files linked to
`/etc/letsencrypt/live/<domain>/privkey.pem` were left to the old one,
so we must update all files linked to `/etc/letsencrypt/live/<domain>/privkey.pem`
with argument `--post-hook` right after renewed to make sure they're linked to
correct one.

Here's a sample cron job that runs at 3:01AM everyday, and restart
postfix/nginx/dovecot after renewed:

!!! attention

    - Replace `<domain>` by the real domain name.
    - Replace `/etc/ssl/private/iRedMail.key` by the real linked private key file path on your server.
        - On CentOS/Rocky, it's `/etc/pki/tls/private/iRedMail.key`.
        - On Debian/Ubuntu, FreeBSD and OpenBSD, it's `/etc/ssl/private/iRedMail.key`.

```
1 3 * * * certbot certificates; certbot renew --post-hook 'ln -sf /etc/letsencrypt/live/<domain>/privkey.pem /etc/ssl/private/iRedMail.key; /usr/sbin/systemctl restart postfix dovecot nginx'
```

## Cert configuration in different applications

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

## References

* [How it works](https://letsencrypt.org/how-it-works/)

## See Also

* [Request a free cert from Let's Encrypt (for servers deployed with iRedMail Easy platform)](./letsencrypt-easy.html)
* [Use a bought SSL certificate](./use.a.bought.ssl.certificate.html)
