# EE: Use a Remote MySQL/MariaDB server as backend database

[TOC]

Since version __v1.6.0__, EE supports using a remote MySQL or MariaDB server as
backend database. This can be done during initial setup, not after.

## Requirements

- A working remote MySQL or MariaDB server.
- __Network latency__ of SQL connection between your server and this remote
  SQL server should be __no longer than 50 ms__. Long latency causes
  bad performance and user experience.

## Initial Setup

During initial setup, you can choose to use a remote MySQL or MariaDB server
as backend database to store mail accounts and application data.

![](./images/ee/remote-mysql/setup-1.png){: width="800px" }
![](./images/ee/remote-mysql/setup-2.png){: width="800px" }

## Post-install management

After initial setup, you can manage parameters of remote MySQL/MariaDB server.

- Login to EE as global admin
- Click `Server Settings` -> `Remote MySQL Server`

Notes:

- SQL root password is hidden and not transferred on network due to security concern.
- You can still click button `Test Connection` to test connection to remote SQL server.
- If you need to update SQL root password, please click the `Update` button,
  it will show you an input box, input the new password and click
  `Save Changes` to update it.

![](./images/ee/remote-mysql/server-settings.png){: width="800px" }

## See Also

* [Best Practice](./ee.best.practice.html)
* [ChangeLog of iRedMail Enterprise Edition](./ee.changelog.html)
