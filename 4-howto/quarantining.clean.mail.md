# Quarantine clean mail into SQL database

To quarantine clean mails into SQL database, please follow below steps:

# Configure Amavisd to enable quarantining

* Edit Amavisd config file, find below settings and update them. If it doesn't exist, just add them.
    * on Red Hat Enterprise Linux, CentOS, Scientific Linux, it's `/etc/amavisd/amavisd.conf`.
    * on Debian/Ubuntu, it's `/etc/amavis/conf.d/50-user`.
    * on FreeBSD, it's `/usr/local/etc/amavisd.conf`.
    * on OpenBSD, it's `/etc/amavisd.conf`.

<pre>
$clean_quarantine_method = 'sql:';
$clean_quarantine_to = 'clean-quarantine';
</pre>

* Find policy bank 'MYUSERS', append two lines in this policy bank:

<pre>
$policy_bank{'MYUSERS'} = {
    ...
    clean_quarantine_method => 'sql:',
    final_destiny_by_ccat => {CC_CLEAN, D_DISCARD},
}
</pre>

* Make sure you have '@storage_sql_dsn' enabled. For example:

<pre>
@storage_sql_dsn = (
    ['DBI:mysql:database=amavisd;host=127.0.0.1;port=3306', 'amavisd', 'qAv9CYva0vHA1GCX0J9f23WJvqRzt7'],
);
</pre>

* Restart Amavisd service.

That's all. Now all clean emails sent by your mail users will be quarantined
into SQL database. if you have iRedAdmin-Pro, you can manage (release or delete)
quarantined emails with it.

* Screenshot of iRedAdmin-Pro for your reference 

* [View quarantined mails](http://www.iredmail.org/images/iredadmin/system_maillog_quarantined.png)
* [Expand quarantined mail to view mail headers and body](http://www.iredmail.org/images/iredadmin/system_maillog_quarantined_expanded.png) 
