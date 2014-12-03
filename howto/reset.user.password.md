# Reset user password

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
$ doveadm pw -s 'ssha' -p '123456'
{SSHA}MU5Y8OfD9HylnHk4UQaVyaJf6Lugx6vt
```

* Reset password for user `user@domain.ltd` and `another-user@domain.ltd`:

```
sql> USE vmail;
sql> UPDATE mailbox SET password='$1$2dQ48hyz$.mCLeDSdPkP3fxVmARsB.0' WHERE username='user@domain.ltd';
sql> UPDATE mailbox SET password='{SSHA}MU5Y8OfD9HylnHk4UQaVyaJf6Lugx6vt' WHERE username='another-user@domain.ltd';
```

With OpenLDAP backend, you can reset it with phpLDAPadmin or other LDAP client
tools, `SSHA` is preferred.

Reference: [how to use or migrate password hashes](./password.hashes.html)
