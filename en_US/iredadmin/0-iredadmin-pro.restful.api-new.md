# iRedAdmin-Pro: RESTful API

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! attention

    * This document is applicable to `iRedAdmin-Pro-SQL-4.9` and
      `iRedAdmin-Pro-LDAP-5.0`. If you're running an old release, please
      upgrade iRedAdmin-Pro to the latest release, or check
      [document for old releases](./iredadmin-pro.releases.html).
    * If you need an API which has not yet been implemented, don't hesitate to
      [contact us](https://www.iredmail.org/contact.html).
    * [Release Notes of all iRedAdmin-Pro releases](./iredadmin-pro.releases.html).

## Summary

iRedAdmin-Pro RESTful API will return message in JSON format.

* If operation succeed:
    * For http `POST`, `DELETE`, `PUT` methods, it returns JSON data: `{'_success': true}`.
    * For http `GET` method, it returns JSON data: `{'_success': true, '_data': <program_output>}`.
* If operation failed, it returns JSON data: `{'_success': false, '_msg': '<error_reason>'}`.

## Enable RESTful API

RESTful API is disabled by default, to enable it, please add setting below in
iRedAdmin-Pro config file `settings.py`:

```
ENABLE_RESTFUL_API = True
```

Restarting `iredadmin` (if you're running Nginx) or Apache service is required
after changed iRedAdmin config file.

!!! note "iRedAdmin-Pro config file location"

    * on RHEL/CentOS, it's `/opt/www/iredadmin/settings.py` (in recent iRedMail
      releases) or `/var/www/iredadmin/settings.py` (in old iRedMail releases).
    * on Debian/Ubuntu, it's `/opt/www/iredadmin/settings.py` (in recent
      iRedMail releases) or `/usr/share/apache2/iredadmin/settings.py` (in old
      iRedMail releases).
    * on FreeBSD, it's `/usr/local/www/iredadmin/settings.py`.
    * on OpenBSD, it's `/opt/www/iredadmin/settings.py` (in recent iRedMail
      releases) or `/var/www/iredadmin/settings.py` (in old iRedMail releases).

To restrict API access to few IP addresses, please login to iRedAdmin-Pro as
global admin, then click menu `System -> Settings`, find option `RESTful API is accessible only from specified IP addresses or networks`, input the allowed IP addresses or
networks.

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

!!! api "`GET`{: .get } `/api/domains`{: .url } `Get profiles of all managed mail domains`{: .comment } `Parameters`{: .has_params }"

    <div class="params params_domain">

    Parameter | Summary | Sample Usage
    --- |--- |---
    `name_only` | Return only mail domain names | `name_only=yes`
    `disabled_only` | Return only disabled mail domains | `disabled_only=yes`

    </div>

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
!!! api "`DELETE`{: .delete } `/api/domain/<domain>/keep_mailbox_days/<number>`{: .url } `Delete domain, and keep all mail messages for given days. Defaults to 0 day which means keeping forever.`{: .comment }"
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
    `is_backupmx` | Mark domain as Backup MX. If parameter `primarymx` is not given, MTA (Postfix) will query DNS record to get primary mx server. Conflicts with parameter `transport`. | `is_backupmx=yes` (or `no`)
    `primarymx` | Hostname or IP address of primary MX, smtp port number is optional. Must be used with parameter `is_backupmx`. Conflicts with parameter `transport`. | `primarymx=202.96.134.133`, `primarymx=[mail.iredmail.org]:25`
    `catchall` | Per-domain catch-all account (a list of email addresses used to receive emails sent to non-existing addresses under same domain). Multiple addresses must be separated by comma. Set an empty value to disable catch-all support. | `catchall=user@domain.com,user2@domain.com` or `catchall=` (disable catch-all)
    `outboundRelay` | Per-domain outbound relay. Set an empty value to disable outbound relay. | `outboundRelay=smtp:[192.168.1.2]:25` or `outboundRelay=` (disable outbound relay)
    `addAliasDomain` | Add new alias domains. Multiple services must be separated by comma. | `addAliasDomain=alias1.com,alias2.com`
    `removeAliasDomain` | Remove existing alias domains. Multiple services must be separated by comma. | `removeAllServices=alias1.com,alias2.com`
    `aliasDomains` | Reset all alias domains. If empty, all existing alias domains will be removed. Conflicts with parameter `addAliasDomain` and `removeAliasDomain`. | `aliasDomains=alias1.com,alias2.com`
    `addService` | Enable new services. Multiple services must be separated by comma. Available services are listed below. | `addService=self-service`
    `removeService` | Disable existing services. Multiple services must be separated by comma. Available services are listed below. | `removeService=self-service`
    `services` | Reset all services. If empty, all existing services will be removed. | `services=mail,self-service`
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
    mail | All mail services. (__LDAP backends only__)
    domainalias | Alias domain support. (__LDAP backends only__)
    senderbcc | Per-domain sender bcc. (__LDAP backends only__)
    recipientbcc | Per-domain recipient bcc. (__LDAP backends only__)

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
    password_policies | Password policies. including min/max password lengths.
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

!!! api "`GET`{: .get } `/api/admin/<mail>`{: .url } `Get profile of an existing domain admin`{: .comment } `Parameters`{: .has_params }"

    <div class="params params_user">
    Encrypted account password is not exposed in API request by default, if you
    want to expose it for some reason, please add a new line in iRedAdmin-Pro config
    file `/opt/www/iredadmin/settings.py` like below, then restart `iredadmin`
    service:

    ```
    API_HIDDEN_ADMIN_PROFILES = []
    ```

    </div>

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
    `disableViewingMailLog` | Disallow this admin to view log of inbound/outbound mails. | `disableViewingMailLog=yes` (or `no`)
    `disableManagingQuarantinedMails` | Disallow this admin to manage quarantined mails. | `disableManagingQuarantinedMails=yes` (or `no`)

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
    `disableViewingMailLog` | Disallow this admin to view log of inbound/outbound mails. | `disableViewingMailLog=yes` (or `no`)
    `disableManagingQuarantinedMails` | Disallow this admin to manage quarantined mails. | `disableManagingQuarantinedMails=yes` (or `no`)

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

!!! api "`GET`{: .get } `/api/user/<mail>`{: .url } `Get profile of an existing mail user`{: .comment } `Parameters`{: .has_params }"

    <div class="params params_user">
    Encrypted account password is not exposed in API request by default, if you
    want to expose it for some reason, please add a new line in iRedAdmin-Pro config
    file `/opt/www/iredadmin/settings.py` like below, then restart `iredadmin`
    service:

    ```
    API_HIDDEN_USER_PROFILES = []
    ```

    </div>

