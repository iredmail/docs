# iRedAdmin-Pro: Custom logo image, brand name, short product description

!!! attention

    Restarting Apache or uwsgi (if you're running Nginx) service is required
    after updated iRedAdmin config file.

You can easily change default iRedAdmin-Pro logo image to your company logo,
set a brand name and short product description by adding parameters listed
below in iRedAdmin-Pro config file `/opt/www/iredadmin/settings.py`.

```
# Path to the logo image.
# Please copy your logo image to 'static/' folder, then put the image file name
# in BRAND_LOGO.  e.g.: 'logo.png' (will load file 'static/logo.png').
BRAND_LOGO = ''

# Product name, short description.
BRAND_NAME = 'iRedAdmin-Pro'
BRAND_DESC = 'iRedMail Admin Panel'
```
