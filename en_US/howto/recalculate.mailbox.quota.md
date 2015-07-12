# Force Dovecot to recalculate mailbox quota

## Dovecot-2.x

Dovecot provides command line tool `doveadm` to recalcuate mailbox quota.
Sample usage:

* Recalculate one mailbox:
```
# doveadm quota recalc -u user@domain.ltd
```

* Recalculate ALL mail accounts:
```
# doveadm quota recalc -A
```

Reference: [Doveadm-Quota](http://wiki2.dovecot.org/Tools/Doveadm/Quota)

## Dovecot-1.x and Dovecot-2.x

iRedMail enables dict quota since iRedMail-0.7.0, dict quota is recalculated
only if the quota goes below zero.

* For MySQL and PostgreSQL backend:

```
mysql> USE vmail;
mysql> DELETE FROM used_quota WHERE username='user@domain.ltd';
```

* For OpenLDAP backend:

```
mysql> USE iredadmin;
mysql> DELETE FROM used_quota WHERE username='user@domain.ltd';
```

Re-login via POP3/IMAP (or webmail) will trigger Dovecot to recalculate mailbox
quota.

__TIP__: it's safe to delete records in SQL table `used_quota` if mail user
was deleted in table `vmail.mailbox` or LDAP. iRedAdmin-Pro will handle this
for you automatically.
