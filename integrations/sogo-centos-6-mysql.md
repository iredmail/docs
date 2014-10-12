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

mysql> GRANT SELECT ON vmail.mailbox TO sogo@localhost;

mysql> CREATE VIEW sogo.sogo_users (c_uid, c_name, c_password, c_cn, mail, home) AS SELECT username, username, password, name, username, maildir FROM vmail.mailbox;
```

## Configure SOGo

Default SOGo config file is `/etc/sogo/sogo.conf`:

```
{
    WOPort = 127.0.0.1:20000;

    SOGoProfileURL = "mysql://sogo:password@localhost:3306/sogo/sogo_user_profile";
    OCSFolderInfoURL = "mysql://sogo:password@localhost:3306/sogo/sogo_folder_info";
    OCSSessionsFolderURL = "mysql://sogo:password@localhost:3306/sogo/sogo_sessions_folder";

    // Enable email-based alarms on events and tasks.
    SOGoEnableEMailAlarms = YES;
    OCSEMailAlarmsFolderURL = "mysql://sogo:password@localhost:3306/sogo/sogo_alarms_folder";

    // Use TLS
    SOGoIMAPServer = "imaps://127.0.0.1:143/?tls=YES";
    //SOGoDraftsFolderName = Drafts;
    //SOGoSentFolderName = Sent;
    //SOGoTrashFolderName = Trash;

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
}
```

__NOTE__: SOGo will create required SQL tables automatically
(`sogo_user_profile`, `sogo_folder_info`, `sogo_sessions_folder`, ...),  we
don't need to create them manually.

## Enable ActiveSync support

### Apache web server

SOGo installs config file `/etc/httpd/conf.d/SOGo.conf` by default, please
open it and find below lines:

```
#ProxyPass /Microsoft-Server-ActiveSync \
# http://127.0.0.1:20000/SOGo/Microsoft-Server-ActiveSync \
# retry=60 connectiontimeout=5 timeout=360
```

Remove `#` at the beginning to enable ActiveSync support:

```
ProxyPass /Microsoft-Server-ActiveSync \
 http://127.0.0.1:20000/SOGo/Microsoft-Server-ActiveSync \
 retry=60 connectiontimeout=5 timeout=360
```

### Nginx web server

If you're running Nginx web server, please open file
`/etc/nginx/conf.d/default.conf`, add some lines in `server {}` block which
is configured for HTTPS:

```
server {
    listen 443;
    ...

    # Add below lines for SOGo

    # SOGo
    location ^~ /SOGo {
        proxy_pass http://127.0.0.1:20000;
        #proxy_redirect http://127.0.0.1:20000/SOGo/ /SOGo;
        # forward user's IP address
        #proxy_set_header X-Real-IP $remote_addr;
        #proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        #proxy_set_header Host $host;
        proxy_set_header x-webobjects-server-protocol HTTP/1.0;
        #proxy_set_header x-webobjects-remote-host 127.0.0.1;
        #proxy_set_header x-webobjects-server-name $server_name;
        #proxy_set_header x-webobjects-server-url $scheme://$host;
    }

    location ^~ /Microsoft-Server-ActiveSync {
        proxy_pass http://127.0.0.1:20000/SOGo/Microsoft-Server-ActiveSync;
        proxy_redirect http://127.0.0.1:20000/Microsoft-Server-ActiveSync /;
    }

    location ^~ /SOGo/Microsoft-Server-ActiveSync {
        proxy_pass http://127.0.0.1:20000/SOGo/Microsoft-Server-ActiveSync;
        proxy_redirect http://127.0.0.1:20000/SOGo/Microsoft-Server-ActiveSync /;
    }

    location /SOGo.woa/WebServerResources/ {
        alias /usr/lib/GNUstep/SOGo/WebServerResources/;
    }
    location /SOGo/WebServerResources/ {
        alias /usr/lib/GNUstep/SOGo/WebServerResources/;
    }
    location ^/SOGo/so/ControlPanel/Products/([^/]*)/Resources/(.*)$ {
        alias /usr/lib/GNUstep/SOGo/$1.SOGo/Resources/$2;
    }
}
```

__Important note__: You should replace directory `/usr/lib/GNUstep/SOGo` the
the real directory which contains SOGo files:

* on RHEL/CentOS: it's `/usr/lib/GNUstep/SOGo` on x86 platform,
  `/usr/lib64/GNUstep/SOGo` on x86_64 platform.
* on Debian/Ubuntu, it's `/usr/lib/GNUstep/SOGo`.
* on OpenBSD, it's `/

## Start SOGo and dependent services

```
service sogod start
service httpd restart
service memcached start
```

## Access SOGo

Open your favourite web browser, access URL: `https://[your_server]/SOGo`.

## How to configure client applications

### Apple Devices

URL for calendar service: `http://[host]/SOGo/dav/[user]/`

## TODO

## References

