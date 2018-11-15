# Create AD account for iRedMail
[TOC]

## Summary
With iRedMail (ad backend), we need two accounts, admin account with all privileges, low-privileged account with read-only privilege.
In this tutorial, we will show you how to create account in AD, with strong and complex password.

- low-privileged account `vmail`.
- admin account `vmailadmin`.

This tutorial has been tested on:

- Windows Server 2012

If it works for you on different Windows Server version, please let us know.

## Create low-privileged account.

- Click `Start` on bottom-left corner of your Windows OS, click `Server Manager`.

![](./images/ad/start-server-manager.png)

- Click `Tools` on top-right corner, click `Active Directory Domains and Trusts`.

![](./images/ad/create_ad_account_1.png)

-  Right click your AD domain, here is `iredmail.org`,  then click `Manage`.

![](./images/ad/create_ad_account_2.png)

-  At the new windows,  right click `Users` --> `New` --> `User`.

![](./images/ad/create_ad_account_3.png)

- Input `vmail` account info, click `Next`.

![](./images/ad/read_only_account_1.png)

- Input `vmail` account passowrd, and select `Password never expires`, click `Next`.

![](./images/ad/read_only_account_2.png)


- Click `Finish` to confirm.

![](./images/ad/read_only_account_3.png)


- Now account `vmail` has created, we will set read-only permission for `vmail`,  right click your AD domian here is `iredmail.org`, and select `Delegate Control...`.

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

- Click `Finish` to confirm.

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

- Click `Finish` to confirm.

![](./images/ad/admin_account_7.png)

- Low-privileged account `vmailadmin` created.
