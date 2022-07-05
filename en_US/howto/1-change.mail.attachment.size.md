# Change mail attachment size

[TOC]

Mail attachment size is configured in multiple places with default iRedMail settings:

- Postfix is the MTA, it checks the size of each received and sent message.
- Dovecot is the LDA (local delivery agent), it checks mailbox size (a.k.a. mailbox quota)
- Nginx / Apache is web server, if you upload mail attachment via webmail, web
  server checks the size of uploaded mail attachment.
- Roundcube webmail, SOGo have their own message size limit settings, but
  they're not enabled by iRedMail by default, so they use web server upload
  size instead.
- Desktop mail client application like Outlook may have its own message size
  limit.

## Change message size limit in postfix

Postfix is MTA, so we have to change its setting to transfer mail with large
attachment.

For example, to allow mail with 100Mb attachment, please change both
`message_size_limit` and `mailbox_size_limit` settings like below:

```
# postconf -e message_size_limit=104857600
# postconf -e mailbox_size_limit=104857600
```

!!! note

    * They don't have to be same. but `mailbox_size_limit` (size of the mailbox)
      MUST be equal to or LARGER than `message_size_limit` (size of single email
      message).
    * Postfix is configured to pipe received email to Dovecot for local mail
      delivery, so the `mailbox_size_limit` setting is not used, but we still
      need this setting to surpress Postfix warning while starting Postfix
      service.

Restart postfix to make it work:

```
# /etc/init.d/postfix restart
```

__NOTES__:

* `104857600` is 100 (MB) x 1024 (KB) x 1024 (Byte).
* Mail will be encoded by mail user agent (Outlook, Thunderbird, etc) before
  transferred, the actual message size will be larger than 100MB, you can
  simplily increase above setting to 110Mb or 120Mb to make it work as expected.
* If `mailbox_size_limit` is smaller than `message_size_limit`, you will get
  error message in Postfix log file like this: `fatal: main.cf configuration
  error: mailbox_size_limit is smaller than message_size_limit`.

If you use mail clients such as Outlook, thunderbird to send mails, it's now
ok to sent large attachment with above setting.

## Change message size limit in iRedAPD

> * iRedAPD is a Postfix policy server developed and maintained by iRedMail team.
> * With default iRedMail setting, no message size limit is set.
> * For more details, please check tutorial: [Manage iRedAPD](./manage.iredapd.html).

With plugin `throttle` enabled in iRedAPD config file (`/opt/iredapd/settings.py`),
iRedAPD will query throttle settings from SQL database (SQL table `iredapd.throttle`),
if there's a global, per-domain or per-user message size limit set for sender
or recipient, it will performs the check.

Both Postfix and iRedAPD check the size of single message, if the message size reaches
the limit of either Postfix setting or iRedAPD throttle setting, the email will
be rejected.

You can set the throttle with iRedAdmin-Pro, or with SQL command tool, for more
details, please check plugin source file, it's documented with examples and
explanation: [Throttle plugin](https://github.com/iredmail/iRedAPD/blob/master/plugins/throttle.py).

If you have Roundcube webmail, please change two more settings:

## Change PHP settings to upload large file

Please also update PHP config file `php.ini` to allow uploading large file:

* on RHEL/CentOS: it's `/etc/php.ini`
* on Debian/Ubuntu, it's `/etc/php/<7.x>/fpm/php.ini` (Please replace `<7.x>`
  by the real version number on your server).
    * on Ubuntu 16.04 and later releases, it's `/etc/php/7.0/apache2/php.ini`
      for Apache, or `/etc/php/7.0/fpm/php.ini` for Nginx + php-fpm.
* on FreeBSD, it's `/usr/local/etc/php.ini` for Apache, or
  `/etc/php5/fpm/php.ini` for Nginx.
* on OpenBSD, it's `/etc/php-5.4.ini`. If you're running different PHP release,
  the version number `5.4` will be different.

```
memory_limit = 200M;
upload_max_filesize = 100M;
post_max_size = 100M;
```

Note:

