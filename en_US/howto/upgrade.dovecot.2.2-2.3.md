# Upgrade Dovecot from 2.2.x to 2.3.x

[TOC]

Dovecot 2.3 breaks some backward compatible, and here's a short tutorial to
convert your Dovecot 2.2 config file to fully work with Dovecot 2.3.

For more details, please read Dovecot wiki page: [Upgrading Dovecot v2.2 to v2.3](https://wiki2.dovecot.org/Upgrading/2.3).

!!! attention

    * Currently only FreeBSD offers Dovecot 2.3 by the ports tree, other Linux
      or OpenBSD distributions still offers Dovecot 2.2, you should stick to
      Dovecot 2.2 if your Linux/BSD vendor doesn't offer 2.3 yet.
    * Dovecot 2.3 uses TLSv1 as minimal SSL protocol, if you prefer TLSv1.1 or
      TLSv1.2, please set the protocol version in parameter `ssl_min_protocol`
      like below:

      ```
      ssl_min_protocol = TLSv1.2
      ```

## Upgrade Dovecot on Linux/FreeBSD/OpenBSD

Open a shell terminal, and switch to Dovecot configuration directory first:

* On Linux/OpenBSD:
```
cd /etc/dovecot/
```

* On FreeBSD:
    * Please upgrade ports `mail/dovecot` and `mail/dovecot-pigeonhole` first.
      You can use tool like `portmaster` or `portupgrade` for this purpose.
      FYI: [Using the Ports Collection](https://www.freebsd.org/doc/handbook/ports-using.html)
    * After upgraded both ports, please run:

```
cd /usr/local/etc/dovecot/
```

Run commands below as root user, these commands will:

* Comment out parameter `ssl_protocols`
* Remove parameter `postmaster_address`
* Rename plugin names and parameters:
    * `stats` -> `old_stats`
    * `imap_stats` -> `imap_old_stats`
    * `stats_refresh` -> `old_stats_refresh`
    * `service stats {}` -> `service old-stats {}`
    * `fifo_listener stats-mail {}` -> `fifo_listener old-stats-mail {}`
    * `stats_track_cmds` -> `old_stats_track_cmds`

```
perl -pi -e 's/^ssl_protocols/#${1}/g' dovecot.conf
perl -pi -e 's#(postmaster_address.*)##g' dovecot.conf
perl -pi -e 's#^(mail_plugins.*) stats(.*)#${1} old_stats${2}#g' dovecot.conf
perl -pi -e 's#imap_stats#imap_old_stats#g' dovecot.conf
perl -pi -e 's#service stats#service old-stats#g' dovecot.conf
perl -pi -e 's#fifo_listener stats-mail#fifo_listener old-stats-mail#g' dovecot.conf
perl -pi -e 's#stats_refresh#old_stats_refresh#g' dovecot.conf
perl -pi -e 's#stats_track_cmds#old_stats_track_cmds#g' dovecot.conf
```

* On RHEL/CentOS, please add new setting in `dovecot.conf`:

```
ssl_dh = </etc/pki/tls/dh2048_param.pem

service stats {
    unix_listener stats-reader {
        user = vmail
        group = vmail
        mode = 0660
    }

    unix_listener stats-writer {
        user = vmail
        group = vmail
        mode = 0660
    }
}
```

* On Debian/Ubuntu/OpenBSD/FreeBSD, please add new setting in `dovecot.conf`:

```
ssl_dh = </etc/ssl/dh2048_param.pem

service stats {
    unix_listener stats-reader {
        user = vmail
        group = vmail
        mode = 0660
    }

    unix_listener stats-writer {
        user = vmail
        group = vmail
        mode = 0660
    }
}
```

## SQL structure changes for MySQL/MariaDB/PostgreSQL backends

!!! warning

    If you upgraded iRedMail to `1.0` release, you should already have these
    SQL changes, please double check and not apply them blindly.

Dovecot-2.3 changes the flag for TLS secure connections internally, it's used
by iRedMail to detect the connection type. We need to create a new SQL column
for this change.

* For MySQL/MariaDB, please login to SQL server as root user, then run SQL
  commands below:

```
USE vmail;
ALTER TABLE mailbox ADD COLUMN enableimaptls TINYINT(1) NOT NULL DEFAULT 1;
ALTER TABLE mailbox ADD INDEX (enableimaptls);
ALTER TABLE mailbox ADD COLUMN enablepop3tls TINYINT(1) NOT NULL DEFAULT 1;
ALTER TABLE mailbox ADD INDEX (enablepop3tls);
ALTER TABLE mailbox ADD COLUMN enablesievetls TINYINT(1) NOT NULL DEFAULT 1;
ALTER TABLE mailbox ADD INDEX (enablesievetls);
```

* For PostgreSQL backend, please switch to PostgreSQL daemon user with `su`
  command first, then run SQL commands below:

```
\c vmail;
ALTER TABLE mailbox ADD COLUMN enableimaptls INT2 NOT NULL DEFAULT 1;
CREATE INDEX idx_mailbox_enableimaptls ON mailbox (enableimaptls);
ALTER TABLE mailbox ADD COLUMN enablepop3tls INT2 NOT NULL DEFAULT 1;
CREATE INDEX idx_mailbox_enablepop3tls ON mailbox (enablepop3tls);
ALTER TABLE mailbox ADD COLUMN enablesievetls INT2 NOT NULL DEFAULT 1;
CREATE INDEX idx_mailbox_enablesievetls ON mailbox (enablesievetls);
```

## LDAP changes for OpenLDAP/ldapd backends

We need to add new ldap attribute/value pairs for existing mail users.

* Download script used to update existing mail users:

```
cd /root/
wget https://raw.githubusercontent.com/iredmail/iRedMail/master/update/ldap/update-ldap-dovecot-2.3.py
```

* Open downloaded file `update-ldap-dovecot-2.3.py`, set LDAP server
  related settings in this file. For example:

```
# Part of file: update-ldap-dovecot-2.3.py

uri = 'ldap://127.0.0.1:389'
basedn = 'o=domains,dc=example,dc=com'
bind_dn = 'cn=vmailadmin,dc=example,dc=com'
bind_pw = 'password'
```

You can find required LDAP credential in iRedAdmin config file or
`iRedMail.tips` file under your iRedMail installation directory. Using either
`cn=Manager,dc=xx,dc=xx` or `cn=vmailadmin,dc=xx,dc=xx` as bind dn is ok, both
of them have read-write privilege to update mail accounts.

* Execute this script with Python-3, it will add required data:

```
python3 update-ldap-dovecot-2.3.py
```

