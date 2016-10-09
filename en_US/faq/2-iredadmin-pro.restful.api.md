# iRedAdmin-Pro: RESTful API

!!! note

    If you need an API which has not yet been implemented, don't hesitate to
    [contact us](../contact.html).

[TOC]

### ChangeLog

* Variable names in returned JSON data has been changed to:
  `{'_success': ..., '_msg': ...}` (was `{'success': ..., 'msg': ...}`).
* Some variable names have been renamed:
    * `cn` -> `name`.
    * `mailQuota` -> `quota`
    * `preferredLanguage` -> `language`

## Summary

iRedAdmin-Pro RESTful API will return message in JSON format.

* If operation succeed:
    * For `POST`, `DELETE`, `PUT` actions, it returns JSON data: `{'_success': true}`.
    * For `GET` action, it returns JSON data: `{'_success': true, '_data': <program_output>}`.
* If operation failed, it returns JSON data: `{'_success': false, '_msg': '<error_reason>'}`.

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

!!! api "`GET`{: .get } `/api/domain/<domain>`{: .url } `Get profile of an existing domain`{: .comment } `upcoming`{: .upcoming }"
!!! api "`POST`{: .post } `/api/domain/<domain>`{: .url } `Create a new domain`{: .comment } `Parameters`{: .has_params }"

    <div class="params params_domain">

    Parameter Name | Summary | Sample Usage
    --- |--- |---
    `name` | Short description of this domain name. e.g. company name | `name=Google Inc`
    `quota` | Per-domain mailbox quota, in MB. | `quota=2048`
    `language` | Default preferred language for newly created mail user | `language=en_US`
    `transport` | Transport program | `transport=dovecot`
    `defaultQuota` | Default per-user mailbox quota for newly created user, in MB. | `defaultQuota=1024`
    `maxUserQuota` | Max mailbox quota of a mail user, in MB. | `maxUserQuota=2048`
    `numberOfUsers` | Max number of mail user accounts | `numberOfUsers=20`
    `numberOfAliases` | Max number of mail alias accounts | `numberOfAliases=30`
    `numberOfLists` | Max number of mailing list accounts (LDAP only)| `numberOfLists=40`
    `senderBcc` | Per-domain sender bcc | `senderBcc=user@domain.com`
    `recipientBcc` | Per-domain recipient bcc | `recipientBcc=user@domain.com`

    </div>

!!! api "`DELETE`{: .delete } `/api/domain/<domain>`{: .url } `Delete an existing domain`{: .comment }"
!!! api "`PUT`{: .put } `/api/domain/<domain>`{: .url } `Update profile of an existing domain`{: .comment } `upcoming`{: .upcoming } `Parameters`{: .has_params }"

    <div class="params params_domain">

    Parameter Name | Summary | Sample Usage
    --- |--- |---
    `name` | Short description of this domain name. e.g. company name | `name=Google Inc`
    `accountStatus` | Enable or disable domain | `accountStatus=active` (or `disabled`)
    `quota` | Mailbox quota for whole domain, in MB. | `quota=2048`
    `language` | Default preferred language for newly created mail user | `language=en_US`
    `transport` | Transport program | `transport=dovecot`
    `defaultQuota` | Default per-user mailbox quota for newly created user | `defaultQuota=1024`
    `maxUserQuota` | Max mailbox quota of a mail user | `maxUserQuota=2048`
    `numberOfUsers` | Max number of mail user accounts | `numberOfUsers=20`
    `numberOfAliases` | Max number of mail alias accounts | `numberOfAliases=30`
    `senderBcc` | Per-domain sender bcc address | `senderBcc=user@domain.com`
    `recipientBcc` | Per-domain recipient bcc address | `recipientBcc=user@domain.com`
    `backupmx` | Mark domain as Backup MX. Must be used with parameter `primarymx`. Conflicts with `transport`. | `backupmx=yes` (or `no`)
    `primarymx` | IP address of primary MX. Must be used with parameter `backupmx`. Conflicts with `transport`. | `primarymx=202.96.134.133`

    </div>

!!! api "`GET`{: .get } `/api/domain/services/<domain>`{: .url } `Get/List all enabled per-domain services`{: .comment } `upcoming`{: .upcoming }"
!!! api "`PUT`{: .put } `/api/domain/services/<domain>`{: .url } `Manage enabled per-domain services`{: .comment } `upcoming`{: .upcoming } `Parameters`{: .has_params }"

    <div class="params params_domain_services">

    Parameter Name | Summary | Sample Usage
    --- |--- |---
    `enableService` | Enable new services. Multiple services must be separated by comma. | `enableService=sogo,vpn,xmpp`
    `disableService` | Disable existing services. Multiple services must be separated by comma. | `disableService=sogo,vpn,xmpp`
    `removeAllServices` | Disable all services (including mail service) | `removeAllServices=` (empty value)

    </div>

!!! api "`PUT`{: .put } `/api/domain/admins/<domain>`{: .url } `Manage normal domain admins.`{: .comment } `upcoming`{: .upcoming } `Parameters`{: .has_params }"

    <div class="params params_domain_admins">

    !!! attention

        Normal domain admin can only promote mail users under managed domains
        to be a domain admin.

    Parameter Name | Summary | Sample Usage
    --- |--- |---
    `addAdmin` | Add new domain admins. Multiple services must be separated by comma. | `addAdmin=one@domain.com,two@domain.com`
    `removeAdmin` | Remove existing domain admins. Multiple services must be separated by comma. | `removeAdmin=one@domain.com,two@domain.com`
    `removeAllAdmins` | Remove all existing domain admins. | `removeAllAdmins=` (empty value)

    </div>

