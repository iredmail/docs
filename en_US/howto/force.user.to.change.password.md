# Force mail user to change password in 90 days

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

## How it works

iRedMail configures Roundcube webmail to store last password change date while
user changed password. For MySQL/MariaDB/PostgreSQL backends, it's stored in
SQL database `vmail`, column `mailbox.passwordlastchange`. For LDAP backends,
it's stored in LDAP attribute `shadowLastChange` of user account. If user
didn't change password before, or user account is newly created, the password
last change date will be set to `0000-00-00 00:00:00`.

iRedAPD has plugin to force mail users to change password before sending email:

* `sql_force_change_password`: for SQL backends (MySQL, MariaDB and
  PostgreSQL).
* `ldap_force_change_password`: for LDAP backends (OpenLDAP and OpenBSD
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
plugins = [..., 'sql_force_change_password']

# For LDAP backends:
plugins = [..., 'ldap_force_change_password']
```

There're three optional settings pre-defined in `/opt/iredapd/libs/default_settings.py`,
if you want to change them, please copy the parameter names and set proper values
in `/opt/iredapd/settings.py`:

```
# Force to change password in certain days.
CHANGE_PASSWORD_DAYS = 90

# Reject reason.
# It's recommended to add URL of the web applications which user can login
# to change password in this message. e.g. Roundcube webmail, iRedAdmin-Pro.
CHANGE_PASSWORD_MESSAGE = 'Password expired or never changed, please change your password in webmail before sending email'

# Allow certain users or domains to never change password.
# sample values: ['user@example.com', 'domain.com']
CHANGE_PASSWORD_NEVER_EXPIRE_USERS = []
```

Restarting `iredapd` service is required after changed `/opt/iredapd/settings.py`.

## Roundcube plugin: `force_password_change`

There's a third-party Roundcube plugin can force user to change password.
<https://bitbucket.org/wainlake/force_password_change>

Roundcube will __ALWAYS__ redirect user to `Password` page (offered by official
Roundcube plugin password) until user changed the password.
