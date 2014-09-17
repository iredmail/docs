# How to force Dovecot to recalculate mailbox quota

iRedMail enables dict quota since iRedMail-0.7.0, dict quota is recalculated
only if the quota goes below zero

* For MySQL and PostgreSQL backend:

<pre>
mysql> USE vmail;
mysql> DELETE FROM used_quota WHERE username='user@domain.ltd';
</pre>

* For OpenLDAP backend:

<pre>
mysql> USE iredadmin;
mysql> DELETE FROM used_quota WHERE username='user@domain.ltd';
</pre>

Re-login via POP3/IMAP (or webmail) will trigger Dovecot to recalculate mailbox
quota.

__TIP__: it's safe to delete records in SQL table `used_quota` if mail user
was deleted in table `vmail.mailbox` or LDAP. iRedAdmin-Pro will handle this
for you automatically.
