# iRedAdmin-Pro: Default password restrictions

!!! attention

    Restarting Apache or uwsgi (if you're running Nginx) service is required
    after updated iRedAdmin config file.

!!! warning

    The weakest part of a mail server is user's weak password. Email spammers
    don't want to hack your server, they just want to send spam from your
    server. Please ALWAYS ALWAYS ALWAYS force users to use strong password.

## Password length

You can define required password length in iRedAdmin config file, parameters:

```
# 0 means unlimited, but at least 1 character is required.
min_passwd_length = 8
max_passwd_length = 0
```

It's also supported to set a per-domain password length in domain profile page.

## Password policy

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
