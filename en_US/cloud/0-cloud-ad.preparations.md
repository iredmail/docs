# Preparations for using Microsoft Active Directory as iRedMail backend

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

- Right click your AD domain, here is `iredmail.org`,  then click `Manage`. It
  will show you a new window.

![](./images/ad/create_ad_account_2.png)

- In the new windows, right click on item `Users`, select `New -> User`.

![](./images/ad/create_ad_account_3.png)

- Input `vmail` as `User logon name`, and fill other fields, then click `Next`.

![](./images/ad/read_only_account_1.png)

- Input a strong password for `vmail` user, toggle on `Password never expires`,
  and uncheck other 3 options. Then click `Next`.

![](./images/ad/read_only_account_2.png)

- Click `Finish` to finish account creation.

![](./images/ad/read_only_account_3.png)

Now we need to grant `vmail` user required privileges.

In the `Active Directory Users and Computers` window, right click your AD
domian name (in our example it's `iredmail.org`), and select `Delegate Control...`.

![](./images/ad/create_ad_account_4.png)

- Click `Next`. 

![](./images/ad/create_ad_account_5.png)

- Click `Add`.

![](./images/ad/create_ad_account_6.png)

- Input read-only account `vmail`, and click `Ok`.

![](./images/ad/read_only_account_4.png)

- Click `Next`.

![](./images/ad/read_only_account_5.png)

- Select `"Read all user information"`, click `Next`.

![](./images/ad/read_only_account_6.png)

- Click `Finish` to confirm.

![](./images/ad/read_only_account_7.png)

- Low-privileged account `vmail` created.

## Create admin account.

- Click `Start` on bottom-left corner of your Windows OS, click `Server Manager`.

![](./images/ad/start-server-manager.png)

- Click `Tools` on top-right corner, click `Active Directory Domains and Trusts`.

![](./images/ad/create_ad_account_1.png)

-  Right click your AD domain, here is `iredmail.org`,  then click `Manage`.

![](./images/ad/create_ad_account_2.png)

-  At the new windows,  right click `Users` --> `New` --> `User`.

![](./images/ad/create_ad_account_3.png)

- Input `vmailadmin` account info, click `Next`.

![](./images/ad/admin_account_1.png)

- Input `vmailadmin` account passowrd, and select `Password never expires`, click `Next`.

![](./images/ad/admin_account_2.png)

- Click `Finish` to finish account creation.

![](./images/ad/admin_account_3.png)

- Now account `vmailadmin` has created, we will set read-only permission for `vmail`,  right click your AD domian here is `iredmail.org`, and select `Delegate Control...`.

![](./images/ad/create_ad_account_4.png)

- Click `Next`. 

![](./images/ad/create_ad_account_5.png)

- Click `Add`.

![](./images/ad/create_ad_account_6.png)

- Input admin account `vmailadmin`, and click `Ok`.

![](./images/ad/admin_account_4.png)

- Click `Next`.

![](./images/ad/admin_account_5.png)

- Select `"Create，delete, and manage user accounts"`, `"Reset user passowords and force password change at next logon"`, `"Read all user information"`, click `Next`.

![](./images/ad/admin_account_6.png)

- Click `Finish`.

![](./images/ad/admin_account_7.png)

- Low-privileged account `vmailadmin` created.
