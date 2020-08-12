# Store SpamAssassin bayes in SQL

[TOC]

!!! warning

    The bayesian classifier can only score new messages after it already learn
    200 known spams and 200 known hams.

## Summary

This article will guide you to configure related components to store
SpamAssassin Bayes data in SQL server, and allow webmail users to report spam
with one click.

Tested with:

* iRedMail-0.8.0, iRedMail-0.8.7.
* CentOS 6.2 (x86_64)
* SpamAssassin-3.3.1
* Amavisd-new-2.6.6
* MySQL-5.1.61
* Roundcubemail-0.7.2

Notes:

* This article should work with all iRedMail releases. We take iRedMail-0.8.0 for example.
* This article should work with all backends: OpenLDAP, MySQL, MariaDB, PostgreSQL. We take MySQL backend for example.
* This article should work with Amavisd-new-2.6.0 and later versions.

__IMPORTANT NOTES__:

* The bayesian classifier can only score new messages after it already learn
  known spams and 200 known hams.
* If Spamassassin fails to identify a spam, teach it so it can do better next
  time. e.g. Mark it as spam in roundcube webmail.
* Read `References` section at the end of this article before asking questions.

## Create required SQL database used to store bayes data

We need to create a SQL database and necessary tables to store SpamAssassin
bayes data. The RPM package installed on CentOS 6 doesn't ship SQL template
for bayes database, so we have to download it from Apache web site. We're
running SpamAssassin-3.3.1, so what we need is this SQL template file:
[http://svn.apache.org/repos/asf/spamassassin/tags/spamassassin_release_3_3_1/sql/bayes_mysql.sql](http://svn.apache.org/repos/asf/spamassassin/tags/spamassassin_release_3_3_1/sql/bayes_mysql.sql)
If you're running different version, please find the proper SQL file here:
[http://svn.apache.org/repos/asf/spamassassin/tags/](http://svn.apache.org/repos/asf/spamassassin/tags/).

```
# cd /root/
# wget http://svn.apache.org/repos/asf/spamassassin/tags/spamassassin_release_3_3_1/sql/bayes_mysql.sql
```

Create MySQL database and import SQL template file:

```
# mysql -uroot -p
mysql> CREATE DATABASE sa_bayes;
mysql> USE sa_bayes;
mysql> SOURCE /root/bayes_mysql.sql;
```

Create a new MySQL user (with password `sa_user_password`) and grant
permissions. __IMPORTANT NOTE__: Please replace password `sa_user_password`
by your own password.

```
mysql> GRANT SELECT, INSERT, UPDATE, DELETE ON sa_bayes.* TO sa_user@localhost IDENTIFIED BY 'sa_user_password';
mysql> FLUSH PRIVILEGES;
```

## Enable Bayes modules in SpamAssassin

Edit `/etc/mail/spamassassin/local.cf`, add (or modify below settings):

```
use_bayes          1
bayes_auto_learn   1
bayes_auto_expire  1

# Store bayesian data in MySQL
bayes_store_module Mail::SpamAssassin::BayesStore::MySQL
bayes_sql_dsn      DBI:mysql:sa_bayes:127.0.0.1:3306

# Store bayesian data in PostgreSQL
#bayes_store_module Mail::SpamAssassin::BayesStore::PgSQL
#bayes_sql_dsn      DBI:Pg:sa_bayes:127.0.0.1:5432

bayes_sql_username sa_user
bayes_sql_password sa_user_password

# Override the username used for storing data in the database.
# This could be used to group users together to share bayesian filter data.
# You can also use this config option to trick sa-learn to learn data as a
# specific user.
#
# In iRedMail, SpamAssassin is called by Amavisd, so we must set it to be
# same as Amavisd daemon user:
#   - on Linux, it's user `amavis`.
#   - on FreeBSD, it's user `vscan`.
#   - on OpenBSD, it's user `_vscan`.
bayes_sql_override_username amavis
```

Make sure SpamAssassin will load bayes modules:

```
# /etc/init.d/amavisd stop
# amavisd -c /etc/amavisd/amavisd.conf debug 2>&1 | grep -i 'bayes'
May 16 09:59:33 ... SpamAssassin loaded plugins: ..., Bayes, ...
May 16 10:27:38 ... extra modules loaded after daemonizing/chrooting:
    Mail/SpamAssassin/BayesStore/MySQL.pm, Mail/SpamAssassin/BayesStore/SQL.pm, ...
```
Looks fine, now press `Ctrl-C` to terminate above command, and start Amavisd
service again normally:

```
# /etc/init.d/amavisd restart
```

It is required to initialize the database by learning a message. We use the
sample spam email shipped in the RPM package provided by CentOS 6:

```
# rpm -ql spamassassin | grep 'sample-spam'
/usr/share/doc/spamassassin-3.3.1/sample-spam.txt

# sa-learn --spam --username=amavis /usr/share/doc/spamassassin-3.3.1/sample-spam.txt
Learned tokens from 1 message(s) (1 message(s) examined)
```

## Auto learn spam/ham with Dovecot imap_sieve plugin

* [Auto learn spam/ham with Dovecot imap_sieve plugin](./dovecot.imapsieve.html)

## Backup your `sa_bayes` database

Don't forget to update `/var/vmail/backup/backup_mysql.sh` (or
`backup_pgsql.sh` if you're running PostgreSQL backend) to backup this newly
created `sa_bayes` database. For example:

```
# Part of file `/var/vmail/backup/backup_mysql.sh`
DATABASES='... sa_bayes'
```

## References

* [Bayes Introduction](http://wiki.apache.org/spamassassin/BayesInSpamAssassin). Please do read section `Things to remember`.
* [SpamAssassin Bayes Frequently Asked Questions](http://wiki.apache.org/spamassassin/BayesFaq)
