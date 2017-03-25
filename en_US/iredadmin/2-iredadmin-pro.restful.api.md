# iRedAdmin-Pro: RESTful API

[TOC]

!!! attention

    * If you need an API which has not yet been implemented, don't hesitate to
      [contact us](../contact.html).
    * This document is applicable to
        * iRedAdmin-Pro-SQL-2.5.0, 2.6.0
        * iRedAdmin-Pro-LDAP-2.7.0, 2.8.0

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
    * For http `POST`, `DELETE`, `PUT` methods, it returns JSON data: `{'_success': true}`.
    * For http `GET` method, it returns JSON data: `{'_success': true, '_data': <program_output>}`.
* If operation failed, it returns JSON data: `{'_success': false, '_msg': '<error_reason>'}`.

## Requirements

This document is applicable to iRedAdmin-Pro-LDAP-2.7.0 and iRedAdmin-Pro-SQL-2.5.0.

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
* replace `<domain>` in URL by the real domain name. e.g. `example.com`
* replace `<mail>` in URL by the real email address. e.g. `user@domain.com`
* replace `<number>` in URL by an integer number. e.g. `30`, `200`

<button type="button" class="toggle_all">Expand/Collapse All API Parameters</button>

### Login {: .toggle }

!!! api "`POST`{: .post } `/api/login`{: .url } `Login with an admin username (full email address) and password`{: .comment } `Parameters`{: .has_params }"

    <div class="params params_domain">

    Parameter | Summary | Sample Usage
    --- |--- |---
    `username` | Admin username. Must be a full email address. | `username=admin@mydomain.com`
    `password` | (Plain) admin password. | `password=AsTr0ng@`

    </div>

### Domain {: .toggle }

!!! api "`GET`{: .get } `/api/domain/<domain>`{: .url } `Get profile of an existing domain`{: .comment }"
!!! api "`POST`{: .post } `/api/domain/<domain>`{: .url } `Create a new domain`{: .comment } `Parameters`{: .has_params }"

    <div class="params params_domain">

    Parameter | Summary | Sample Usage
    --- |--- |---
    `name` | Short description of this domain name. e.g. company name | `name=Google Inc`
    `quota` | Per-domain mailbox quota, in MB. | `quota=2048`
    `language` | Default preferred language for newly created mail user | `language=en_US`
    `transport` | Transport program | `transport=dovecot`
    `defaultQuota` | Default per-user mailbox quota for newly created user, in MB. | `defaultQuota=1024`
    `maxUserQuota` | Max mailbox quota of a mail user, in MB. | `maxUserQuota=2048`
    `numberOfUsers` | Max number of mail user accounts | `numberOfUsers=20`
    `numberOfAliases` | Max number of mail alias accounts | `numberOfAliases=30`
    `numberOfLists` | Max number of mailing list accounts (Available in LDAP backends)| `numberOfLists=40`
    `senderBcc` | Per-domain sender bcc | `senderBcc=user@domain.com`
    `recipientBcc` | Per-domain recipient bcc | `recipientBcc=user@domain.com`

    </div>

