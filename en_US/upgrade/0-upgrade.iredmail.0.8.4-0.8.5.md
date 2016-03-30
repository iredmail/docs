# Upgrade iRedMail from 0.8.4 to 0.8.5

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](../support.html) and [contact us](../contact.html).

## ChangeLog

* 2013-07-14: First public release.
* 2013-06-27: [All backends] Add new SQL table: deleted_mailboxes. Used to store maildir path of removed mail user, used in iRedAdmin-Pro.
* 2013-06-08: [All backends] Add SQL trigger for table `used_quota`.
* 2013-06-08: [MySQL/PostgreSQL] Add 2 new columns on table `vmail.domain`: `disableddomainprofiles`, `disableduserprofiles`. Used in iRedAdmin-Pro.
* 2013-05-17: [ldap] Support assigning mail list/alias as member of another mailing list.
* 2013-05-12: [all backends] Fix incorrect Amavisd SQL column name: policy.unchecked_lovers_maps (incorrect one) -> policy.unchecked_lover.
* 2013-04-26: [ldap] Fix incorrect ACL for attribute `memberOfGroup`.
* 2013-04-03: [ldap] Use the latest iRedMail LDAP schema file.
* 2013-04-03: [MySQL/PostgreSQL] Add one new column used for store preferred language for newly created mail users.  Used in iRedAdmin-Pro.

## General (All backends should apply these steps)

### Update /etc/iredmail-release with iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
# File: /etc/iredmail-release

0.8.5
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

## OpenLDAP backend special

### Use the latest LDAP schema file provided by iRedMail

With the latest LDAP schema file, we can:

* use attribute `preferredLanguage` for mail domain object, it's used to
  storage short language code (e.g. de_DE, en_US) for newly created mail users.
* Assign mail list/alias as member of another mailing list.

Steps to use the latest LDAP schema file are:

* Download the newest iRedMail ldap schema file
* Copy old ldap schema file as a backup copy
* Replace the old one
* Restart OpenLDAP service.

Here we go:

* On RHEL/CentOS/Scientific Linux (both release 5.x and 6.x), openSUSE, Gentoo, OpenBSD:

```
# cd /tmp
# wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/iredmail.schema

# cd /etc/openldap/schema/
# cp iredmail.schema iredmail.schema.bak

# cp -f /tmp/iredmail.schema /etc/openldap/schema/
# /etc/init.d/slapd restart       # <-- Or: /etc/init.d/ldap restart
```

* On Debian/Ubuntu:
```
# cd /tmp
# wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/iredmail.schema

# cd /etc/ldap/schema/
# cp iredmail.schema iredmail.schema.bak

# cp -f /tmp/iredmail.schema /etc/ldap/schema/
# /etc/init.d/slapd restart
```

* On FreeBSD:

```
# cd /tmp
# wget https://bitbucket.org/zhb/iredmail/raw/default/iRedMail/samples/iredmail.schema

# cd /usr/local/etc/ldap/schema/
# cp iredmail.schema iredmail.schema.bak

# cp -f /tmp/iredmail.schema /usr/local/etc/openldap/schema/
# /etc/init.d/slapd restart
```

### Fix incorrect ACL for attribute `memberOfGroup`

Permission for attribute `memberOfGroup` is not set correctly, it causes normal
user can add himself to any mail list in LDAP. Default permission is writeable
by self, it should be "read" by "self" instead.

* Open OpenLDAP config file `slapd.conf`, find below lines:

    * On RHEL/CentOS, openSUSE, Gentoo, OpenBSD, it's `/etc/openldap/slapd.conf`.
    * On Debian/Ubuntu, it's `/etc/ldap/slapd.conf`.
    * On FreeBSD, it's `/usr/local/etc/openldap/slapd.conf`.

```
# Part of file: slapd.conf

# User attrs.
access to attrs="employeeNumber, ..."
```

* Prepend attribute name `memberOfGroup` before `employeeNumber`. The final
  result looks like below:

