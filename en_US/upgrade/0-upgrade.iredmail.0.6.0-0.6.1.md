# Upgrade iRedMail from 0.6.0 to 0.6.1

[TOC]

> We provide remote upgrade service, check [the price](../support.html) and [contact us](../contact.html).

## General (All backends should apply these steps)

### Apply hotfix for iRedMail-0.6.0

All users should apply hotfixes for iRedMail-0.6.0:

* [Add missing mail log files in logrotate. (Debian/Ubuntu)](http://www.iredmail.org/forum/topic1130-hotfix-for-060-add-missing-log-files-in-logrotate-debianubuntu.html) 2010-08-03
* [Protect iRedMail configure files](http://www.iredmail.org/forum/topic1108-hotfix-protect-config-files-which-contains-passwords.html) 2010-07-25
* [Secure your iRedAdmin](http://www.iredmail.org/forum/topic1102-secure-your-exist-iredadmin.html) 2010-07-23
* [Hotfix for iRedAPD-1.3.2: Blacklisting all recipients](http://www.iredmail.org/forum/topic1096-hotfix-for-iredapd132-blacklisting-all-recipients.html) 2010-07-22
* 
[Hotfix on RHEL/CentOS 5: New version of perl-Archive-Tar breaks SpamAssassin](http://www.iredmail.org/forum/topic1085-hotfix-new-version-of-perlarchivetar-breaks-spamassassin.html) 2010-07-21
* [Hotfix for iRedAPD-1.3.1: Invalid per-user restriction of whitelist](http://www.iredmail.org/forum/topic1052-hotfix-for-iredapd131-invalid-peruser-restriction-of-whitelist.html) 2010-07-07
* [Incorrect path of awstats.pl on Debian 5](http://www.iredmail.org/forum/topic982-hotfix-for-060-incorrect-path-of-awstatspl-on-debian-5.html) 2010-06-12
* [Duplicate log entry for /var/log/mail.log](http://www.iredmail.org/forum/topic983-hotfix-for-060-duplicate-log-entry-for-varlogmaillog.html) 2010-06-12

## OpenLDAP backend only

* [Domain alias and shadow address don't work](http://www.iredmail.org/forum/topic1023-hotfix-for-060-domain-alias-and-shadow-address-dont-work.html) 2010-06-25 (Note: OpenLDAP backend only)

## MySQL backend only

* Small improvement: [Catch-all account support](./sql.create.domain.catchall.account.html)
