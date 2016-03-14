# Exchange ActiveSync: Setup Outlook 2013 for Windows

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
* Outlook 2013 for Windows. Earlier releases of Outlook for Windows doesn't work.

## Step-by-step configuration

1: Open application `Outlook 2013`:

![](./images/sogo/outlook.2013.app.png)

2: Add a new account in Outlook, in `Auto Account Setup` page, please choose `Manual setup
   or additional server types`, then click `Next`:

![](./images/sogo/outlook.add.account.png)

3: In `Choose Service` page, please choose `Outlook.com or Exchange ActiveSync
   compatible service`, then click `Next`:

![](./images/sogo/outlook.choose.service.png)

4: In `Server Settings` page, fill up the form with your server address and
   email account credential, then click `Next`:

* Your Name: `your full name`
* E-mail Address: `your full email address`
* Mail server: `your server name or IP address`
* User Name: `your full email address`
* Password: `password of your email account`

![](./images/sogo/outlook.server.settings.png)

After you click `Next`, Outlook will start verifying your email account, please
wait and you will see below screen after verified:

![](./images/sogo/outlook.test.account.settings.png)

That's all.

## References

* [SOGo web site](http://sogo.nu)
* Outlook plugins:

    * [Outlook CalDav Synchronizer](https://github.com/aluxnimm/outlookcaldavsynchronizer)

        > Outlook Plugin, which synchronizes events, tasks and contacts(beta) between Outlook and Google, SOGo, Horde or any other CalDAV or CardDAV server. Supported Outlook versions are 2016, 2013, 2010 and 2007.
