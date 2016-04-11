# iRedAdmin-Pro RESTful API (interact with `curl`)

[TOC]

## Summary

iRedAdmin-Pro RESTful API will return message in JSON format.

* If operation succeed, it returns JSON `{'success': true}`.
* If operation failed, it returns JSON `{'success': false, 'msg': '<error_reason>'}`.

## Requirements

* At least iRedAdmin-Pro-SQL-2.4.0 or iRedAdmin-Pro-LDAP-2.6.0. Earlier releases
  didn't offer RESTful API.
* Our samples below requires tool `curl`: <https://curl.haxx.se>.

## Login

```
curl -X POST -c cookie.txt -d "username=<username>&password=<password>" https://<server>/api/login
```

* Replace `<username>` by the real admin email address.
* Replace `<password>` by the real admin password.
* It will create a plain text file `cookie.txt` under current directory.

## Domain

### Create a new mail domain

```
curl -X POST -i -b cookie.txt -d "var=<value>&var2=value2" https://<server>/api/domain/<domain>
```

* Replace `<domain>` by the (new) real domain name.

Optional POST data:

* `cn`: the short description of this domain name. e.g. company name.
* `quota`: a integer number for mailbox quota (for whole domain)
* `preferredLanguage`: default preferred language for new user. e.g. `en_US` for English, `de_DE` for Deutsch.
* `defaultQuota`: default mailbox quota for new user.
* `maxUserQuota`: Max mailbox quota of a single mail user
* `numberOfUsers`: Max number of mail user accounts
* `numberOfAliases`: Max number of mail alias accounts

### Delete an existing mail domain

```
curl -X DELETE -i -b cookie.txt https://<server>/api/domain/<domain>
```

* Replace `<domain>` by the (existing) domain name.

## User

### Create a new mail user

```
curl -X POST -i -b cookie.txt -d "var=value1&var2=value2&..." https://<server>/api/user/<mail>
```

* Replace `<mail>` by the (new) email address.

Required POST data:

* `password`: password for this user

Optional POST data:

* `cn`: display name
* `preferredLanguage`: default preferred language for new user. e.g. `en_US` for English, `de_DE` for Deutsch.
* `mailQuota`: mailbox quota for this user (in MB). Defaults to per-domain quota setting or unlimited.

### Delete an existing mail user

```
curl -X DELETE -i -b cookie.txt https://<server>/api/user/<mail>
```

* Replace `<mail>` by the (existing) email address.

## See Also

* [iRedAdmin-Pro RESTful API (interact with Python)](./iredadmin-pro.restful.api.python.html)