!!! api "`POST`{: .post } `/api/user/<mail>`{: .url } `Create a new mail user`{: .comment } `Parameters`{: .has_params }"

    <div class="params params_user">

    Parameter | Summary | Sample Usage
    --- |--- |---
    `name` | Display name | `name=My New Name`
    `password` | Plain password. __WARNING__: Conflict with parameter `password_hash`. | `password=AsTr0ng@`
    `password_hash` | Set user password to the given hashed/encrypted password. __NOTE__: Since the password is encrypted, iRedAdmin-Pro can not verify it against password policies. __WARNING__: Conflict with parameter `password`. | `password_hash={SSHA}APvI8DhU8Ktstdlye6yVDaypcrfqsUcXk0c7aQ==`
    `language` | Preferred language of iRedAdmin web UI | `language=en_US`
    `quota` | Mailbox quota (in MB) | `quota=1024`
    `mailboxFormat` | Mailbox format. e.g. `maildir`, `mdbox`. Defaults to `maildir` if not present. For more details, please read Dovecot document: <https://wiki2.dovecot.org/MailboxFormat>. __WARNING__: Changing mailbox format does not migrate the mailbox on file system automatically, you have to migrate it manually. New email will be stored in new mailbox format immediately. | `mailboxFormat=mdbox`
    `mailboxFolder` | Mailbox folder name (case sensitive) which will be appended to user's home path. Defaults to `Maildir`. It's useful if you need to migrate to different mailbox folder. __WARNING__: New email will be stored in new mailbox folder immediately. | `mailboxFolder=Maildir`
    `maildir` | Absolute path of the mailbox. All characters will be converted to lower cases. | `maildir=/var/vmail/vmail1/example.com/username`

    </div>

!!! api "`DELETE`{: .delete } `/api/user/<mail>`{: .url } `Delete an existing mail user`{: .comment }"
!!! api "`DELETE`{: .delete } `/api/user/<mail>/keep_mailbox_days/<number>`{: .url } `Delete an existing mail user, and keep the mailbox for given days. Defaults to 0 day which means keeping forever.`{: .comment }"
!!! api "`PUT`{: .put } `/api/user/<mail>`{: .url } `Update profile of an existing mail user`{: .comment } `Parameters`{: .has_params} "

    <div class="params params_user">

    Parameter | Summary | Sample Usage
    --- |--- |---
    `name` | Display name | `name=Michael Jordon`
    `gn` | Given name | `gn=Jordon`
    `sn` | Surname | `sn=Jeffery`
    `password` | Set user password to the given one. | `password=u0tBF82cIV@vi8Gme`
    `password_hash` | Set user password to the given hashed/encrypted password. __NOTE__: Since the password is encrypted, iRedAdmin-Pro can not verify it against password plicies. __WARNING__: Conflict with parameter `password`. | `password={SSHA}qjmhvlsofWDu/AvVhOJX1cU/CvYKLYlwlM5bHw==`
    `quota` | Mailbox quota (in MB). `0` means unlimited. | `quota=1024`
    `accountStatus` | Enable or disable user. Possible values: `active`, `disabled`. | `accountStatus=active`
    `language` | Preferred language of iRedAdmin web UI | `language=en_US`
    `employeeid` | User ID (or Employee Number) | `employeeid=My Employee ID`
    `transport` | Transport program | `transport=dovecot`
    `isGlobalAdmin` | Promote user to be a global admin. Possible values: `yes`, `no` | `isGlobalAdmin=yes`
    `forwarding` | Reset per-user mail forwarding to given (valid) addresses. Multiple addresses must be separated by comma. To save an email copy in mailbox, add original email address as one of forwarding addresses. | `forwarding=user1@domain.com,user2@domain.com,user3@domain.com`
    `addForwarding` | Add per-user mail forwarding addresses. Multiple addresses must be separated by comma. __WARNING__: Conflict with parameter `forwarding`. | `addForwarding=user1@domain.com,user2@domain.com,user3@domain.com`
    `removeForwarding` | Remove existing per-user mail forwarding addresses. Multiple addresses must be separated by comma. __WARNING__: Conflict with parameter `forwarding`. | `removeForwarding=user1@domain.com,user2@domain.com,user3@domain.com`
    `senderBcc` | Per-user BCC for outbound emails. Only one email address is allowed. Parameter with empty value will remove existing sender bcc address. | `senderBcc=user1@domain.com` or <br/>`senderBcc=` (remove existing bcc address)
    `recipientBcc` | Per-user BCC for inbound emails. Only one email address is allowed. Parameter with empty value will remove existing recipient bcc address. | `recipientBcc=user1@domain.com` or <br/>`recipientBcc=` (remove existing bcc address)
    `aliases` | Per-user alias addresses. Multiple addresses must be separated by comma. If empty, all per-user alias addresses owned by this user will be removed. Conflicts with parameter `addAlias` and `removeAlias`. | `aliases=user1@domain.com,user2@domain.com,user3@domain.com`
    `addAlias` | Add new per-user alias addresses. Multiple addresses must be separated by comma. Conflicts with parameter `aliases`. | `addAlias=user1@domain.com,user2@domain.com,user3@domain.com`
    `removeAlias` | Remove existing per-user alias addresses. Multiple addresses must be separated by comma. Conflicts with parameter `aliases`. | `removeAlias=user1@domain.com,user2@domain.com,user3@domain.com`
    `services` | Reset per-user enabled mail services to given values. Conflicts with parameter `addService` and `removeService`. See additional notes below. | `services=mail,smtp,pop3,imap`
    `addService` | Add new per-user enabled mail service(s). Multiple values must be separated by comma. Conflicts with parameter `services`. See additional notes below. | `addService=vpn,owncloud`
    `removeService` | Add new per-user enabled mail service(s). Multiple values must be separated by comma. Conflicts with parameter `services`. See additional notes below. | `removeService=forward,senderbcc`
    `mailboxFormat` | Mailbox format. e.g. `maildir`, `mdbox`. Defaults to `maildir` if not present. For more details, please read Dovecot document: <https://wiki2.dovecot.org/MailboxFormat>. __WARNING__: Changing mailbox format does not migrate the mailbox on file system automatically, you have to migrate it manually. New email will be stored in new mailbox format immediately. | `mailboxFormat=mdbox`
    `mailboxFolder` | Mailbox folder name (case sensitive) which will be appended to user's home path. Defaults to `Maildir`. It's useful if you need to migrate to different mailbox folder. __WARNING__: New email will be stored in new mailbox folder immediately. | `mailboxFolder=Maildir`
    `maildir` | Absolute path of the mailbox. All characters will be converted to lower cases. | `maildir=/var/vmail/vmail1/example.com/username`
    `telephoneNumber` | Telephone number __(LDAP backend only)__ | `telephoneNumber=12345678,88888888`
    `mobile` | Mobile phone number __(LDAP backend only)__ | `mobile=12345678,88888888`

    !!! attention

        Notes about `services`, `addService`, `removeService` parameters:

        * Available service names in iRedMail:
            * smtp
            * smtpsecured (SMTP over TLS or SSL)
            * smtptls (SMTP over TLS)
            * pop3
            * pop3secured (POP3 over TLS or SSL)
            * pop3tls (POP3 over TLS)
            * imap
            * imapsecured (IMAP over TLS or SSL)
            * imaptls (IMAP over TLS)
            * managesieve
            * managesievesecured (Managesieve over TLS or SSL)
            * managesievetls (Managesieve over TLS)
            * deliver (deliver received email to local mailbox)
            * sogo (SOGo groupware)

        * For LDAP backends, you're free to add custom service names, because
          the LDAP attribute name used to store service names supports storing
          multiple values and we don't need to change LDAP schema.

        * For SQL backends, column `enable<service>` in SQL table
          `vmail.mailbox` must be present, if not, specified service name will
          be silently ignored.

    </div>

