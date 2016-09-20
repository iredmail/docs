# Exchange ActiveSync: Setup iOS devices

!!! note "Important Notes"

    * SOGo provides __EAS (Exchange ActiveSync)__ support, but not __EWS
      (Exchange Web Service)__.
    * __Outlook__ 2013, 2016 for Windows works well with EAS.
    * Mainstream __mobile devices__ (iOS, Android, BlackBerry 10) work well with
      EAS, they can sync mails, calendars, contacts, tasks.
    * Apple Mail.app, and Outlook for Mac support EWS. But not EAS.
    * Outlook 2010 for Windows supports MAPI.

    iRedMail doesn't integrate [OpenChange](http://www.openchange.org) and
    [Samba4](http://www.samba.org) for native MAPI support, so SOGo groupware
    in iRedMail doesn't provide full support for Microsoft Outlook clients,
    Mac OS X Mail.app and all iOS devices, don't try to add your mail account
    as an `Exchange` account in these mail clients. You have to add account as
    POP3/IMAP account, caldav/carddav account instead.

## Requirements

* iRedMail-0.9.0 or later releases is required.
* You must choose to install SOGo groupware during iRedMail installation.

## Step-by-step configuration

1: Open application `Settings` on home screen:

![](./images/sogo/ios.settings.png)

2: Click `Mails , Contacts, Calendars`:

![](./images/sogo/ios.settings.accounts.png)

3: Click `Add Account`:

![](./images/sogo/ios.settings.accounts.add.png)

4: Choose `Exchange`.

![](./images/sogo/ios.settings.accounts.add.exchange.png)

5: Fill up the form with your server address and email account credential

* Email: `your full email address`
* Password: `password of your email account`
* Description: `you can type anything here`

![](./images/sogo/ios.exchange.1.png)

6: If it cannot auto discover server settings, you should fill up the form
   with server address and username.

* Server: `your server name or IP address`
* Username: `your full email address`

![](./images/sogo/ios.exchange.2.png)

7: Choose items you want to sync to this mobile device:

![](./images/sogo/ios.exchange.sync.items.png)

That's all.
