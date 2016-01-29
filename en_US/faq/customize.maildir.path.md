# Customize maildir path

iRedAdmin offers several settings to customize the maildir path, default values
are stored in file `libs/default_settings.py`, if you need to change them,
please write your own setting in iRedAdmin main config file `settings.py`, so
that your settings will be kept after upgrading iRedAdmin.

```
# It's RECOMMEND for better performance. Samples:
# - hashed:     domain.ltd/u/s/e/username-2009.09.04.12.05.33/
# - non-hashed: domain.ltd/username-2009.09.04.12.05.33/
MAILDIR_HASHED = True

# Prepend domain name in path. Samples:
# - with domain name: domain.ltd/username/
# - without:          username/
MAILDIR_PREPEND_DOMAIN = True

# Append timestamp in path. Samples:
# - with timestamp:     domain.ltd/username-2010.12.20.13.13.33/
# - without timestamp:  domain.ltd/username/
MAILDIR_APPEND_TIMESTAMP = True
```

Note: each time you modified iRedAdmin source code (Python source file which
file name ends with `.py`), you must restart Apache or uwsgi (if you're running
Nginx) service to load modified code.