!!! api "`POST`{: .post } `/api/user/<mail>/change_email/<new_mail>`{: .url } `Change user's email address (from '<mail>' to '<new_mail>')`{: .comment }"
!!! api "`GET`{: .get } `/api/users/<domain>`{: .url } `Get user profiles under given domain`{: .comment } `Parameters`{: .has_params }"

    <div class="params">

    Parameter | Default Value | Comment | Sample Usage
    --- |--- |--- |---
    `email_only` | `no` | Return a list of mail users' email addresses instead of detailed profiles. | `email_only=yes`
    `disabled_only` | `no` | Return only disabled mail users. | `disabled_only=yes`

    </div>

!!! api "`PUT`{: .put } `/api/users/<domain>`{: .url } `Update profiles of all users under given domain`{: .comment } `Parameters`{: .has_params }"

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

### Subscribable Mailing List {: .toggle }

!!! attention

    * Subscribable mailing list requires iRedMail-0.9.8 and later releases,
      it's implemented with [`mlmmj`](http://mlmmj.org) mailing list manager.
    * It's available for both SQL and LDAP backends.

!!! api "`GET`{: .get } `/api/mls/<domain>`{: .url } `Get profile of all mailing lists under given domain`{: .comment } `Parameters`{: .has_params}"

    <div class="params">

    Parameter | Sample Usage | Default Value | Comment
    --- |--- |---|---
    `email_only` | `email_only=yes` | `no` | Return a list of mailing list email addresses instead of detailed profile.

    </div>

!!! api "`GET`{: .get } `/api/ml/<mail>`{: .url } `Get profile of an existing mailing list account`{: .comment } `Parameters`{: .has_params}"

    <div class="params">

    Parameter | Sample Usage | Default Value | Comment
    --- |--- |---|---
    `with_subscribers` | `with_subscribers=yes` | `no` | Get subscribers of mailing list.

    </div>

