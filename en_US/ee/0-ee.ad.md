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
- iRedMail retrieves full email addresses of mail accounts from specified LDAP
  attributes on AD server, the email address must end with target domain,
  otherwise these accounts will not be replicated to iRedMail server.

    For example, you choose to replicate mail accounts from AD to email domain
    `example.com` which is hosted on iRedMail server, and retrieve full email
    addresses of AD user accounts from LDAP attribute `userPrincipalName`, then
    the value of `userPrincipalName` must be a valid email address ends with
    `@example.com`.

## Replicate mail accounts from Microsoft Active Directory

### Add Active Directory as an account resource

Please login to EE as global admin, then click `Account Resource` on left
sidebar, it shows you supported server types.

![](./images/ee/account-resource/account-resource.png){: width="800px" }

Click the Active Directory icon to add AD as account resource.

![](./images/ee/account-resource/ad-connection.png){: width="800px" }
![](./images/ee/account-resource/ad-replication.png){: width="800px" }
![](./images/ee/account-resource/ad-users.png){: width="800px" }
![](./images/ee/account-resource/ad-groups.png){: width="800px" }
![](./images/ee/account-resource/ad-list.png){: width="800px" }

## See Also

* [Install iRedMail Enterprise Edition](./install.ee.html)
* [Use a remote MySQL or MariaDB server as backend database](./ee.remote.mysql.html)
* [Best Practice](./ee.best.practice.html)
* [ChangeLog of iRedMail Enterprise Edition](./ee.changelog.html)
