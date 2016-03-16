# Mailbox sharing (Sharing IMAP folder with other users)

!!! note

    * Since iRedMail-`0.9.0`, mailbox sharing are enabled by default, you don't
      need to modify any config file.
    * Since iRedMail-`0.7.0`, mailbox sharing related settings are configured
      in Dovecot but not enabled, what you need to do is enabling `acl` plugin
      as mentioned below.
    * Do not mistake "shared folders" for "public folders". For shared folders,
      users must select which folder they want to share and with who, using an
      interface, like IMAP command line or the ones available with Roundcube
      webmail or SOGo and SOGo connectors.

## Enable mailbox sharing

To enable mailbox sharing, please make sure you have plugin `acl` enabled
in Dovecot config file `/etc/dovecot/dovecot.conf` like below:

* For Dovecot-1.2:
```
# Part of file: /etc/dovecot/dovecot.conf

protocol lda {
    mail_plugins = ... acl
}

protocol imap {
    mail_plugins = ... acl imap_acl
}
```

* For Dovecot-2.x:
```
# Part of file: /etc/dovecot/dovecot.conf

mail_plugins = ... acl

protocol imap {
    mail_plugins = ... imap_acl
}
```

Restarting Dovecot service is required.

## Test shared folder

Example: share `from@domain.ltd`'s `Sent` folder to user `testing@domain.ltd`.

!!! warning

    Do not forget the dot before each IMAP command.

```
# telnet localhost 143                # <- Type this.
* OK [...] Dovecot ready.

. login from@domain.ltd passwd        # <- Type this.
                                      # Login with full email address and password
. OK [... ACL ..] Logged in

. SETACL Sent testing@domain.ltd rli  # <- Type this.
                                      # Share folder `Sent` with user testing@domain.ltd,
                                      # with permissions: read (r), lookup (l) and insert (i).
. OK Setacl complete.

^]                                    # <- Press `Ctrl + ]` to exit telnet.
telnet> quit
```

Log into Roundcube webmail or SOGo as user `testing@domain.ltd`, you should
see the shared folder.

Some more details:

* After you shared folder with `SETACL` command, dovecot will insert a record
  in MySQL database.

    * With OpenLDAP backend, it's stored in `iredadmin.share_folder`.
    * With MySQL/MariaDB/PostgreSQL backends, it's stored in `vmail.share_folder`.

```
# mysql -uroot -p
mysql> USE vmail;
mysql> SELECT * FROM share_folder;
+-----------------+--------------------+-------+
| from_user       | to_user            | dummy |
+-----------------+--------------------+-------+
| from@domain.ltd | testing@domain.ltd | 1     |
+-----------------+--------------------+-------+
```

## References

* Dovecot wiki:

    * [Mailbox sharing between users (v2.0+)](http://wiki2.dovecot.org/SharedMailboxes/Shared)
    * [Mailbox sharing between users (v1.2+)](http://wiki.dovecot.org/SharedMailboxes/Shared)

* Roundcubemail has official plugin `acl` to manage mailbox sharing.
* SOGo groupware supports mailbox sharing by default: right-click IMAP folder, choose `Sharing`.
* [Imap-ACL-Extension for Thunderbird](https://addons.mozilla.org/en-US/thunderbird/addon/imap-acl-extension/), manage acls/permissions for shared mailboxes/folders on imap servers.

## See Also

* [How to create and manage public folder](./public.folder.html)