!!! api "`POST`{: .post } `/api/ml/<mail>`{: .url } `Create a new mailing list`{: .comment } `Parameters`{: .has_params }"

    <div class="params">

    Parameter | Sample Usage | Default Value | Comment
    --- |--- |---|---
    `name` | `name=Sales Team` | | Display name of the mailing list.
    `accountStatus` | `accountStatus=active` | | Enable or disable account. Possible values: `active`, `disabled`.
    `accessPolicy` | `accessPolicy=membersonly` | | Defines who can send email to this mailing list. Possible values: `public`, `domain`, `subdomain`, `membersonly`, `moderatorsonly`.
    `is_newsletter` | `is_newsletter=yes` | `no` | Mark this mailing list as a newsletter, to enable subscription/unsubscription from web site.
    `newsletter_description` | `newsletter_description=short description text` | | The short description text displayed on newsletter subscription page.
    `close_list` | `close_list=yes` | `no` | If set to `yes`, subscription and unsubscription via mail is disabled.
    `only_moderator_can_post` | `only_moderator_can_post=yes` | `no` | If set to `yes`, only moderators are allowed to post to it. The check is made against the `From:` header.
    `only_subscriber_can_post` | `only_subscriber_can_post=yes` | `yes` | If set to `yes`, only subscribed members are allowed to post to it. The check is made against the `From:` header.
    `disable_subscription` | `disable_subscription=yes` | `no` | If set to `yes`, subscription is disabled, but unsubscription is still possible.
    `disable_subscription_confirm` | `disable_subscription_confirm=yes` | | If set to `yes`, mlmmj won't send mail to subscriber to ask for confirmation to subscribe to the list. __WARNING__: This should in principle never ever be used, but there are times on local lists etc. where this is useful. HANDLE WITH CARE!
    `disable_digest_subscription` | `disable_digest_subscription=yes` | | If set to `yes`, subscription to the digest version of the mailing list is disabled. Useful if you don't want to allow digests and notify users about it.
    `disable_digest_text` | `disable_digest_text=yes` | | If set to `yes`, digest mails won't have a text part with a thread summary.
    `disable_nomail_subscription` | `disable_nomail_subscription=yes` | | If set to `yes`, subscription to the 'nomail' version of the mailing list is disabled. Useful if you don't want to allow 'nomail' and notify users about it.
    `moderated` | `moderated=yes` | `no` | If set to `yes`. Parameter `owner` __or__ `moderators` is required to specify the moderators. Note: `moderators` has higher priority (means only addresses specified by `moderators` are act as moderators).
    `moderate_non_subscriber_post` | `moderate_non_subscriber_post=no` | `no` | If set to `yes`, all postings from people who are not allowed to post to the list will be moderated. Default (set to `no`) is denied.
    `disable_retrieving_old_posts` | `disable_retrieving_old_posts=yes` | | If set to `yes`, retrieving old posts by sending email to address `<listname>+get-N@` is disabled.
    `only_subscriber_can_get_old_posts` | `only_subscriber_can_get_old_posts=no` | `yes` | If set to `yes`, only subscribers can retrieve old posts by sending email to `LISTNAME+get-N@`
    `disable_retrieving_subscribers` | `disable_retrieving_subscribers=yes` | `yes` | If set to `yes`, (owner) retrieving subscribers by sending email to `LISTNAME+list@` is disabled. Note: only owner can send to such address.
    `disable_send_copy_to_sender` | `disable_send_copy_to_sender=yes` | `yes` | If set to `yes`, senders won't receive copies of their own posts.
    `notify_owner_when_sub_unsub` | `notify_owner_when_sub_unsub=no` | `no` | Notify the owner(s) when someone sub/unsubscribing to a mailing list.
    `notify_sender_when_moderated` | `notify_sender_when_moderated=no` | `no` | Notify sender (based on the envelope from) when their post is being moderated.
    `disable_archive` | `disable_archive=yes` | `no` | If set to `yes`, emails won't be saved in the archive but simply deleted.
    `moderate_subscription` | `moderate_subscription=yes` | `no` | If set to `yes`, subscription will be moderated by owner(s) or moderators specified by `subscription_moderators`. Moderators specified by `subscription_moderators` has higher priority. If set to `no`, subscription is not moderated, also, all moderators which were specified by `subscription_moderators` will be removed.
    `extra_addresses` | `extra_addresses=extra1@domain.com,extra2@domain.com` | | Define extra addresses of the mailing list.
    `subscription_moderators` | `subscription_moderators=<mail1>,<mail2>,<mail3>` | | Specify subscription moderators. Note: if `subscription_moderators` is given, `moderate_subscription` will be set to `yes` automatically. If no valid moderators are given, subscription will be moderated by owner(s).
    `owner` | `owner=<mail1>,<mail2>,<mail3>` | | Define owner(s) of the mailing list. Owners will get mails sent to `<listname>+owner@<domain.com>`.
    `moderators` | `moderators=<mail1>,<mail2>` | | Specify moderators of the mailing list. Set to empty value will remove all existing moderators.
    `max_message_size` | `max_message_size=10240` | | Specify max mail message size in __bytes__.
    `subject_prefix` | `subject_prefix=[prefix text]` | | Add a prefix in the `Subject:` line of mails sent to the list. Set to empty value to remove it.
    `custom_headers` | `custom_headers=<header1>:<value1>\n<header2>:<value2>` | | Add custom headers to every mail coming through. Multiple headers must be separated by `\n`. Set empty value to remove it. Note: mlmmjadmin will always add `X-Mailing-List: <mail>` and `Reply-To: <mail>` for each mailing list account.
    `remove_headers` | `remove_headers=Message-ID,Received` | | Remove given mail headers. NOTE: either `header:` or `header` (without `:`) is ok. Note: mlmmjadmin will always remove `DKIM-Signature:` and `Authentication-Results:`.
    `name` | `name=Short description of list` | | Set a short description of the mailing list account.
    `footer_text` | `footer_text=footer in plain text` | | Append footer (in plain text format) to every email sent to the list.
    `footer_html` | `footer_text=<p>footer in html</p>` | | Append footer (in html format) to every email sent to the list.

    Parameters used to add subscribers:

    Parameter | Sample Usage | Default Value | Comment
    --- |--- |---|---
    `subscribers` | `subscribers=<mail1>,<mail2>,<mail3>,...` | | Subscribe users to mailing list. Multiple subscribers must be separated by comma.
    `require_confirm` | `require_confirm=no` | `yes` | Send email to subscribers and let subscribers confirm the subscription.
    `subscription` | `subscription=normal` | `normal` | Subscribe to different subscription. Valid values are: `normal`, `digest`, `nomail`.

    </div>

!!! api "`DELETE`{: .delete } `/api/ml/<mail>`{: .url } `Delete an existing mailing list`{: .comment } `Parameters`{: .has_params }"

    <div class="params">

    Parameter | Summary | Sample Usage
    --- |--- |---
    `keep_archive` | Archive account settings and messages before deleting the mailing list. | `keep_archive=no`

    </div>

