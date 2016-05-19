# iRedAdmin-Pro: RESTful API

!!! note

    If you need an API which has not yet been implemented, don't hesitate to
    [contact us](../contact.html).

[TOC]

## Summary

iRedAdmin-Pro RESTful API will return message in JSON format.

* If operation succeed, iRedAdmin-Pro returns JSON data: `{'success': true}`.
* If operation failed, iRedAdmin-Pro returns JSON data: `{'success': false, 'msg': '<error_reason>'}`.

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

##  Sample code to interact with iRedAdmin-Pro RESTful API

* [iRedAdmin-Pro RESTful API (interact with `curl`)](./iredadmin-pro.restful.api.curl.html)
* [iRedAdmin-Pro RESTful API (interact with Python)](./iredadmin-pro.restful.api.python.html)

## APIs

Notes:

* Parameter name with a `*` mark means the parameter is required, otherwise is optional.
* replace `<domain>` in URL by the real domain name.
* replace `<mail>` in URL by the real email address.

<button type="button" class="toggle_all">Expand/Collapse All API Parameters</button>

### Domain {: .toggle }

<!--
!!! api "`GET`{: .get } `/api/domain/<domain>`{: .url } `Get profile of an existing domain`{: .comment }"
-->
!!! api "`POST`{: .post } `/api/domain/<domain>`{: .url } `Create a new domain`{: .comment } `Parameters`{: .has_params }"

    <div class="params params_domain">

    Parameter Name | Summary | Sample Usage
    --- |--- |---
    `cn` | Short description of this domain name. e.g. company name | `cn=Google Inc`
    `quota` | Per-domain mailbox quota, in MB. | `quota=2048`
    `language` | Default preferred language for newly created mail user | `preferredLanguage=en_US`
    `defaultQuota` | Default per-user mailbox quota for newly created user, in MB. | `defaultQuota=1024`
    `maxUserQuota` | Max mailbox quota of a mail user, in MB. | `maxUserQuota=2048`
    `numberOfUsers` | Max number of mail user accounts | `numberOfUsers=20`
    `numberOfAliases` | Max number of mail alias accounts | `numberOfAliases=30`
    `numberOfLists` | Max number of mailing list accounts (LDAP only)| `numberOfLists=40`

    </div>

!!! api "`DELETE`{: .delete } `/api/domain/<domain>`{: .url } `Delete an existing domain`{: .comment }"

<!--
!!! api "`PUT`{: .put } `/api/domain/<domain>`{: .url } `Update profile of an existing domain`{: .comment } `Parameters`{: .has_params }"

    <div class="params params_domain">

    Parameter Name | Summary | Sample Usage
    --- |--- |---
    `cn` | Short description of this domain name. e.g. company name | `cn=Google Inc`
    `quota` | Mailbox quota for whole domain, in MB. | `quota=2048`
    `language` | Default preferred language for newly created mail user | `preferredLanguage=en_US`
    `defaultQuota` | Default per-user mailbox quota for newly created user | `defaultQuota=1024`
    `maxUserQuota` | Max mailbox quota of a mail user | `maxUserQuota=2048`
    `numberOfUsers` | Max number of mail user accounts | `numberOfUsers=20`
    `numberOfAliases` | Max number of mail alias accounts | `numberOfAliases=30`
    `numberOfLists` | Max number of mailing list accounts (LDAP only)| `numberOfLists=40`

    </div>
-->

### User {: .toggle }

!!! api "`POST`{: .post } `/api/user/<mail>`{: .url } `Create a new mail user`{: .comment }"
!!! api "`DELETE`{: .delete } `/api/user/<mail>`{: .url } `Delete an existing mail user`{: .comment }"
!!! api "`PUT`{: .put } `/api/user/<mail>`{: .url } `Update profile of an existing mail user`{: .comment } `Parameters`{: .has_params} "

    <div class="params params_user">

    Parameter Name | Summary | Sample Usage
    --- |--- |---
    `cn` | Display name | `cn=My New Name`
    `language` | Preferred language of web UI | `preferredLanguage=en_US`
    `mailQuota` | User's mailbox quota, in MB | `mailQuota=1024`
    `transport` | Transport program | `transport=dovecot`

    </div>

!!! api "`PUT`{: .put } `/api/user/<mail>/password`{: .url } `Update user's password`{: .comment } `upcoming`{: .upcoming } `Parameters`{: .has_params }"

    <div class="params">

    Parameter Name | Comment
    --- |---
    `password` | Password

    </div>

!!! api "`PUT`{: .put } `/api/users/<domain>`{: .url } `Update profiles of all users under domain`{: .comment } `upcoming`{: .upcoming } `Parameters`{: .has_params }"

    <div class="params">

    Parameter Name | Comment
    --- |---
    accountStatus | Account status. Possible value is: active, disabled.
    language | Preferred language of web UI
    transport | Per-user transport

    </div>

!!! api "`PUT`{: .put } `/api/users/<domain>/password`{: .url } `Update passwords of all users under domain`{: .comment } `upcoming`{: .upcoming } `Parameters`{: .has_params }"

    <div class="params">

    Parameter Name | Comment
    --- |---
    `password` | Password

    </div>

