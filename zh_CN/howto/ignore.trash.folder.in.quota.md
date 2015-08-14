# 在邮箱配额中忽略垃圾箱目录

在 Dovecot 中针对单个用户的邮箱配额规格是由以下列明的其中一个配置文件决定的：

* `/etc/dovecot/dovecot-mysql.conf`: MySQL 后台
* `/etc/dovecot/dovecot-pgsql.conf`: PostgreSQL 后台

如果没有找到针对单个用户的邮箱配额文件， Dovecot 将会调用 `/etc/dovecot/dovecot.conf` 文件中的 'quota_rule[X]' 参数来替代，例如：

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

因此，要忽略配额中的 `Trash` 目录，你可以在 `/etc/dovecot/dovecot.conf` 或者 `/etc/dovecot/dovecot-{mysql,pgsql,ldap}.conf` 中增加新的配额规则（quota_rule）。

* 配置示例 #1:

```
# File: /etc/dovecot/dovecot.conf

plugin {                                                                        

    quota = dict:user::proxy::quotadict
    quota_rule = *:storage=1G
    quota_rule2 = Trash:ignore

    ...
}
```

* 配置示例 #2:

```
# File: /etc/dovecot/dovecot-ldap.conf
user_attrs      = ...,mailQuota=quota_rule=*:bytes=%$,=quota_rule2=Trash:ignore

# File: /etc/dovecot/dovecot-mysql.conf, or dovecot-pgsql.conf
user_query = SELECT ... \
                   CONCAT('*:bytes=', mailbox.quota*1048576) AS quota_rule \
                   'Trash:ignore' AS quota_rule2 \
                   FROM ...
```
