# Setup SSL support for Windows Active Directory

[TOC]

## Summary

Windows Active Directory requires secure connection for updating user password
from another host via LDAP protocol. In this tutorial, we will show you how to
setup SSL support for Active Directory with a self-signed ssl cert.

This tutorial has been tested on:

- Windows Server 2012

If it works for you on different Windows Server version, please let us know.

## Enable Active Directory Certificate Services

- Click `Start` on bottom-left corner of your Windows OS, click `Server Manager`.

![](./images/ad/start-server-manager.png)

- Click `Manage` on top-right corner, click `Add Roles and Features`.

![](./images/setup.ad.ssl/server-manager-add-roles-and-features.png){:width="1024px"}

- Click `Next`:

![](./images/setup.ad.ssl/setup_ad_ssl_1.png)

- Choose `Role-based or feature-based installation`. Click Next.

![](./images/setup.ad.ssl/setup_ad_ssl_2.png)

- Select your server from the server pool. Click Next.

![](./images/setup.ad.ssl/setup_ad_ssl_3.png)

- Choose `Active Directory Certificate Services` from the list, and click Next.

![](./images/setup.ad.ssl/setup_ad_ssl_4-1.png)

![](./images/setup.ad.ssl/setup_ad_ssl_4-2.png)


- Click Next directly without choosing any item from list on the `Features` page.

![](./images/setup.ad.ssl/setup_ad_ssl_5.png)

- Click Next.

![](./images/setup.ad.ssl/setup_ad_ssl_6.png)

- Toggle on `Certificate Authority` and click Next.

![](./images/setup.ad.ssl/setup_ad_ssl_7.png)

- Click `Install` to install selected roles/features.

![](./images/setup.ad.ssl/setup_ad_ssl_8.png)

- It may take some time to finish, after finished, close the wizard window.

![](./images/setup.ad.ssl/setup_ad_ssl_9.png)

## Create a self-signed certificate

Now let’s create a certificate using AD CS Configuration Wizard, To open the wizard:

- Click `Start` on bottom-left corner of your Windows OS, click `Server Manager`.

![](./images/ad/start-server-manager.png)

- Click `Alert Flag` on top-right corner, click `Configure Active Directory Certificate Services on the destincation server`.

![](./images/setup.ad.ssl/server_manager_configuration_ad_certificate.png)

- Click `Next`:

![](./images/setup.ad.ssl/config_ad_ssl_1.png)

- Choose `Certification Authority`. Click Next.

![](./images/setup.ad.ssl/config_ad_ssl_2.png)

- Choose `Enterprise CA`. Click Next.

![](./images/setup.ad.ssl/config_ad_ssl_3.png)

- Choose `Root CA` as the type of CA, click Next.

![](./images/setup.ad.ssl/config_ad_ssl_4.png)

- Since we do not possess a private key – let’s create a new one. choose `Create a new private key`, Click Next.

![](./images/setup.ad.ssl/config_ad_ssl_5.png)

- Choose `SHA1` as the Hash algorithm, change key lenth to `4096`, Click Next.

![](./images/setup.ad.ssl/config_ad_ssl_6.png)

- Click Next.

![](./images/setup.ad.ssl/config_ad_ssl_7.png)

- Specifying validity period of the certificate. Choosing `99 years`. Click Next.

![](./images/setup.ad.ssl/config_ad_ssl_8.png)

- Choose default database locations, click Next.

![](./images/setup.ad.ssl/config_ad_ssl_9.png)

- Click Configure to confirm.

![](./images/setup.ad.ssl/config_ad_ssl_10.png)

- Once the configuration is successful/complete. Click Close.

![](./images/setup.ad.ssl/config_ad_ssl_11.png)

- Restart system.

### Test LDAPS
After restart system, we can connect to the LDAP server over SSL.
Now let us try to connect to LDAP Server (with and without SSL) using the ldp.exe tool.

Connection strings for:

- `LDAP:\\ad.iredmail.org:389`
- `LDAPS:\\ad.iredmail.org:636`

- Click `Start` on bottom-left corner of your Windows OS,
- Click `Search` on top-right corner, enter `ldp.exe` in the input box.
- Connection and fill in the following parameters and click OK to connect:

![](./images/setup.ad.ssl/test_ldap_1.png)

- If Connection is successful, you will see the following message in the ldp.exe tool:

![](./images/setup.ad.ssl/test_ldap_2.png)

- To Connect to LDAPS (LDAP over SSL), use port 636 and mark SSL. Click OK to connect.

![](./images/setup.ad.ssl/test_ldaps_1.png)

- If connection is successful, you will see the following message in the ldp.exe tool:

![](./images/setup.ad.ssl/test_ldaps_2.png)
