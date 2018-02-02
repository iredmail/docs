# Roadmap

[TOC]

Feel free to request new features or report bugs in our [issue tracker](https://bitbucket.org/zhb/iredmail/issues?status=new&status=open), direct pull requests are always welcome.

You can also contact us via email directly: [Contact Us](https://www.iredmail.org/contact.html).

## Planned changes in next iRedMail / iRedAdmin-Pro release

* HIGH: OpenDMARC integration.
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