### Mailing List {: .toggle }

!!! attention

    Mailing list is only available in OpenLDAP backend. For SQL backends,
    please use mail alias account as mailing list.

!!! api "`POST`{: .post } `/api/maillist/<mail>`{: .url } `Create a new mailing list`{: .comment }"
!!! api "`DELETE`{: .delete } `/api/maillist/<mail>`{: .url } `Delete an existing mailing list`{: .comment }"
!!! api "`PUT`{: .put } `/api/maillist/<mail>`{: .url } `Update profile of an existing mailing list`{: .comment } `Parameters`{: .has_params }"

    <div class="params">

    Parameter Name | Summary | Sample Usage
    --- |--- |---
    `cn` | display name | `cn=My List Name`
    `accessPolicy` | Defines who can send email to this mailing list | `accessPolicy=public`

    </div>

### Mail Alias {: .toggle }

!!! api "`POST`{: .post } `/api/alias/<mail>`{: .url } `Create a new mail alias`{: .comment }"
!!! api "`DELETE`{: .delete } `/api/alias/<mail>`{: .url } `Delete an existing mail alias`{: .comment }"
!!! api "`PUT`{: .put } `/api/alias/<mail>`{: .url } `Update profile of an existing mail alias`{: .comment } `Parameters`{: .has_params }"

    <div class="params">

    Parameter Name | Summary | Sample Usage
    --- |--- |---
    `cn` | display name | `cn=My List Name`
    `accessPolicy` | Defines who can send email to this mail alias account | `accessPolicy=public`

    > Note: `accessPolicy` for mail alias account is only available for SQL backends.

    </div>


### Throttling {: .toggle }

!!! api "`GET`{: .get } `/api/throttle/global/inbound`{: .url } `Get global inbound throttle settings`{: .comment }"
!!! api "`POST`{: .post } `/api/throttle/global/inbound`{: .url } `Set global inbound throttle settings`{: .comment } `Parameters`{: .has_params_throttle }"
!!! api "`GET`{: .get } `/api/throttle/global/outbound`{: .url } `Get global outbound throttle settings`{: .comment }"
!!! api "`POST`{: .post } `/api/throttle/global/outbound`{: .url } `Set global inbound throttle settings`{: .comment } `Parameters`{: .has_params_throttle }"
!!! api "`GET`{: .get } `/api/throttle/<domain>/inbound`{: .url } `Get domain inbound throttle settings`{: .comment }"
!!! api "`POST`{: .post } `/api/throttle/<domain>/inbound`{: .url } `Set domain inbound throttle settings`{: .comment } `Parameters`{: .has_params_throttle }"
!!! api "`GET`{: .get } `/api/throttle/<domain>/outbound`{: .url } `Get domain outbound throttle settings`{: .comment }"
!!! api "`POST`{: .post } `/api/throttle/<domain>/outbound`{: .url } `Set domain outbound throttle settings`{: .comment } `Parameters`{: .has_params_throttle }"
!!! api "`GET`{: .get } `/api/throttle/<mail>/inbound`{: .url } `Get user inbound throttle settings`{: .comment }"
!!! api "`POST`{: .post } `/api/throttle/<mail>/inbound`{: .url } `Set user inbound throttle settings`{: .comment } `Parameters`{: .has_params_throttle }"
!!! api "`GET`{: .get } `/api/throttle/<mail>/outbound`{: .url } `Get user outbound throttle settings`{: .comment }"
!!! api "`POST`{: .post } `/api/throttle/<mail>/outbound`{: .url } `Set user outbound throttle settings`{: .comment } `Parameters`{: .has_params_throttle }"

    <div class="params params_throttle">

    Parameters available for global, per-domain, per-user throttle settings.

    Parameter Name | Summary | Sample Usage
    --- |--- |---
    `period` * | Period of time, in seconds | `period=3600` (one hour)
    `msg_size` | Max size of single email, in bytes | `msg_size=10485760` (10 MB)
    `max_msgs` | Number of max inbound emails | `max_msgs=20` (up to 20 messages)
    `max_quota` | Cumulative size of inbound or outbound emails, in bytes | `max_quota=1048576000` (1 GB)

    </div>













<script src="./js/jquery-1.12.3.min.js"></script>
<script type="text/javascript">
$(document).ready(function(){
    /* Collapse all parameters by default */
    $('.params').hide();

    /* Expand/Collapse ALL parameters */
    $('.toggle_all').bind('click', function(){$('.params').toggle();});  

    /* Expand/Collapse parameters under same title/category */
	$('.toggle').on('click', function() {
        $(this).nextUntil('.toggle').children('.params').toggle();
    });

    /* Expand/Collapse parameter for current API */
	$('.has_params').on('click', function() {
        $(this).parent().nextUntil('.has_params').toggle();
    });

    /* Expand/Collapse specific parameters */
	$('.has_params_throttle').bind('click', function(){$('.params_throttle').toggle();});  
});
</script>
