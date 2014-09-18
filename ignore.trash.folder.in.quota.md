<http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/Ignore.Trash.Folder.in.Quota>
# How to ignore Trash folder in mailbox quota

Quota\_rule is overrode in `/etc/dovecot/dovecot-mysql.conf` or `/etc/dovecot/dovecot-ldap.conf`, so please change them instead. If no per-user quota rules found, Dovecot will use 'quota_ruleX' in dovecot.conf.

For example, with OpenLDAP backend, you have `/etc/dovecot/dovecot-ldap.conf`, update it with 'Trash:ignore' like below:

<pre>
user_attrs      = ...,mailQuota=quota_rule=*:bytes=%$,=quota_rule2=Trash:ignore
</pre>

With MySQL backend, update `/etc/dovecot/dovecot-mysql.conf`:

<pre>
user_query = SELECT ... \
                   CONCAT('*:bytes=', mailbox.quota*1048576) AS quota_rule \
                   'Trash:ignore' AS quota_rule2 \
                   FROM ...
</pre>
