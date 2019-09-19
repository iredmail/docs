# iRedMail Easy: Preparations for using Microsoft Active Directory as iRedMail backend

[TOC]

## Summary

To query mail accounts against Microsoft Active Directory, we need a LDAP
user account which can query the Active Directory.

In this tutorial, we will show you how to

* create account `vmail` with read-only privilege used to query mail accounts
* create account `vmailadmin` with read-write privileges used to query and
  manage mail accounts.

This tutorial has been tested on Windows Server 2012, but it should work for
all Windows Server versions.

## Create read-only account: vmail

- Click `Start` on bottom-left corner of your Windows OS, click `Server Manager`.

![](./images/ad/start-server-manager.png)

- Click `Tools` on top-right corner, click `Active Directory Domains and Trusts`.

![](./images/ad/create_ad_account_1.png)

- Right click your AD domain, then click `Manage`. It will show you a new window.
  In this example, it's domain `iredmail.org`.

![](./images/ad/create_ad_account_2.png)

- In the new windows, right click on item `Users`, select `New -> User`.

![](./images/ad/create_ad_account_3.png)

- Input `vmail` in `User logon name` field, and fill other fields, then click `Next`.

![](./images/ad/read_only_account_1.png)

- Input a strong password for `vmail` user, make sure option `Password never
  expires` is checked, and uncheck other 3 options. Then click `Next`.

![](./images/ad/read_only_account_2.png)

- Click `Finish` to finish account creation.

![](./images/ad/read_only_account_3.png)

### Grant privileges

We need to grant `vmail` user required privileges.

In the `Active Directory Users and Computers` window, right click your AD
domian name (in our example it's `iredmail.org`), and select `Delegate Control...`.

![](./images/ad/create_ad_account_4.png)

- Click `Next`.

![](./images/ad/create_ad_account_5.png)

- Click `Add`.

![](./images/ad/create_ad_account_6.png)

- Input read-only account `vmail`, and click `OK`.

![](./images/ad/read_only_account_4.png)

- Click `Next`.

![](./images/ad/read_only_account_5.png)

- Select `"Read all user information"`, click `Next`.

![](./images/ad/read_only_account_6.png)

- Click `Finish` to confirm.

![](./images/ad/read_only_account_7.png)

## Create read-write account: vmailadmin

This account is used to manage mail accounts.

- Click `Start` on bottom-left corner of your Windows OS, click `Server Manager`.

![](./images/ad/start-server-manager.png)

- Click `Tools` on top-right corner, click `Active Directory Domains and Trusts`.

![](./images/ad/create_ad_account_1.png)

-  Right click your AD domain, then click `Manage`. In this example, it's domain `iredmail.org`.

![](./images/ad/create_ad_account_2.png)

-  At the new windows,  right click `Users` --> `New` --> `User`.

![](./images/ad/create_ad_account_3.png)

- Input `vmailadmin` in `User logon name` field, and fill other fields, then click Next.

![](./images/ad/admin_account_1.png)

- Input a strong password for user `vmailadmin`, make sure option `Password never expires` is checked, click `Next`.

![](./images/ad/admin_account_2.png)

- Click `Finish` to finish account creation.

![](./images/ad/admin_account_3.png)

### Grant privileges

Account `vmailadmin` has been created, we need to grant it more privileges than `vmail` user.

In the Active Directory Users and Computers window, right click your AD domian
and select `Delegate Control...`. In this example, it's domain `iredmail.org`,

![](./images/ad/create_ad_account_4.png)

- Click `Next`.

![](./images/ad/create_ad_account_5.png)

- Click `Add`.

![](./images/ad/create_ad_account_6.png)

- Input account name `vmailadmin`, and click `OK`.

![](./images/ad/admin_account_4.png)

- Click `Next`.

![](./images/ad/admin_account_5.png)

- Select tasks listed below, then click `Next`:
    * `Create，delete, and manage user accounts`
    * `Reset user passowords and force password change at next logon`
    * `Read all user information`
    * `Modify the membership of a group`

![](./images/ad/admin_account_6.png)

- Click `Finish`.

![](./images/ad/admin_account_7.png)

## Store passwords on your iRedMail server

iRedMail Cloud Deployment Platform does not store any password on its servers,
instead, it reads passwords from different files which are stored under
`/root/.iredmail/kv/` on YOUR server. So you need to create few files to store
`vmail` and `vmailadmin` account passwords on the iRedMail server you're going
to integrate with Active Directory.

Please login to your iRedMail server first, then:

* Create directory `/root/.iredmail/kv/` with command below (NOTE: You may need
  `sudo` privilege if you're not root user):

    ```mkdir -p /root/.iredmail/kv```

* Create file `/root/.iredmail/kv/ad_ldap_vmail_password`, input password of
  `vmail` user in the file. Do not leave any comment lines or other characters
  in the file.
* Create file `/root/.iredmail/kv/ad_ldap_vmailadmin_password`, input password
  of `vmailadmin` user in the file. Do not leave any comment lines or other characters
  in the file.
