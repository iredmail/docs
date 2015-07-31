# Upgrade iRedMail from 0.9.2 to 0.9.3

[TOC]

__This is still a DRAFT document, do NOT apply it.__

## ChangeLog

> We provide remote upgrade service, check [the price](../support.html) and [contact us](../contact.html).

* 2015-07-06: Add new SQL table `outbound_wblist` in `amavisd` database
* 2015-07-06: Amavisd: Fix incorrect setting which signs DKIM on inbound messages
* 2015-07-03: Dovecot: Fix incorrect quota warning priorities
* 2015-06-30: Dovecot-2.2: Add more special folders as alias folders.
* 2015-06-09: [OPTIONAL] Fixed: Not preserve the case of `${extension}` while delivering message to mailbox.

## General (All backends should apply these steps)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
# File: /etc/iredmail-release

0.9.3
```

### Upgrade iRedAPD (Postfix policy server) to the latest 1.7.0

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[How to upgrade iRedAPD-1.4.0 or later versions to the latest stable release](./upgrade.iredapd.html)

Detailed release notes are available here: [iRedAPD release notes](./iredapd.releases.html).

### Upgrade Roundcube webmail to the latest stable release

Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release immediately: [How to upgrade Roundcube](http://trac.roundcube.net/wiki/Howto_Upgrade)

### Amavisd: Fix incorrect setting which signs DKIM on inbound messages

In iRedMail-0.9.2 and earlier releases, Amavisd will signing DKIM on inbound
message, this is wrong. Please follow steps below to fix it.

With below changes, Amavisd will aply policy bank 'ORIGINATING' to emails
submitted through submission (port 587) by smtp authenticated user. This way
we clearly separate emails submitted by authenticated users and inbound message
sent by others, and Amavisd won't sign DKIM on inbound message anymore.

* Open Amavisd config file, make sure you have below settings. If they don't
  exist, please add them or update them.

    * on RHEL/CentOS: it's `/etc/amavisd/amavisd.conf`.
    * on Debian/Ubuntu: it's `/etc/amavis/conf.d/50-user`.
    * on FreeBSD: it's `/usr/local/etc/amavisd.conf`.
    * on OpenBSD: it's `/etc/amavisd.conf`.

```
$inet_socket_port = [10024, 10026, 9998];
$interface_policy{'10026'} = 'ORIGINATING';
```

We will configure Postfix to pipe email submitted by authenticated user through
port 10026, others through port 10024. And port 9998 is used to manage
quarantined mails.

* Find `$policy_bank{'ORIGINATING'} = {` block, comment out `forward_method`
  line in the block:

```
  #forward_method => 'smtp:[127.0.0.1]:10027',
```

* Comment out below line in Amavisd config file:

    __WARNING: Do NOT remove `originating => 1,` in other `$policy_bank` blocks.__

```
$originating = 1;
```

* Comment out the whole `$policy_bank{'MYUSERS'}` block:

```
#$policy_blank{'MYUSERS'} = {
#   ...
#}
```

* Restart Amavisd service.

* Open Postfix config file `/etc/postfix/master.cf` (Linux/OpenBSD) or
  `/usr/local/etc/postfix/master.cf` (FreeBSD), update transport `submission`
  to use `content_filter=smtp-amavis:[127.0.0.1]:10026` as content filter like
  below:

```
submission inet n       -       n       -       -       smtpd
  ... [omit other settings here] ...
  -o content_filter=smtp-amavis:[127.0.0.1]:10026
```

* Restart Postfix service.

### Dovecot: Fix incorrect quota warning priorities

iRedMail configures Dovecot to send warning message to local user when the
mailbox quota is 85%, 90% or 95% full, but the priorities is wrong. Please
fix it with steps below.

* Find below setting in Dovecot config file `/etc/dovecot/dovecot.conf`
  (Linux/OpenBSD) or `/usr/local/etc/dovecot/dovecot.conf` (FreeBSD):

```
    quota_warning = storage=85%% quota-warning 85 %u
    quota_warning2 = storage=90%% quota-warning 90 %u
    quota_warning3 = storage=95%% quota-warning 95 %u
```

`quota_warning` has the highest priority, `quota_warning3` has the lowest
priority. Only the command for the first exceeded limit is executed, so we must
configure the highest limit first.

With above setting, when the mailbox quota goes from 70% to 98% directly, it
sends warning message to notify user that the quota is 85% full, this is wrong,
it's expected to be warned as 95% full instead.

* Update them to below ones to fix it. Please pay close attention to the percent
  numbers:

```
    quota_warning = storage=95%% quota-warning 95 %u
    quota_warning2 = storage=90%% quota-warning 90 %u
    quota_warning3 = storage=85%% quota-warning 85 %u
```

Restart Dovecot service is required.

For more details, please read Dovecot document:
[Quota Configuration](http://wiki2.dovecot.org/Quota/Configuration)

### Dovecot-2.2: Add more special folders as alias folders

Note: This is applicable to Dovecot-2.2.x. if you're running Dovecot-2.1.x or
earlier versions, please skip this step.

Check Dovecot version number with below command first:

```bash
# dovecot --version
```

Open Dovecot config file `/etc/dovecot/dovecot.conf` (Linux/OpenBSD) or
`/usr/local/etc/dovecot/dovecot.conf` (FreeBSD), find below setting:

```
namespace {
    type = private
    ...
    inbox = yes
    ...
}
```

Add below alias folders inside the same `namespace {}` block:

```
    mailbox "Sent Items" {
        auto = no
        special_use = \Sent
    }

    mailbox "Deleted Messages" {
        auto = no
        special_use = \Trash
    }

    mailbox "Deleted Messages" {
        auto = no
        special_use = \Trash
    }

    # Archive
    mailbox Archive {
        auto = subscribe
        special_use = \Archive
    }
    mailbox Archives {
        auto = no
        special_use = \Archive
    }
```

Restart Dovecot service is required.

### [OPTIONAL] Fixed: Not preserve the case of `${extension}` while delivering message to mailbox

With iRedMail-0.9.2 and earlier releases, email sent to user
`username+Ext@domain.com` (upper case `E`) will be delivered to folder
`ext` (lower case `e`) of `username@domain.com`'s mailbox. This fix will
preserve the case of address extension.

* Open file `/etc/postfix/master.cf` (Linux/OpenBSD) or
  `/usr/local/etc/postfix/master.cf` (FreeBSD), find below lines:

```
# Use dovecot deliver program as LDA.
dovecot unix    -       n       n       -       -      pipe
    flags=DRhu ...
```

* Replace `flags=DRhu` by `flags=DRh` (remove `u`) in the third line:

```
    flags=DRh ...
```

* Save your change and restart Postfix service.

## OpenLDAP backend special

### Fixed: Dovecot Master User doesn't work with ACL plugin

iRedMail has both Dovecot Master User and Dovecot `acl` plugin enabled by
default, if `acl` plugin is enabled, the Master User is still subject to ACLs
just like any other user, which means that by default the Master User has no
access to any mailboxes of the user. Please fix this issue by following steps
below.

* Open file `/etc/dovecot/dovecot-ldap.conf` (Linux/OpenBSD) or
  `/usr/local/etc/dovecot/dovecot-ldap.conf` (FreeBSD), find below line:

```
user_attrs      = mail=user, ...
```

* Add new setting `mail=master_user` in `user_attrs` like below:

```
user_attrs      = mail=master_user,mail=user, ...
```

* Restart Dovecot service.

### Add new SQL table `outbound_wblist` in `amavisd` database

We need a new SQL table `outbound_wblist` in `amavisd` database, it's used
to store white/blacklists for outbound message, required by iRedAPD plugin
`amavisd_wblist`.

Please connect to MySQL server as MySQL root user, create new table:

```
$ mysql -uroot -p
mysql> USE amavisd;
mysql> CREATE TABLE outbound_wblist (rid integer unsigned NOT NULL, sid integer unsigned NOT NULL, wb varchar(10) NOT NULL, PRIMARY KEY (rid,sid));
```

After table created, please restart iRedAPD service.

## MySQL/MariaDB backend special

### Add new SQL table `outbound_wblist` in `amavisd` database

We need a new SQL table `outbound_wblist` in `amavisd` database, it's used
to store white/blacklists for outbound message, required by iRedAPD plugin
`amavisd_wblist`.

Please connect to MySQL server as MySQL root user, create new table:

```
$ mysql -uroot -p
mysql> USE amavisd;
mysql> CREATE TABLE outbound_wblist (rid integer unsigned NOT NULL, sid integer unsigned NOT NULL, wb varchar(10) NOT NULL, PRIMARY KEY (rid,sid));
```

After table created, please restart iRedAPD service.

## PostgreSQL backend special

### Add new SQL table `outbound_wblist` in `amavisd` database

We need a new SQL table `outbound_wblist` in `amavisd` database, it's used
to store white/blacklists for outbound message, required by iRedAPD plugin
`amavisd_wblist`.

Please switch to PostgreSQL daemon user, then execute SQL commands to import it:

    * On Linux, PostgreSQL daemon user is `postgres`.
    * On FreeBSD, PostgreSQL daemon user is `pgsql`.
    * On OpenBSD, PostgreSQL daemon user is `_postgresql`.

```
# su - postgres
$ psql -d cluebringer -d amavisd
sql> CREATE TABLE outbound_wblist (rid integer NOT NULL CHECK (rid >= 0), sid integer NOT NULL CHECK (sid >= 0), wb varchar(10) NOT NULL, PRIMARY KEY (rid,sid));
```

After table created, please restart iRedAPD service.