!!! api "`PUT`{: .put } `/api/ml/<mail>`{: .url } `Update profile of an existing mailing list`{: .comment } `Parameters`{: .has_params }"

    <div class="params">

    Parameter | Sample Usage | Default Value | Comment
    --- |--- |---|---
    `name` | `name=Sales Team` | | Display name of the mailing list.
    `accountStatus` | `accountStatus=active` | | Enable or disable account. Possible values: `active`, `disabled`.
    `accessPolicy` | `accessPolicy=membersonly` | | Defines who can send email to this mailing list. Possible values: `public`, `domain`, `subdomain`, `membersonly`, `moderatorsonly`.
    `is_newsletter` | `is_newsletter=yes` | `no` | Mark this mailing list as a newsletter, to enable subscription/unsubscription from web site.
    `newsletter_description` | `newsletter_description=short description text` | | The short description text displayed on newsletter subscription page.
    `close_list` | `close_list=yes` | `no` | If set to `yes`, subscription and unsubscription via mail is disabled.
    `only_moderator_can_post` | `only_moderator_can_post=yes` | `no` | If set to `yes`, only moderators are allowed to post to it. The check is made against the `From:` header.
    `only_subscriber_can_post` | `only_subscriber_can_post=yes` | `yes` | If set to `yes`, only subscribed members are allowed to post to it. The check is made against the `From:` header.
    `disable_subscription` | `disable_subscription=yes` | `no` | If set to `yes`, subscription is disabled, but unsubscription is still possible.
    `disable_subscription_confirm` | `disable_subscription_confirm=yes` | | If set to `yes`, mlmmj won't send mail to subscriber to ask for confirmation to subscribe to the list. __WARNING__: This should in principle never ever be used, but there are times on local lists etc. where this is useful. HANDLE WITH CARE!
    `disable_digest_subscription` | `disable_digest_subscription=yes` | | If set to `yes`, subscription to the digest version of the mailing list is disabled. Useful if you don't want to allow digests and notify users about it.
    `disable_digest_text` | `disable_digest_text=yes` | | If set to `yes`, digest mails won't have a text part with a thread summary.
    `disable_nomail_subscription` | `disable_nomail_subscription=yes` | | If set to `yes`, subscription to the 'nomail' version of the mailing list is disabled. Useful if you don't want to allow 'nomail' and notify users about it.
    `moderated` | `moderated=yes` | `no` | If set to `yes`. Parameter `owner` __or__ `moderators` is required to specify the moderators. Note: `moderators` has higher priority (means only addresses specified by `moderators` are act as moderators).
    `moderate_non_subscriber_post` | `moderate_non_subscriber_post=no` | `no` | If set to `yes`, all postings from people who are not allowed to post to the list will be moderated. Default (set to `no`) is denied.
    `disable_retrieving_old_posts` | `disable_retrieving_old_posts=yes` | | If set to `yes`, retrieving old posts by sending email to address `<listname>+get-N@` is disabled.
    `only_subscriber_can_get_old_posts` | `only_subscriber_can_get_old_posts=no` | `yes` | If set to `yes`, only subscribers can retrieve old posts by sending email to `LISTNAME+get-N@`
    `disable_retrieving_subscribers` | `disable_retrieving_subscribers=yes` | `yes` | If set to `yes`, (owner) retrieving subscribers by sending email to `LISTNAME+list@` is disabled. Note: only owner can send to such address.
    `disable_send_copy_to_sender` | `disable_send_copy_to_sender=yes` | `yes` | If set to `yes`, senders won't receive copies of their own posts.
    `notify_owner_when_sub_unsub` | `notify_owner_when_sub_unsub=no` | `no` | Notify the owner(s) when someone sub/unsubscribing to a mailing list.
    `notify_sender_when_moderated` | `notify_sender_when_moderated=no` | `no` | Notify sender (based on the envelope from) when their post is being moderated.
    `disable_archive` | `disable_archive=yes` | `no` | If set to `yes`, emails won't be saved in the archive but simply deleted.
    `moderate_subscription` | `moderate_subscription=yes` | `no` | If set to `yes`, subscription will be moderated by owner(s) or moderators specified by `subscription_moderators`. Moderators specified by `subscription_moderators` has higher priority. If set to `no`, subscription is not moderated, also, all moderators which were specified by `subscription_moderators` will be removed.
    `extra_addresses` | `extra_addresses=extra1@domain.com,extra2@domain.com` | | Define extra addresses of the mailing list.
    `subscription_moderators` | `subscription_moderators=<mail1>,<mail2>,<mail3>` | | Specify subscription moderators. Note: if `subscription_moderators` is given, `moderate_subscription` will be set to `yes` automatically. If no valid moderators are given, subscription will be moderated by owner(s).
    `owner` | `owner=<mail1>,<mail2>,<mail3>` | | Define owner(s) of the mailing list. Owners will get mails sent to `<listname>+owner@<domain.com>`.
    `moderators` | `moderators=<mail1>,<mail2>` | | Specify moderators of the mailing list. Set to empty value will remove all existing moderators.
    `max_message_size` | `max_message_size=10240` | | Specify max mail message size in __bytes__.
    `subject_prefix` | `subject_prefix=[prefix text]` | | Add a prefix in the `Subject:` line of mails sent to the list. Set to empty value to remove it.
    `custom_headers` | `custom_headers=<header1>:<value1>\n<header2>:<value2>` | | Add custom headers to every mail coming through. Multiple headers must be separated by `\n`. Set empty value to remove it. Note: mlmmjadmin will always add `X-Mailing-List: <mail>` and `Reply-To: <mail>` for each mailing list account.
    `remove_headers` | `remove_headers=Message-ID,Received` | | Remove given mail headers. NOTE: either `header:` or `header` (without `:`) is ok. Note: mlmmjadmin will always remove `DKIM-Signature:` and `Authentication-Results:`.
    `name` | `name=Short description of list` | | Set a short description of the mailing list account.
    `footer_text` | `footer_text=footer in plain text` | | Append footer (in plain text format) to every email sent to the list.
    `footer_html` | `footer_text=<p>footer in html</p>` | | Append footer (in html format) to every email sent to the list.

    Parameters used to add subscribers:

    Parameter | Sample Usage | Default Value | Comment
    --- |--- |---|---
    `add_subscribers` | `add_subscribers=<mail1>,<mail2>,<mail3>,...` | | Subscribe users to mailing list. Multiple subscribers must be separated by comma.
    `require_confirm` | `require_confirm=no` | `yes` | Send email to subscribers and let subscribers confirm the subscription.
    `subscription` | `subscription=normal` | `normal` | Subscribe to different subscription. Valid values are: `normal`, `digest`, `nomail`.

    Parameters used to remove subscribers:

    Parameter | Sample Usage | Default Value | Comment
    --- |--- |---|---
    `remove_subscribers` | `remove_subscribers=<mail1>,<mail2>,<mail3>,...` | | Remove existing subscribers from mailing list. Multiple subscribers must be separated by comma.

    </div>

### Mailing List (Unsubscribable) {: .toggle }

!!! attention

    * This unsubscribable mailing list is only available in __LDAP__ backend.
    * It's recommended to use the Subscribable Mailing List instead, you're
      free to disable public subscribable.

!!! api "`GET`{: .get } `/api/maillist/<mail>`{: .url } `Get profile of an existing mailing list account`{: .comment }"
!!! api "`POST`{: .post } `/api/maillist/<mail>`{: .url } `Create a new mailing list`{: .comment } `Parameters`{: .has_params }"
    <div class="params">

    Parameter | Summary | Sample Usage
    --- |--- |---
    `name` | Display name | `name=My List Name`
    `accessPolicy` | Defines who can send email to this mail alias account | `accessPolicy=public`
    `members` | Members of mailing list. Multiple members must be separated by comma. | `members=user1@domain.com,user2@domain.com`

    </div>

!!! api "`DELETE`{: .delete } `/api/maillist/<mail>`{: .url } `Delete an existing mailing list`{: .comment } `Parameters`{: .has_params }"

    <div class="params">

    Parameter | Summary | Sample Usage
    --- |--- |---
    `archive` | Archive subscribable mailing list before deleting the account. NOTE: This option is only applicable to the subscribable mailing list account. | `archive=no`

    </div>

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
    `accountStatus` | Enable or disable domain. Valid values: `active`, `disabled`. | `accountStatus=active`
    `accessPolicy` | Defines who can send email to this mail alias account | `accessPolicy=public`
    `members` | Members of mail alias. Multiple members must be separated by comma. Conflict with parameter `addMember` and `removeMember`. | `members=user1@domain.com,user2@domain.com`
    `addMember` | Add new members of mail alias. Multiple members must be separated by comma. Conflict with parameter `members`. | `addMember=user1@domain.com,user2@domain.com`
    `removeMember` | Remove existing members of mail alias. Multiple members must be separated by comma. Conflict with parameter `members`. | `removeMember=user1@domain.com,user2@domain.com`

    </div>

