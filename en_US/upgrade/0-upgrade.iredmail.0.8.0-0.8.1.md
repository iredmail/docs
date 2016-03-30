# Upgrade iRedMail from 0.8.0 to 0.8.1

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](../support.html) and [contact us](../contact.html).

## ChangeLog

* 2012-06-14: Fix incorrect logrotate setting for iRedAPD on FreeBSD. Thanks openbsdnoob <w-chi _at_ gmx.de> for the report.
* 2012-06-06: Add new column `mailbox.language` in MySQL & PGSQL backends, used by iRedAdmin.
* 2012-05-22: Make per-user BCC settings have higher priority than per-domain settings.
* 2012-05-20: Add Dovecot share folder: anyone_shares.

## General (All backends should apply these upgrade steps)

### Update /etc/iredmail-release with iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
# File: /etc/iredmail-release

0.8.1
```

### Upgrade Roundcube webmail to the latest stable release

Please follow Roundcube official tutorial to upgrade Roundcube webmail to the
latest stable release immediately: [How to upgrade Roundcube](http://trac.roundcube.net/wiki/Howto_Upgrade)

### Upgrade iRedAPD (Postfix policy server) to the latest stable release

Please follow below tutorial to upgrade iRedAPD to the latest stable release:
[Upgrade iRedAPD to the latest stable release](./upgrade.iredapd.html)

### Upgrade iRedAdmin (open source edition) to the latest stable release

Please follow this tutorial to upgrade iRedAdmin open source edition to the
latest stable release: [Upgrade iRedAdmin to the latest stable release](./migrate.or.upgrade.iredadmin.html)

### Add missing auth service in Dovecot for Dovecot-2

__NOTE__: This is applicable to only Dovecot-2.x. You can check Dovecot version
and its main config file with command:

```
# dovecot -n | head -1
2.0.17 ...
```

* Edit `/etc/dovecot/dovecot.conf`, add service `auth-userdb` in section `service auth {}`:

```
# Part of file: dovecot.conf

service auth {
    ...
    unix_listener auth-userdb {
        user = vmail
        group = vmail
        mode = 0660
    }
}
```

* Restarting Dovecot service is required.

### Add missing config for IMAP share folder in Dovecot

__NOTE__: This is applicable to both Dovecot-1.2 and Dovecot-2.

* Edit `/etc/dovecot/dovecot-share-folder.conf`, append below lines:

    * The config file is `/etc/dovecot/share-folder.conf` if you're running old
      iRedMail versions, and it's `/usr/local/etc/dovecot/dovecot-share-folder.conf`
      on FreeBSD.

```
# Part of file: dovecot-share-folder.conf

# To share mailbox to anyone, please uncomment 'acl_anyone = allow' in          
# dovecot.conf
map {
    pattern = shared/shared-boxes/anyone/$from
    table = anyone_shares
    value_field = dummy
    fields {
        from_user = $from
    }
}
```

* Restarting Dovecot service is required.

Note: We will mention how to create required SQL table later in this upgrade tutorial.

### Rotate iRedAPD log file on FreeBSD and OpenBSD

__NOTE__: This fix is only applicable to FreeBSD and OpenBSD.

* For FreeBSD, please append below line to `/etc/newsyslog.conf` to rotate
  iRedAPD log file:

```
# Part of file: /etc/newsyslog.conf

/var/log/iredapd.log    root:wheel      640  7     *    24    Z /var/run/iredapd.pid
```

* For OpenBSD, please append below line to `/etc/newsyslog.conf` to rotate
  iRedAPD log file:

```
# Part of file: /etc/newsyslog.conf

/var/log/iredapd.log    root:wheel      640  7     *    24    Z "/etc/rc.d/iredapd restart"
```

Then restart syslogd service on either FreeBSD or OpenBSD:
```
# /etc/rc.d/syslogd restart
```

## OpenLDAP backend special

### Deliver emails to mail list members without `enabledService=smtp`

With default Postfix settings in iRedMail-0.7.4 and earlier versions, if a mail
user is not allowed to use SMTP service to send out email (without
`enabledService=smtp`), user cannot receive emails which delivered to the mail
lists which the user belongs to. Below steps fix this issue.

* Edit Postfix config file, `main.cf`, update `virtual_alias_maps` to replace
  `sender_login_maps.cf` by `virtual_group_members_maps.cf`:

    * On Linux and OpenBSD, it's `/etc/postfix/main.cf`.
    * On FreeBSD, it's `/usr/local/etc/postfix/main.cf`. And you should use
      `/usr/local/etc/postfix/ldap/virtual_group_members_maps.cf` in Postfix
      setting described below.

```
# Part of file: main.cf

