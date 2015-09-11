# Reset user password

> * SSHA512 is recommended for SQL backends, don't use MD5 unless you have a reason.
> * BCRYPT is recommended for SQL backens on BSD systems.

With MySQL or PostgreSQL backends, you can generate a password hash with
`openssl` or `doveadm` command first, then replace old one with this newly
generated one.

For example: generate a SSHA512 password hash with `doveadm`:

```
$ doveadm pw -s 'ssha512' -p '123456'
{SSHA512}jOcGSlKEz95VeuLGecbL0MwJKy0yWY9foj6UlUVfZ2O2SNkEExU3n42YJLXDbLnu3ghnIRBkwDMsM31q7OI0jY5B/5E=
```

To generate a salted MD5 password hash, you can use `doveadm` or `openssl`:

```
# doveadm pw -s 'MD5' -p '123456' | awk -F'{MD5}' '{print $2}'
$1$TDG8oXHb$6YB9NO5NZaZxku0xv6RsW0

# openssl passwd -1 123456
$1$fnWOb5X8$Ed6FYg9CLuWuUQplnwOQK/
```

> __Important note__: SOGo groupware doesn't support salted MD5 hash without a
> prefix, so if you're going to use MD5 password hash with SOGo,
> please prepend `{CRYPT}` prefix in password hash. For example,
> `{CRYPT}$1$TDG8oXHb$6YB9NO5NZaZxku0xv6RsW0`.

* Reset password for user `user@domain.ltd`:

```
sql> USE vmail;
sql> UPDATE mailbox SET password='{SSHA512}jOcGSlKEz95VeuLGecbL0MwJKy0yWY9foj6UlUVfZ2O2SNkEExU3n42YJLXDbLnu3ghnIRBkwDMsM31q7OI0jY5B/5E=' WHERE username='user@domain.ltd';
```

With OpenLDAP backend, you can reset it with phpLDAPadmin or other LDAP client
tools, `SSHA` is preferred if you have other applications to authenticate
users against OpenLDAP.

It's ok to use plain password temporarily, then login to Roundcube webmail
or iRedAdmin-Pro (with self-service enabled) to reset password immediately.
For example:

```
sql> USE vmail;
sql> UPDATE mailbox SET password='{PLAIN}123456' WHERE username='user@domain.ltd';
```

## See also

* [Password hashes used/supported by iRedMail](./password.hashes.html)
