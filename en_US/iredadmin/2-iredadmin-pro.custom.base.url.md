# iRedAdmin-Pro: Custom base url (/iredadmin)

If you want to replace the base url used to access iRedAdmin (`/iredadmin`) by,
for example, `/admin` (from `https://<server>/iredadmin/` to
`https://<server>/admin/`), you can update Nginx config file
`/etc/nginx/templates/iredadmin.tmpl` and replace `/iredadmin` defined in
`location` and `rewrite`, `uwsgi_param SCRIPT_NAME` directives.

Here's a working full example:

```
# static files under /iredadmin/static
location ~ ^/admin/static/(.*) {                # <- Changed
    alias /var/www/iredadmin/static/$1;
}

# Handle newsletter-style subscription/unsubscription supported in iRedAdmin-Pro.
location ~ ^/newsletter/ {
    rewrite /newsletter/(.*) /admin/newsletter/$1 last; # <- Changed
}

# Python scripts
location ~ ^/admin(.*) {                        # <- Changed
    rewrite ^/admin(/.*)$ $1 break;             # <- Changed

    include /etc/nginx/templates/hsts.tmpl;

    include uwsgi_params;
    uwsgi_pass unix:/run/uwsgi/iredadmin.socket;
    uwsgi_param UWSGI_CHDIR /var/www/iredadmin;
    uwsgi_param UWSGI_SCRIPT iredadmin;
    uwsgi_param SCRIPT_NAME /admin;             # <- Changed

    # Access control
    #allow 127.0.0.1;
    #allow 192.168.1.10;
    #allow 192.168.1.0/24;
    #deny all;
}

# iRedAdmin: redirect /iredadmin to /iredadmin/
location = /admin {                             # <- Changed
    rewrite ^ /admin/;                          # <- Changed
}
```