!!! api "`DELETE`{: .delete } `/api/domain/<domain>`{: .url } `Delete an existing domain (all mail messages will NOT be removed)`{: .comment }"
!!! api "`DELETE`{: .delete } `/api/domain/<domain>/keep_mailbox_days/<number>`{: .url } `Delete domain, and keep all mail messages for given days`{: .comment }"
!!! api "`PUT`{: .put } `/api/domain/<domain>`{: .url } `Update profile of an existing domain`{: .comment } `Parameters`{: .has_params }"

    <div class="params params_domain">

    Parameter | Summary | Sample Usage
    --- |--- |---
    `name` | Short description of this domain name. e.g. company name | `name=Google Inc`
    `accountStatus` | Enable or disable domain. Possible values: `active`, `disabled`. | `accountStatus=active`
    `quota` | Mailbox quota for whole domain, in MB. | `quota=2048`
    `language` | Default preferred language for newly created mail user | `language=en_US`
    `transport` | Transport program | `transport=dovecot`
    `minPasswordLength` | Minimal password length | `minPasswordLength=8`
    `maxPasswordLength` | Maximum password length | `minPasswordLength=20`
    `defaultQuota` | Default per-user mailbox quota for newly created user | `defaultQuota=1024`
    `maxUserQuota` | Max mailbox quota of a mail user | `maxUserQuota=2048`
    `numberOfUsers` | Max number of mail user accounts | `numberOfUsers=20`
    `numberOfAliases` | Max number of mail alias accounts | `numberOfAliases=30`
    `senderBcc` | Per-domain sender bcc address | `senderBcc=user@domain.com`
    `recipientBcc` | Per-domain recipient bcc address | `recipientBcc=user@domain.com`
    `is_backupmx` | Mark domain as Backup MX. Must be used with parameter `primarymx`. Conflicts with parameter `transport`. | `is_backupmx=yes` (or `no`)
    `primarymx` | Hostname or IP address of primary MX, smtp port number is optional. Must be used with parameter `is_backupmx`. Conflicts with parameter `transport`. | `primarymx=202.96.134.133`, `primarymx=[mail.iredmail.org]:25`
    `catchall` | Per-domain catch-all account (a list of email addresses used to receive emails sent to non-existing addresses under same domain). Multiple addresses must be separated by comma. Set an empty value to disable catch-all support. | `catchall=user@domain.com,user2@domain.com` or `catchall=` (disable catch-all)
    `outboundRelay` | Per-domain outbound relay. Set an empty value to disable outbound relay. | `outboundRelay=smtp:[192.168.1.2]:25` or `outboundRelay=` (disable outbound relay)
    `enableService` | Enable new services. Multiple services must be separated by comma. Available services are listed below. | `enableService=self-service`
    `disableService` | Disable existing services. Multiple services must be separated by comma. Available services are listed below. | `disableService=self-service`
    `removeAllServices` | Disable all services (including mail service) | `removeAllServices=` (empty value)
    `disableDomainProfile` | disable given domain profiles. Normal admin cannot view and update disabled profiles in domain profile page. Available domain profiles are listed below. | `disableDomainProfile=bcc,relay,aliases`
    `enableDomainProfile` | enable given domain profiles. Normal admin can view and update disabled profiles in domain profile page. Available domain profiles are listed below. | `enableDomainProfile=bcc,relay,aliases`
    `disableUserProfile` | disable given user profiles. Normal admin cannot view and update disabled profiles in user profile page. Available user profiles are listed below. | `disableUserProfile=bcc,relay,aliases`
    `enableUserProfile` | enable given domain profiles. Normal admin can view and update disabled profiles in user profile page. Available user profiles are listed below. | `enableUserProfile=bcc,relay,aliases`
    `disableUserPreference` | disable given user preferences in self-service page. Normal mail user cannot view and update disabled preferences. Available user preferences are listed below. | `disableUserPreference=forwarding,wblist`
    `enableUserPreference` | disable given user preferences in self-service page. Normal mail user can view and update disabled preferences. Available user preferences are listed below. | `enableUserProfile=forwarding,wblist`

    Available mail services:

    Profile | Comment
    --- |---
    self-service | Enable self-service for the mail domain.
    mail | All mail services. (LDAP backends only)
    domainalias | Alias domain support. (LDAP backends only)
    senderbcc | Per-domain sender bcc. (LDAP backends only)
    recipientbcc | Per-domain recipient bcc. (LDAP backends only)

    Available domain profiles:

    Profile | Comment
    --- |---
    bcc | Per-domain sender bcc and recipient bcc
    relay | Per-domain inbound relay and outbound relay
    catchall | Per-domain catchall account
    aliases | Alias domains
    throttle | Per-domain inbound and outbound throttling
    greylisting | Per-domain greylisting service
    wblist | Per-domain whitelists and blacklists
    spampolicy | Per-domain spam policy
    backupmx | Backup MX
    advanced | Some extra settings

    Available user profiles:

    Profile | Comment
    --- |---
    bcc | Per-user sender bcc and recipient bcc
    forwarding | Per-user mail forwarding addresses
    relay | Per-user inbound relay and outbound relay
    aliases | Per-user alias addresses
    throttle | Per-user inbound and outbound throttling
    greylisting | Per-user greylisting service
    wblist | Per-user whitelists and blacklists
    spampolicy | Per-user spam policy

    Available user preferences (self-service):

    Profile | Comment
    --- |---
    personal_info | Name, time zone, preferred language of web UI
    forwarding | Per-user mail forwarding addresses
    wblist | Per-user whitelists and blacklists
    quarantine | Manage quarantined mails
    rcvd_mails | View basic info of received mails, and whitelist/blacklist mail sender directly.
    spampolicy | Per-user spam policy

    </div>