```
# Part of file: slapd.conf

# User attrs.
# WARNING: No space in attr list.
access to attrs="memberOfGroup,employeeNumber,..."
```

* Save the config file, then restart OpenLDAP service to make it use new ACL.

    * On RHEL/CentOS 5, openSUSE, please restart it with command <pre># /etc/init.d/ldap restart</pre>
    * On RHEL/CentOS 6 and other Linux distribution, please restart it with command: <pre># /etc/init.d/slapd restart</pre>
    * On FreeBSD, please restart it with command: <pre># /usr/local/etc/rc.d/slapd restart</pre>
    * On OpenBSD, please restart it with command: <pre># /etc/rc.d/slapd restart</pre>

### Support assigning mail list/alias as member of another mailing list

* Open Postfix ldap lookup file `/etc/postfix/ldap/virtual_group_maps.cf` (or `/usr/local/etc/postfix/ldap/virtual_group_maps.cf` on FreeBSD), update the value of `query_filter` parameter to add additional LDAP objectclasses:

```
# Part of file: /etc/postfix/ldap/virtual_group_maps.cf

# OLD SETTING
#query_filter    = (&(accountStatus=active)(enabledService=mail)(enabledService=deliver)(|(memberOfGroup=%s)(shadowAddress=%s))(|(objectClass=mailUser)(objectClass=mailExternalUser)))

# NEW SETTING
query_filter    = (&(accountStatus=active)(enabledService=mail)(enabledService=deliver)(|(&(|(memberOfGroup=%s)(shadowAddress=%s))(objectClass=mailUser))(&(memberOfGroup=%s)(!(shadowAddress=%s))(|(objectClass=mailExternalUser)(objectClass=mailList)(objectClass=mailAlias)))))
```

* Restart Postfix service to use our new setting.

    * On Linux: ```# /etc/init.d/postfix restart```
    * On FreeBSD: ```# /usr/local/etc/rc.d/postfix restart```
    * On OpenBSD: ```# /etc/rc.d/postfix restart```

### Fix incorrect SQL column name in Amavisd database

NOTE: This fix is applicable to Amavisd-new-2.7 and later versions, not
applicable to Amavisd-new-2.6 and earlier versions.

Amavisd-new-2.7.1 fixes a SQL column name `policy.unchecked_lover`, previously
incorrectly specified as `policy.unchecked_lovers_maps`;

Please login to MySQL server as root user, execute SQL commands to fix
incorrect column name:

```
# mysql -uroot -p
mysql> USE amavisd;
mysql> ALTER TABLE policy CHANGE unchecked_lovers_maps unchecked_lover CHAR(1) DEFAULT NULL;
```

### Add SQL trigger in MySQL database: `iredadmin`

With OpenLDAP backend, Dovecot stores real-time mailbox quota in MySQL table
`iredadmin.used_quota`. But it's hard to calculate per-domain used mailbox
quota, so we add a SQL trigger to set domain name while Dovecot inserting new
record for mail user.

* Please save below SQL command in a plain text file. For example, `/root/trigger.sql`:

```
ALTER TABLE used_quota ADD COLUMN domain VARCHAR(255) NOT NULL DEFAULT '';
ALTER TABLE used_quota ADD INDEX (domain);

DELIMITER $$
CREATE TRIGGER `after_insert_used_quota` BEFORE INSERT ON `used_quota` FOR EACH ROW
    BEGIN
        SET NEW.domain = SUBSTRING_INDEX(NEW.username, '@', -1);
    END;
$$
DELIMITER ;

UPDATE used_quota SET domain = SUBSTRING_INDEX(username, '@', -1);
```

* Now login to MySQL database as MySQL `root` user, then execute below command
to add required SQL trigger:

```
# mysql -uroot -p
mysql> USE iredadmin;
mysql> SOURCE /root/trigger.sql;
```

That's all.

### Add new table in MySQL database: `iredadmin`

