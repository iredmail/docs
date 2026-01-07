# SSL Certificate Management

[TOC]

Since version v1.3.0, EE supports requesting free ssl certificate from
Let's Encrypt and renew it automatically.

## Request a free cert

Login to EE web ui as global admin, click `SSL Certificate` on left sidebar.

![](./images/ee/cert-1.png){: width="800px" }

Input the domain names you want to support in the ssl cert under the `Domains Names` card.

- It could be the server hostname used by end users in MUAs, or web domain
  names accessed via https protocol.
    - NOTE: All domain names must be pointed to this EE server in A/AAAA/CNAME type DNS record.
- EE requests only one cert with multiple domain names instead of one cert
  per domain. You can add up to 100 domain names.

After you input the domain names, EE queries DNS and displays all IP addresses,
so that you can quickly verify whether they are pointed to this EE server.

![](./images/ee/cert-2.png){: width="800px" }

Once you have all domain names, click the `Request a new cert` button to
request the cert.

- EE requests the cert in dry run mode first to make sure everything is ok and
  avoid [Let's Encrypt rate limit](https://letsencrypt.org/docs/rate-limits/).
  After dry run succeeds, it requests the valid one immediately.
- EE restarts or reloads network services immediately after successfully
  requested the cert, so that they can use the new cert.
  Depends on the backend database you're running and installed components, it
  may restart or reload Postfix, Dovecot, Nginx, OpenLDAP and Prosody services.

![](./images/ee/cert-modal.png){: width="700px" }

After successfully requested, EE displays the valid date and renewal date on
web UI. It will renew the cert right on time automatically and send email
notification to administrator.

![](./images/ee/cert-requested.png){: width="800px" }

If you add or remove some domain names after requested, please click the
`Request a new cert` button again to get a new cert.

If you prefer a purchased cert or whatever, you can remove this free cert by
click the `Delete` button. Be careful, EE does not remove the cert files on
disk, also not restart or reload network services, you must replace the cert
files manually, then restart services.

## Certificate files

- Private key: `/opt/iredmail/ssl/key.pem`
- Full chain: `/opt/iredmail/ssl/combined.pem`
- Cert file: `/opt/iredmail/ssl/cert.pem`. It has same content as full chain file.

## Notes

EE doesn't rely on external tool like `certbot` or `acme.sh` to request or
renew the cert, if you use any of them on this EE server before v1.3.0,
you should at least remove the cron job used to renew the cert (including the
one added by certbot package automatically, `/etc/cron.d/certbot`) to avoid
conflict.

Better remove `certbot` package and its data directory `/etc/letsencrypt/`
completely since you don't need it anymore.
