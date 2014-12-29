# Mac OS X: Add calendar (CalDAV) and task (Reminders) service in iCalendar.app

> To use calendar and task service, you must choose to install SOGo groupware
> during iRedMail installation.

1: Open application `System Preferences`:

![](./images/sogo/macosx.system.preferences.png)

2: Click `Internet Accounts`:

![](./images/sogo/macosx.internet.accounts.png)

3: on right panel, click `Add Other Account` at the bottom

![](./images/sogo/macosx.add.other.account.png)

4: choose `Add a CalDAV account` in popup window

![](./images/sogo/macosx.choose.account.type.caldav.png)

5: Fill up the form with your server address and email account credential

* Account Type: `Advanced`
* User Name: `your full email address`
* Password: `password of your email account`
* Server Address: `server name or IP address`
* Server Path: `/SOGo/dav/[your full email address]`
* Port: `443`
* Use SSL: checked

![](./images/sogo/macosx.add.caldav.account.png)

6: Click `Create` button to create account. You can also enable Reminders (task
   service) if you want.

![](./images/sogo/macosx.add.reminder.png)