!!! api "`PUT`{: .put } `/api/domain/admins/<domain>`{: .url } `Manage normal domain admins.`{: .comment } `Parameters`{: .has_params }"

    <div class="params params_domain_admins">

    !!! attention

        Normal domain admin can only promote mail users under managed domains
        to be a domain admin.

    Parameter | Summary | Sample Usage
    --- |--- |---
    `addAdmin` | Add new domain admins. Multiple services must be separated by comma. | `addAdmin=one@domain.com,two@domain.com`
    `removeAdmin` | Remove existing domain admins. Multiple services must be separated by comma. | `removeAdmin=one@domain.com,two@domain.com`
    `removeAllAdmins` | Remove all existing domain admins. | `removeAllAdmins=` (empty value)

    </div>

### Domain Admin {: .toggle }

!!! attention

    * This is standalone domain admin account, not mail user with admin privileges.
    * Only global admin can access these APIs.

!!! api "`GET`{: .get } `/api/admin/<mail>`{: .url } `Get profile of an existing domain admin`{: .comment }"
!!! api "`POST`{: .post } `/api/admin/<mail>`{: .url } `Create a new domain admin`{: .comment } `Parameters`{: .has_params }"

    <div class="params params_admin">

    Parameter | Summary | Sample Usage
    --- |--- |---
    `name` | Display name | `name=My Admin Name`
    `password` | Password| `password=AsTr0ng@`
    `accountStatus` | Enable or disable account. Possible values: `active`, `disabled`. | `accountStatus=active`
    `language` | Preferred language of iRedAdmin web UI | `language=en_US`
    `isGlobalAdmin` | Mark this admin as global admin | `isGlobalAdmin=yes`

    Below parameters are used by normal domain admin (`isGlobalAdmin=no`). With `isGlobalAdmin=yes`, these parameters will be discarded.

    Parameter | Summary | Sample Usage
    --- |--- |---
    `maxDomains` | how many mail domains this admin can create | `maxDomains=5`
    `maxQuota` | how much mailbox quota this admin can create. Quota is shared by all domains created/managed by this admin. Must be used with parameter `quotaUnit`. Sample: 10TB, 20GB, 100MB.| `maxQuota=2`
    `quotaUnit` | Quota unit used by `maxQuota` parameter. Must be used with parameter `maxQuota`. Possible values: TB, GB, MB. | `quotaUnit=TB`
    `maxUsers` | how many mail users this admin can create. It's shared by all domains created/managed by this admin. | `maxUsers=100`
    `maxAliases` | how many mail aliases this admin can create. It's shared by all domains created/managed by this admin. | `maxAliases=200`
    `maxLists` | how many mailing lists this admin can create. It's shared by all domains created/managed by this admin. | `maxLists=300`

    </div>

!!! api "`DELETE`{: .delete } `/api/admin/<mail>`{: .url } `Delete an existing domain admin`{: .comment }"
!!! api "`PUT`{: .put } `/api/admin/<mail>`{: .url } `Update profile of an existing domain admin`{: .comment } `Parameters`{: .has_params }"

    <div class="params params_admin">

    Parameter | Summary | Sample Usage
    --- |--- |---
    `name` | Display name | `name=My Admin Name`
    `password` | Password| `password=AsTr0ng@`
    `accountStatus` | Enable or disable account. Possible values: `active`, `disabled`. | `accountStatus=active`
    `language` | Preferred language of iRedAdmin web UI | `language=en_US`
    `isGlobalAdmin` | Mark this admin as global admin | `isGlobalAdmin=yes`

    Below parameters are used by normal domain admin (`isGlobalAdmin=no`). With `isGlobalAdmin=yes`, these parameters will be discarded.

    Parameter | Summary | Sample Usage
    --- |--- |---
    `maxDomains` | how many mail domains this admin can create | `maxDomains=5`
    `maxQuota` | how much mailbox quota this admin can create. Quota is shared by all domains created/managed by this admin. Must be used with parameter `quotaUnit`. Sample: 10TB, 20GB, 100MB.| `maxQuota=2`
    `quotaUnit` | Quota unit used by `maxQuota` parameter. Must be used with parameter `maxQuota`. Possible values: TB, GB, MB. | `quotaUnit=TB`
    `maxUsers` | how many mail users this admin can create. It's shared by all domains created/managed by this admin. | `maxUsers=100`
    `maxAliases` | how many mail aliases this admin can create. It's shared by all domains created/managed by this admin. | `maxAliases=200`
    `maxLists` | how many mailing lists this admin can create. It's shared by all domains created/managed by this admin. | `maxLists=300`

    </div>