# OLD SETTING
#virtual_alias_maps = ..., proxy:ldap:/etc/postfix/ldap/sender_login_maps.cf, ...

# NEW SETTING
virtual_alias_maps = ..., proxy:ldap:/etc/postfix/ldap/virtual_group_members_maps.cf, ...
```

* Create new file `virtual_group_members_maps.cf`:

    * Copy `sender_login_maps.cf` to `virtual_group_members_maps.cf`.
    * Edit `virtual_group_members_maps.cf`, replace `enabledService=smtp` by `enabledService=deliver` and save it.

```
# Part of file: virtual_group_members_maps.cf

# ---- OLD SETTING ----
#query_filter    = ...(enabledService=smtp)...

# ---- NEW SETTING ----
query_filter    = ...(enabledService=deliver)...
```

* Fix file permission:
```
# ---- On Linux and FreeBSD ----
# chown root:postfix virtual_group_members_maps.cf
# chmod 0640 virtual_group_members_maps.cf

# ---- On OpenBSD ----
# chown root:_postfix virtual_group_members_maps.cf
# chmod 0640 virtual_group_members_maps.cf
```

* Restarting Postfix service is required.

### Add new attribute/value required by IMAP share folder in Dovecot: `enabledService=lib-storage`

Note: This step is required in Dovecot-2.x, but you must apply it no matter
which Dovecot version you're running, so that it won't be an issue while you
upgrading from Dovecot-1.x to 2.x.

Dovecot-2.x requires `enabledService=lib-storage` for IMAP folder sharing.
Below steps are used to add it for all mail users.

* Download python script used to adding missing values.
```
# cd /root/
# wget https://bitbucket.org/zhb/iredmail/raw/cb7d2492563d/extra/update/updateLDAPValues_080_to_081.py
```

* Open `updateLDAPValues_080_to_081.py`, config LDAP server related settings in
  file head. e.g.

```
# Part of file: updateLDAPValues_080_to_081.py

uri = 'ldap://127.0.0.1:389'
basedn = 'o=domains,dc=iredmail,dc=org'
bind_dn = 'cn=vmailadmin,dc=iredmail,dc=org'
bind_pw = 'passwd'
```

You can find required LDAP credential in iRedAdmin config file or `iRedMail.tips`
file under your iRedMail installation directory. Using either
`cn=Manager,dc=xx,dc=xx` or `cn=vmailadmin,dc=xx,dc=xx` as bind dn is ok.

* Execute this script, it will add missing values for mail accounts:
```
# python updateLDAPValues_080_to_081.py
```

### Add missing SQL table `anyone_shares` in MySQL database `iredadmin`

If you want to share IMAP folder to anyone, you have to create new SQL table
`anyone_shares` in MySQL database `iredadmin`. Steps:

```
# mysql -uroot -p
sql> USE iredadmin;
sql> CREATE TABLE IF NOT EXISTS anyone_shares (
    from_user VARCHAR(255) NOT NULL,
    dummy CHAR(1) DEFAULT '1',
    PRIMARY KEY (from_user)
);
```

### Make per-user BCC settings have higher priority than per-domain settings

To make sure per-user BCC settings have higher priority than per-domain
settings, please edit Postfix main config file `main.cf`, reverse the lookup
maps in both `sender_bcc_maps` and `recipient_bcc_maps`.

    * On Linux and OpenBSD, it's `/etc/postfix/main.cf`.
    * On FreeBSD, it's `/usr/local/etc/postfix/main.cf`.

```
# Part of file: main.cf

# OLD SETTINGS
#recipient_bcc_maps = proxy:ldap:/etc/postfix/ldap/recipient_bcc_maps_domain.cf, proxy:ldap:/etc/postfix/ldap/recipient_bcc_maps_user.cf
#sender_bcc_maps = proxy:ldap:/etc/postfix/ldap/sender_bcc_maps_domain.cf, proxy:ldap:/etc/postfix/ldap/sender_bcc_maps_user.cf

# NEW SETTINGS
recipient_bcc_maps = proxy:ldap:/etc/postfix/ldap/recipient_bcc_maps_user.cf, proxy:ldap:/etc/postfix/ldap/recipient_bcc_maps_domain.cf
sender_bcc_maps = proxy:ldap:/etc/postfix/ldap/sender_bcc_maps_user.cf, proxy:ldap:/etc/postfix/ldap/sender_bcc_maps_domain.cf
```

## MySQL backend special

### Fix incorrect maildir path with 'virtual' transport

iRedMail uses Dovecot LDA as transport by default, but if you use transport
`virtual`, the Postfix built-in transport, it will use different maildir path
from Dovecot LDA. Below step is used to fix it.

* Edit `/etc/postfix/mysql/virtual_mailbox_maps.cf`, update `query =`:

```
# Part of file: mysql/virtual_mailbox_maps.cf

