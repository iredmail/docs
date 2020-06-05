# Upgrade iRedMail from 1.2.1 to 1.3

[TOC]

!!! warning

    THIS IS STILL A DRAFT DOCUMENT, DO NOT APPLY IT.

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

## ChangeLog

* May XX, 2020: initial release.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.3
```

### Fixed: inconsistent Fail2ban jail names

!!! attention

    This is applicable to Linux and OpenBSD.

iRedMail-1.2 and 1.2.1 introduced [SQL integration in
Fail2ban](./fail2ban.sql.html), but there're few inconsistent jail names which
caused unbanning IP from iRedAdmin-Pro doesn't work. Please run commands below
to fix them.

```
cd /etc/fail2ban/jail.d/
perl -pi -e 's#dovecot-iredmail#dovecot#g' dovecot.local

perl -pi -e 's#postfix-pregreet-iredmail#postfix-pregreet#g' postfix-pregreet.local
perl -pi -e 's#name=postfix,#name=postfix-pregreet,#g' postfix-pregreet.local

perl -pi -e 's#postfix-iredmail#postfix#g' postfix.local
perl -pi -e 's#roundcube-iredmail#roundcube#g' roundcube.local
perl -pi -e 's#sogo-iredmail#sogo#g' sogo.local
```

## OpenLDAP backend special

### Add missing index for SQL column `msgs.time_iso` in `amavisd` database

Please run SQL commands below as MySQL root user:

```
USE amavisd;
CREATE INDEX msgs_idx_time_iso ON msgs (time_iso);
```

### Improvement: Store more info in Fail2ban SQL db

!!! attention

    Since iRedMail-1.2, Fail2ban is configured to [store banned IP addresses in 
    SQL database](./fail2ban.sql.html), if you're running an old iRedMail
    release, please upgrade your iRedMail server by following the upgrade
    tutorials: [iRedMail release notes and upgrade tutorials](./iredmail.releases.html).

With changes below, we now store more info in Fail2ban SQL database:

- Matched log lines which triggerred the ban
- Number of times the failure occurred until ban
- Reverse DNS name of banned IP address

Please run SQL commands below as MySQL root user:

```
USE fail2ban;
ALTER TABLE banned ADD COLUMN failures INT(2) NOT NULL DEFAULT 0;
ALTER TABLE banned ADD COLUMN loglines TEXT;
ALTER TABLE banned ADD COLUMN `rdns` VARCHAR(255) NOT NULL DEFAULT '';
CREATE INDEX rdns ON banned (`rdns`);
```

Now open file `/etc/fail2ban/action.d/banned_db.conf`, find the `actionban =`
line like below:

```
actionban   = /usr/local/bin/fail2ban_banned_db ban <ip> <port> <protocol> <name>
```

Replace it by:

```
actionban   = /usr/local/bin/fail2ban_banned_db ban <ip> <port> <protocol> <name> <ipjailfailures> <ipjailmatches>
```

Download improved shell script and replace the existing one:

```
wget https://github.com/iredmail/iRedMail/raw/1.3/samples/fail2ban/bin/fail2ban_banned_db
mv fail2ban_banned_db /usr/local/bin/
chmod 0550 /usr/local/bin/fail2ban_banned_db
```

Now restart Fail2ban service.

## MySQL/MariaDB backend special

### Add missing index for SQL column `msgs.time_iso` in `amavisd` database

Please run SQL commands below as MySQL root user:

```
USE amavisd;
CREATE INDEX msgs_idx_time_iso ON msgs (time_iso);
```

### Improvement: Store more info in Fail2ban SQL db

!!! attention

    Since iRedMail-1.2, Fail2ban is configured to [store banned IP addresses in 
    SQL database](./fail2ban.sql.html), if you're running an old iRedMail
    release, please upgrade your iRedMail server by following the upgrade
    tutorials: [iRedMail release notes and upgrade tutorials](./iredmail.releases.html).

With changes below, we now store more info in Fail2ban SQL database:

- Matched log lines which triggerred the ban
- Number of times the failure occurred until ban
- Reverse DNS name of banned IP address

Please run SQL commands below as MySQL root user:

```
USE fail2ban;
ALTER TABLE banned ADD COLUMN failures INT(2) NOT NULL DEFAULT 0;
ALTER TABLE banned ADD COLUMN loglines TEXT;
ALTER TABLE banned ADD COLUMN `rdns` VARCHAR(255) NOT NULL DEFAULT '';
CREATE INDEX rdns ON banned (`rdns`);
```

Now open file `/etc/fail2ban/action.d/banned_db.conf`, find the `actionban =`
line like below:

```
actionban   = /usr/local/bin/fail2ban_banned_db ban <ip> <port> <protocol> <name>
```

Replace it by:

```
actionban   = /usr/local/bin/fail2ban_banned_db ban <ip> <port> <protocol> <name> <ipjailfailures> <ipjailmatches>
```

Download improved shell script and replace the existing one:

```
wget https://github.com/iredmail/iRedMail/raw/1.3/samples/fail2ban/bin/fail2ban_banned_db
mv fail2ban_banned_db /usr/local/bin/
chmod 0550 /usr/local/bin/fail2ban_banned_db
```

Now restart Fail2ban service.

## PostgreSQL backend special

### Improvement: Store more info in Fail2ban SQL db

!!! attention

    Since iRedMail-1.2, Fail2ban is configured to [store banned IP addresses in 
    SQL database](./fail2ban.sql.html), if you're running an old iRedMail
    release, please upgrade your iRedMail server by following the upgrade
    tutorials: [iRedMail release notes and upgrade tutorials](./iredmail.releases.html).

With changes below, we now store more info in Fail2ban SQL database:

- Matched log lines which triggerred the ban
- Number of times the failure occurred until ban
- Reverse DNS name of banned IP address

Please follow steps below to apply required changes.

* Connect to PostgreSQL server as `postgres` user and connect to `vmail` database:
    * on Linux, it's `postgres` user
    * on FreeBSD, it's `pgsql` user
    * on OpenBSD, it's `_postgresql` user

```
su - postgres
psql -d fail2ban
```

* Run SQL commands below:

```
\c fail2ban;
ALTER TABLE banned ADD COLUMN failures SMALLINT NOT NULL DEFAULT 0;
ALTER TABLE banned ADD COLUMN loglines TEXT;
ALTER TABLE banned ADD COLUMN rdns VARCHAR(255) NOT NULL DEFAULT '';
CREATE INDEX idx_banned_rdns ON banned (rdns);
```

* Open file `/etc/fail2ban/action.d/banned_db.conf`, find the `actionban =`
  line like below:

```
actionban   = /usr/local/bin/fail2ban_banned_db ban <ip> <port> <protocol> <name>
```

Replace it by:

```
actionban   = /usr/local/bin/fail2ban_banned_db ban <ip> <port> <protocol> <name> <ipjailfailures> <ipjailmatches>
```

* Download improved shell script and replace the existing one:

```
wget https://github.com/iredmail/iRedMail/raw/1.3/samples/fail2ban/bin/fail2ban_banned_db
mv fail2ban_banned_db /usr/local/bin/
chmod 0550 /usr/local/bin/fail2ban_banned_db
```

* Now restart Fail2ban service.
