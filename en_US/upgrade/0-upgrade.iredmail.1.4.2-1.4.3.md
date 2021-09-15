# Upgrade iRedMail from 1.4.2 to 1.4.3

[TOC]

!!! warning

    This IS A DRAFT DOCUMENT, DO NOT APPLY IT.

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.4.3
```

### Nginx: several improvements

!!! attention

    All credit goes to GitHub user
    [@ludovicandrieux](https://github.com/ludovicandrieux), thanks for the
    contributions. See also:
    [#136](https://github.com/iredmail/iRedMail/issues/136), 
    [#137](https://github.com/iredmail/iRedMail/issues/137),
    [#138](https://github.com/iredmail/iRedMail/issues/138).

- Enable TLSv1.3. WARNING: It requires Nginx 1.13 or later releases, which is
  available on:
    - CentOS 7 and later
    - Debian 10 and later
    - FreeBSD
    - OpenBSD
- Greatly improve the performance of http keep-alive connections over SSL by
  enabling `ssl_session_cache` parameter.
- Add new ssl cipher: `EECDH+CHACHA20`. It requires openssl 1.1.0, which is
  available on:
    - CentOS 7 and later
    - Debian 9 and later
    - FreeBSD
    - OpenBSD
- Remove weak ssl cipher: `AES256+EDH`.

To apply these changes, please open file `/etc/nginx/templates/ssl.tmpl` with
your favourite text editor, then:

- Append `TLSv1.3` in parameter `ssl_protocols`. For example:

```
ssl_protocols TLSv1.2 TLSv1.3;
```

- Prepend `EECDH+CHACHA20` in parameter `ssl_ciphers`, also remove `AES256+EDH`.
  For example:

```
ssl_ciphers EECDH+CHACHA20:EECDH+AESGCM:EDH+AESGCM:AES256+EECDH;
```

- Add new parameter `ssl_session_cache` and optional comment lines:

```
# Greatly improve the performance of keep-alive connections over SSL.
# With this enabled, client is not necessary to do a full SSL-handshake for
# every request, thus saving time and cpu-resources.
ssl_session_cache shared:SSL:10m;
```

Restarting Nginx service is required.
