# Install SOGo groupware on CentOS 6 with iRedMail (MySQL backend)

[TOC]

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
baseurl=http://packages.inverse.ca/SOGo/nightly/3/rhel/6/$basearch
enabled=1
gpgcheck=0
```

* Install SOGo and dependences:

```
# yum install sogo sope49-gdl1-mysql sogo-activesync sogo-ealarms-notify sogo-tool
```

* Append an alias entry in Postfix config file `/etc/postfix/aliases`, so that
  notifications of cron jobs will be sent to mail server administrator.

```
# Part of file: /etc/postfix/aliases

sogo: root
```

Execute command to update alias db:

```
# postalias /etc/postfix/aliases
```

## Create required SQL database

SOGo will store some data (e.g. user preferences, sieve rules) in SQL database,
so we need to create a database for it. Please login to SQL server as `root`
user, then execute SQL commands below:

```
CREATE DATABASE sogo CHARSET='UTF8';
GRANT ALL ON sogo.* TO sogo@localhost IDENTIFIED BY 'password';

GRANT SELECT ON vmail.mailbox TO sogo@localhost;

CREATE VIEW sogo.users (c_uid, c_name, c_password, c_cn, mail, domain) AS SELECT username, username, password, name, username, domain FROM vmail.mailbox WHERE enablesogo=1 AND active=1;
```

!!! note

    * SOGo will create required SQL tables automatically, we don't need to
      import a SQL template file or create them manually.
    * SQL column `mailbox.enablesogo` is available since iRedMail-0.9.5, if you
      don't have it, it's safe to remove this SQL condition (`enablesogo=1`).

## Configure SOGo

Default SOGo config file is `/etc/sogo/sogo.conf`. We have a sample config file
for you, just replace MySQL username/password in this file, then it's done.

With below config file, SOGo will listen on address `127.0.0.1`, port `20000`.

!!! warning

    Sample config file below may be out of date, please check the [latest one
    in iRedMail source code repository](https://bitbucket.org/zhb/iredmail/src/default/iRedMail/samples/sogo/sogo.conf).

```
{
    // Official SOGo documents:
    //  - http://www.sogo.nu/english/support/documentation.html
    //  - http://wiki.sogo.nu
    //
    // Mailing list:
    //  - http://www.sogo.nu/english/support/community.html

    // Enable verbose logging. Reference:
    // http://www.sogo.nu/nc/support/faq/article/how-to-enable-more-verbose-logging-in-sogo.html
    //ImapDebugEnabled = YES;
    //LDAPDebugEnabled = YES;
    //MySQL4DebugEnabled = YES;
    //PGDebugEnabled = YES;

    // Daemon address and port
    WOPort = 127.0.0.1:20000;

    // PID file
    //WOPidFile = /var/run/sogo/sogo.log;

    // Log file
    //WOLogFile = /var/log/sogo/sogo.log;

    // IMAP connection pool.
    // Your performance will slightly increase, as you won't open a new
    // connection for every access to your IMAP server.
    // But you will get a lot of simultaneous open connections to your IMAP
    // server, so make sure he can handle them.
    // For debugging it is reasonable to turn pooling off.
    //NGImap4DisableIMAP4Pooling = NO;

    SOGoProfileURL = "mysql://sogo:password@127.0.0.1:3306/sogo/sogo_user_profile";
    OCSFolderInfoURL = "mysql://sogo:password@127.0.0.1:3306/sogo/sogo_folder_info";
    OCSSessionsFolderURL = "mysql://sogo:password@127.0.0.1:3306/sogo/sogo_sessions_folder";
    OCSEMailAlarmsFolderURL = "mysql://sogo:password@127.0.0.1:3306/sogo/sogo_alarms_folder";

    // With 3 parameters below, SOGo requires only 9 SQL tables in total
    // instead of creating 4 SQL tables for each user.
    OCSCacheFolderURL = "mysql://sogo:password@127.0.0.1:3306/sogo/sogo_cache_folder";
    OCSStoreURL = "mysql://sogo:password@127.0.0.1:3306/sogo/sogo_store";
    OCSAclURL = "mysql://sogo:password@127.0.0.1:3306/sogo/sogo_acl";

    // Default language in the web interface
    SOGoLanguage = English;

    // Specify which module to show after login: Calendar, Mail, Contacts.
    SOGoLoginModule = Mail;

    // Must login with full email address
    SOGoForceExternalLoginWithEmail = YES;

    // Allow user to change full name and email address.
    SOGoMailCustomFromEnabled = YES;

    // Enable email-based alarms on events and tasks.
    SOGoEnableEMailAlarms = YES;

    // IMAP server
    //SOGoIMAPServer = "imaps://127.0.0.1:143/?tls=YES";
    // Local connection is considered as secure by Dovecot.
    SOGoIMAPServer = "imap://127.0.0.1:143/";

    // SMTP server
    SOGoMailingMechanism = smtp;
    SOGoSMTPServer = 127.0.0.1;
    //SOGoSMTPAuthenticationType = PLAIN;

    // Enable managesieve service
    //
    // WARNING: Sieve scripts generated by SOGo is not compatible with Roundcube
    //          webmail, don't use sieve service in both webmails, otherwise
    //          it will be messy.
    //
    //SOGoSieveServer = sieve://127.0.0.1:4190;
    //SOGoSieveScriptsEnabled = YES;
    //SOGoVacationEnabled = YES;
    //SOGoForwardEnabled = YES;

    // Memcached
    SOGoMemcachedHost = 127.0.0.1;

    SOGoTimeZone = "America/New_York";

    SOGoFirstDayOfWeek = 1;

    SOGoRefreshViewCheck = every_5_minutes;
    SOGoMailReplyPlacement = below;

    SOGoAppointmentSendEMailNotifications = YES;
    SOGoFoldersSendEMailNotifications = YES;
    SOGoACLsSendEMailNotifications = YES;

    // PostgreSQL cannot update view
    SOGoPasswordChangeEnabled = YES;

    // Authentication using SQL
    SOGoUserSources = (
        {
            type = sql;
            id = vmail_mailbox;
            viewURL = "mysql://sogo:password@127.0.0.1:3306/sogo/users";
            canAuthenticate = YES;

            // Default algorithm used when changing passwords.
            userPasswordAlgorithm = ssha;
            prependPasswordScheme = YES;

            // Use vmail.mailbox as global address book.
            // WARNING: This will search all user accounts, not just accounts
            // under same domain as login user.
            //isAddressBook = YES;
            //displayName = "Global Address Book";
        }
    );
}
```

Important note: sieve rules generated by SOGo is not compatible with Roundcube
webmail, so if you're running both Roundcube and SOGo, you must disable sieve
support (including forwarding and vacation support) in one of them to avoid
incompatible sieve rules. if you choose to run only SOGo, you can enable sieve
support by removing comment mark of below lines in above configuration:

```
    SOGoSieveServer = sieve://127.0.0.1:4190;
    SOGoSieveScriptsEnabled = YES;
    SOGoVacationEnabled = YES;
    SOGoForwardEnabled = YES;
