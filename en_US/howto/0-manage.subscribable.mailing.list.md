# Manage subscribable mailing list

[TOC]

## Summary

iRedMail-0.9.8 integrates [mlmmj](http://mlmmj.org) as mailing list manager.
"Although it doesn't aim to include every feature possible, but focuses on
staying mean and lean, and doing what it does do well, it does have a great
set of features, including:"

* Archive
* Custom headers / footer
* Fully automated bounce handling (similar to ezmlm)
* Complete requeueing functionality
* Moderation functionality
* Subject prefix
* Subscribers only posting
* Regular expression access control
* Functionality to retrieve old posts
* Digests
* No-mail subscription
* VERP support
* Delivery Status Notification (RFC1891) support
* Rich, customisable texts for automated operations

For more details about mlmmj, please visit [mlmmj website](http://mlmmj.org).

## Default settings on iRedMail server

* mlmmj doesn't have a global config file.
* Data (archive, configurations, etc) of mailing lists are stored under
  `/var/vmail/mlmmj` by default. For example: mailing list `newsletter@mydomain.com`:
    * Archived messages are stored under `/var/vmail/mlmmj/mydomain.com/newsletter/archive/`.
    * Normal subscribers are stored under
      `/var/vmail/mlmmj/mydomain.com/newsletter/subscribers.d/`, file `a` under
      this directory contains all subscribers whose email addresses start with
      letter `a`.

## Manage mailing lists with command line tools

iRedMail team develops a HTTP RESTful API server called `mlmmjadmin` to help
manage mlmmj mailing lists:

* It's installed under `/opt/mlmmjadmin`, which is a symbol link to
  `/opt/mlmmjadmin-<version>`.
* It listens on address `127.0.0.1`, port `7779` by default.
* It's written in Python programming language, full source code is
  hosted on github: <https://github.com/iredmail/mlmmjadmin>. Feel free to fork
  it and send us pull requests to improve it.

### Create a mailing list

Let's say you have mail domain `mydomain.com` hosted on iRedMail server,
now let's create mailing list `newsletter@mydomain.com` from command line:

```
cd /opt/mlmmjadmin/tools/
python maillist_admin.py create newsletter@mydomain.com
```

You can create mailing list with extra options, for example:

```
python maillist_admin.py create newsletter@mydomain.com name='Support Team' disable_archive=no
```

* All options are listed in file `/opt/mlmmjadmin/docs/API.md` on your server.
* You can specify as many (different) options as you want.

### View mailing list settings

To view mailing list settings, use the `info` argument like below:

```
python maillist_admin.py info newsletter@mydomain.com
```

### Update an existing mailing list

To update existing mailing list, use the `update` argument like below:

```
python maillist_admin.py update newsletter@mydomain.com name='Updated name' disable_archive=yes
```

All options are listed in file `/opt/mlmmjadmin/docs/API.md` on your server.

### Delete an existing mailing list

To delete an existing mailing list, use the `delete` argument like below:

```
python maillist_admin.py delete newsletter@mydomain.com
```

### List all members/subscribers

To delete an existing mailing list, use the `subscribers` argument like below:

```
python maillist_admin.py subscribers newsletter@mydomain.com
```

### Check whether mailing list has given member/subscriber

To check whether mailing list has given member/subscriber, use the
`has_subscriber` argument like below:

```
python maillist_admin.py has_subscriber newsletter@mydomain.com subscriber@gmail.com
```

### Check all subscribed mailing lists of a given member/subscriber

To check all subscribed mailing lists of a given member/subscriber, use the
`subscribed` argument like below:

```
python maillist_admin.py subscribed subscriber@gmail.com
```

## How to subscribe to or unsubscribe from a mailing list

* To subscribe to mailing list `newsletter@mydomain.com`, simply send an email
  to address `newsletter+subscribe@mydomain.com` (content of mail subject and
  body don't matter at all), you will receive an email for subscription
  confirmation. Simply reply the confirm email with any subject/body will
  confirm your subscription.

* To unsubscribe from mailing list `newsletter@mydomain.com`, simply send an
  email to address `newsletter+unsubscribe@mydomain.com` (content of mail
  subject and body don't matter at all), you will receive an email for
  unsubscription confirm, simply reply the confirm email with any subject/body
  will confirm your unsubscription.
