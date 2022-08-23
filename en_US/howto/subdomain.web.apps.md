# Run web applications under subdomain with Nginx

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

## Introduction

By default, Roundcube, SOGo, Netdata and iRedAdmin are located at `/mail`,
`/SOGo`, `/netdata` and `/iredadmin`. If you have SOGo but no Roundcube,
`/mail` will be redirected to `/SOGo` too.

For example, if your server hostname is `mail.example.com`, and you correctly
added an A type DNS record pointed to this iRedMail server, you should be able
to visit them with URLs below:

- Roundcube webmail: `https://mail.example.com/mail`
- SOGo Groupware: `https://mail.example.com/SOGo`
- Netdata monitor: `https://mail.example.com/netdata`
- iRedAdmin or iRedAdmin-Pro: `https://mail.example.com/iredadmin`

The URIs are defined in the catch-all Nginx web host config file
`/etc/nginx/sites-available/00-default-ssl.conf`, here's its full content:

```
#
# Note: This file must be loaded before other virtual host config files,
#
# HTTPS
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name _;      # <- Name `_` will catch all web domain names,
                        # <- this is why this file must be loaded before other
                        # <- web host config files.

    root /var/www/html;
    index index.php index.html;

    include /etc/nginx/templates/misc.tmpl;         # <- Misc
    include /etc/nginx/templates/ssl.tmpl;          # <- SSL related configurations.
    include /etc/nginx/templates/iredadmin.tmpl;    # <- iRedAdmin
    include /etc/nginx/templates/roundcube.tmpl;    # <- Roundcube webmail
    include /etc/nginx/templates/sogo.tmpl;         # <- SOGo Groupware
    include /etc/nginx/templates/netdata.tmpl;      # <- Netdata monitor
    include /etc/nginx/templates/php-catchall.tmpl; # <- php support
    include /etc/nginx/templates/stub_status.tmpl;  # <- Nginx status monitoring
}
```

As you can see, it loads multiple configuration snippets, and they define the
URIs you can access to visit the web applications.

iRedMail also generates configuration snippet files to run them under subdomain:

- /etc/nginx/templates/iredadmin-subdomain.tmpl
- /etc/nginx/templates/netdata-subdomain.tmpl
- /etc/nginx/templates/roundcube-subdomain.tmpl
- /etc/nginx/templates/sogo-subdomain.tmpl

## Run web applications under subdomain

To run Roundcube, SOGo and/or iRedAdmin under subdomain, you can simply create
a new web host config file, and load the `*-subdomain.tmpl` file.

Let's say you want to run Roundcube under subdomain `webmail.example.com`.

- Update DNS record to point domain name `webmail.example.com` to your iRedMail
  server.
- Create new web host config file `/etc/nginx/sites-available/webmail.example.com.conf` with content below:

```
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name webmail.example.com;

    include /etc/nginx/templates/misc.tmpl;
    include /etc/nginx/templates/ssl.tmpl;
    include /etc/nginx/templates/roundcube-subdomain.tmpl;
}
```

- Create symbol link to `/etc/nginx/sites-enabled/` with shell command below:

```
ln -sf /etc/nginx/sites-available/webmail.example.com.conf /etc/nginx/sites-enabled/webmail.example.com.conf
```

- [OPTIONAL] If you want to remove acess from `https://mail.example.com/mail/`
  (`mail.exmaple.com` is your server hostname), you can simply comment out
  (or add) below line in `/etc/nginx/sites-available/00-default-ssl.conf`:

```
include /etc/nginx/templates/roundcube.tmpl;
```

- Restart or reload Nginx service:

```
service nginx restart
```

### Extra steps for SOGo

SOGo is only accessible by `/SOGo` URI, so when you visit `https://your-site.com/`
it won't redirect to `https://your-site.com/SOGo`. In this case you must
add a `location` directive for `/` URI and redirect requests to `/SOGo`.

```
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name webmail.example.com;

    # Redirect homepage to /SOGo.
    location = / {
        return 302 https://$host/SOGo;
    }

    include /etc/nginx/templates/misc.tmpl;
    include /etc/nginx/templates/ssl.tmpl;
    include /etc/nginx/templates/subdomain-sogo.tmpl;
}
```

## Important notes

- File `/etc/nginx/templates/ssl.tmpl` loads self-signed ssl cert by default,
  we strongly recommend to request free SSL cert by following our tutorial:
  [Request a free cert from Let's Encrypt](https://docs.iredmail.org/letsencrypt.html).

    Note: You can request one cert with multiple domain names.

- You can also create your own Nginx configuration snipppet file with
  different SSL cert/key files too.
