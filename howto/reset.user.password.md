# Reset user password

> * SSHA512 is recommended for SQL backends, don't use MD5 unless you have a reason.
> * BCRYPT is recommended for SQL backens on BSD systems.

With MySQL or PostgreSQL backends, you can generate a password hash with
`openssl` or `doveadm` command first, then replace old one with this newly
generated one.

For example:

* Generate a salted MD5 password hash with `openssl` (plain password is `123456`
in this case):

```
$ openssl passwd -1 123456
$1$2dQ48hyz$.mCLeDSdPkP3fxVmARsB.0
```

Or, generate password hash with `doveadm`:

```
$ doveadm pw -s 'ssha512' -p '123456'
{SSHA512}jOcGSlKEz95VeuLGecbL0MwJKy0yWY9foj6UlUVfZ2O2SNkEExU3n42YJLXDbLnu3ghnIRBkwDMsM31q7OI0jY5B/5E=
```

* Reset password for user `user@domain.ltd` and `another-user@domain.ltd`:

```
sql> USE vmail;
sql> UPDATE mailbox SET password='$1$2dQ48hyz$.mCLeDSdPkP3fxVmARsB.0' WHERE username='user@domain.ltd';
sql> UPDATE mailbox SET password='{SSHA512}jOcGSlKEz95VeuLGecbL0MwJKy0yWY...' WHERE username='another-user@domain.ltd';
```

With OpenLDAP backend, you can reset it with phpLDAPadmin or other LDAP client
tools, `SSHA` is preferred if you have other applications to authenticate
users against OpenLDAP.

It's ok to use plain password temporarily, then login to Roundcube webmail
or iRedAdmin-Pro (with self-service enabled) to reset password immediately.
For example:

```
sql> UPDATE mailbox SET password='{PLAIN}123456' WHERE username='user@domain.ltd';
```

## See also

* [Password hashes used/supported by iRedMail](./password.hashes.html)
