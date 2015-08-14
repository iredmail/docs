# 在邮箱配额中忽略垃圾箱目录

在 Dovecot 中，针对单个用户的邮箱配额限制定义在下列文件之一：

* `/etc/dovecot/dovecot-mysql.conf`: MySQL 后端
* `/etc/dovecot/dovecot-pgsql.conf`: PostgreSQL 后端

如果没有针对单个用户的邮箱配额限制，Dovecot 将使用 `/etc/dovecot/dovecot.conf`
文件中的 `quota_rule[X]` 设置。例如：

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

因此，要忽略 `Trash` 目录的邮箱容量，可以在 `/etc/dovecot/dovecot.conf` 或
`/etc/dovecot/dovecot-{mysql,pgsql,ldap}.conf` 中增加新的配额规则（quota_rule）。

* 配置示例 1：

```
# File: /etc/dovecot/dovecot.conf

plugin {                                                                        

    quota = dict:user::proxy::quotadict
    quota_rule = *:storage=1G
    quota_rule2 = Trash:ignore      # <- 新配额规则：忽略 Trash 目录

    ...
}
```

* 配置示例 2:

OpenLDAP 后端：
```
# File: /etc/dovecot/dovecot-ldap.conf

user_attrs      = ...,mailQuota=quota_rule=*:bytes=%$,=quota_rule2=Trash:ignore
```

MySQL 或 PostgreSQL 后端：
# File: /etc/dovecot/dovecot-mysql.conf, or dovecot-pgsql.conf
user_query = SELECT ... \
                   CONCAT('*:bytes=', mailbox.quota*1048576) AS quota_rule \
                   'Trash:ignore' AS quota_rule2 \      -- 新配额规则：忽略 Trash 目录
                   FROM ...
```