### Mail User {: .toggle }

!!! api "`GET`{: .get } `/api/user/<mail>`{: .url } `Get profile of an existing mail user`{: .comment } `upcoming`{: .upcoming }"
!!! api "`POST`{: .post } `/api/user/<mail>`{: .url } `Create a new mail user`{: .comment } `Parameters`{: .has_params }"

    <div class="params params_user">

    Parameter Name | Summary | Sample Usage
    --- |--- |---
    `name` | Display name | `name=My New Name`
    `password` | Password| `password=AsTr0ng@`
    `language` | Preferred language of web UI | `language=en_US`
    `quota` | Mailbox quota (in MB) | `quota=1024`

    </div>

!!! api "`DELETE`{: .delete } `/api/user/<mail>`{: .url } `Delete an existing mail user`{: .comment }"
!!! api "`PUT`{: .put } `/api/user/<mail>`{: .url } `Update profile of an existing mail user`{: .comment } `Parameters`{: .has_params} "

    <div class="params params_user">

    Parameter Name | Summary | Sample Usage
    --- |--- |---
    `name` | Display name | `name=My New Name`
    `password` | Password | `password=u0tBF82cIV@vi8Gme`
    `quota` | Mailbox quota (in MB) | `quota=1024`
    `accountStatus` | Enable or disable user | `accountStatus=active` (or `disabled`)
    `language` | Preferred language of web UI | `language=en_US`
    `transport` | Transport program | `transport=dovecot`

    </div>

!!! api "`PUT`{: .put } `/api/users/<domain>`{: .url } `Update profiles of all users under domain`{: .comment } `upcoming`{: .upcoming } `Parameters`{: .has_params }"

    <div class="params">

    Parameter Name | Comment
    --- |---
    `accountStatus` | Account status. Possible value is: active, disabled.
    `password` | Password
    `language` | Preferred language of web UI
    `transport` | Per-user transport

    </div>

!!! api "`POST`{: .post } `/api/verify_password/user/<mail>`{: .url } `Verify given (plain) password against the one stored in SQL/LDAP`{: .comment } `upcoming`{: .upcoming } `Parameters`{: .has_params} "

    <div class="params params_user">

    Parameter Name | Summary | Sample Usage
    --- |--- |---
    `password` | Plain password | `password=u0tBF82cIV@vi8Gme`

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
    `name` | display name | `name=My List Name`
    `accessPolicy` | Defines who can send email to this mailing list | `accessPolicy=public`

    </div>

### Mail Alias {: .toggle }

!!! api "`GET`{: .get } `/api/alias/<mail>`{: .url } `Get profile of an existing mail alias`{: .comment } `upcoming`{: .upcoming }"
!!! api "`POST`{: .post } `/api/alias/<mail>`{: .url } `Create a new mail alias`{: .comment } `upcoming`{: .upcoming} `Parameters`{: .has_params}"

    <div class="params">

    Parameter Name | Summary | Sample Usage
    --- |--- |---
    `name` | display name | `name=My List Name`
    `accessPolicy` | Defines who can send email to this mail alias account | `accessPolicy=public`

    !!! attention

        `accessPolicy` for mail alias account is only available for SQL backends.

    </div>

!!! api "`DELETE`{: .delete } `/api/alias/<mail>`{: .url } `Delete an existing mail alias`{: .comment }"
!!! api "`PUT`{: .put } `/api/alias/<mail>`{: .url } `Update profile of an existing mail alias`{: .comment } `Parameters`{: .has_params }"

    <div class="params">

    !!! attention

        `accessPolicy` for mail alias account is only available for SQL backends.

    Parameter Name | Summary | Sample Usage
    --- |--- |---
    `name` | display name | `name=My List Name`
    `accessPolicy` | Defines who can send email to this mail alias account | `accessPolicy=public`

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


### Export Accounts {: .toggle }

#### LDIF (LDAP backend only) {: .toggle }

!!! api "`GET`{: .get } `/api/ldif/domain/<domain>`{: .url } `Export domain to LDIF`{: .comment } `upcoming`{: .upcoming }"
!!! api "`GET`{: .get } `/api/ldif/catchall/<domain>`{: .url } `Export per-domain catch-all account to LDIF`{: .comment } `upcoming`{: .upcoming }"
!!! api "`GET`{: .get } `/api/ldif/admin/<mail>`{: .url } `Export (separated) domain admin to LDIF`{: .comment } `upcoming`{: .upcoming }"
!!! api "`GET`{: .get } `/api/ldif/user/<mail>`{: .url } `Export mail user to LDIF`{: .comment } `upcoming`{: .upcoming }"
!!! api "`GET`{: .get } `/api/ldif/maillist/<mail>`{: .url } `Export mailing list account to LDIF`{: .comment } `upcoming`{: .upcoming }"
!!! api "`GET`{: .get } `/api/ldif/alias/<mail>`{: .url } `Export mail alias account to LDIF`{: .comment } `upcoming`{: .upcoming }"










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
