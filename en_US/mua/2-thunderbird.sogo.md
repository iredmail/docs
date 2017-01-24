# Setup Thunderbird: SOGo Address Book and Calendar synchronization with CardDAV and CalDAV

[TOC]

SOGo Connector extention provides integration of Mozilla Thunderbird with the SOGo groupware solution. It does this by adding support for remote DAV address books and by adding features to be used along with the Lightning calendar extension.

## Download and install SOGo Connector

* Download the SOGo connector from SOGo website: <https://sogo.nu/download.html#/frontends>
* Launch Thunderbird, go to `Tools` -> `Add-ons`

![](./images/thunderbird/sogo_menu_addons.png)

Click the gear icon and choose `Install Add-on From File`

![](./images/thunderbird/sogo_install_addons_from_file.png)

Select the downloaded SOGo Connector xpi file to install it, then restart Thunderbird.

### Configure Remote Address Book

To use SOGo address book, we need to get the link of SOGo Address Book first.

* Login to SOGo
* Click `Address Book` on top-right corner
* Choose the address book you want to sync (`Personal Address Book` is the
  default one), click on 3 vertical dots, choose `Link to this Address Book`,
  and copy CardDAV URL.

    Note: Some old SOGo releases might use `127.0.0.1:20000` as server
    address in the CardDAV URL, you must replace them by the real server
    address like `https://<your_server_name_or_ip>/SOGo`.

![](./images/thunderbird/sogo_link_to_address_book.png)

Now launch Thunderbird:

* open its Address Book (on macOS, it's menu `Windows` -> `Address Book`)
* on Address Book window, click `File` -> `New` -> `Remote Address Book`

![](./images/thunderbird/sogo_new_remote_address_book.png)

Configure the Address Book Properties:

* `Name`: SOGo Address Book name (you can use whatever name you like here)
* `URL`: insert link you got from SOGo above - like: `https://<host>/SOGo/dav/<userName>/Contacts/personal/`
* Optionally check Periodic sync

![](./images/thunderbird/sogo_remote_address_book.png)

## Install Thunderbird Lightning

Lightning is a calendar add-on for Thunderbird.

Launch Thunderbird, click menu: `Tools` -> `Add-ons`, Search "Lightning" and
install it.

![](./images/thunderbird/sogo_lightning_addon_install.png)

Restart Thunderbird after installation.

### Configure Remote Calendar

To use SOGo calendar, we need to get the link of SOGo Calendar first.

* Login to SOGo
* Click `Calendar` on top-right corner
* Choose the calendar you want to sync (`Personal Calendar` is the default one),
  click on 3 vertical dots, choose `Link to this Calendar` and copy CalDAV URL.

    Note: Some old SOGo releases might use `127.0.0.1:20000` as server
    address in the CardDAV URL, you must replace them by the real server
    address like `https://<your_server_name_or_ip>/SOGo`.

![](./images/thunderbird/sogo_link_to_calendar.png)

Launch Thunderbird to add SOGo calendar:

* Create a new calendar by click menu on Thunderbird main window: `File` ->
  `New` -> `Calendar`, and choose `On the Network` for SOGo calendar:

![](./images/thunderbird/sogo_new_calendar.png)

* on the `On the Network` page, choose format `CalDAV`, and paste the link of
  SOGo calendar. for example, `https://<host>/SOGo/dav/<userName>/Calendar/personal/`

![](./images/thunderbird/sogo_configure_calendar.png)

* Type a preferred name for this calendar, then click `Continue` to finish the
  setup.
