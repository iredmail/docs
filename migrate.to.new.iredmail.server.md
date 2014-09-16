<http://www.iredmail.org/wiki/index.php?title=Addition/Migrate.to.New.iRedMail.Server>
#How to migrate a test server to production


__TO BE CONTINUED.__

__Please try it on a test server first, if it works well, then try it on product server.__

Since new iRedMail server will install same components as old server, you can choose what data you want to migrate. The core data are mail accounts, user mailboxes, roundcube webmail database, Policyd database, Amavisd database.

WARNING: Do not restore database "mysql" exported from old server, it contains SQL usernames/passwords for Roundcube/Amavisd/Policyd/Cluebringer used on old server. New iRedMail server has the same SQL usernames, but different passwords. So please do not restore it.

##Client settings (Outlook, Thunderbird)

* Since iRedMail-0.8.7, iRedMail enforces secure smtp connection, client must issue 'STARTTLS' command before authentication, so you must change your mail client program (e.g. Outlook, Thunderbird) to use TLS connection on port 587. If you want to enable smtp authentication on port 25 (again, not recommended), please comment out Postfix parameter __"smtpd\_tls\_auth\_only = yes"__ in its config file /etc/postfix/main.cf.

##LDAP: migrate mail accounts
Steps to migrate LDAP mail accounts:

* Setup a new server with the latest iRedMail, and make iRedAdmin-Pro-LDAP work as expected.
* Export mail accounts from LDAP on OLD mail server.

Normally, LDAP data can be exported into LDIF format. Here's backup/export script: <http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/Backup>

__Note__:
* There might be some changes in LDAP schema, please find scripts in below URL to apply all required changes: <https://bitbucket.org/zhb/iredmail/src/default/extra/update/>
* You can find all upgrade tutorials of iRedMail here: <http://www.iredmail.org/doc.html#upgrade_tutorial>

##MySQL/PostgreSQL: Migrate mail accounts

All mail accounts are stored in database __vmail__ by default, to migrate mail accounts, just simply export this database on old server, then import it on new server.

* __IMPORTANT NOTE__: iRedMail-0.8.7 drops several SQL columns, so before you import backup SQL database, please add them first. It's safe to drop them after you imported database.
<pre>
mysql> USE vmail;

mysql> ALTER TABLE mailbox ADD COLUMN bytes BIGINT(20) NOT NULL DEFAULT 0;
mysql> ALTER TABLE mailbox ADD COLUMN messages BIGINT(20) NOT NULL DEFAULT 0;

mysql> ALTER TABLE domain ADD COLUMN defaultlanguage VARCHAR(5) NOT NULL DEFAULT 'en_US';
mysql> ALTER TABLE domain ADD COLUMN defaultuserquota BIGINT(20) NOT NULL DEFAULT '1024';
mysql> ALTER TABLE domain ADD COLUMN defaultuseraliases TEXT;
mysql> ALTER TABLE domain ADD COLUMN disableddomainprofiles VARCHAR(255) NOT NULL DEFAULT '';
mysql> ALTER TABLE domain ADD COLUMN disableduserprofiles VARCHAR(255) NOT NULL DEFAULT '';
mysql> ALTER TABLE domain ADD COLUMN defaultpasswordscheme VARCHAR(10) NOT NULL DEFAULT '';
mysql> ALTER TABLE domain ADD COLUMN minpasswordlength INT(10) NOT NULL DEFAULT 0;
mysql> ALTER TABLE domain ADD COLUMN maxpasswordlength INT(10) NOT NULL DEFAULT 0;

mysql> ALTER TABLE alias ADD COLUMN islist TINYINT(1) NOT NULL DEFAULT 0;
</pre>

After you imported backup SQL databases, please execute below commands to mark mail alias accounts and drop above newly created columns:
<pre>
mysql> USE vmail;
mysql> UPDATE alias SET islist=1 WHERE address NOT IN (SELECT username FROM mailbox);
mysql> UPDATE alias SET islist=0 WHERE address=domain;    -- domain catch-all account