!!! api "`POST`{: .post } `/api/verify_password/admin/<mail>`{: .url } `Verify given (plain) password against the one stored in SQL/LDAP`{: .comment } `Parameters`{: .has_params} "

    <div class="params params_admin">

    !!! attention

        Password verification is limited to global domain admin.

    Parameter | Summary | Sample Usage
    --- |--- |---
    `password` | Plain password | `password=u0tBF82cIV@vi8Gme`

    </div>

### Mail User {: .toggle }

!!! api "`GET`{: .get } `/api/user/<mail>`{: .url } `Get profile of an existing mail user`{: .comment }"
!!! api "`POST`{: .post } `/api/user/<mail>`{: .url } `Create a new mail user`{: .comment } `Parameters`{: .has_params }"

    <div class="params params_user">

    Parameter | Summary | Sample Usage
    --- |--- |---
    `name` | Display name | `name=My New Name`
    `password` | Password| `password=AsTr0ng@`
    `language` | Preferred language of iRedAdmin web UI | `language=en_US`
    `quota` | Mailbox quota (in MB) | `quota=1024`

    </div>

!!! api "`DELETE`{: .delete } `/api/user/<mail>`{: .url } `Delete an existing mail user`{: .comment }"
!!! api "`DELETE`{: .delete } `/api/user/<mail>/keep_mailbox_days/<number>`{: .url } `Delete an existing mail user, and keep the mailbox for given days. Defaults to 100 years.`{: .comment }"
!!! api "`PUT`{: .put } `/api/user/<mail>`{: .url } `Update profile of an existing mail user`{: .comment } `Parameters`{: .has_params} "

    <div class="params params_user">

    Parameter | Summary | Sample Usage
    --- |--- |---
    `name` | Display name | `name=My New Name`
    `password` | Password | `password=u0tBF82cIV@vi8Gme`
    `quota` | Mailbox quota (in MB) | `quota=1024`
    `accountStatus` | Enable or disable user. Possible values: `active`, `disabled`. | `accountStatus=active`
    `language` | Preferred language of iRedAdmin web UI | `language=en_US`
    `employeeid` | User ID (or Employee Number) | `employeeid=My Employee ID`
    `transport` | Transport program | `transport=dovecot`
    `forwarding` | Per-user mail forwarding. Multiple addresses must be separated by comma. To save an email copy in mailbox, add original email address as one of forwarding addresses. | `forwarding=user1@domain.com,user2@domain.com,user3@domain.com`
    `aliases` | Per-user alias addresses. Multiple addresses must be separated by comma. If empty, all per-user alias addresses owned by this user will be removed. __If given addresses exist on system before this assignment, they won't be assigned to the user.__ Conflicts with parameter `addAlias` and `removeAlias`. | `aliases=user1@domain.com,user2@domain.com,user3@domain.com`
    `addAlias` | Add new per-user alias addresses. Multiple addresses must be separated by comma. Conflicts with parameter `aliases`. | `aliases=user1@domain.com,user2@domain.com,user3@domain.com`
    `removeAlias` | Remove existing per-user alias addresses. Multiple addresses must be separated by comma. Conflicts with parameter `aliases`. | `aliases=user1@domain.com,user2@domain.com,user3@domain.com`

    </div>

!!! api "`POST`{: .put } `/api/user/<mail>/change_email/<new_mail>`{: .url } `Change user's email address (from '<mail>' to '<new_mail>')`{: .comment }"
!!! api "`PUT`{: .put } `/api/users/<domain>`{: .url } `Update profiles of all users under domain`{: .comment } `Parameters`{: .has_params }"

    <div class="params">

    Parameter | Comment
    --- |---
    `accountStatus` | Account status. Possible value is: active, disabled.
    `password` | Password
    `language` | Preferred language of iRedAdmin web UI
    `transport` | Per-user transport

    </div>

!!! api "`POST`{: .post } `/api/verify_password/user/<mail>`{: .url } `Verify given (plain) password against the one stored in SQL/LDAP`{: .comment } `Parameters`{: .has_params} "

    <div class="params params_user">

    !!! attention

        Password verification is limited to global domain admin.

    Parameter | Summary | Sample Usage
    --- |--- |---
    `password` | Plain password | `password=u0tBF82cIV@vi8Gme`

    </div>

