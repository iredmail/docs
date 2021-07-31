# Move SOGO, Roundcube and iRedAdmin to subdomains with Nginx

[TOC]

## Introduction
iRedMail create different templates for different needs.
By default, SOGO, Roundcube and iRedAdmin are located at /iredadmin, 
/mail and /sogo (if you install SOGo, then /mail redirect to this too).
For example, we have:

- domain example.com
- server (hosting, etc.) with installed iRedMail
- correctly configured DNS zone example.com

If we visit example.com/iredadmin, then we will be redirected to the iRedAdmin (usually login page of the iRedAdmin)

Let's to see to default config at /etc/nginx/sites-available/00-default-ssl.conf:
```
#
# Note: This file must be loaded before other virtual host config files,
#
# HTTPS
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name _;

    root /var/www/html;
    index index.php index.html;

    include /etc/nginx/templates/misc.tmpl;
    include /etc/nginx/templates/ssl.tmpl;
    include /etc/nginx/templates/iredadmin.tmpl;
    include /etc/nginx/templates/roundcube.tmpl;
    include /etc/nginx/templates/sogo.tmpl;
    include /etc/nginx/templates/netdata.tmpl;
    include /etc/nginx/templates/php-catchall.tmpl;
    include /etc/nginx/templates/stub_status.tmpl;

	location /{
	try_files $uri $uri/ /index.php$is_args$args;
	}
}
```
We can see following:
```
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name _;
    ...
    include /etc/nginx/templates/iredadmin.tmpl;
    include /etc/nginx/templates/roundcube.tmpl;
    include /etc/nginx/templates/sogo.tmpl;
    ...
}
```
That means that SOGO, Roundcube and iRedAdmin are located at host "_" (see (Nginx Documentation)[https://nginx.org/en/docs/http/server_names.html] ).

## Move SOGO, Roundcube and iRedAdmin to subdomain.

We can move 1, 2 or 3 services to any subdomain (ex. Roundcube, iRedAdmin, but SOGO leave at "_" host)

To do this, we need:
1. Delete wanted line(s) from
```
    include /etc/nginx/templates/iredadmin.tmpl;
    include /etc/nginx/templates/roundcube.tmpl;
    include /etc/nginx/templates/sogo.tmpl;
    ...
    include /etc/nginx/templates/example_service.tmpl;
```
As example, we deleted
```
    include /etc/nginx/templates/example_service.tmpl;
```
2. Create new site config at /etc/nginx/sites-available/
As example, we create example_service.example.com.conf
3. Write config to file
We need server{} context with
```
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name example_service.example.com;
```
Then, add line
```
    include /etc/nginx/templates/example_service-subdomain.tmpl;
```
We can also add SSL support:
Create /etc/nginx/templates/ssl-subdomain.tmpl (you may use ssl.tmpl as template), then add line
```
    include /etc/nginx/templates/ssl-subdomain.tmpl;
```
As result, we have
```
server{
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name example_service.example.com;

    include /etc/nginx/templates/example_service-subdomain.tmpl;
    include /etc/nginx/templates/ssl-subdomain.tmpl;
}
```
!!! note
        I recommend 
        - create request wildcard SSL certificate (that works for any subdomain, ex name1.example.com ... 1000name.example.com)
        - create wildcard DNS records, ex. "CNAME *.example.com example.com"

That's all we need