* If you're running Nginx as web server, restarting php-fpm service is required.
* If you're running Apache as web server, restarting Apache service is required.

## Roundcube webmail

Roundcube 1.3.0 and later releases use its own setting `max_message_size` to
limit message size, please add or update this parameter in its config file:

* on RHEL/CentOS, it's `/opt/www/roundcubemail/config/config.inc.php`.
  Old iRedMail releases use `/var/www/roundcubemail/config/config.inc.php`.
* on Debian/Ubuntu, it's `/opt/www/roundcubemail/config/config.inc.php`.
  Old iRedMail releases use `/usr/share/apache2/roundcubemail/config.inc.php`.
* on FreeBSD, it's `/usr/local/www/roundcubemail/config/config.inc.php`
* on OpenBSD, it's `/opt/www/roundcubemail/config/config.inc.php`.
  Old iRedMail releases use `/var/www/roundcubemail/config.inc.php`.

```
$config['max_message_size'] = '100M';
```

Note: Roundcube preserves some percentage of the max message size
(search `1.33` on [this page](https://github.com/roundcube/roundcubemail/blob/master/program/actions/mail/compose.php#L1484), so if you set the max to `100M`, it tells you only `75MB` is
allowed (`100 / 1.33`). This is better because email messsage will be encoded
before sending to MTA and the encoded attachment is larger than the original file.

## Change upload file size in Nginx

Find setting `client_max_body_size` in Nginx config file
`/etc/nginx/conf-enabled/client_max_body_size.conf`, change the size to a
proper value to match your need.

!!! attention

    Old iRedMail releases set this parameter in `/etc/nginx/nginx.conf`.

```
client_max_body_size 100m;
```

Reloading or restarting Nginx service is required.

## Change file size limits in SOGo

SOGo config file is `/etc/sogo/sogo.conf` (Linux/OpenBSD) or
`/usr/local/etc/sogo/sogo.conf` (FreeBSD), 2 settings are relevant to message size:

* SOGo-3.x introduces parameter `WOMaxUploadSize` to limit upload file size.
* SOGo-3.2.5 introduces parameter `SOGoMaximumMessageSizeLimit` to limit single
  message size.

```
    // set the maximum allowed size for content being sent to SOGo using a PUT or
    // a POST call. This can also limit the file attachment size being uploaded
    // to SOGo when composing a mail.
    //
    //  - The value is in kilobyte.
    //  - By default, the value is 0, or disabled so no limit will be set.
    WOMaxUploadSize = 102400;

    // Parameter used to set the maximum allowed email message size when
    // composing a mail.
    // The value is in kilobytes. By default, the value is 0, or disabled so
    // no limit will be set.
    SOGoMaximumMessageSizeLimit = 102400;
```

Restarting SOGo service is required if you changed any setting in SOGo config file.

## Change attachment size limit in Microsoft Outlook

Outlook has its own attachment size limit, and will raise error like `The
attachment size exceeds the allowable limit.`

To modify the default attachment limit size in Outlook on Windows system,
follow these steps:

* Exit Outlook.
* Start Registry Editor.
* Locate and then select one of the following registry subkeys:
    * Manually create the path in the registry if it does not currently exist.
    * `14.01 means Outlook version number, it may be different on your system.

```
HKEY_CURRENT_USER\Software\Microsoft\Office\14.0\Outlook\Preferences
HKEY_CURRENT_USER\Software\Policies\Microsoft\Office\14.0\Outlook\Preferences
```

* Add the following registry data under this subkey:

    * Value type: DWORD
    * Value name: MaximumAttachmentSize
    * Value data: An integer that specifies the total maximum allowable
      attachment size. For example, specify 30720 (Decimal) to configure a
      30-MB limit.

    Notes:

    * Specify a value of zero (0) if you want to configure no limit for attachments.
    * Specify a value that is less than 20 MB if you want to configure a limit
      that is less than the default 20 MB.

* Exit Registry Editor
* Start Outlook.

Reference: <https://support.microsoft.com/en-us/kb/2222370>
