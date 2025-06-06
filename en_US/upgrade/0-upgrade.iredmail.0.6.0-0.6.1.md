# Upgrade iRedMail from 0.6.0 to 0.6.1

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! note "Remote Upgrade Assistance"

    Check out our [remote upgrade support](https://www.iredmail.org/support.html) if you need assistance.

## General (All backends should apply these steps)

### Apply hotfix for iRedMail-0.6.0

All users should apply hotfixes for iRedMail-0.6.0:

* [Add missing mail log files in logrotate. (Debian/Ubuntu)](https://forum.iredmail.org/topic1130-hotfix-for-060-add-missing-log-files-in-logrotate-debianubuntu.html) 2010-08-03
* [Protect iRedMail configure files](https://forum.iredmail.org/topic1108-hotfix-protect-config-files-which-contains-passwords.html) 2010-07-25
* [Secure your iRedAdmin](https://forum.iredmail.org/topic1102-secure-your-exist-iredadmin.html) 2010-07-23
* [Hotfix for iRedAPD-1.3.2: Blacklisting all recipients](https://forum.iredmail.org/topic1096-hotfix-for-iredapd132-blacklisting-all-recipients.html) 2010-07-22
* [Hotfix on RHEL/CentOS 5: New version of perl-Archive-Tar breaks SpamAssassin](https://forum.iredmail.org/topic1085-hotfix-new-version-of-perlarchivetar-breaks-spamassassin.html) 2010-07-21
* [Hotfix for iRedAPD-1.3.1: Invalid per-user restriction of whitelist](https://forum.iredmail.org/topic1052-hotfix-for-iredapd131-invalid-peruser-restriction-of-whitelist.html) 2010-07-07
* [Incorrect path of awstats.pl on Debian 5](https://forum.iredmail.org/topic982-hotfix-for-060-incorrect-path-of-awstatspl-on-debian-5.html) 2010-06-12
* [Duplicate log entry for /var/log/mail.log](https://forum.iredmail.org/topic983-hotfix-for-060-duplicate-log-entry-for-varlogmaillog.html) 2010-06-12

## OpenLDAP backend only

* [Domain alias and shadow address don't work](https://forum.iredmail.org/topic1023-hotfix-for-060-domain-alias-and-shadow-address-dont-work.html) 2010-06-25 (Note: OpenLDAP backend only)

## MySQL backend only

* Small improvement: [Catch-all account support](./sql.create.domain.catchall.account.html)
