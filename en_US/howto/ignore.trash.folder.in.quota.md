# Ignore Trash folder in mailbox quota

Per-user mailbox quota rule is defined in Dovecot, in one of below files:

* `/etc/dovecot/dovecot-mysql.conf`: MySQL backend
* `/etc/dovecot/dovecot-pgsql.conf`: PostgreSQL backend

If no per-user quota rules found, Dovecot will use `quota_rule[X]` defined in
`/etc/dovecot/dovecot.conf`. For example:

```
# File: /etc/dovecot/dovecot.conf

plugin {                                                                        

    quota = dict:user::proxy::quotadict
    quota_rule = *:storage=1G
    #quota_rule2 = *:messages=0
    #quota_rule3 = Trash:storage=1G
    #quota_rule4 = Junk:ignore

    ...
}
```

So, if you want to ignore quota of `Trash` folder, you can add new quota_rule
in either `/etc/dovecot/dovecot.conf` or `/etc/dovecot/dovecot-{mysql,pgsql,ldap}.conf`.

* Sample setting #1:

```
# File: /etc/dovecot/dovecot.conf

plugin {                                                                        

    quota = dict:user::proxy::quotadict
    quota_rule = *:storage=1G
    quota_rule2 = Trash:ignore      # <-- new quota rule, ignore Trash folder

    ...
}
```

* Sample setting #2:

```
# File: /etc/dovecot/dovecot-ldap.conf
user_attrs      = ...,mailQuota=quota_rule=*:bytes=%$,=quota_rule2=Trash:ignore

# File: /etc/dovecot/dovecot-mysql.conf, or dovecot-pgsql.conf
user_query = SELECT ... \
                   CONCAT('*:bytes=', mailbox.quota*1048576) AS quota_rule \
                   'Trash:ignore' AS quota_rule2 \      -- New quota rule, ignore Trash folder
                   FROM ...
```
