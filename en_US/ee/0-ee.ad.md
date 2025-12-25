# EE: Replicate mail accounts from Microsoft Active Directory

[TOC]

Since iRedMail Enterprise Edition __v1.6.0__ ("EE" for short), EE supports
replicating mail accounts from a Microsoft Active Directory ("AD" for short) server.

You can setup such replication anytime after iRedMail initial setup, with any
backend database (MariaDB, PostgreSQL or OpenLDAP).

## Requirements

- A working iRedMail server which runs iRedMail Enterprise Edition version v1.6.0 or later.
- A working Active Directory server which allows connection from iRedMail server.
    - iRedMail server connects to the AD server via port 389 or 636 (secure
      connection) using the LDAP protocol. Please make sure those ports are
      open to iRedMail server in your network firewall.
    - Port 636 (a.k.a. LDAP over SSL) is recommended for security concern,
      otherwise the network between iRedMail and AD servers must be trustable.
- You must specify a hosted email domain as target for such replication,
  accounts replicated from AD will be hosted under this target domain.

    EE retrieves the full email addresses of accounts from specified LDAP
    attributes on AD server, the domain part of email address must be same as
    the target domain, otherwise these accounts will be ignored and not replicated.

    For example, you choose to replicate mail accounts from AD to email domain
    `example.com` which is hosted on iRedMail server, and retrieve full email
    addresses of AD user accounts from LDAP attribute `userPrincipalName`, then
    the value of `userPrincipalName` must be a valid email address ends with
    `@example.com`.

## Replicate mail accounts from Microsoft Active Directory

### Add Active Directory as an account resource

Please login to EE as global admin, then click `Account Resource` on left
sidebar. It shows you supported server types for account replication.

> Currently only AD is supported, [contact us](https://www.iredmail.org/contact.html)
> if you need to support other servers.

![](./images/ee/account-resource/account-resource.png){: width="800px" }

Click the __`Active Directory`__ icon to add AD for account replication, it
will redirect to replication management page.

- It saves default values under __`Replication`__, __`Users`__ and __`Groups`__
  tabs, but you may want to tune it to work with your AD server.

Fill AD server related settings under __`Connection`__ tab.

- __`Replicate accounts for domain`__: The email domain name you'd like to
  replicate for. It will search existing domains when you start typing, click
  the domain name you want to replicate.
- __`Server address and port`__: The hostname of IP address of the AD server.
    - Port 389 is plain/insecure connection by default. A valid ssl cert is
      required on server side to enable TLS secure connection support on this port.
    - Port 636 is SSL secure connection. A valid ssl cert is required on
      server side.
- __`Secure connection (TLS/SSL) is required`__: Toggle on this option if AD server
  has valid ssl cert and requires secure TLS/SSL connection.
- __`Connection timeout`__: Timeout (in seconds) for connection to AD server.
- __`Base DN`__: The container which contains all user / group accounts. For example,
  `cn=Users,dc=xx,dc=xx`.
- __`Bind DN`__: The full LDAP dn used to login to AD. This bind dn is used to
  search all user / group accounts under base dn.
- __`Bind Password`__: Password of the bind dn.

![](./images/ee/account-resource/ad-connection.png){: width="800px" }

After inputed all values, please click the __`Test connection`__ link to
verify those parameters. If all values are correct, it will show you message
__`Connection succeeded`__, and retrieve up to 10 users and groups under the
message. You can verify the retrieved attributes.

Click `Save Changes` after test succeeded.

![](./images/ee/account-resource/ad-test-connection.png){: width="800px" }

Click __`Replication`__ tab:

- __`Replication Interval`__: Set how often to replicate incrementally.
    - Changes made on AD server will be replicated during next replication.
- __`Replicate AD groups as mail alias accounts`__: Replicate AD group accounts,
  and create them as mail alias accounts locally.
    - Group members will be replicated too. You can manage members on AD, and view
      the members on mail alias profile page on iRedMail server.
    - If this option is not toggled on, the tab `Groups` will be hidden and invisible.
- __`Delete accounts locally when they were removed from Active Directory`__:
  delete mail accounts and their application data (e.g. webmail preferences,
  calendar, contacts, per-user whitelists / blacklists, etc) on iRedMail server
  when they were removed from Active Directory.

Click `Save Changes` if you made some changes.

![](./images/ee/account-resource/ad-replication.png){: width="800px" }

Click __`Users`__ tab:

- __`LDAP Filter`__: The LDAP filter used to query against AD to find mail users.
  Default is `(|(objectClass=user)(objectClass=person))`.
- __`Get full email address from attribute`__: Set the LDAP attribute name which
  stores account's full email address on AD.
    - You can select from pre-defined attributes, or input your own one if the
      name is not listed on drop-down menu.
- __`Replicate additional user profile`__: Besides email address, EE
  supports replicating additional user profiles from AD.
    - Again, you can select from pre-defined attributes, or input your own one
      if the name is not listed on drop-down menu.
    - Leave it empty to not replicate certain profiles.

Click `Save Changes` if you made some changes.

You may want to go back to `Connection` tab and click `Test connection` to
check the replicated user profiles.

![](./images/ee/account-resource/ad-users.png){: width="800px" }

If you enables option __`Replicate AD groups as mail alias accounts`__ under
__`Replication`__ tab, the `Groups` tab becomes visible. Click it to manage
group replication related settings.

AD group will be replicated and created as mail alias account locally, you
can set default access policy.

Click `Save Changes` if you made some changes.

Again, you may want to go back to `Connection` tab and click `Test connection`
to check the replicated group profiles.

![](./images/ee/account-resource/ad-groups.png){: width="800px" }

You can now click __`Account Resources`__ on left
sidebar, it will show you all created account resources.

- It displays brief info of the account resource, including server address and
  port, target domain, replication interval, and time of last replication.
- Click `Edit` button to manage account resource.
- Click `Replicate Now` to replicate immediately.
- Click `Log` to check replication history.
- Click `Delete` to delete this account resource.
- Click the small status icon to enable or disable this account resource.

![](./images/ee/account-resource/ad-list.png){: width="800px" }

## See Also

* [Install iRedMail Enterprise Edition](./install.ee.html)
* [Use a remote MySQL or MariaDB server as backend database](./ee.remote.mysql.html)
* [Best Practice](./ee.best.practice.html)
* [ChangeLog of iRedMail Enterprise Edition](./ee.changelog.html)
