# Request a free cert from Let's Encrypt (for iRedMail Enterprise Edition)

!!! warning

    This tutorial is deprecated, please use the bulitin [SSL Cert Management](./ee.cert.html) instead.

    iRedMail Enterprise Edition supports SSL cert management since v1.3.0,
    no need to request cert manually and setup cron job to renew the cert.

!!! attention

    This tutorial is for servers deployed with
    [iRedMail Enterprise Edition](https://www.iredmail.org/ee.html) (`EE` for short),
    if you're looking for tutorial for servers deployed with downloadable iRedMail
    installer, plase check [this one](./letsencrypt.html) instead.

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

iRedMail EE generates a self-signed SSL certificate during installation, it's
strongly recommended to use a valid one.

You can either request free cert from vendors like
[Let's Encrypt](https://letsencrypt.org), or buy one from other vendors.
In this tutorial, we show you how to request a free cert for hostname
`mail.mydomain.com` from Let's Encrypt, and update related configurations to
use the cert/key files.

Let's Encrypt supports wildcard host names, but it's not covered in this
tutorial, please read its [User Guide](https://certbot.eff.org/docs/using.html)
instead.

## Before requesting a cert

### Which host names should be supported in the SSL cert?

You must understand which host names you need to support in the SSL cert:

1. __The full hostname of your mail server.__

    Server hostname is usually used as SMTP/IMAP/POP3 server address in user's
    mail client application like Outlook, Thunderbird.

    You can get full hostname with command `hostname -f` on Linux, or
    `hostname` on OpenBSD. We use `mail.mydomain.com` for example in this tutorial.

1. __The web host names you need to access via https.__

    For example, `https://mydomain.com`, `https://support.mydomain.com`, then
    you need to support `mydomain.com` and `support.mydomain.com` in the cert.

1. No need to support mail domain name in SSL cert, __unless__ it's also a web
   host name.

### One cert for all domain names, or one cert for each domain name?

Dovecot and Nginx support reading/loading multiple ssl certs (for different
host names), but old Postfix software doesn't, so we recommend to use one cert
for all host names for easier management.

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
  limit. We suggest run verification process first to make sure it fully matches
  the requirements.

    Run command below as root user to start the verification (Note: `--dry-run`
    argument is important here). It will ask few simple questions on console,
    please read carefully and answer them.

    ```
    certbot certonly --webroot --dry-run -w /opt/www/well_known/ -d mail.mydomain.com
    ```

    If you need to support multiple domain names in one cert, please append them
    with additional `-d` arguments like this:

    ```
    certbot certonly --webroot --dry-run -w /opt/www/well_known/ -d mail.mydomain.com -d 2nd.com -d 3rd.com -d 4th.com
    ```

* If everything went well and no error was reported by `certbot`, that means
  verification succeeds, it's ok to actually request the cert by running above
  command again without `--dry-run` argument:

```
certbot certonly --webroot -w /opt/www/well_known/ -d mail.mydomain.com
```

If succeeds, it stores the cert and key files under
`/etc/letsencrypt/live/mail.mydomain.com/` (You may have different host name
instead of `mail.mydomain.com` in this sample path).

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
to the self-signed SSL cert generated by iRedMail Easy, then
restart services which use the cert files:

* `/opt/iredmail/ssl/key.pem`: private key
* `/opt/iredmail/ssl/cert.pem`: certificate
* `/opt/iredmail/ssl/combined.pem`: full chain

Run commands below to backup old cert/key files and create symbol links of
Let's Encrypt cert:

!!! attention

    - You must replace `<domain>` in sample commands below by the real domain name
      on your file system.
    - We use just `fullchain.pem`, not `cert.pem`.

```
cd /opt/iredmail/ssl/
mv cert.pem cert.pem.bak
mv key.pem key.pem.bak
mv combined.pem combined.pem.bak
ln -s /etc/letsencrypt/live/<domain>/fullchain.pem combined.pem
ln -s /etc/letsencrypt/live/<domain>/fullchain.pem cert.pem
ln -s /etc/letsencrypt/live/<domain>/privkey.pem key.pem
```

Now restart Postfix / Dovecot / Nginx services to use the cert:

```
systemctl restart postfix dovecot nginx
```

### Verify the cert

* To verify ssl cert used in Postfix (SMTP server) and Dovecot, please launch a
  mail client application (MUA, e.g. Outlook, Thunderbird) and create an email
  account, make sure you correctly configured the MUA to connect to mail
  server. If SSL cert is not valid, MUA will show you a warning or error message.
* For web service, please visit your website with a web browser, the browser
  should show you the ssl cert status.

## Renew the cert automatically

Cert offered by Let's Encrypt will expire in 90 days, you can renew it manually
with command `certbot renew`, or run same command in a daily or weekly cron
job to renew it automatically. Only those certs which expires in less than
30 days will be renewed. Background services which use the cert must be
restarted or reloaded to load renewed cert files.

If cert was renewed, private key `/etc/letsencrypt/live/<domain>/privkey.pem`
is re-created and linked to new file under `/etc/letsencrypt/archive/<domain>/privkey<X>.pem`
(`<X>` is a digit number), but all files linked to
`/etc/letsencrypt/live/<domain>/privkey.pem` were left to the old one,
so we must update all files linked to `/etc/letsencrypt/live/<domain>/privkey.pem`
after renewed.

Here's a sample cron job that runs at 3:01AM everyday, it runs `certbot certificates`
command to print current cert info, then tries to renew the cert, and restart postfix/nginx/dovecot services
after succeeded:

!!! attention

    Again, replace `<domain>` in sample command below by your real domain name.

```
1 3 * * * certbot certificates; certbot renew --post-hook 'ln -sf /etc/letsencrypt/live/<domain>/privkey.pem /opt/iredmail/ssl/key.pem; /usr/bin/systemctl restart postfix dovecot nginx'
```

## References

* [Let's Encrypt: How it works](https://letsencrypt.org/how-it-works/)

## See Also

* [Use a bought SSL certificate](./use.a.bought.ssl.certificate.html)