### Mailing List {: .toggle }

!!! attention

    Mailing list is only available in OpenLDAP backend. For SQL backends,
    please use mail alias account as mailing list.

!!! api "`GET`{: .get } `/api/maillist/<mail>`{: .url } `Get profile of an existing mailing list account`{: .comment }"
!!! api "`POST`{: .post } `/api/maillist/<mail>`{: .url } `Create a new mailing list`{: .comment } `Parameters`{: .has_params }"
    <div class="params">

    Parameter | Summary | Sample Usage
    --- |--- |---
    `name` | Display name | `name=My List Name`
    `accessPolicy` | Defines who can send email to this mail alias account | `accessPolicy=public`
    `members` | Members of mailing list. Multiple members must be separated by comma. | `members=user1@domain.com,user2@domain.com`

    </div>

!!! api "`DELETE`{: .delete } `/api/maillist/<mail>`{: .url } `Delete an existing mailing list`{: .comment }"
!!! api "`PUT`{: .put } `/api/maillist/<mail>`{: .url } `Update profile of an existing mailing list`{: .comment } `Parameters`{: .has_params }"

    <div class="params">

    Parameter | Summary | Sample Usage
    --- |--- |---
    `name` | display name | `name=My List Name`
    `accessPolicy` | Defines who can send email to this mailing list | `accessPolicy=public`
    `members` | Members of mailing list. Multiple members must be separated by comma. Conflict with parameter `addMember` and `removeMember`. | `members=user1@domain.com,user2@domain.com`
    `addMember` | Add new members of mailing list. Multiple members must be separated by comma. Conflict with parameter `members`. | `addMember=user1@domain.com,user2@domain.com`
    `removeMember` | Remove existing members of mailing list. Multiple members must be separated by comma. Conflict with parameter `members`. | `removeMember=user1@domain.com,user2@domain.com`

    </div>

### Mail Alias {: .toggle }

!!! api "`GET`{: .get } `/api/alias/<mail>`{: .url } `Get profile of an existing mail alias`{: .comment }"
!!! api "`POST`{: .post } `/api/alias/<mail>`{: .url } `Create a new mail alias`{: .comment } `Parameters`{: .has_params}"

    <div class="params">

    Parameter | Summary | Sample Usage
    --- |--- |---
    `name` | Display name | `name=My List Name`
    `accessPolicy` | Defines who can send email to this mail alias account | `accessPolicy=public`
    `members` | Members of mail alias. Multiple members must be separated by comma. | `members=user1@domain.com,user2@domain.com`

    !!! attention

        `accessPolicy` for mail alias account is only available for SQL backends.

    </div>

!!! api "`DELETE`{: .delete } `/api/alias/<mail>`{: .url } `Delete an existing mail alias`{: .comment }"
!!! api "`PUT`{: .put } `/api/alias/<mail>`{: .url } `Update profile of an existing mail alias`{: .comment } `Parameters`{: .has_params }"

    <div class="params">

    !!! attention

        `accessPolicy` for mail alias account is only available for SQL backends.

    Parameter | Summary | Sample Usage
    --- |--- |---
    `name` | Display name | `name=My List Name`
    `accessPolicy` | Defines who can send email to this mail alias account | `accessPolicy=public`
    `members` | Members of mail alias. Multiple members must be separated by comma. Conflict with parameter `addMember` and `removeMember`. | `members=user1@domain.com,user2@domain.com`
    `addMember` | Add new members of mail alias. Multiple members must be separated by comma. Conflict with parameter `members`. | `addMember=user1@domain.com,user2@domain.com`
    `removeMember` | Remove existing members of mail alias. Multiple members must be separated by comma. Conflict with parameter `members`. | `removeMember=user1@domain.com,user2@domain.com`

    </div>

!!! api "`POST`{: .put } `/api/alias/<mail>/change_email/<new_mail>`{: .url } `Change email address of alias account (from '<mail>' to '<new_mail>')`{: .comment }"

### Spam Policy {: .toggle }

