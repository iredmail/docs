# SOGo: install SOGo on CentOS 6 with iRedMail (MySQL backend)

[TOC]


__NOTE__: this is still a draft and incomplete tutorial.

## Requirements

* A working iRedMail server (MySQL backend) on CentOS 6.

## Install SOGo

* Make sure you have EPEL repo enabled, if not, please follow [this wiki
tutorial](https://fedoraproject.org/wiki/EPEL#How_can_I_use_these_extra_packages.3F)
to enable it.

```
# yum repolist | grep -i 'epel'
epel              Extra Packages for Enterprise Linux 6 - x86_64          11,109
```

* Add yum repo file `/etc/yum.repos.d/sogo.repo`:

```
[SOGo]
name=Inverse SOGo Repository
baseurl=http://inverse.ca/downloads/SOGo/RHEL6/$basearch
gpgcheck=0
```

* Install SOGo and dependences:

```
# yum install sogo sope49-gdl1-mysql sogo-activesync libwbxml
```

## Create SQL database to store SOGo data

```
$ mysql -u root -p

mysql> CREATE DATABASE sogo CHARSET='UTF8';
mysql> GRANT ALL ON sogo.* TO sogo@localhost IDENTIFIED BY 'password';

-- TODO
mysql> GRANT SELECT ON vmail.mailbox TO sogo@localhost;

mysql> CREATE VIEW sogo.sogo_users (c_uid, c_name, c_password, c_cn, mail, home) AS SELECT username, username, password, name, username, maildir FROM vmail.mailbox;
```

## Configure SOGo

Default SOGo config file is `/etc/sogo/sogo.conf`:

```
(
    WOPort = 127.0.0.1:20000;

    SOGoProfileURL = "mysql://sogo:password@localhost:3306/sogo/sogo_user_profile";
    OCSFolderInfoURL = "mysql://sogo:password@localhost:3306/sogo/sogo_folder_info";
    OCSSessionsFolderURL = "mysql://sogo:password@localhost:3306/sogo/sogo_sessions_folder";

    SOGoIMAPServer = "127.0.0.1";
    SOGoDraftsFolderName Drafts
    SOGoSentFolderName Sent
    SOGoTrashFolderName Trash

    SOGoMailingMechanism = smtp;
    SOGoSMTPServer = 127.0.0.1;

    // Enable managesieve service
    SOGoSieveServer = sieve://127.0.0.1:4190;
    SOGoSieveScriptsEnabled = YES;
    SOGoVacationEnabled = YES;

    SOGoMemcachedHost = 127.0.0.1;

    SOGoTimeZone = "Europe/Berlin";

    SOGoFirstDayOfWeek = 1;

    SOGoMailMessageCheck = every_5_minutes;
    SOGoForceExternalLoginWithEmail = YES;
    SOGoAppointmentSendEMailNotifications = YES;
    SOGoFoldersSendEMailNotifications = YES;
    SOGoACLsSendEMailNotifications = YES;

    // OCSEMailAlarmsFolderURL = "mysql://sogo:password@localhost:3306/sogo/sogo_alarms_folder";

    SOGoPasswordChangeEnabled = YES;

    SOGoUserSources =
    (
        {
            type = sql;
            id = directory;
            viewURL = "mysql://sogo:password@127.0.0.1:3306/sogo/sogo_users";
            canAuthenticate = YES;
            isAddressBook = YES;
            userPasswordAlgorithm = md5;
            prependPasswordScheme = YES;
        }
    );
```

__NOTE__: SOGo will create required SQL tables automatically
(`sogo_user_profile`, `sogo_folder_info`, `sogo_sessions_folder`, ...),  we
don't need to create them manually.

## Start SOGo and dependent services

```
service sogod start
service httpd restart
service memcached start
```

## How to configure client applications

### Apple Devices

URL for calendar service: `http://[host]/SOGo/dav/[user]/`

## TODO

## References

