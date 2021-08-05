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
That means that SOGO, Roundcube and iRedAdmin are located at host "_" (see (Nginx Documentation)[https://nginx.org/en/docs/http/server_names.html] ) and available at example.com/mail/, example.com/sogo/, etc.
## Move SOGO, Roundcube and iRedAdmin to subdomain.

We can move 1, 2 or 3 services to any subdomain (ex. Roundcube, iRedAdmin, but SOGO leave at "_" host)

To do this, we need:
1. Check available configs with subdomain support at /etc/nginx/templates directory
Open terminal (usually this mean connect over ssh to server)
Enter command after "$":
```
$ ls -w 1 /etc/nginx/templates
adminer.tmpl
fastcgi_php.tmpl
hsts.tmpl
iredadmin-subdomain.tmpl
iredadmin.tmpl
misc.tmpl
netdata-subdomain.tmpl
netdata.tmpl
php-catchall.tmpl
redirect_to_https.tmpl
roundcube-subdomain.tmpl
roundcube.tmpl
sogo-subdomain.tmpl
sogo.tmpl
ssl.tmpl
stub_status.tmpl
```
We can see 4 iRedMail configs with subdomain support:
```
iredadmin-subdomain.tmpl
netdata-subdomain.tmpl
roundcube-subdomain.tmpl
sogo-subdomain.tmpl
```
This mean that iRedAdmin, Netdata, Roundcube or SOGO can be moved to subdomain.
We choose one of them, as example roundcube-subdomain.tmpl
2. Create new site config at /etc/nginx/sites-available/
As example, we create roundcube.example.com.conf
3. Write config to file
We need to use "server" context with
```
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name roundcube.example.com;
```
Then, add line
```
    include /etc/nginx/templates/roundcube-subdomain.tmpl;
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
    server_name roundcube.example.com;

    include /etc/nginx/templates/roundcube-subdomain.tmpl;
    include /etc/nginx/templates/ssl-subdomain.tmpl;
}
```
4. [OPTIONAL] If you want deny acess to your service at host "_" over example.com/mail/, you can do the following:
    * Remove line "include /etc/nginx/templates/roundcube.tmpl;"
    from default config at /etc/nginx/sites-available/00-default-ssl.conf
!!! note
        I recommend 
        - create request wildcard SSL certificate (that works for any subdomain, ex name1.example.com ... 1000name.example.com)
        - create wildcard DNS records, ex. "CNAME *.example.com example.com"
        - Use wildcard SSL certificate for any number of your subdomains (use /etc/nginx/templates/ssl.tmpl as template
        and see (Nginx Docs)[https://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl] if you have troubles)

That's all we need