!!! api "`GET`{: .get } `/api/spampolicy/global`{: .url } `Get global spam policy`{: .comment }"
!!! api "`PUT`{: .put } `/api/spampolicy/global`{: .url } `Set global spam policy`{: .comment } `Parameters`{: .has_params_spampolicy }"
!!! api "`DELETE`{: .delete } `/api/spampolicy/global`{: .url } `Delete global spam policy`{: .comment }"
!!! api "`GET`{: .get } `/api/spampolicy/domain/<domain>`{: .url } `Get per-domain spam policy`{: .comment }"
!!! api "`PUT`{: .put } `/api/spampolicy/domain/<domain>`{: .url } `Set per-domain spam policy`{: .comment } `Parameters`{: .has_params_spampolicy }"
!!! api "`DELETE`{: .delete } `/api/spampolicy/domain/<domain>`{: .url } `Delete per-domain spam policy`{: .comment }"
!!! api "`GET`{: .get } `/api/spampolicy/user/<mail>`{: .url } `Get per-user spam policy`{: .comment }"
!!! api "`PUT`{: .put } `/api/spampolicy/user/<mail>`{: .url } `Set per-user spam policy`{: .comment } `Parameters`{: .has_params_spampolicy }"
!!! api "`DELETE`{: .delete } `/api/spampolicy/user/<mail>`{: .url } `Delete per-user spam policy`{: .comment }"

    <div class="params params_spampolicy">

    Parameters available for global, per-domain, per-user spam policies.

    > Per-user policy has the highest priority, then per-domain policy, then global policy.

    Parameter | Summary | Sample Usage
    --- |--- |---
    `bypass_spam_checks` | Bypass spam checks | `bypass_spam_checks=yes` (default is `no`)
    `bypass_virus_checks` | Bypass virus checks | `bypass_virus_checks=yes` (default is `no`)
    `bypass_banned_checks` | Bypass banned file type checks | `bypass_banned_checks=yes` (default is `no`)
    `bypass_header_checks` | Bypass bad header checks | `bypass_header_checks=yes` (default is `no`)
    `quarantine_spam` | Quarantine detected spam into SQL database | `quarantine_spam=yes` (default is `no`)
    `quarantine_virus` | Quarantine detected virus into SQL database | `quarantine_virus=no` (default is `yes`)
    `quarantine_banned` | Quarantine email with banned file type into SQL database | `quarantine_banned=yes` (default is `no`)
    `quarantine_bad_header` | Quarantine email with bad header into SQL database | `quarantine_bad_header=yes` (default is `no`)
    `prefix_spam_in_subject` | Prefix string `[SPAM] ` in mail subject if it's spam | `prefix_spam_in_subject=yes` (default is `no`)
    `always_insert_x_spam_headers` | Always insert `X-Spam-*` headers in email. It contains spam score and matched SpamAssassin rules. __Don't enable this unless you want to debug spam checking.__ | `always_insert_x_spam_headers=yes` (default is `no`)
    `spam_score` | Set a preferred spam score, if scanned email has higher score than this one, it will be marked as spam. | `spam_score=4` (defaults to use system setting defined in Amavisd config file.)

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

    Parameter | Summary | Sample Usage
    --- |--- |---
    `period` * | Period of time, in seconds | `period=3600` (one hour)
    `msg_size` | Max size of single email, in bytes | `msg_size=10485760` (10 MB)
    `max_msgs` | Number of max inbound emails | `max_msgs=20` (up to 20 messages)
    `max_quota` | Cumulative size of inbound or outbound emails, in bytes | `max_quota=1048576000` (1 GB)

    </div>


### Export Accounts {: .toggle }

#### LDIF (LDAP backend only) {: .toggle }

!!! api "`GET`{: .get } `/api/ldif/domain/<domain>`{: .url } `Export domain to LDIF`{: .comment }"
!!! api "`GET`{: .get } `/api/ldif/catchall/<domain>`{: .url } `Export per-domain catch-all account to LDIF`{: .comment }"
!!! api "`GET`{: .get } `/api/ldif/admin/<mail>`{: .url } `Export (separated) domain admin to LDIF`{: .comment }"
!!! api "`GET`{: .get } `/api/ldif/user/<mail>`{: .url } `Export mail user to LDIF`{: .comment }"
!!! api "`GET`{: .get } `/api/ldif/maillist/<mail>`{: .url } `Export mailing list account to LDIF`{: .comment }"
!!! api "`GET`{: .get } `/api/ldif/alias/<mail>`{: .url } `Export mail alias account to LDIF`{: .comment }"










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
	$('.has_params_spampolicy').bind('click', function(){$('.params_spampolicy').toggle();});
});
</script>