# OLD SETTING
#query       = SELECT CONCAT(mailbox.storagenode, '/', mailbox.maildir) FROM ...

# NEW SETTING
query       = SELECT CONCAT(mailbox.storagenode, '/', mailbox.maildir, '/Maildir/') FROM ...
```

* Restart Postfix service to make it use new setting.

### Make per-user BCC settings have higher priority than per-domain settings

To make sure per-user BCC settings have higher priority than per-domain
settings, please edit Postfix main config file `main.cf`, reverse the lookup
maps in both `sender_bcc_maps` and `recipient_bcc_maps`.

    * On Linux and OpenBSD, it's `/etc/postfix/main.cf`.
    * On FreeBSD, it's `/usr/local/etc/postfix/main.cf`.

```
# Part of file: main.cf

# OLD SETTINGS
#recipient_bcc_maps = proxy:mysql:/etc/postfix/mysql/recipient_bcc_maps_domain.cf, proxy:mysql:/etc/postfix/mysql/recipient_bcc_maps_user.cf
#sender_bcc_maps = proxy:mysql:/etc/postfix/mysql/sender_bcc_maps_domain.cf, proxy:mysql:/etc/postfix/mysql/sender_bcc_maps_user.cf

# NEW SETTINGS
recipient_bcc_maps = proxy:mysql:/etc/postfix/mysql/recipient_bcc_maps_user.cf, proxy:mysql:/etc/postfix/mysql/recipient_bcc_maps_domain.cf
sender_bcc_maps = proxy:mysql:/etc/postfix/mysql/sender_bcc_maps_user.cf, proxy:mysql:/etc/postfix/mysql/sender_bcc_maps_domain.cf
```

### Add new column required by IMAP share folder in Dovecot-2: `enablelib-storage=1`

Dovecot-2.x requires `mailbox.enablelib-storage=1` for IMAP folder sharing.
Below steps are used to add it for all mail users.

* Login to MySQL server as root user, execute SQL commands to add required
  column `mailbox.enablelib-storage`:

```
# mysql -uroot -p
sql> USE vmail;
sql> ALTER TABLE mailbox ADD COLUMN `enablelib-storage` TINYINT(1) NOT NULL DEFAULT 1;
sql> CREATE INDEX idx_mailbox_lib_storage ON mailbox (`enablelib-storage`);

-- Add missing index
sql> CREATE INDEX idx_mailbox_enabledoveadm ON mailbox (enabledoveadm);
```

* Update `/etc/dovecot/dovecot-mysql.conf`, add ``` (not single quote) around `enable%Ls%Lc`.

```
# Part of file: dovecot-mysql.conf

# OLD SETTING
#    AND mailbox.enable%Ls%Lc=1 \

# NEW SETTING
    AND mailbox.`enable%Ls%Lc`=1 \
```

### Add missing SQL table `anyone_shares` in MySQL database `vmail`

If you want to share IMAP folder to anyone, you have to create new SQL table
`anyone_shares` in MySQL database `vmail`. Steps:
```
# mysql -uroot -p
sql> USE vmail;
sql> CREATE TABLE IF NOT EXISTS anyone_shares (
    from_user VARCHAR(255) NOT NULL,
    dummy CHAR(1) DEFAULT '1',
    PRIMARY KEY (from_user)
);
```

### Add new column `language` in table `vmail.mailbox`

Column `mailbox.language` is used to store short code of user preferred
language used by iRedAdmin.

* Please login to MySQL server as root user, execute SQL commands to add
  required column `mailbox.language`:

```
# mysql -uroot -p
sql> USE vmail;
sql> ALTER TABLE mailbox ADD COLUMN language VARCHAR(5) NOT NULL DEFAULT 'en_US';
```

## PostgreSQL backend special

### Fix incorrect maildir path with 'virtual' transport

iRedMail uses Dovecot LDA as transport by default, but if you use transport
`virtual`, the Postfix built-in transport, it will use different maildir path
from Dovecot LDA. Below step is used to fix it.

* Edit `/etc/postfix/mysql/virtual_mailbox_maps.cf`, update `query =`:

