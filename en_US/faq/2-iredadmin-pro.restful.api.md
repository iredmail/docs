# iRedAdmin-Pro: RESTful API

!!! note

    If you need an API which has not yet been implemented, don't hesitate to
    [contact us](../contact.html).

[TOC]

## Summary

iRedAdmin-Pro RESTful API will return message in JSON format.

* If operation succeed, client will receive JSON data: `{'success': true}`.
* If operation failed, client will receive JSON data: `{'success': false, 'msg': '<error_reason>'}`.

## Requirements

* At least iRedAdmin-Pro-SQL-2.4.0 or iRedAdmin-Pro-LDAP-2.6.0. Earlier releases
  didn't offer RESTful API.

## Enable RESTful API

RESTful API is disabled by default, to enable it, please add setting below in
iRedAdmin-Pro config file `settings.py`:

```
ENABLE_RESTFUL_API = True
```

To restrict API access to few IP addresses, please also add settings below in
iRedAdmin-Pro config file:

```
# Enable restriction
RESTRICT_API_ACCESS = True

# List all IP addresses of allowed client for API access.
RESTFUL_API_CLIENTS = ['172.16.244.1', ...]
```

Restarting Apache or uwsgi (if you're running Nginx) is required.

## APIs

Notes:

* replace `<domain>` in URL by the real domain name.
* replace `<mail>` in URL by the real email address.

### Domain

URL | HTTP Method | Summary
--- | --- | ---
/api/domain/<domain\> | POST | Create a new domin
/api/domain/<domain\> | DELETE | Delete an existing domain
/api/domain/<domain\> | PUT | Update profile of an existing domain

Possible `PUT` parameters used to update account profile:

Parameter Name | Summary | Sample Usage
--- |--- |---
`cn` | the short description of this domain name. e.g. company name | `cn=iRedMail Project`
`quota` | a integer number for mailbox quota (for whole domain, in MB) | `quota=20480`
`preferredLanguage` | default preferred language for new user | `preferredLanguage=en_US`
`defaultQuota` | default mailbox quota for new user | `defaultQuota=1024`
`maxUserQuota` | Max mailbox quota of a single mail user | `maxUserQuota=2048`
`numberOfUsers` | Max number of mail user accounts | `numberOfUsers=20`
`numberOfAliases` | Max number of mail alias accounts | `numberOfAliases=30`

### User

URL | HTTP Method | Summary
--- |---| ---
/api/user/<mail\> | POST | Create a new mail user
/api/user/<mail\> | DELETE | Delete an existing mail user
/api/user/<mail\> | PUT | Update profile of an existing mail user

Possible `PUT` parameters used to update account profile:

Parameter Name | Summary | Sample Usage
--- |--- |---
`cn` | display name | `cn=My New Name`
`preferredLanguage` | default preferred language for new user | `preferredLanguage=en_US`
`mailQuota` | mailbox quota for this user (in MB) | `mailQuota=1024`
`password` | Password | `password=Ww0nXVEV8iv4ap@p4b`
`transport` | Transport program | `transport=dovecot`

### Mailing List

!!! note

    This is applicable to OpenLDAP. For SQL backends, please use mail alias
    account as mailing list.

URL | HTTP Method | Summary
--- |---| ---
/api/maillist/<mail\> | POST | Create a new mailing list
/api/maillist/<mail\> | DELETE | Delete an existing mailing list
/api/maillist/<mail\> | PUT | Update profile of an existing mailing list

Possible `PUT` parameters used to update account profile:

Parameter Name | Summary | Sample Usage
--- |--- |---
`cn` | display name | `cn=My List Name`
`accessPolicy` | Defines who can send email to this mailing list | `accessPolicy=public`

### Mail Alias

URL | HTTP Method | Summary
--- |---| ---
/api/alias/<mail\> | POST | Create a new mail alias
/api/alias/<mail\> | DELETE | Delete an existing mail alias
/api/alias/<mail\> | PUT | Update profile of an existing mail alias

Possible `PUT` parameters used to update account profile:

Parameter Name | Summary | Sample Usage
--- |--- |---
`cn` | display name | `cn=My List Name`
`accessPolicy` | Defines who can send email to this mail alias account | `accessPolicy=public`

> Note: `accessPolicy` for mail alias account is only available for SQL backends.

### Throttling

URL | HTTP Method | Summary
--- |---| ---
/api/throttle/global/inbound | GET | Get global inbound throttle settings
/api/throttle/global/outbound | GET | Get global outbound throttle settings
/api/throttle/global/inbound | POST | Set global inbound throttle setting
/api/throttle/global/outbound | POST | Set global outbound throttle setting
/api/throttle/<domain\>/inbound | GET | Get domain inbound throttle settings
/api/throttle/<domain\>/outbound | GET | Get domain outbound throttle settings
/api/throttle/<domain\>/inbound | POST | Set domain inbound throttle setting
/api/throttle/<domain\>/outbound | POST | Set domain outbound throttle setting
/api/throttle/<mail\>/inbound | GET | Get user inbound throttle settings
/api/throttle/<mail\>/outbound | GET | Get user outbound throttle settings
/api/throttle/<mail\>/inbound | POST | Set user inbound throttle setting
/api/throttle/<mail\>/outbound | POST | Set user outbound throttle setting

Possible `POST` parameters used to set throttle setting:

Parameter Name | Summary | Sample Usage
--- |--- |---
`period` | Period of time (in seconds) | `period=3600` (one hour)
`msg_size` | Max size of single email | `msg_size=10485760` (10 MB)
`max_msgs` | Number of max inbound emails | `max_msgs=20` (up to 20 messages)
`max_quota` | Cumulative size of all inbound emails | `max_quota=1048576000` (1 GB)

##  Sample code to interact with iRedAdmin-Pro RESTful API

* [iRedAdmin-Pro RESTful API (interact with `curl`)](./iredadmin-pro.restful.api.curl.html)
* [iRedAdmin-Pro RESTful API (interact with Python)](./iredadmin-pro.restful.api.python.html)
