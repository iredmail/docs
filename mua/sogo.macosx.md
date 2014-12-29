# Setup Mac OS X (Microsoft Exchange ActiveSync)

> Important note:
>
> * iRedMail-0.9.0 doesn't integrate [OpenChange](http://www.openchange.org) and
>   [Samba4](http://www.samba.org), so SOGo groupware in iRedMail can NOT
>   provide full support for Microsoft Outlook clients.

## Requirements

* iRedMail-0.9.0 or later releases is required.
* You must choose to install SOGo groupware during iRedMail installation.

## Steps

1: Open application `System Preferences`:

![](./images/sogo/mac.system.preferences.png)

2: Click `Internet Accounts`:

![](./images/sogo/mac.internet.accounts.png)

3: on right panel, click `Exchange`

![](./images/sogo/mac.add.exchange.png)

4: fill your account info in popup window

* Name: `your full name`
* Email Address: `your full email address`
* Password: `password of your email account`

![](./images/sogo/mac.exchange.settings.1.png)

If it cannot find required info automatically, it will show you another window
to let you fill them manually:

* Description: `you can type anything here`
* User Name: `your full email address`
* Password: `password of your email account`
* Server Address: `server name or IP address`

![](./images/sogo/mac.exchange.settings.2.png)

5: After it verified all settings, you will see the final window like below:

![](./images/sogo/mac.exchange.png)
