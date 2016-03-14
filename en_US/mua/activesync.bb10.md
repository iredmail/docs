# Exchange ActiveSync: Setup BlackBerry 10 devices

!!! note "Important Notes"

    * SOGo provides __EAS (Exchange ActiveSync)__ support, but not __EWS
      (Exchange Web Service)__.
    * Outlook 2013 for Windows works well with EAS.
    * Below mobile devices works well with EAS, they will sync mails, calendars,
      contacts, tasks, memos/notes.
        * BlackBerry 10 devices
        * iOS devices (iPad, iPhone). Tested with iOS 8.1.3.
        * Android devices. Tested with OS v4.0.
    * Apple Mail.app, and Outlook for Mac support EWS. But not EAS.
    * Outlook 2010 for Windows supports MAPI.
    * iRedMail doesn't integrate [OpenChange](http://www.openchange.org) and
      [Samba4](http://www.samba.org) for native MAPI support, so SOGo groupware
      in iRedMail doesn't provide full support for Microsoft Outlook clients,
      Mac OS X Mail.app and all iOS devices, don't try to add your mail account
      as an `Exchange` account in these mail clients. You have to add separate
      POP3/IMAP account, caldav/carddav account instead.

## Requirements

* iRedMail-0.9.0 or later releases is required.
* You must choose to install SOGo groupware during iRedMail installation.

## Step-by-step configuration

1: Open application `Settings`:

![](./images/sogo/bb10.settings.png)

2: Click `Accounts`:

![](./images/sogo/bb10.settings.accounts.png)

3: Click `Add Account` at the bottom:

![](./images/sogo/bb10.settings.accounts.list.png)

4: Click `Advanced` at the bottom:

![](./images/sogo/bb10.settings.add.account.png)

5: Choose `Microsoft Exchange ActiveSync`.

![](./images/sogo/bb10.add.exchange.png)

6: Fill up the form with your server address and email account credential

* Description: `you can type anything here`
* Domain: `you can type anything here`
* Username: `your full email address`
* Email Address: `your full email address`
* Password: `password of your email account`
* Server Address: `your server name or IP address`
* Port: `443`
* Use SSL: checked

![](./images/sogo/bb10.exchange.1.png)
![](./images/sogo/bb10.exchange.2.png)

That's all.
