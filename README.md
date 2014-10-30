We're migrating [old wiki documents](http://www.iredmail.org/wiki) to Markdown format for easier maintenance.
# Install iRedMail
* [Install iRedMail on Red Hat Enterprise Linux, CentOS](https://bitbucket.org/zhb/docs.iredmail.org/src/default/installation/0-install.iredmail.on.rhel.md)
* [Install iRedMail on Debian or Ubuntu Linux](https://bitbucket.org/zhb/docs.iredmail.org/src/default/installation/1-install.iredmail.on.debian.ubuntu.md)
* [Install iRedMail on FreeBSD (without Jail)](https://bitbucket.org/zhb/docs.iredmail.org/src/default/installation/2-install.iredmail.on.freebsd.md)
* [Install iRedMail on OpenBSD](https://bitbucket.org/zhb/docs.iredmail.org/src/default/installation/3-install.iredmail.on.openbsd.md)
* [Setup DNS records for your iRedMail server](https://bitbucket.org/zhb/docs.iredmail.org/src/default/installation/setup_dns.md)
* [Perform silent/unattended iRedMail installation](https://bitbucket.org/zhb/docs.iredmail.org/src/default/installation/unattended.iredmail.installation.md)
# Configure mail client applications
* [Configure Thunderbird as mail client (POP3/IMAP, SMTP and global ldap address book)](https://bitbucket.org/zhb/docs.iredmail.org/src/default/mua/configure.thunderbird.md)
# How to
* [Allow certain users to send email as another user](https://bitbucket.org/zhb/docs.iredmail.org/src/default/howto/0-allow.certain.users.to.send.email.as.different.user.md)
* [Change mail attachment size](https://bitbucket.org/zhb/docs.iredmail.org/src/default/howto/0-change.mail.attachment.size.md)
* [Completely disable Amavisd + ClamAV + SpamAssassin](https://bitbucket.org/zhb/docs.iredmail.org/src/default/howto/0-completely.disable.amavisd.clamav.spamassassin.md)
* [Enable SMTPS service (SMTP over SSL, port 465)](https://bitbucket.org/zhb/docs.iredmail.org/src/default/howto/0-enable.smtps.md)
* [Disable spam virus scanning for outgoing mails](https://bitbucket.org/zhb/docs.iredmail.org/src/default/howto/1-disable.spam.virus.scanning.for.outgoing.mails.md)
* [Amavisd + SpamAssassin not working, no mail header (X-Spam-*) inserted.](https://bitbucket.org/zhb/docs.iredmail.org/src/default/howto/1-no.x-spam.headers.md)
* [Quarantining](https://bitbucket.org/zhb/docs.iredmail.org/src/default/howto/1-quarantining.md)
* [Sign DKIM signature on outgoing emails for new mail domain](https://bitbucket.org/zhb/docs.iredmail.org/src/default/howto/1-sign.dkim.signature.for.new.domain.md)
* [Allow insecure POP3/IMAP/SMTP connections without STARTTLS](https://bitbucket.org/zhb/docs.iredmail.org/src/default/howto/2-allow.insecure.pop3.imap.smtp.connections.md)
* [Allow user to send email without authentication](https://bitbucket.org/zhb/docs.iredmail.org/src/default/howto/allow.user.to.send.email.without.authentication.md)
* [Force mail user to change password in 90 days](https://bitbucket.org/zhb/docs.iredmail.org/src/default/howto/force.user.to.change.password.md)
* [Ignore Trash folder in mailbox quota](https://bitbucket.org/zhb/docs.iredmail.org/src/default/howto/ignore.trash.folder.in.quota.md)
* [LDAP: Add an alias domain](https://bitbucket.org/zhb/docs.iredmail.org/src/default/howto/ldap.add.alias.domain.md)
* [LDAP: Add a mail alias account](https://bitbucket.org/zhb/docs.iredmail.org/src/default/howto/ldap.add.mail.alias.md)
* [LDAP: Add a mail list account](https://bitbucket.org/zhb/docs.iredmail.org/src/default/howto/ldap.add.mail.list.md)
* [LDAP: User mail forwarding.](https://bitbucket.org/zhb/docs.iredmail.org/src/default/howto/ldap.user.mail.forwarding.md)
* [Monitor incoming and outgoing mails with BCC](https://bitbucket.org/zhb/docs.iredmail.org/src/default/howto/monitor.incoming.and.outgoing.mails.with.bcc.md)
* [Pipe incoming email for certain user to external script ](https://bitbucket.org/zhb/docs.iredmail.org/src/default/howto/pipe.incoming.email.for.certain.user.to.external.script.md)
* [Force Dovecot to recalculate mailbox quota](https://bitbucket.org/zhb/docs.iredmail.org/src/default/howto/recalculate.mailbox.quota.md)
* [SQL: Create an mail alias account with SQL command line](https://bitbucket.org/zhb/docs.iredmail.org/src/default/howto/sql.create.mail.alias.md)
* [Store SpamAssassin bayes in SQL](https://bitbucket.org/zhb/docs.iredmail.org/src/default/howto/store.spamassassin.bayes.in.sql.md)

Documents contributed by iRedMail users:

* [Anti-spam with Dovecot antispam plugin and SpamAssassin](http://www.iredmail.org/forum/topic8169-iredmail-support-antispam-via-dovecot-and-spamassassin.html), contributed by Dexus.
# Third-party integrations
* [Integrate Microsoft Active Directory in iRedMail](https://bitbucket.org/zhb/docs.iredmail.org/src/default/integrations/active.directory.md)
* [SOGo: install SOGo on CentOS 6 with iRedMail (MySQL backend)](https://bitbucket.org/zhb/docs.iredmail.org/src/default/integrations/sogo-centos-6-mysql.md)

Documents contributed by iRedMail users:

* [Enabling Apache Solr 4.10 (using jetty) with Dovecot 2.2 for fulltext search results on Centos 6 (iRedMail compatible)](https://extremeshok.com/6622/enabling-apache-solr-4-10-using-jetty-with-dovecot-2-2-for-fulltext-search-results-on-centos-6-iredmail-compatible/)
# Cluster

Documents contributed by iRedMail users:

* [An Ultra-HA, full Mult-Master E-mail cluster with iRedMail, MariaDB, and IPVS](http://pastebin.com/JcYeQBrX), contributed by Joshua Boniface.
# Migrations
* [Migrate iRedAdmin open source edition to iRedAdmin-Pro](https://bitbucket.org/zhb/docs.iredmail.org/src/default/migrations/migrate.or.upgrade.iredadmin.md)
* [Migrate old iRedMail server to the latest stable release](https://bitbucket.org/zhb/docs.iredmail.org/src/default/migrations/migrate.to.new.iredmail.server.md)
* [Password hashes](https://bitbucket.org/zhb/docs.iredmail.org/src/default/migrations/password.hashes.md)
# Troubleshooting and Debug
* [Turn on debug mode in Amavisd and SpamAssassin](https://bitbucket.org/zhb/docs.iredmail.org/src/default/troubleshooting/turn.on.debug.mode.in.amavisd.md)
* [Turn on debug mode in Cluebringer](https://bitbucket.org/zhb/docs.iredmail.org/src/default/troubleshooting/turn.on.debug.mode.in.cluebringer.md)
* [Turn on debug mode in Dovecot](https://bitbucket.org/zhb/docs.iredmail.org/src/default/troubleshooting/turn.on.debug.mode.in.dovecot.md)
* [Turn on debug mode in iRedAPD](https://bitbucket.org/zhb/docs.iredmail.org/src/default/troubleshooting/turn.on.debug.mode.in.iredapd.md)
* [Turn on debug mode in OpenLDAP](https://bitbucket.org/zhb/docs.iredmail.org/src/default/troubleshooting/turn.on.debug.mode.in.openldap.md)
# Frequently Asked Questions
* [Locations of configuration and log files of mojor components](https://bitbucket.org/zhb/docs.iredmail.org/src/default/faq/file.locations.md)
* [Why append timestamp in maildir path](https://bitbucket.org/zhb/docs.iredmail.org/src/default/faq/why.append.timestamp.in.maildir.path.md)
