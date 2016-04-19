# Interact iRedAdmin-Pro RESTful API with Python

!!! note

    * For more details about iRedAdmin-Pro RESTful API, please read document:
      [iRedAdmin-Pro: RESTful API](./iredadmin-pro.restful.api.html).
    * If you need an API which has not yet been implemented, don't hesitate to
      [contact us](../contact.html).
    * Our sample code below requires thiard-party Python module `requests`. For
      more details, please read its official documentation:
      [Requests: HTTP for Humans](http://docs.python-requests.org/en/master/)

Sample Python code to interact iRedAdmin-Pro RESTful API.

```
import sys
import requests

url = 'http://<server>/iredadmin/api'

# Admin email address and password.
admin = 'postmaster@mydomain.com'
pw = 'my_password'

# Login
r = requests.post(url + '/login', data={'username': admin,
                                        'password': pw})

# Get returned JSON data
data = r.json()
if not data['success']:
    sys.exit('Login failed')

cookies = r.cookies

# Create domain: test.com
requests.post(url + '/domain/test.com',
              cookies=cookies,
              data={'defaultQuota': '1024'})

# Create user: zhb@test.com
requests.post(url + '/user/zhb@test.com',
              cookies=cookies,
              data={'cn': 'My Name',
                    'password': '1@Password',
                    'preferredLanguage': 'zh_CN',
                    'mailQuota': 2048})

# Create list: list@test.com. Note: OpenLDAP only.
requests.post(url + '/maillist/list@test.com',
              cookies=cookies,
              data={'cn': 'My List'})

# Create alias: alias@test.com
requests.post(url + '/alias/alias@test.com',
              cookies=cookies,
              data={'cn': 'My Alias'})

# Update user: zhb@test.com
requests.put(url + '/user/zhb@test.com',
             cookies=cookies,
             data={'cn': 'My New Name',
                   'password': 'WHDZ2@5yxORvVqzYY',
                   'transport': 'dovecot',
                   'language': 'en_US',
                   'quota': 2048})

# Delete user: zhb@test.com
requests.delete(url + '/user/zhb@test.com', cookies=cookies)

# Delete mailing list: list@test.com. Note: OpenLDAP only.
requests.delete(url + '/maillist/list@test.com', cookies=cookies)

# Delete alias: alias@test.com
requests.delete(url + '/alias/alias@test.com', cookies=cookies)

# Delete domain: test.com
requests.delete(url + '/domain/test.com', cookies=cookies)
```

## See Also

* [Interact iRedAdmin-Pro RESTful API with `curl`](./iredadmin-pro.restful.api.curl.html)
