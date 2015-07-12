# Force mail user to change password in 90 days

## How it works

iRedMail configures Roundcube webmail to store last password change date while
user changed password. For MySQL/MariaDB/PostgreSQL backends, it's stored in
SQL database `vmail`, column `mailbox.passwordlastchange`. For LDAP backends,
it's stored in LDAP attribute `shadowLastChange` of user account. If user
didn't change password before, or user account is newly created, the password
last change date will be set to `0000-00-00 00:00:00`.

iRedAPD has plugin to force mail users to change password before sending email:

* `sql_force_change_password_in_days`: for SQL backends (MySQL, MariaDB and
  PostgreSQL).
* `ldap_force_change_password_in_days`: for LDAP backends (OpenLDAP and OpenBSD
  built-in LDAP server `ldapd(8)`).

When user trying to send an email, iRedAPD will invoke this plugin to 
check password last change date stored in SQL/LDAP and compare
it with current date. if password last change date is longer than specified
days, this plugin rejects smtp session with specified message.

## How to enable iRedAPD plugin

To enable this plugin, please list the plugin name in iRedAPD config file
`/opt/iredapd/settings.py`, variable `plugins =`. For example:

```python
# For SQL backends
plugins = [..., 'sql_force_change_password_in_days']

# For LDAP backends:
plugins = [..., 'ldap_force_change_password_in_days']
```

There're two optional settings you can set in `/opt/iredapd/settings.py`:

```
# User has to change password in certain days. Default is 90 days.
CHANGE_PASSWORD_DAYS = 90

# MTA will reject user's smtp session with below message. You'd better describe
# why user's email was rejected and guide user to change password.
CHANGE_PASSWORD_MESSAGE = 'Please change your password in webmail before sending email: https://xxx/webmail/'
```

Then restart iRedAPD service.
