# Reset user password

[TOC]

## Reset password with SQL/LDAP command line

### Generate password hash for new password

Storing password in plain text is dangerous, so we need to hash the password.
In case the SQL/LDAP database was leaked/cracked, cracker still need some time
to decode the password hash to get plain password, this will give you some
time to reset password to prevent mail message leak.

> * SSHA512 is recommended on Linux systems.
> * BCRYPT is recommended on BSD systems.
> * MD5 is not safe, DO NOT USE IT no matter what reasons you have.

To generate password hash for new password, please use `doveadm` command. For
example: generate a SSHA512 password hash:

```
$ doveadm pw -s 'ssha512' -p '123456'
{SSHA512}jOcGSlKEz95VeuLGecbL0MwJKy0yWY9foj6UlUVfZ2O2SNkEExU3n42YJLXDbLnu3ghnIRBkwDMsM31q7OI0jY5B/5E=
```

### SQL backends

To reset password for user `user@domain.ltd`, please login to SQL server as
either SQL root user or `vmailadmin` user (note: sql user `vmail` has read-only
privilege to `vmail` database, so you cannot use it to change user password):

```
sql> USE vmail;
sql> UPDATE mailbox SET password='{SSHA512}jOcGSlKEz95VeuLGecbL0MwJKy0yWY9foj6UlUVfZ2O2SNkEExU3n42YJLXDbLnu3ghnIRBkwDMsM31q7OI0jY5B/5E=' WHERE username='user@domain.ltd';
```

### LDAP backends

With OpenLDAP backend, you can reset it with `ldapvi`, phpLDAPadmin or other
LDAP client tools. `SSHA512` is recommended, but if you have some application
which needs to perform authentication with ldap dn directly, then `SSHA` is
preferred.

## Reset password with scripts shipped in iRedAdmin-Pro

### Reset password for one user

iRedAdmin-Pro ships script `tools/reset_user_password.py` to help you reset
one user's password. For example, on CentOS 7 (iRedAdmin is installed under
`/var/www/iredadmin`):

```
cd /var/www/iredadmin/tools/
python reset_user_password.py user@domain.ltd '123456'
```

Sample output:

```
[user@domain.ltd] Password has been reset.
```

### Reset passwords for multiple users with a CSV file

If you need to update many users' passwords, another way is resetting passwords
with script shipped in iRedAdmin-Pro: `tools/update_password_in_csv.py`. It
reads the user email addresses and NEW passwords from a CSV file.

The content is CSV file is:

```
<email> <new_password>
```

One mail user (and new password) per line. For example, file `new_passwords.csv`:

```
user1@domain.com pF4mTq4jaRzDLlWl
user2@domain.com SPhkTUlZs1TBxvmJ
user3@domain.com 8deNR8IBLycRujDN
```

Then run script with this file:

```
python update_password_in_csv.py new_passwords.csv
```

## See also

* [Password hashes used/supported by iRedMail](./password.hashes.html)
* [Promote a mail user to be global admin](./promote.user.to.global.admin.html)
