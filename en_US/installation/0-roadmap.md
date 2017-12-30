# Roadmap

[TOC]

Feel free to request new features or report bugs in our [issue tracker](https://bitbucket.org/zhb/iredmail/issues?status=new&status=open), direct pull requests are always welcome.

You can also contact us via email directly: [Contact Us](https://www.iredmail.org/contact.html).

## Upcoming iRedMail release (0.9.8)

### Work In Progress

* Integrate [mlmmj](http://mlmmj.org) mailing list manager.
    * Improve iRedAPD to handle access policy of mlmmj mailing list.
    * [DONE] RESTful API server used to manage mlmmj: [mlmmj-admin](https://bitbucket.org/iredmail/mlmmj-admin/src).
    * [DONE] Integrate mlmmj and mlmmj-admin in iRedAdmin-Pro for SQL backends.
    * [DONE] Integrate mlmmj and mlmmj-admin in iRedAdmin-Pro for LDAP backends.

* Replace Awstats by [netdata](https://my-netdata.io).
    * [DONE] <strike>Remove Awstats.</strike>
    * Install and configure netdata.

* Issues:
    - Postfix: Improper SQL queries used to query per-user bcc address.

### DONE

Features listed below have been implemented in latest development edition.

* Supports new distribution releases:
    + OpenBSD 6.2.
    + Ubuntu 17.10

* Drop support for old distribution releases:
    - CentOS 6
    - Debian 8
    - OpenBSD 6.1
    - Ubuntu 14.04 LTS, 17.04.

* Apache has been removed, Nginx is the only one option you have.

* Improvements:
    - LDAP backend: Allow mailing list account to use 2 attributes: member,
      uniqueMember.
    - Dovecot: Log subject, sender, size in mail deliver log.
    - Amavisd: Add new sql column `maddr.email_raw` and trigger to store
      email address without address extension.

* Fixed issues:
    - installer: not correctly configure SOGo with IPv6 SQL server address.
      Thanks to Wraptor <nijs.thibaut _at_ gmail.com> for the report in
      forum.
    - Nginx: Use single config file for default web hosts.
    - SQL backends: User under disabled domain is able to send email with
      smtp protocol.
    - Cannot sync contacts on Android devices via EAS with SOGo.
    - scripts under `iRedMail-0.9.8/tools/`:
        - `backup_sogo.sh`:
            - not set correct owner and permission on backup files.
            - cannot remove old backup files.
        - `backup_openldap.sh`: Cannot log backup result to SQL db.
          Note: backup is fine, just no log in SQL db.
          Thanks swejun <ingvar _at_ zebware.com> for the feedback and fix in
          forum.
        - `create_mail_user_*`: not use current date as password last change
          date for newly created user.
        - `migrate_sql_alias_table.py`: doesn't support 'utf8' charset.
          Thanks Kacper Guzik <kacper.guzik _at_ zenbox _dot_ pl> for the
          report and code contribution.

* Updated packages:
    + Roundcube -> 1.3.3

## Planned changes in next iRedMail / iRedAdmin-Pro release

* HIGH: [#14 Allow domain admin to set vacation message for mail user](https://bitbucket.org/zhb/iredmail/issues/14/allow-admin-to-set-vacation-for-user-with)
## Planned changes in future iRedMail release

* A (new) RESTful API server for general administration (core of API server has
  been implemented, need to write plugins for each particular tasks):
    * [HIGH] Manage Nginx virtual web hosts.
    * Network service control: get service status, stop/start/restart service.
    * Manage fail2ban banned/unbanned IPs.
    * Query user mailbox with `doveadm search`, fetch partial/full messages or
      message information. Possible use cases with iRedAdmin-Pro:
        * View (either partial/full) mail messages in user's mailbox.
        * In sent/received mail log page, query API server with given
          query messages with `Message-ID:` or subject, display the full
          message if necessary.
        * Destroy delivered messages which matches given query.
    * LOW: Allow domain admin to share someone's mailbox folder to others.
    * SOGo management via command line tool `sogo-tool`.

* Dovecot:
    * Enable plugin `imap_sieve` for spam learning while user moving message to
      Junk folder. Requires Dovecot-2.2.24+ (dovecot-pigeonhole-0.4.14+).
    * Enable plugin `mail_crypt` to encrypts and decrypts mail. (requires Dovecot-2.2.27+).

* LDAP backends:
    * Migrate old mailing list (`objectClass=mailList`) to new mlmmj mailing
      list, convert all old mailing lists to be groups which have ldap dn of
      all members defined in ldap attribute `member` (or `memberdn`).
    * [Configure OpenLDAP with slapd.d instead of slapd.conf](https://bitbucket.org/zhb/iredmail/issue/31/switch-to-slapdd)