-- Store values into new column: domain.settings and drop them
mysql> UPDATE domain SET settings='';
mysql> UPDATE domain SET settings=CONCAT(settings, IF(defaultlanguage IS NULL OR defaultlanguage='', '', CONCAT('default_language:', defaultlanguage, ';')));
mysql> UPDATE domain SET settings=CONCAT(settings, IF(defaultuserquota IS NULL OR defaultuserquota=0, '', CONCAT('default_user_quota:', defaultuserquota, ';')));
mysql> UPDATE domain SET settings=CONCAT(settings, IF(defaultuseraliases IS NULL OR defaultuseraliases='', '', CONCAT('default_groups:', defaultuseraliases, ';')));
mysql> UPDATE domain SET settings=CONCAT(settings, IF(minpasswordlength IS NULL OR minpasswordlength=0, '', CONCAT('min_passwd_length:', minpasswordlength, ';')));
mysql> UPDATE domain SET settings=CONCAT(settings, IF(maxpasswordlength IS NULL OR maxpasswordlength=0, '', CONCAT('max_passwd_length:', maxpasswordlength, ';')));
mysql> UPDATE domain SET settings=CONCAT(settings, IF(disableddomainprofiles IS NULL OR disableddomainprofiles='', '', CONCAT('disabled_domain_profiles:', disableddomainprofiles, ';')));
mysql> UPDATE domain SET settings=CONCAT(settings, IF(disableduserprofiles IS NULL OR disableduserprofiles='', '', CONCAT('disabled_user_profiles:', disableduserprofiles, ';')));

mysql> ALTER TABLE domain DROP defaultlanguage;
mysql> ALTER TABLE domain DROP defaultuserquota;
mysql> ALTER TABLE domain DROP defaultuseraliases;
mysql> ALTER TABLE domain DROP minpasswordlength;
mysql> ALTER TABLE domain DROP maxpasswordlength;
mysql> ALTER TABLE domain DROP disableddomainprofiles;
mysql> ALTER TABLE domain DROP disableduserprofiles;
</pre>

* __IMPORTANT NOTE__: There might be some changes in SQL structure, please read all upgrade tutorials for your running iRedMail version, then apply SQL structure related upgradings. For example: <http://www.iredmail.org/wiki/index.php?title=Upgrade/iRedMail/0.7.4-0.8.0#Add_internal_service_required_by_Doveadm_2>

##Migrate mailboxes (in maildir format)
* Simply copy all mailboxes (in maildir format) to new iRedMail server.
* Set correct file owner of mailboxes. Default is owned by user __vmail__, group __vmail__.
* Set correct file permission of mailboxes. Default is 0700.

WARNING: please make sure maildir path which stored/configured in LDAP
will match the real path on file system, so that mail clients can find
them.

##Important Notes for MySQL backend
__This section is applicable to iRedMail-0.7.3 and earlier versions, with MySQL backend. Not required in iRedMail-0.7.4 and later versions.__

Please refer to this section for more details: [Store realtime mailbox quota usage in seperate SQL table](http://iredmail.org/wiki/index.php?title=Upgrade/iRedMail/0.7.3-0.7.4#Store_realtime_mailbox_quota_usage_in_seperate_SQL_table) 

##Migrate Roundcube webmail data

* Export/import roundcube webmail database, and upgrade database to work with new version of Roundcube.
<http://trac.roundcube.net/wiki/Howto_Upgrade>

__IMPORTANT NOTES__
* Upcoming iRedMail-0.8.7 enforces secure smtp connection. client must issue 'STARTTLS' command to establish secure smtp connection before authentication, otherwise you will get __"SMTP error: Authentication failure"__ in Roundcube while sending email. To fix this error, you have to change smtp server address and port to below settings(config/config.inc.php):
<pre>
// Settings for Roundcube webmail 1.0.0 and later releases
$config['smtp_server'] = 'tls://127.0.0.1';
$config['smtp_port'] = 587;
</pre>

##Migrate Policyd database

Policyd database stores blacklist/whitelist, throttling, etc. To migrate its data, simply export this database on old server, then import it on new server.
