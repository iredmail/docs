# iRedAdmin-Pro RESTful API (interact with Python)

[TOC]

!!! note

    If you need an API which has not yet been implemented, feel free to
    [contact us](../contact.html).

## Summary

iRedAdmin-Pro RESTful API will return message in JSON format.

* If operation succeed, it returns JSON `{'success': true}`.
* If operation failed, it returns JSON `{'success': false, 'msg': '<error_reason>'}`.

## Requirements

* At least iRedAdmin-Pro-SQL-2.4.0 or iRedAdmin-Pro-LDAP-2.6.0. Earlier releases
  didn't offer RESTful API.
* Our sample Python code requires Python module `requests`. For more details,
  please read its [official documentation](http://docs.python-requests.org/en/master/).

## Sample code

### Login

!!! note

    We need the cookies for further operations.

```
import sys
import requests

# Base URL to iRedAdmin-Pro API interface
url = 'https://<server>/iredadmin/api'

# Admin username (email) and password.
admin = 'my_admin@domain.com'
pw = 'my_password'

#
# Login
#
r = requests.post(url + '/login', data={'username': admin, 'password': pw})

# Get returned JSON data (Python dict)
data = r.json()
if not data['success']:
    sys.exit('Login failed')

# Get cookies
cookies = r.cookies
```

### Create new domain

Create new domain `test.com`.

```
requests.post(url + '/domain/test.com',
              cookies=cookies,
              data={'defaultQuota': '1024'})
```

Optional POST data:

* `cn`: the short description of this domain name. e.g. company name.
* `quota`: a integer number for mailbox quota (for whole domain)
* `preferredLanguage`: default preferred language for new user. e.g. `en_US` for English, `de_DE` for Deutsch.
* `defaultQuota`: default mailbox quota for new user.
* `maxUserQuota`: Max mailbox quota of a single mail user
* `numberOfUsers`: Max number of mail user accounts
* `numberOfAliases`: Max number of mail alias accounts

### Delete domain

Delete domain: test.com

```
requests.delete(url + '/domain/test.com', cookies=cookies)
```

### Create new user

Create new user `zhb@test.com`.

```
requests.post(url + '/user/zhb@test.com',
              cookies=cookies,
              data={'cn': 'Zhang Huangbin',
                    'password': 'password_for_zhb',
                    'preferredLanguage': 'en_US',
                    'mailQuota': 2048})
```

Required POST data:

* `password`: password for this user

Optional POST data:

* `cn`: display name
* `preferredLanguage`: default preferred language for new user. e.g. `en_US` for English, `de_DE` for Deutsch.
* `mailQuota`: mailbox quota for this user (in MB). Defaults to per-domain quota setting or unlimited.

### Delete user

Delete user `zhb@test.com`

```
requests.delete(url + '/user/zhb@test.com', cookies=cookies)
```

## See Also

* [iRedAdmin-Pro RESTful API (interact with `curl`)](./iredadmin-pro.restful.api.curl.html)
