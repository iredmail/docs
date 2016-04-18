# Interact iRedAdmin-Pro RESTful API with `curl`

!!! note

    * For more details about iRedAdmin-Pro RESTful API, please read document:
      [iRedAdmin-Pro: RESTful API](./iredadmin-pro.restful.api.html).
    * If you need an API which has not yet been implemented, don't hesitate to
      [contact us](../contact.html).
    * Our sample code below requires thiard-party Python module `requests`. For
      more details, please read its official documentation:
      [Requests: HTTP for Humans](http://docs.python-requests.org/en/master/)

Sample `curl` commands to interact iRedAdmin-Pro RESTful API.

* replace `<server>` in url by the real server address (hostname or IP) which
  runs iRedAdmin-Pro (with the `/iredadmin` prefix). for example,
  `https://my_domain.com/iredadmin`.
* replace `<domain>` in url by the real domain name.
* replace `<mail>` in url by the real email address.

```
#
# Login
#
# Replace `<username>` by the real admin email address.
# Replace `<password>` by the real admin password.
# It will create a plain text file `cookie.txt` under current directory.
curl -X POST -c cookie.txt -d "username=<username>&password=<password>" https://<server>/api/login

#
# Create domain (POST)
#
# cn=ABC Inc. (display name: "ABC Inc."
# quota=20480 (quota: 20 GB)
curl -X POST -i -b cookie.txt -d "cn=ABC Inc.&quota=20480" https://<server>/api/domain/<domain>

#
# Create mail user (POST)
#
# cn=Zhang Huangbin (display name: "Zhang Huangbin")
# mailQuota=1024 (mailbox quota: 1 GB)
curl -X POST -i -b cookie.txt -d "cn=Zhang Huangbin&mailQuota=1024" https://<server>/api/user/<mail>

#
# Delete mail user (DELETE)
#
curl -X DELETE -i -b cookie.txt https://<server>/api/user/<mail>

#
# Update mail user profiles (PUT)
#
curl -X PUT -i -b cookie.txt -d "cn=John Smith&mailQuota=2048" https://<server>/api/user/<mail>

#
# Create mail alias (POST)
#
# cn=My Alias (display name: "My Alias")
curl -X POST -i -b cookie.txt -d "cn=My Alias" https://<server>/api/alias/<mail>

#
# Delete mail alias (DELETE)
#
curl -X DELETE -i -b cookie.txt https://<server>/api/alias/<mail>

#
# Create mailing list (POST, OpenLDAP backend only)
#
curl -X POST -i -b cookie.txt -d "cn=My List" https://<server>/api/maillist/<mail>

#
# Delete mail alias (DELETE)
#
curl -X DELETE -i -b cookie.txt https://<server>/api/maillist/<mail>

#
# Delete domain (DELETE)
#
curl -X DELETE -i -b cookie.txt https://<server>/api/domain/<domain>
```

## See Also

* [Interact iRedAdmin-Pro RESTful API with Python](./iredadmin-pro.restful.api.python.html)
