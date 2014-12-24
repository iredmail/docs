# TODO

* how to translate iRedAdmin-Pro: http://www.iredmail.org/forum/topic378-faq-how-to-translate-iredadmin-to-your-language.html
* iRedAdmin-Pro installation guides

    * http://www.iredmail.org/admin_installation_debian.html
    * http://www.iredmail.org/admin_installation_opensuse.html
    * http://www.iredmail.org/admin_installation_freebsd.html
    * http://www.iredmail.org/admin_installation_rhel.html
    * http://www.iredmail.org/admin_installation_openbsd.html

* New tutorial: which config files must be update if i want to change hostname

    * re-generate ssl cert/key
    * /etc/postfix/main.cf
    * /etc/amavisd/amavisd.conf
    * /etc/hosts, /var/spool/postfix/etc/hosts
    * /usr/local/bin/dovecot-quota-warning.sh (old iredmail release)

* How to enable SSHA512/BCRYPT in Dovecot + Roundcubemail.
* How to custom SpamAssassin scores
* How to enable DNSBL in Postfix.

* http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/Send.out.email.from.specified.IP.address
* http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/Backup
* http://www.iredmail.org/forum/topic1968-enabling-ipv6-for-your-iredmail-postfixdovecot.html
* http://www.iredmail.org/forum/topic210-iredmail-support-faq-how-to-enable-signing-disclaimer-on-outgoing-mails.html

# integrations

* http://www.iredmail.org/wiki/index.php?title=Integration/Ejabberd.iRedMail.with.OpenLDAP
* http://www.iredmail.org/wiki/index.php?title=Integration/OpenVPN.iRedMail.with.OpenLDAP
* http://www.iredmail.org/wiki/index.php?title=Integration/SOGo.iRedMail.with.OpenLDAP
* http://www.iredmail.org/wiki/index.php?title=Integration/DBMail.iRedMail.with.MySQL.backend
* http://www.iredmail.org/wiki/index.php?title=Integration/PureFTPd.iRedMail.with.OpenLDAP

* ~~ http://www.iredmail.org/wiki/index.php?title=Integration/Active.Directory.iRedMail ~~

# installation guides

* ~~http://www.iredmail.org/install_iredmail_on_debian.html~~
* ~~http://www.iredmail.org/install_iredmail_on_ubuntu.html~~
* ~~http://www.iredmail.org/install_iredmail_on_freebsd.html~~
* ~~ http://www.iredmail.org/wiki/index.php?title=Install/iRedMail/FreeBSD.Jail ~~
* ~~http://www.iredmail.org/install_iredmail_on_openbsd.html~~
* ~~ http://www.iredmail.org/install_iredmail_on_rhel.html ~~
* ~~ https://code.google.com/p/iredmail/wiki/DNS_DKIM ~~
* ~~ https://code.google.com/p/iredmail/wiki/DNS_SPF ~~

# Howto

* ~~ http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/Dovecot.Master.User ~~
* ~~ Upgrade iRedAPD: http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/Upgrade.iRedAPD ~~
* ~~ http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/MySQL/per-user.send.receive.restrictions ~~
* ~~ How to enable per-recipient policy lookup in Amavisd (@lookup_sql_dsn). ~~
* ~~Use same DKIM PEM file for all mail domains.~~
* ~~ How to sign DKIM signature on sent emails for new mail domain. mention how
  to use one DKIM key for all domains. ~~

* ~~ http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/Reset.password.for.mail.user ~~
* ~~http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/LDAP/Monitor.Incoming.and.Outgoing.Mails.with.BCC~~
* ~~http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/LDAP/Turn.On.Debug.Mode.In.OpenLDAP~~
* ~~ http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/Quarantining.Clean.Mail ~~
* ~~ http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/Quarantining.SPAM ~~
* ~~ http://www.iredmail.org/wiki/index.php?title=Addition/MySQL/Catch-all ~~

# Migration

* ~~ http://www.iredmail.org/wiki/index.php?title=Migrate/iRedAdmin-Pro/OSE-Pro ~~

# FAQ

* ~~ http://www.iredmail.org/wiki/index.php?title=IRedAdmin-Pro/FAQ/change.default.password.policy ~~
* ~~ http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/Turn.On.Debug.Mode.In.Amavisd ~~
* ~~ http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/SQL/Create.Mail.Alias ~~
* ~~ http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/LDAP/Monitor.Incoming.and.Outgoing.Mails.with.BCC ~~
* ~~ http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/LDAP/Turn.On.Debug.Mode.In.OpenLDAP ~~
* ~~ http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/LDAP/Add.Alias.Domain ~~
* ~~ http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/LDAP/Add.Alias.Account.with.phpLDAPadmin ~~
* ~~ http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/LDAP/Add.Maillist.with.phpLDAPadmin ~~
* ~~ http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/LDAP/Add.Mail.Forwarding.Address ~~
* ~~ http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/Ignore.Trash.Folder.in.Quota ~~
* ~~ http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/why.iredmail.append.timestamp.in.maildir.path ~~
* ~~ http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/Recalculate.Mailbox.Quota ~~
* ~~ http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/Allow.User.to.Send.Email.without.Authentication ~~


# faq.html

* ~~http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/Quarantining.Clean.Mail ~~
* ~~http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/Unattended.iRedMail.Installation ~~
* ~~ http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/use.or.migrate.password.hashes ~~
* ~~ http://iredmail.org/wiki/index.php?title=IRedMail/FAQ/Disable.Spam.Virus.Scanning.for.Outgoing.Mails ~~
* ~~ http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/Completely.Disable.Amavisd.ClamAV.SpamAssassin ~~
* ~~ http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/EndUser/Howto.Configure.Thunderbird.for.iRedMail ~~
* ~~http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/Store.SpamAssassin.Bayes.In.SQL ~~
* ~~http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/Allow.Insecure.POP3.IMAP.Connection.without.STARTTLS ~~
* ~~http://iredmail.org/wiki/index.php?title=IRedMail/FAQ/Pipe.Incoming.Email.For.Certain.User.To.External.Script ~~
* ~~http://www.iredmail.org/wiki/index.php?title=Addition/Migrate.to.New.iRedMail.Server ~~
* ~~http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/Turn.On.Debug.Mode.In.Dovecot ~~
