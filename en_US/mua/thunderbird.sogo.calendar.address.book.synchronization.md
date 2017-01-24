# Setup Thunderbird: SOGo Address Book and Calendar synchronization with CardDAV and CalDAV

[TOC]

SOGo Connector extention provides integration of Mozilla Thunderbird with the SOGo groupware solution. It does this by adding support for remote DAV address books and by adding features to be used along with the Lightning calendar extension.

## Download and install SOGo Connector

[Check the right version for your Thunderbird and download SOGo Connector](https://sogo.nu/download.html#/frontends).

Menu: `Add-ons`

![](./images/thunderbird/sogo_menu_addons.png)

`Tools for all add-ons` -> `Install Add-on from file`

![](./images/thunderbird/sogo_install_addons_from_file.png)

Select SOGo Connector xpi file from the folder you downloaded

Click Install now to install SOGo Connector add-on

Restart Thunderbird

## Configure Remote Address Book

Get SOGo Address Book link

Access SOGo -> `Address Book` -> Choose the address book you want to sync (Personal Address Book is default), click on 3 vertical dots -> Link to this Address Book - copy CardDAV URL

NOTE:

* Some old releases might not have right URL settings, so URL contains `127.0.0.1:20000`, replace this with your real SOGo URL.

![](./images/thunderbird/sogo_link_to_address_book.png)

Add Remote Address to Thunderbird

Address Book: `File` -> `New` -> `Remote Address Book`

![](./images/thunderbird/sogo_new_remote_address_book.png)

Configure Address Book:

* Properties
    * Name: SOGo Address Book name
    * URL: insert link you got from SOGo above - like: https://<host>/SOGo/dav/<userName>/Contacts/personal/
    * Optionally check Periodic sync

![](./images/thunderbird/sogo_remote_address_book.png)


## Install Thunderbird Lightning

Menu: `Add-ons` -> Search "Lightning", click Install

![](./images/thunderbird/sogo_lightning_addon_install.png)

After installation click "Restart now"


## Configure Remote Calendar

Get SOGo Calendar link

Access SOGo -> `Calendar` -> Choose the calendar you want to sync (Personal Calendar is default), click on 3 vertical dots -> Link to this Calendar - copy CalDAV URL

NOTE:

* Some old releases might not have right URL settings, so URL contains `127.0.0.1:20000`, replace this with your real SOGo URL.

![](./images/thunderbird/sogo_link_to_calendar.png)

Add Remote Calendar to Thunderbird

File -> `New` -> `Calendar`

![](./images/thunderbird/sogo_new_calendar.png)

Configure:

* On the Network -> 

	* Format: CalDAV
	* Location: insert link you got from SOGo above - like: https://<host>/SOGo/dav/<userName>/Calendar/personal/

![](./images/thunderbird/sogo_configure_calendar.png)

Name: Enter your calendar name

Click Synchronize

Enter username and password for your email account