We need a new SQL table to store maildir path of removed mail user, so that you
can delete his/her mailbox manually or with a cron job.

* Please save below SQL command in a plain text file. For example, `/root/deleted_mailboxes.sql`:

```
CREATE TABLE IF NOT EXISTS `deleted_mailboxes` (
    `id` BIGINT(20) UNSIGNED AUTO_INCREMENT,
    `timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- Email address of deleted user
    `username` VARCHAR(255) NOT NULL DEFAULT '',
    -- Domain part of user email address
    domain VARCHAR(255) NOT NULL DEFAULT '',
    -- Absolute path of user's mailbox
    `maildir` TEXT NOT NULL DEFAULT '',
    -- Which domain admin deleted this user
    `admin` VARCHAR(255) NOT NULL DEFAULT '',
    KEY id (id),
    INDEX (timestamp),
    INDEX (username),
    INDEX (domain),
    INDEX (admin)
) ENGINE=MyISAM;
```

* Now login to MySQL database as MySQL `root` user, then execute below command to add required SQL table:

```
# mysql -uroot -p
mysql> USE iredadmin;
mysql> SOURCE /root/deleted_mailboxes.sql;
```

That's all.

## MySQL backend special

### Add new SQL columns in vmail database

* New column `domain.defaultlanguage`, used to storage short language code (e.g. de_DE, en_US) for newly created mail users. It's used in iRedAdmin-Pro.
* New column `domain.disableddomainprofiles`, used to store per-domain disabled domain profiles. It's used in iRedAdmin-Pro, global admin can select which profiles are disabled in domain profile page, and normal domain admin cannot view and update disabled domain profiles in domain profile page.
* New column `domain.disableduserprofiles`, used to store per-domain disabled user profiles. It's used in iRedAdmin-Pro, global admin can select which profiles are disabled in domain profile page, and normal domain admin cannot view and update disabled user profiles in user profile page.

Please login to MySQL server as root user, execute SQL commands to add required columns and indexes.

```
# mysql -uroot -p
mysql> USE vmail;
mysql> ALTER TABLE domain ADD COLUMN defaultlanguage VARCHAR(5) NOT NULL DEFAULT 'en_US';
mysql> ALTER TABLE domain ADD COLUMN disableddomainprofiles VARCHAR(255) NOT NULL DEFAULT '';
mysql> ALTER TABLE domain ADD COLUMN disableduserprofiles VARCHAR(255) NOT NULL DEFAULT '';
```

No INDEX is required for those 3 new columns.

### fix incorrect column name in Amavisd database

NOTE: This fix is applicable to Amavisd-new-2.7 and later versions, not applicable to Amavisd-new-2.6 and earlier versions.

Amavisd-new-2.7.1 fixes a SQL column name "policy.unchecked_lover", previously incorrectly specified as "policy.unchecked_lovers_maps";

```
# mysql -uroot -p
mysql> USE amavisd;
mysql> ALTER TABLE policy CHANGE unchecked_lovers_maps unchecked_lover CHAR(1) DEFAULT NULL;
```

### Add SQL trigger in MySQL database `vmail`

With MySQL backend, Dovecot stores real-time mailbox quota in MySQL table
`vmail.used_quota`. But it's hard to calculate per-domain used mailbox quota,
so we add a SQL trigger to set domain name while Dovecot inserting new record
for mail user.

* Please save below SQL command in a plain text file. For example, `/root/trigger.sql`:

```
ALTER TABLE used_quota ADD COLUMN domain VARCHAR(255) NOT NULL DEFAULT '';
ALTER TABLE used_quota ADD INDEX (domain);

DELIMITER $$
CREATE TRIGGER `after_insert_used_quota` BEFORE INSERT ON `used_quota` FOR EACH ROW
    BEGIN
        SET NEW.domain = SUBSTRING_INDEX(NEW.username, '@', -1);
    END;
$$
DELIMITER ;

