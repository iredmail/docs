# How to install SOGo on CentOS 6 with iRedMail (MySQL backend)

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

mysql> CREATE VIEW sogo.sogo_auth (c_uid, c_name, c_password, c_cn, mail, home) AS SELECT username, username, password, name, username, maildir FROM vmail.mailbox;
```

## Configure SOGo

Default SOGo config file is `/etc/sogo/sogo.conf`:

```
(
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

    SOGoForceExternalLoginWithEmail = YES;
    SOGoAppointmentSendEMailNotifications = YES;
    SOGoFoldersSendEMailNotifications YES
    SOGoACLsSendEMailNotifications YES

    SOGoUserSources =
    (
        {
            type = sql;
            id = directory;
            viewURL = "mysql://sogo:password@127.0.0.1:3306/sogo/sogo_view";
            canAuthenticate = YES;
            isAddressBook = YES;
            userPasswordAlgorithm = md5;
            prependPasswordScheme = YES;
        }
    );
```

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

## References:

* Addition settings:

```
defaults write sogod OCSEMailAlarmsFolderURL mysql://sogo:password@localhost:3306/sogo/sogo_alarms_folder
defaults write sogod SOGoTimeZone "Europe/Berlin"

defaults write sogod SOGoMailingMechanism smtp
defaults write sogod SOGoSMTPServer 127.0.0.1
defaults write sogod SOGoMemcachedHost 127.0.0.1

defaults write sogod SOGoIMAPServer localhost
defaults write sogod SOGoPasswordChangeEnabled YES
defaults write sogod SOGoSieveScriptsEnabled YES
defaults write sogod SOGoSieveServer sieve://127.0.0.1:4190
defaults write sogod WOPort 127.0.0.1:20000
```