!!! api "`POST`{: .put } `/api/alias/<mail>/change_email/<new_mail>`{: .url } `Change email address of alias account (from '<mail>' to '<new_mail>')`{: .comment }"

!!! api "`GET`{: .get } `/api/aliases/<domain>`{: .url } `Get mail aliases' profiles under given domain`{: .comment } `Parameters`{: .has_params }"

    <div class="params">

    Parameter | Default Value | Comment | Sample Usage
    --- |--- |--- |---
    `email_only` | `no` | Return a list of mail aliases' email addresses instead of detailed profiles. | `email_only=yes`
    `disabled_only` | `no` | Return only disabled mail aliases. | `disabled_only=yes`

    </div>

### Spam Policy {: .toggle }

!!! api "`GET`{: .get } `/api/spampolicy/global`{: .url } `Get global spam policy`{: .comment }"
!!! api "`GET`{: .get } `/api/spampolicy/domain/<domain>`{: .url } `Get per-domain spam policy`{: .comment }"
!!! api "`GET`{: .get } `/api/spampolicy/user/<mail>`{: .url } `Get per-user spam policy`{: .comment }"
!!! api "`DELETE`{: .delete } `/api/spampolicy/global`{: .url } `Delete global spam policy`{: .comment }"
!!! api "`DELETE`{: .delete } `/api/spampolicy/domain/<domain>`{: .url } `Delete per-domain spam policy`{: .comment }"
!!! api "`DELETE`{: .delete } `/api/spampolicy/user/<mail>`{: .url } `Delete per-user spam policy`{: .comment }"
!!! api "`PUT`{: .put } `/api/spampolicy/global`{: .url } `Set global spam policy`{: .comment } `Parameters`{: .has_params_spampolicy }"
!!! api "`PUT`{: .put } `/api/spampolicy/domain/<domain>`{: .url } `Set per-domain spam policy`{: .comment } `Parameters`{: .has_params_spampolicy }"
!!! api "`PUT`{: .put } `/api/spampolicy/user/<mail>`{: .url } `Set per-user spam policy`{: .comment } `Parameters`{: .has_params_spampolicy }"

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
    `banned_rulenames` | Assign ban rules | `banned_rulenames=ALLOW_MS_WORD,ALLOW_MS_EXCEL`

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

### Whitelisting and Blacklisting {: .toggle }

Valid whitelisting and blacklisting addresses. __Invalid addresses will be discarded silently.__

Address | Examples
--- |---
Single IP Address | `192.168.2.10`
IP CIDR Network | `192.168.2.0/24`, `2620:0:2d0:200::7/128`
Single email address | `user@domain.ltd`
Entire email domain | `@domain.ltd`
Entire email domain and all its sub-domains | `@.domain.ltd`
Catch-all address | `@.`

<br/>

!!! api "`GET`{: .get } `/api/wblist/inbound/whitelist/global`{: .url } `Get global whitelists for inbound.`{: .comment }"
!!! api "`GET`{: .get } `/api/wblist/inbound/blacklist/global`{: .url } `Get global blacklists for inbound.`{: .comment }"
!!! api "`GET`{: .get } `/api/wblist/outbound/whitelist/global`{: .url } `Get global whitelists for outbound.`{: .comment }"
!!! api "`GET`{: .get } `/api/wblist/outbound/blacklist/global`{: .url } `Get global whitelists for outbound.`{: .comment }"
!!! api "`GET`{: .get } `/api/wblist/inbound/whitelist/<domain>`{: .url } `Get per-domain whitelists for inbound.`{: .comment }"
!!! api "`GET`{: .get } `/api/wblist/inbound/blacklist/<domain>`{: .url } `Get per-domain blacklists for inbound.`{: .comment }"
!!! api "`GET`{: .get } `/api/wblist/outbound/whitelist/<domain>`{: .url } `Get per-domain whitelists for outbound.`{: .comment }"
!!! api "`GET`{: .get } `/api/wblist/outbound/blacklist/<domain>`{: .url } `Get per-domain whitelists for outbound.`{: .comment }"
!!! api "`GET`{: .get } `/api/wblist/inbound/whitelist/<mail>`{: .url } `Get per-user whitelists for inbound.`{: .comment }"
!!! api "`GET`{: .get } `/api/wblist/inbound/blacklist/<mail>`{: .url } `Get per-user blacklists for inbound.`{: .comment }"
!!! api "`GET`{: .get } `/api/wblist/outbound/whitelist/<mail>`{: .url } `Get per-user whitelists for outbound.`{: .comment }"
!!! api "`GET`{: .get } `/api/wblist/outbound/blacklist/<mail>`{: .url } `Get per-user whitelists for outbound.`{: .comment }"

!!! api "`POST`{: .post } `/api/wblist/inbound/whitelist/global`{: .url } `Add new global whitelists for inbound.`{: .comment } `Parameters`{: .has_params_wblist_put }"
!!! api "`POST`{: .post } `/api/wblist/inbound/blacklist/global`{: .url } `Add new global blacklists for inbound.`{: .comment } `Parameters`{: .has_params_wblist_put }"
!!! api "`POST`{: .post } `/api/wblist/outbound/whitelist/global`{: .url } `Add new global whitelists for outbound.`{: .comment } `Parameters`{: .has_params_wblist_put }"
!!! api "`POST`{: .post } `/api/wblist/outbound/blacklist/global`{: .url } `Add new global whitelists for outbound.`{: .comment } `Parameters`{: .has_params_wblist_put }"
!!! api "`POST`{: .post } `/api/wblist/inbound/whitelist/<domain>`{: .url } `Add new per-domain whitelists for inbound.`{: .comment } `Parameters`{: .has_params_wblist_put }"
!!! api "`POST`{: .post } `/api/wblist/inbound/blacklist/<domain>`{: .url } `Add new per-domain blacklists for inbound.`{: .comment } `Parameters`{: .has_params_wblist_put }"
!!! api "`POST`{: .post } `/api/wblist/outbound/whitelist/<domain>`{: .url } `Add new per-domain whitelists for outbound.`{: .comment } `Parameters`{: .has_params_wblist_put }"
!!! api "`POST`{: .post } `/api/wblist/outbound/blacklist/<domain>`{: .url } `Add new per-domain whitelists for outbound.`{: .comment } `Parameters`{: .has_params_wblist_put }"
!!! api "`POST`{: .post } `/api/wblist/inbound/whitelist/<mail>`{: .url } `Add new per-user whitelists for inbound.`{: .comment } `Parameters`{: .has_params_wblist_put }"
!!! api "`POST`{: .post } `/api/wblist/inbound/blacklist/<mail>`{: .url } `Add new per-user blacklists for inbound.`{: .comment } `Parameters`{: .has_params_wblist_put }"
!!! api "`POST`{: .post } `/api/wblist/outbound/whitelist/<mail>`{: .url } `Add new per-user whitelists for outbound.`{: .comment } `Parameters`{: .has_params_wblist_put }"
!!! api "`POST`{: .post } `/api/wblist/outbound/blacklist/<mail>`{: .url } `Add new per-user whitelists for outbound.`{: .comment } `Parameters`{: .has_params_wblist_put }"

    <div class="params params_wblist_put">

    Parameters available for global, per-domain and per-user whitelist/blacklist settings.

    Parameter | Summary | Sample Usage
    --- |--- |---
    `addresses` | The addresses you want to whitelist or blacklist.<br/>Multiple addresses must be separated by comma. | `addresses=user1@domain.com,192.168.1.10`

    </div>

