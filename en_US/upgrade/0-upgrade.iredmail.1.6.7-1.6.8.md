# Upgrade iRedMail from 1.6.7 to 1.6.8

!!! attention

	 Check out the on-premises, lightweight email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! note "Remote Upgrade Assistance"

    Check out our [remote upgrade support](https://www.iredmail.org/support.html) if you need assistance.

## ChangeLog

- Dec 29, 2023: initial publish.

## General (All backends should apply these changes)

### Update `/etc/iredmail-release` with new iRedMail version number

iRedMail stores the release version in `/etc/iredmail-release` after
installation, it's recommended to update this file after you upgraded iRedMail,
so that you can know which version of iRedMail you're running. For example:

```
1.6.8
```

### Mitigate Postfix "SMTP Smuggling" attack (short-term workaround)

There's a "SMTP Smuggling" attack found in all Postfix versions, visit Postfix
website for more details: [SMTP Smuggling](https://www.postfix.org/smtp-smuggling.html).

Quote from Postfix website:

> __Details__
>
> The attack involves a COMPOSITION of two email services with specific differences in the way they handle line endings other than <CR><LF>:
>
> - One email service A that does not recognize malformed line endings in SMTP such as in <LF>.<CR><LF> in an email message from an authenticated attacker to a recipient at email service B, and that propagates those malformed line endings verbatim when it forwards that message to:
> - One different email service B that does support malformed line endings in SMTP such as in <LF>.<CR><LF>. When this is followed by "smuggled" SMTP MAIL/RCPT/DATA commands and message header plus body text, email service B is tricked into receiving two email messages: one message with the content before the <LF>.<CR><LF>, and one message with the "smuggled" header plus body text after the "smuggled" SMTP commands. All this when email service A sends only one message.
>
> Postfix is an example of email service B. Microsoft's outlook.com was an example of email service A.

> __Impact__
>
> - The authenticated attacker can use the "smuggled" SMTP MAIL/RCPT/DATA commands and header plus body text, to spoof an email message from any MAIL FROM address whose domain is also hosted at email service A, to any RCPT TO address whose domain is also hosted at email service B.
> - The spoofed email message will pass SPF-based DMARC checks at email service B, because the spoofed message has a MAIL FROM address whose domain is hosted at email service A, and because the message was received from an IP address for email service A.

Please run shell commands below to apply the fix:

```shell
postconf -e smtpd_data_restrictions=reject_unauth_pipelining
postconf -e smtpd_discard_ehlo_keywords=chunking
postfix reload
```

Note: Most Linux/BSD distribution releases don't have latest Postfix release
till today (Dec 29, 2023), we can only apply this "short-term workarounds".
The "long-term fix" is upgrading Postfix to at least version: 3.8.4, 3.7.9,
3.6.13 and 3.5.23 to stop all forms of the smuggling attacks on recipients at
a Postfix server.

- Ubuntu 22.04.3 ships Postfix 3.6.4 (requires 3.6.13)
- Debian 12 ships Postfix 3.7.6 (requires 3.7.9)
- CentOS / Rocky 9 ships Postfix 3.5.9 (requires 3.5.23)
- OpenBSD 7.4 ships Postfix 3.7.3 (requires 3.7.9)
- Latest FreeBSD ports tree ships Postfix 3.8.4, please upgrade.

### CentOS/Rocky/Alma: Enable daily cron job to update SpamAssassin rules

!!! attention

    This is applicable to only CentOS, Rocky Linux, AlmaLinux.

Please run command below to enable daily cron job to update SpamAssassin rules:

```
ln -sf /usr/share/spamassassin/sa-update.cron /etc/cron.daily/sa-update
```

### Upgrade mlmmjadmin to the latest stable release (3.1.9)

Please follow below tutorial to upgrade mlmmjadmin to the latest stable release:
[Upgrade mlmmjadmin to the latest stable release](./upgrade.mlmmjadmin.html)

### Upgrade netdata to the latest stable release (1.44.1)

If you have netdata installed, you can upgrade it by following this tutorial:
[Upgrade netdata](./upgrade.netdata.html).

## OpenLDAP backend

### Fix: allow to use (mlmmj) mailing list as member of another mailing list.

Please open file `/etc/postfix/ldap/virtual_group_maps.cf`, replace
`query_filter` line by below one:

```
query_filter    = (&(accountStatus=active)(!(domainStatus=disabled))(enabledService=mail)(enabledService=deliver)(|(&(|(memberOfGroup=%s)(shadowAddress=%s))(|(objectClass=mailUser)(objectClass=mailExternalUser)))(&(memberOfGroup=%s)(!(shadowAddress=%s))(|(objectClass=mailAlias)(objectClass=mailList)))(&(objectClass=mailList)(enabledService=mlmmj)(|(mail=%s)(shadowAddress=%s)))))
```

Restarting postfix service is required.
