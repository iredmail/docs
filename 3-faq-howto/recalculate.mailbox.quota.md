<http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/Recalculate.Mailbox.Quota>
# How to recalculate mailbox quota
[TOC]

iRedMail enables dict quota since v0.7.0, dict quota is recalculated only if the quota goes below zero.

* For MySQL and PostgreSQL backend:
<pre>
#
# ---- For iRedMail-0.7.4 and later versions ----
#
mysql> USE vmail;
mysql> DELETE FROM used_quota WHERE username='user@domain.ltd';

#
# ---- For iRedMail-0.7.3 and earlier versions ----
#
mysql> USE vmail;
mysql> UPDATE mailbox SET bytes=-1,messages=-1 WHERE username='user@domain.ltd';
</pre>

* For OpenLDAP backend:
<pre>
mysql> USE iredadmin;
mysql> DELETE FROM used_quota WHERE username='user@domain.ltd';
</pre>

Re-login to webmail will get correct quota size.

If there're records for non-exist mail users in table ```used_quota```, please delete them.
