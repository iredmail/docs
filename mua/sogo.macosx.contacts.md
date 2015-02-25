# Mac OS X: Add contact service (CardDAV) in Contacts.app

> Important notes:
>
> * SOGo provides __EAS (Exchange ActiveSync)__ support, but not __EWS
>   (Exchange Web Service)__.
>
> * Outlook 2013 for Windows works well with EAS.
>
> * Below mobile devices works well with EAS, they will sync mails, calendars,
>   contacts, tasks, memos/notes.
>
>       * BlackBerry 10 devices
>       * iOS devices (iPad, iPhone). Tested with iOS 8.1.3.
>
> * Apple Mail.app, and Outlook for Mac support EWS. But not EAS.
> * Outlook 2010 for Windows supports MAPI.
> * iRedMail-0.9.0 doesn't integrate [OpenChange](http://www.openchange.org) and
>   [Samba4](http://www.samba.org) for native MAPI support, so SOGo groupware
>   in iRedMail doesn't provide full support for Microsoft Outlook clients,
>   Mac OS X Mail.app and all iOS devices, don't try to add your mail account
>   as an `Exchange` account in these mail clients. You have to add separate
>   POP3/IMAP account, caldav/carddav account instead.

## Requirements

* iRedMail-0.9.0 or later releases is required.
* To use contact service (CardDAV protocol), you must choose to install
  SOGo groupware during iRedMail installation.

## Step-by-step configuration

1: Open application `System Preferences`:

![](./images/sogo/macosx.system.preferences.png)

2: Click `Internet Accounts`:

![](./images/sogo/macosx.internet.accounts.png)

3: on right panel, click `Add Other Account` at the bottom

![](./images/sogo/macosx.add.other.account.png)

4: choose `Add a CardDAV account` in popup window

![](./images/sogo/macosx.choose.account.type.carddav.png)

5: Fill up the form with your server address and email account credential

* User Name: `your full email address`
* Password: `password of your email account`
* Server Address: `https://[server name or IP address]/SOGo/dav/[your full email address]`

![](./images/sogo/macosx.add.carddav.account.png)

That's all.