```

## Configure web server

To access SOGo groupware (webmail/calendar/contact), we need to configure
web server.

### Apache web server

* SOGo installs Apache config file `/etc/httpd/conf.d/SOGo.conf` by default,
  please open it, comment out 2 `ProxyPass` directives as shown below:

```
#ProxyPass /Microsoft-Server-ActiveSync ...
#ProxyPass /SOGo http://127.0.0.1:20000/SOGo retry=0
```

* Add 2 `ProxyPass` directives in `/etc/httpd/conf.d/ssl.conf`, so that SOGo
  is only accessible via https.
```
ProxyPass /Microsoft-Server-ActiveSync \
    http://127.0.0.1:20000/SOGo/Microsoft-Server-ActiveSync \
    retry=60 connectiontimeout=5 timeout=360

ProxyPass /SOGo http://127.0.0.1:20000/SOGo retry=0
```

* Open `/etc/httpd/conf.d/SOGo.conf` again, find 3 `RequestHeader` directives
  like below:

```
    RequestHeader set "x-webobjects-server-port" ...
    RequestHeader set "x-webobjects-server-name" ...
    RequestHeader set "x-webobjects-server-url" ...
```

Replace them by below settings:

```
    RequestHeader set "x-webobjects-server-port" "443"
    RequestHeader set "x-webobjects-server-name" "%{HTTP_HOST}e" env=HTTP_HOST
    RequestHeader set "x-webobjects-server-url" "https://%{HTTP_HOST}e" env=HTTP_HOST
