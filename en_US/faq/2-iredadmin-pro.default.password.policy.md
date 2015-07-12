# iRedAdmin-Pro: Default password restrictions

iRedAdmin-Pro has some default password restrictions, you can find default
settings in file `libs/default_settings.py` under iRedAdmin-Pro directory.
If you want to change them, please copy the parameters to iRedAdmin-Pro config
file `settings.py` then update their values. Restarting Apache or uwsgi (if
you're running Nginx) service is required after modified `settings.py`.

```
# default password restriction setting in file: libs/default_settings.py

# Special characters which can be used in password.
PASSWORD_SPECIAL_CHARACTERS = """#$%&'"*+-,.:;!<=>?@[]/\(){}^_`~"""

# Must contain at least one letter, one uppercase letter, one number, one special character
PASSWORD_HAS_LETTER = True
PASSWORD_HAS_UPPERCASE = True
PASSWORD_HAS_NUMBER = True
PASSWORD_HAS_SPECIAL_CHAR = True
```

For example, if you don't want to enforce upper case in password, set below
parameter in iRedAdmin-Pro config file `settings.py`:

```
PASSWORD_HAS_UPPERCASE = False
```