!!! api "`PUT`{: .put } `/api/wblist/inbound/whitelist/global`{: .url } `Delete given global whitelists for inbound.`{: .comment } `Parameters`{: .has_params_wblist }"
!!! api "`PUT`{: .put } `/api/wblist/inbound/blacklist/global`{: .url } `Delete given existing global blacklists for inbound.`{: .comment } `Parameters`{: .has_params_wblist }"
!!! api "`PUT`{: .put } `/api/wblist/outbound/whitelist/global`{: .url } `Delete given existing global whitelists for outbound.`{: .comment } `Parameters`{: .has_params_wblist }"
!!! api "`PUT`{: .put } `/api/wblist/outbound/blacklist/global`{: .url } `Delete given existing global whitelists for outbound.`{: .comment } `Parameters`{: .has_params_wblist }"
!!! api "`PUT`{: .put } `/api/wblist/inbound/whitelist/<domain>`{: .url } `Delete given per-domain whitelists for inbound.`{: .comment } `Parameters`{: .has_params_wblist }"
!!! api "`PUT`{: .put } `/api/wblist/inbound/blacklist/<domain>`{: .url } `Delete given per-domain blacklists for inbound.`{: .comment } `Parameters`{: .has_params_wblist }"
!!! api "`PUT`{: .put } `/api/wblist/outbound/whitelist/<domain>`{: .url } `Delete given per-domain whitelists for outbound.`{: .comment } `Parameters`{: .has_params_wblist }"
!!! api "`PUT`{: .put } `/api/wblist/outbound/blacklist/<domain>`{: .url } `Delete given per-domain whitelists for outbound.`{: .comment } `Parameters`{: .has_params_wblist }"
!!! api "`PUT`{: .put } `/api/wblist/inbound/whitelist/<mail>`{: .url } `Delete given per-user whitelists for inbound.`{: .comment } `Parameters`{: .has_params_wblist }"
!!! api "`PUT`{: .put } `/api/wblist/inbound/blacklist/<mail>`{: .url } `Delete given per-user blacklists for inbound.`{: .comment } `Parameters`{: .has_params_wblist }"
!!! api "`PUT`{: .put } `/api/wblist/outbound/whitelist/<mail>`{: .url } `Delete given per-user whitelists for outbound.`{: .comment } `Parameters`{: .has_params_wblist }"
!!! api "`PUT`{: .put } `/api/wblist/outbound/blacklist/<mail>`{: .url } `Delete given per-user whitelists for outbound.`{: .comment } `Parameters`{: .has_params_wblist }"

    <div class="params params_wblist_put">

    Parameters available for global, per-domain and per-user whitelist/blacklist settings.

    Parameter | Summary | Sample Usage
    --- |--- |---
    `addresses` | The addresses you want to whitelist or blacklist.<br/>Multiple addresses must be separated by comma. | `addresses=user1@domain.com,192.168.1.10`

    </div>

!!! api "`DELETE`{: .delete } `/api/wblist/inbound/whitelist/global`{: .url } `Delete all existing global whitelists for inbound.`{: .comment }"
!!! api "`DELETE`{: .delete } `/api/wblist/inbound/blacklist/global`{: .url } `Delete all existing global blacklists for inbound.`{: .comment }"
!!! api "`DELETE`{: .delete } `/api/wblist/outbound/whitelist/global`{: .url } `Delete all existing global whitelists for outbound.`{: .comment }"
!!! api "`DELETE`{: .delete } `/api/wblist/outbound/blacklist/global`{: .url } `Delete all existing global whitelists for outbound.`{: .comment }"
!!! api "`DELETE`{: .delete } `/api/wblist/inbound/whitelist/<domain>`{: .url } `Delete all per-domain global whitelists for inbound.`{: .comment }"
!!! api "`DELETE`{: .delete } `/api/wblist/inbound/blacklist/<domain>`{: .url } `Delete all per-domain global blacklists for inbound.`{: .comment }"
!!! api "`DELETE`{: .delete } `/api/wblist/outbound/whitelist/<domain>`{: .url } `Delete all per-domain existing global whitelists for outbound.`{: .comment }"
!!! api "`DELETE`{: .delete } `/api/wblist/outbound/blacklist/<domain>`{: .url } `Delete all per-domain existing global whitelists for outbound.`{: .comment }"
!!! api "`DELETE`{: .delete } `/api/wblist/inbound/whitelist/<mail>`{: .url } `Delete all per-user existing global whitelists for inbound.`{: .comment }"
!!! api "`DELETE`{: .delete } `/api/wblist/inbound/blacklist/<mail>`{: .url } `Delete all per-user existing global blacklists for inbound.`{: .comment }"
!!! api "`DELETE`{: .delete } `/api/wblist/outbound/whitelist/<mail>`{: .url } `Delete all per-user existing global whitelists for outbound.`{: .comment }"
!!! api "`DELETE`{: .delete } `/api/wblist/outbound/blacklist/<mail>`{: .url } `Delete all per-user existing global whitelists for outbound.`{: .comment }"


### Greylisting {: .toggle }