UPDATE used_quota SET domain = SUBSTRING_INDEX(username, '@', -1);
```

Now login to MySQL database as MySQL `root` user, then execute below command to add required SQL trigger:

```
# mysql -uroot -p
mysql> USE vmail;
mysql> SOURCE /root/trigger.sql;
```

That's all.

### Add new table in MySQL database: `vmail`

We need a new SQL table to store maildir path of removed mail user, so that you
can delete his/her mailbox manually or with a cron job.

* Please save below SQL command in a plain text file. For example, `/root/deleted_mailboxes.sql`:

```
CREATE TABLE IF NOT EXISTS `deleted_mailboxes` (
    `id` BIGINT(20) UNSIGNED AUTO_INCREMENT,
    `timestamp` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- Email address of deleted user
    `username` VARCHAR(255) NOT NULL DEFAULT '',
    -- Domain part of user email address
    domain VARCHAR(255) NOT NULL DEFAULT '',
    -- Absolute path of user's mailbox
    `maildir` TEXT NOT NULL DEFAULT '',
    -- Which domain admin deleted this user
    `admin` VARCHAR(255) NOT NULL DEFAULT '',
    KEY id (id),
    INDEX (timestamp),
    INDEX (username),
    INDEX (domain),
    INDEX (admin)
) ENGINE=MyISAM;
```

* Now login to MySQL database as MySQL `root` user, then execute below command
  to add required SQL table:

```
# mysql -uroot -p
mysql> USE vmail;
mysql> SOURCE /root/deleted_mailboxes.sql;
```

That's all.

## PostgreSQL backend special

### Add new SQL columns in vmail database

* New column `domain.defaultlanguage`, used to storage short language code (e.g. de_DE, en_US) for newly created mail users. It's used in iRedAdmin-Pro.
* New column `domain.disableddomainprofiles`, used to store per-domain disabled domain profiles. It's used in iRedAdmin-Pro, global admin can select which profiles are disabled in domain profile page, and normal domain admin cannot view and update disabled domain profiles in domain profile page.
* New column `domain.disableduserprofiles`, used to store per-domain disabled user profiles. It's used in iRedAdmin-Pro, global admin can select which profiles are disabled in domain profile page, and normal domain admin cannot view and update disabled user profiles in user profile page.

Please switch to PostgreSQL daemon user, then execute SQL commands to add required columns and indexes:

* On Linux, PostgreSQL daemon user is `postgres`.
* On FreeBSD, PostgreSQL daemon user is `pgsql`.
* On OpenBSD, PostgreSQL daemon user is `_postgresql`.

```
# su - postgres
$ psql -d vmail
sql> ALTER TABLE domain ADD COLUMN defaultlanguage VARCHAR(5) NOT NULL DEFAULT 'en_US';
sql> ALTER TABLE domain ADD COLUMN disableddomainprofiles VARCHAR(255) NOT NULL DEFAULT '';
sql> ALTER TABLE domain ADD COLUMN disableduserprofiles VARCHAR(255) NOT NULL DEFAULT '';
```

No INDEX is required for these 3 new columns.

### Fix incorrect column name in Amavisd database

NOTE: This fix is applicable to Amavisd-new-2.7 and later versions, not
applicable to Amavisd-new-2.6 and earlier versions.

Amavisd-new-2.7.1 fixes a SQL column name `policy.unchecked_lover`, previously
incorrectly specified as `policy.unchecked_lovers_maps`.

```
# su - postgres
$ psql -d amavisd
sql> ALTER TABLE policy RENAME unchecked_lovers_maps TO unchecked_lover;
```

### Add SQL trigger in PostgreSQL database: `vmail`

With PostgreSQL backend, Dovecot stores real-time mailbox quota in PostgreSQL
database `vmail`, table `used_quota`. But it's hard to calculate per-domain
used mailbox quota, so we add a SQL trigger to set domain name while Dovecot
inserting new record for mail user.

* Please save below SQL command in a plain text file. For example,
`/tmp/trigger.sql` (This file must be readable by PostgreSQL daemon user):

```
ALTER TABLE used_quota ADD COLUMN domain VARCHAR(255) NOT NULL DEFAULT '';
CREATE INDEX idx_used_quota_domain ON used_quota (domain);