```
# Part of file: mysql/virtual_mailbox_maps.cf

# OLD SETTING
#query       = SELECT (mailbox.storagenode || '/' || mailbox.maildir) FROM ...

# NEW SETTING
query       = SELECT CONCAT(mailbox.storagenode, '/', mailbox.maildir, '/Maildir/') FROM ...
```

* Restart Postfix service to make it use new setting.

### Make per-user BCC settings have higher priority than per-domain settings

To make sure per-user BCC settings have higher priority than per-domain
settings, please edit Postfix main config file `main.cf`, reverse the lookup
maps in both `sender_bcc_maps` and `recipient_bcc_maps`.

    * On Linux and OpenBSD, it's `/etc/postfix/main.cf`.
    * On FreeBSD, it's `/usr/local/etc/postfix/main.cf`.

```
# Part of file: main.cf

# OLD SETTINGS
#recipient_bcc_maps = proxy:pgsql:/etc/postfix/pgsql/recipient_bcc_maps_domain.cf, proxy:pgsql:/etc/postfix/pgsql/recipient_bcc_maps_user.cf
#sender_bcc_maps = proxy:pgsql:/etc/postfix/pgsql/sender_bcc_maps_domain.cf, proxy:pgsql:/etc/postfix/pgsql/sender_bcc_maps_user.cf

# NEW SETTINGS
recipient_bcc_maps = proxy:pgsql:/etc/postfix/pgsql/recipient_bcc_maps_user.cf, proxy:pgsql:/etc/postfix/pgsql/recipient_bcc_maps_domain.cf
sender_bcc_maps = proxy:pgsql:/etc/postfix/pgsql/sender_bcc_maps_user.cf, proxy:pgsql:/etc/postfix/pgsql/sender_bcc_maps_domain.cf
```

### Add new column required by IMAP share folder in Dovecot-2: `enablelib-storage=1`

Dovecot-2.x requires `mailbox.enablelib-storage=1` for IMAP folder sharing.
Below steps are used to add it for all mail users.

* Please switch to PostgreSQL daemon user, and execute SQL commands to add
  required column `mailbox.enablelib-storage`:

    * On Linux, the daemon user of PostgreSQL is `postgres`.
    * On FreeBSD, the daemon user of PostgreSQL is `pgsql`.
    * On OpenBSD, the daemon user of PostgreSQL is `_postgresql`.

```
# su - postgres
# psql -d vmail
sql> ALTER TABLE mailbox ADD COLUMN "enablelib-storage" INT2 NOT NULL DEFAULT 1;
sql> CREATE INDEX idx_mailbox_lib_storage ON mailbox ("enablelib-storage");

-- Add missing index
sql> CREATE INDEX idx_mailbox_enabledoveadm ON mailbox (enabledoveadm);

sql> GRANT SELECT ON mailbox TO vmail;
sql> GRANT SELECT,UPDATE,INSERT,DELETE ON mailbox to vmailadmin;
```

* Update `/etc/dovecot/dovecot-pgsql.conf`, add quotes for column `mailbox.enable%Ls%Lc`:

```
# Part of file: dovecot-pgsql.conf

# OLD SETTING
#    AND mailbox.enable%Ls%Lc=1 \

# NEW SETTING
    AND mailbox."enable%Ls%Lc"=1 \
```

### Add missing SQL table `anyone_shares` in PostgreSQL database `vmail`

If you want to share IMAP folder to anyone, you have to create new SQL table
`anyone_shares` in PostgreSQL database `vmail`. Steps:

    * On Linux, the daemon user of PostgreSQL is `postgres`.
    * On FreeBSD, the daemon user of PostgreSQL is `pgsql`.
    * On OpenBSD, the daemon user of PostgreSQL is `_postgresql`.

```
# su - postgres
# psql -d vmail
sql> CREATE TABLE anyone_shares (
    from_user VARCHAR(255) NOT NULL,
    dummy CHAR(1),
    PRIMARY KEY (from_user)
);
```

### Add new column `language` in table `vmail.mailbox`

Column `mailbox.language` is used to store short code of user preferred
language used by iRedAdmin.

* Please switch to PostgreSQL daemon user, and execute SQL commands to add
  required column `mailbox.language`:

    * On Linux, the daemon user of PostgreSQL is `postgres`.
    * On FreeBSD, the daemon user of PostgreSQL is `pgsql`.
    * On OpenBSD, the daemon user of PostgreSQL is `_postgresql`.

```
# su - postgres
# psql -d vmail
sql> ALTER TABLE mailbox ADD COLUMN language VARCHAR(5) NOT NULL DEFAULT 'en_US';
```