!!! api "`GET`{: .get } `/api/greylisting/all`{: .url } `Get all existing greylisting settings`{: .comment }"
!!! api "`GET`{: .get } `/api/greylisting/global`{: .url } `Get global greylisting setting`{: .comment }"
!!! api "`GET`{: .get } `/api/greylisting/<domain>`{: .url } `Get per-domain greylisting setting`{: .comment }"
!!! api "`GET`{: .get } `/api/greylisting/<mail>`{: .url } `Get per-user greylisting setting`{: .comment }"
!!! api "`POST`{: .post } `/api/greylisting/global`{: .url } `Set global greylisting setting`{: .comment } `Parameters`{: .has_params_greylisting }"
!!! api "`POST`{: .post } `/api/greylisting/<domain>`{: .url } `Set per-domain greylisting setting`{: .comment } `Parameters`{: .has_params_greylisting }"
!!! api "`POST`{: .post } `/api/greylisting/<mail>`{: .url } `Set per-user greylisting setting`{: .comment } `Parameters`{: .has_params_greylisting }"

    <div class="params params_greylisting">

    Parameters available for global, per-domain and per-user greylisting settings.

    Parameter | Summary | Sample Usage
    --- |--- |---
    `status` | Explicitly enable or disable greylisting service. | `status=enable` (or `disable`)

    </div>

!!! api "`DELETE`{: .delete } `/api/greylisting/global`{: .url } `Delete global greylisting setting`{: .comment }"
!!! api "`DELETE`{: .delete } `/api/greylisting/<domain>`{: .url } `Delete per-domain greylisting setting`{: .comment }"
!!! api "`DELETE`{: .delete } `/api/greylisting/<mail>`{: .url } `Delete per-user greylisting setting`{: .comment }"
!!! api "`GET`{: .get } `/api/greylisting/global/whitelists`{: .url } `Get globally whitelisted senders for greylisting service`{: .comment }"
!!! api "`GET`{: .get } `/api/greylisting/<domain>/whitelists`{: .url } `Get whitelisted senders for greylisting service for specified domain`{: .comment }"
!!! api "`GET`{: .get } `/api/greylisting/<mail>/whitelists`{: .url } `Get whitelisted senders for greylisting service for specified user`{: .comment }"
!!! api "`POST`{: .post } `/api/greylisting/global/whitelists`{: .url } `Whitelist senders for greylisting service globally`{: .comment } `Parameters`{: .has_params_greylisting_whitelists }"
!!! api "`POST`{: .post } `/api/greylisting/<domain>/whitelists`{: .url } `Whitelist senders for greylisting service for specified domain`{: .comment } `Parameters`{: .has_params_greylisting_whitelists }"
!!! api "`POST`{: .post } `/api/greylisting/<mail>/whitelists`{: .url } `Whitelist senders for greylisting services for specified user`{: .comment } `Parameters`{: .has_params_greylisting_whitelists }"

    <div class="params params_greylisting_whitelists">

    Parameter | Summary | Sample Usage
    --- |--- |---
    `senders` | Reset whitelisted senders for global greylisting service to given senders. Multiple addresses must be separated by comma. Conflicts with parameter `addSenders` and `removeSenders`. | `senders=192.168.1.0/24,172.16.10.1,@example.com`
    `addSenders` | Whitelist new senders for greylisting service globally. Multiple addresses must be separated by comma. Conflicts with parameter `senders`. | `addSenders=192.168.1.0/24,@example.com`
    `removeSenders` | Remove existing whitelisted senders for greylisting service globally. Multiple addresses must be separated by comma. Conflicts with parameter `senders`. | `removeSenders=192.168.1.0/24,@example.com`

    Valid sender address formats:

    Sender Address | Comment
    ---|---
    `192.168.2.10` | Single IP address
    `192.168.1.0/24` | CIDR network
    `user@example.com` | Single email address
    `@example.com` | Entire domain
    `@.example.com` | Entire domain and all its sub-domains

    </div>

!!! api "`POST`{: .post } `/api/greylisting/whitelist_spf_domains`{: .url } `Whitelist IP addresses and networks listed in SPF/MX DNS record of given sender domains for greylisting service globally`{: .comment } `Parameters`{: .has_params }"

    <div class="params">

    Given sender domain names are not used directly while checking whitelisting, instead, there's a cron job to query SPF and MX DNS records of given sender domains, then whitelist the IP addresses/networks listed in DNS records.

    Multiple domains must be separated by comma.

    Parameter | Summary | Sample Usage
    --- |--- |---
    `domains` | Reset whitelisted sender domains for global greylisting service to given sender domains. Conflicts with parameters `addDomains` and `removeDomains`. | `domains=iredmail.org,gmail.com`
    `addDomains` | Add new whitelist sender domains for global greylisting service. Conflicts with parameter `domains`. | `addDomains=iredmail.org,gmail.com`
    `removeDomains` | Remove existing whitelisted sender domains for global greylisting service. Conflicts with parameter `domains`. | `removeDomains=iredmail.org,gmail.com`

    <!--
    `query_dns_immediately` | Query SPF/MX/A DNS records of given sender domains immediately, and whitelist returned IP/networks | `query_dns_immediately=yes`
    -->

    </div>

### Export Accounts {: .toggle }

#### LDIF (LDAP backend only) {: .toggle }

!!! api "`GET`{: .get } `/api/ldif/domain/<domain>`{: .url } `Export domain to LDIF`{: .comment }"
!!! api "`GET`{: .get } `/api/ldif/catchall/<domain>`{: .url } `Export per-domain catch-all account to LDIF`{: .comment }"
!!! api "`GET`{: .get } `/api/ldif/admin/<mail>`{: .url } `Export (separated) domain admin to LDIF`{: .comment }"
!!! api "`GET`{: .get } `/api/ldif/user/<mail>`{: .url } `Export mail user to LDIF`{: .comment }"
!!! api "`GET`{: .get } `/api/ldif/maillist/<mail>`{: .url } `Export mailing list account to LDIF`{: .comment }"
!!! api "`GET`{: .get } `/api/ldif/alias/<mail>`{: .url } `Export mail alias account to LDIF`{: .comment }"





<script src="./js/jquery-1.12.4.min.js"></script>
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
    $('.has_params_greylisting').bind('click', function(){$('.params_greylisting').toggle();});
    $('.has_params_greylisting_whitelists').bind('click', function(){$('.params_greylisting_whitelists').toggle();});
    $('.has_params_spampolicy').bind('click', function(){$('.params_spampolicy').toggle();});
    $('.has_params_wblist').bind('click', function(){$('.params_wblist').toggle();});
});
</script>
