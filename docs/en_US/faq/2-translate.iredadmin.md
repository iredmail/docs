# iRedAdmin-Pro: Translate iRedAdmin to your local language

If you want to help translate iRedAdmin to your local language, please contact
us to get the latest file which contains all translation items. You can open
the file with your faviourte text editor, translate new items and/or fix existing
improper items. Mail the translated file to email address
`support _at_ iredmail.org`, we will handle rest work.

If you already have iRedAdmin or iRedAdmin-Pro installed, you can find
translated languages under `i18n/` directory. If you are about to translate
it to a new language, you can copy file `i18n/iredadmin.po`, translate it,
and mail translated file to us.

To verify translated items, you can translate the items first (e.g.
`i18n/es_ES/LC_MESSAGES/iredadmin.po` for Spainish), then run script to compile
it:

```
# cd /path/to/iRedAdmin-Pro/
# cd i18n/
# bash translation.sh es_ES     # <- Update Spainish language (es_ES)
```

Restarting Apache or uwsgi (if you're running Nginx) service is required to
reload new translation.

Your help is greatly appreciated.