```

* Append line below in `/etc/httpd/conf/httpd.conf` to make Apache always
  redirect http access to https.

```
RewriteRule /SOGo(.*) https://%{HTTP_HOST}%{REQUEST_URI}
```

* Restart Apache service.

### Nginx web server

If you're running Nginx web server configured by iRedMail, please open file
`/etc/nginx/conf.d/default.conf`, add some lines in `server {}` configured for
HTTPS:

```
server {
    listen 443;
    ...

    #
    # Add lines below for SOGo
    #
    location ~ ^/sogo { rewrite ^ https://$host/SOGo; }
    location ~ ^/SOGO { rewrite ^ https://$host/SOGo; }

    # For IOS 7
    rewrite ^/.well-known/caldav    /SOGo/dav permanent;
    rewrite ^/.well-known/carddav   /SOGo/dav permanent;
    rewrite ^/principals           /SOGo/dav permanent;

    location ^~ /SOGo {
        proxy_pass http://127.0.0.1:20000;

        # forward user's IP address
        #proxy_set_header X-Real-IP $remote_addr;
        #proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        #proxy_set_header Host $host;

        proxy_set_header x-webobjects-server-port 443;
        proxy_set_header x-webobjects-server-name $host;
        proxy_set_header x-webobjects-server-url $scheme://$host;

        proxy_set_header x-webobjects-server-protocol HTTP/1.0;
    }

    location ^~ /Microsoft-Server-ActiveSync {
        proxy_pass http://127.0.0.1:20000/SOGo/Microsoft-Server-ActiveSync;

        proxy_connect_timeout 360;
        proxy_send_timeout 360;
        proxy_read_timeout 360;
    }

    location ^~ /SOGo/Microsoft-Server-ActiveSync {
        proxy_pass http://127.0.0.1:20000/SOGo/Microsoft-Server-ActiveSync;

        proxy_connect_timeout 360;
        proxy_send_timeout 360;
        proxy_read_timeout 360;
    }

    location /SOGo.woa/WebServerResources/ {
        alias /usr/lib64/GNUstep/SOGo/WebServerResources/;
    }
    location /SOGo/WebServerResources/ {
        alias /usr/lib64/GNUstep/SOGo/WebServerResources/;
    }
    location ^/SOGo/so/ControlPanel/Products/([^/]*)/Resources/(.*)$ {
        alias /usr/lib64/GNUstep/SOGo/$1.SOGo/Resources/$2;
    }
}
```

__Important note__: You must replace path `/usr/lib/GNUstep/SOGo` with
the real directory which contains SOGo files:

* on i386 platform, it's `/usr/lib/GNUstep/SOGo`.
* on x86_64, it's `/usr/lib64/GNUstep/SOGo`.

## Start SOGo and dependent services

```
# service httpd restart     # <- restart 'nginx' service if you're running Nginx
# service memcached restart
# service sogod restart
```

## Add Dovecot Master User, used for vacation message expiration

SOGo need a Dovecot Master User to cleanup vacation expiration, please follow
our tutorial to add a Dovecot Master User for this purpose: [Dovecot Master User](./dovecot.master.user.html).

After added a Dovecot Master User for SOGo, we must store its username and
plain password in a separate file used by SOGo, we use `/etc/sogo/sieve.cred`
here for example.

Create file `/etc/sogo/sieve.cred`, write Dovecot Master User in this file in
format: `username:password`. For example:

```
my_master_user@non-exist.com:my_master_password
```

Set strict file owner and permission:

```
# chown sogo:sogo /etc/sogo/sieve.cred
# chmod 0400 /etc/sogo/sieve.cred
```

## Add required cron jobs

Please add below cron jobs for SOGo daemon user `sogo`. You can add them with
command: `crontab -l -u sogo`

```
# 1) SOGo email reminder, should be run every minute.
# 2) SOGo session cleanup, should be run every minute.
#    Ajust the [X]Minutes parameter to suit your needs
#    Example: Sessions without activity since 30 minutes will be dropped:
*   *   *   *   *   /usr/sbin/sogo-ealarms-notify; /usr/sbin/sogo-tool expire-sessions 30

# 3) SOGo vacation messages expiration
#    The credentials file should contain the sieve admin credentials (username:passwd)
0   0   *   *   *   /usr/sbin/sogo-tool expire-autoreply -p /etc/sogo/sieve.cred
```

## Access SOGo from web browser

Open your favourite web browser, access URL: `https://[your_server]/SOGo` (the
word `SOGo` is case-sensitive), you can login with your email account credential.

## Configure your mail clients or mobile devices to use CalDav/CardDAV services

Please check our documents [here](./index.html#configure-mail-client-applications)
to configure your mail clients or mobile devices.


## References

* [SOGo web site](http://sogo.nu)
* Outlook plugins:
    * [Outlook CalDav Synchronizer](https://github.com/aluxnimm/outlookcaldavsynchronizer)

        > Outlook Plugin, which synchronizes events, tasks and contacts(beta) between Outlook and Google, SOGo, Horde or any other CalDAV or CardDAV server. Supported Outlook versions are 2016, 2013, 2010 and 2007.
