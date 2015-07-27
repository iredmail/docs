# Upgrade iRedMail from 0.7.3 to 0.7.4

[TOC]

> We provide remote upgrade service, check [the price](../support.html) and [contact us](../contact.html).

## General (All backends should apply these upgrade steps)

### Fix incorrect per-user sieve_dir setting in Dovecot

__Note__: This fix is applicable to Dovecot-1.x, you can check Dovecot version
with command `dovecot -n`.

In `/etc/dovecot.conf` or `/etc/dovecot/dovecot.conf`, remove the last slash
(`/`) in setting `sieve_dir =` like below:

```
# Part of file: dovecot.conf

# Original setting:
#sieve_dir = /var/vmail/sieve/%Ld/%Ln/

# Change to:
sieve_dir = /var/vmail/sieve/%Ld/%Ln              # <-- Remove the last slash.
```

### Add indexes for Amavisd database

```
$ mysql -uroot -p
mysql> USE amavisd;
mysql> ALTER TABLE maddr ADD INDEX maddr_idx_email (email);
mysql> ALTER TABLE maddr ADD INDEX maddr_idx_domain (domain);
mysql> ALTER TABLE msgs ADD INDEX msgs_idx_content (content);
mysql> ALTER TABLE msgs ADD INDEX msgs_idx_content_time_num (content, time_num);
mysql> ALTER TABLE msgs ADD INDEX msgs_idx_mail_id (mail_id);
mysql> ALTER TABLE quarantine ADD INDEX quar_idx_mail_id (mail_id);
```

### [Debian and Ubuntu special] Assign Apache daemon user to group `adm`

__Note__: This fix is applicable to only Debian and Ubuntu.

Assign Apache daemon user to group `adm` to avoid Awstats cron job issue.

```
# usermod -g adm www-data
```

## OpenLDAP backend special

### Fix incorrect calculation of mailbox quota

There's a bug in iRedMail-0.7.3 and all earlier versions: Mailbox quota gets
calculated per user and per user alias account, so both email addresses get
their own mailbox quota usage. Here's the solution to fix it.

* Open `/etc/dovecot-ldap.conf` (on RHEL/CentOS/Scientific Linux) or
  `/etc/dovecot/dovecot-ldap.conf` (on Debian/Ubuntu/openSUSE) or
  `/usr/local/etc/dovecot-ldap.conf` (on FreeBSD), prepend `mail=user,` in both
  `user_attrs =` and `pass_attrs =` like below:

```
# Part of file: dovecot-ldap.conf

# Original settings:
#pass_attrs = userPassword=password
#user_attrs = homeDirectory=home,[...OMIT OTHER SETTINGS HERE...]

# Changed:
pass_attrs = mail=user,userPassword=password
user_attrs = mail=user,homeDirectory=home,[...OMIT OTHER SETTINGS HERE...]
```

Restarting Dovecot service is required.

## MySQL backend special

### Store realtime mailbox quota usage in seperate SQL table

In iRedMail-0.7.3 and some earlier versions, Dovecot stores realtime mailbox
quota usage in MySQL database in two columns: `mailbox.bytes`,
`mailbox.messages`, if they have invalid values (e.g. empty value, non-integer
value), Dovecot will update them with two SQL commands:

1. delete record with SQL: `DELETE FROM mailbox WHERE username='xxx@yyy.com'`
1. create a new record with current, correct quota info. SQL: `INSERT INTO mailbox (username, bytes, messages) VALUES ('xxx@yyy.com', xx, xx)`

As you can see, first sql command will delete iRedMail mail user, that's
critial issue. So we have to store realtime mailbox quota usage in a separate
MySQL table to avoid similar issues.

Below are steps to store realtime mailbox quota usage in a separate SQL table:

* Create new SQL table `vmail.used_quota` to store real-time mailbox quota and
  drop unused SQL columns: `mailbox.bytes`, `mailbox.messages`:
```
# mysql -uroot -p
mysql> USE vmail;
mysql> CREATE TABLE IF NOT EXISTS `used_quota` (
    `username` VARCHAR(255) NOT NULL,
    `bytes` BIGINT NOT NULL DEFAULT 0,
    `messages` BIGINT NOT NULL DEFAULT 0,
    PRIMARY KEY (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

mysql> ALTER TABLE mailbox DROP COLUMN bytes;
mysql> ALTER TABLE mailbox DROP COLUMN messages;
```

* Replace `table = mailbox` with `table = used_quota` in below config file,
  so that Dovecot will store mailbox quota in new SQL table. 

    * On RHEL/CentOS/Scientific Linux 5.x, please update `/etc/dovecot-used-quota.conf`, on 6.x, please update `/etc/dovecot/used-quota.conf`.
    * On Debian/Ubuntu, please update `/etc/dovecot/dovecot-used-quota.conf`.
    * On openSUSE, please update `/etc/dovecot/dovecot-used-quota.conf`.
    * On FreeBSD, please update `/usr/local/etc/dovecot-used-quota.conf`.

* Restarting Dovecot service is required.