DROP TRIGGER mergequota ON used_quota;
CREATE OR REPLACE FUNCTION merge_quota() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.messages < 0 OR NEW.messages IS NULL THEN
        -- ugly kludge: we came here from this function, really do try to insert
        IF NEW.messages IS NULL THEN
            NEW.messages = 0;
        ELSE
            NEW.messages = -NEW.messages;
        END IF;
        return NEW;
    END IF;

    LOOP
        UPDATE used_quota
        SET bytes = bytes + NEW.bytes, messages = messages + NEW.messages, domain=split_part(NEW.username, '@', 2)
        WHERE username = NEW.username;
        IF found THEN
            RETURN NULL;
        END IF;

        BEGIN
            IF NEW.messages = 0 THEN
                INSERT INTO used_quota (bytes, messages, username, domain)
                VALUES (NEW.bytes, NULL, NEW.username, split_part(NEW.username, '@', 2));
            ELSE
                INSERT INTO used_quota (bytes, messages, username, domain)
                VALUES (NEW.bytes, -NEW.messages, NEW.username, split_part(NEW.username, '@', 2));
            END IF;
            return NULL;
            EXCEPTION WHEN unique_violation THEN
            -- someone just inserted the record, update it
        END;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER mergequota BEFORE INSERT ON used_quota
    FOR EACH ROW EXECUTE PROCEDURE merge_quota();

UPDATE used_quota SET domain = SPLIT_PART(username, '@', 2);
```

* Now switch to PostgreSQL daemon user, then execute SQL commands to add
required columns and indexes:

    * On Linux, PostgreSQL daemon user is `postgres`.
    * On FreeBSD, PostgreSQL daemon user is `pgsql`.
    * On OpenBSD, PostgreSQL daemon user is `_postgresql`.

```
# su - postgres
$ psql -d vmail
sql> \i /tmp/trigger.sql;
```

That's all.

### Add new table in PostgreSQL database: `vmail`

We need a new SQL table to store maildir path of removed mail user, so that you
can delete his/her mailbox manually or with a cron job.

* Please save below SQL command in a plain text file. For example,
`/root/deleted_mailboxes.sql`:

```
CREATE TABLE deleted_mailboxes (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- Email address of deleted user
    username VARCHAR(255) NOT NULL DEFAULT '',
    -- Domain part of user email address
    domain VARCHAR(255) NOT NULL DEFAULT '',
    -- Absolute path of user's mailbox
    maildir TEXT NOT NULL DEFAULT '',
    -- Which domain admin deleted this user
    admin VARCHAR(255) NOT NULL DEFAULT ''
);

CREATE INDEX idx_deleted_mailboxes_timestamp ON deleted_mailboxes (timestamp);
CREATE INDEX idx_deleted_mailboxes_username ON deleted_mailboxes (username);
CREATE INDEX idx_deleted_mailboxes_domain ON deleted_mailboxes (domain);
CREATE INDEX idx_deleted_mailboxes_admin ON deleted_mailboxes (admin);

GRANT SELECT,UPDATE,INSERT,DELETE ON deleted_mailboxes TO vmail;
GRANT SELECT,UPDATE,INSERT,DELETE ON deleted_mailboxes TO vmailadmin;
```

* Now switch to PostgreSQL daemon user, then execute SQL commands to add
required columns and indexes:

    * On Linux, PostgreSQL daemon user is `postgres`.
    * On FreeBSD, PostgreSQL daemon user is `pgsql`.
    * On OpenBSD, PostgreSQL daemon user is `_postgresql`.

```
# su - postgres
$ psql -d vmail
sql> \i /tmp/deleted_mailboxes.sql;
```

That's all.

