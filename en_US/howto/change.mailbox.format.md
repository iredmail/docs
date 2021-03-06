# Change per-user mailbox format (e.g. maildir, mdbox)

iRedMail uses `maildir` mailbox format by default, it's easy to backup, migrate
and recover.  As long as mailbox grows larger and larger, the performance will
be slower due to too much disk I/O - caused by `maildir` format. Dovecot's own
mailbox format `mdbox` has very good performance for large mailbox due to
reduced disk I/O.

You may want to switch to other mailbox format for some reason. To help you
switch easily, iRedMail-0.9.9 introduces 2 new SQL columns (for SQL backends)
and LDAP attributes (for LDAP backends) to help you switch per-user mailbox
format easily. All [mailbox formats supported by
Dovecot](https://wiki.dovecot.org/MailboxFormat) are supported in iRedMail.

!!! attention

    * If you're running an iRedMail release earlier than iRedMail-0.9.9, you can
      upgrade it by following [iRedMail upgrade tutorials](./iredmail.releases.html).
    * iRedAdmin-Pro RESTful API interface supports changing mailbox format too.
      Check its [API document](./iredadmin-pro.restful.api.html) (expand all
      parameters and search `mailboxformat` or `mailboxFormat`).

!!! warning

    With `mdbox` format, if mailbox index files are damaged or lost, mail
    messages will be lost. Because one of the main reasons for dbox's high
    performance is that it uses Dovecot's index files as the only storage for
    message flags and keywords, so the indexes don't have to be "synchronized".
    Dovecot trusts that they're always up-to-date (unless it sees that
    something is clearly broken).

    Please read documents on Dovecot website to make sure you fully understand
    the pros and (most importantly) cons of the format you're going to use:
    [Mailbox Formats](https://wiki.dovecot.org/MailboxFormat).

!!! warning

    - Changing mailbox format does not migrate existing mailbox for you. You
      have to migrate it __BEFORE__ switching to new mailbox format, then
      update SQL/LDAP data to use new mailbox format right after migrated the
      mailbox.
    - New mailbox format will be used by Dovecot immediately after SQL/LDAP change.

## SQL backends

You can switch to different mailbox format with SQL commands below. We use
MySQL for example here.

```
USE vmail;
UPDATE mailbox SET mailboxformat='mdbox', mailboxfolder='mdbox' where username="user@your-domain.com";
```

* Value of `mailboxfolder` can be any folder name supported by Linux/BSD file
  system, but value of `mailboxformat` must be one of the formats supported by
  Dovecot, e.g. maildir, sdbox, mdbox.
* Value of `mailboxfolder` can not be same as previously used one, otherwise
  old mailbox will be messed up when Dovecot delivers new email.

## LDAP backends

You need some LDAP management tool like [phpLDAPadmin](http://phpldapadmin.sourceforge.net/),
[Apache Directory Studio](https://directory.apache.org/studio/), or command
line tool `ldapvi` (you can install it with `yum` or `apt-get` command directly)
to update mail user's LDIF data.

```
mailboxFormat: mdbox
mailboxFolder: mdbox
```

* Value of `mailboxFolder` can be any folder name supported by Linux/BSD file
  system, but value of `mailboxFormat` must be one of the formats supported by
  Dovecot, e.g. maildir, sdbox, mdbox.
* Value of `mailboxfolder` can not be same as previously used one, otherwise
  old mailbox will be messed up when Dovecot delivers new email.
* With iRedMail-0.9.9, if attribute `mailboxFormat` and `mailboxFolder` don't
  present in user LDAP object, Dovecot is configured to use `maildir` as
  default mailbox format and `Maildir` (case-sensitive) as folder name.

## Reference

* [Doveadm Sync](https://wiki.dovecot.org/Tools/Doveadm/Sync). It mentions how
  to easily migrate existing mailbox to new mailbox format with `doveadm sync`
  command.
