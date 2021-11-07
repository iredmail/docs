# LDAP: Bulk create mail users

[TOC]

iRedMail ships 2 scripts to help you create many mail users quickly.

* `tools/create_mail_user_OpenLDAP.sh` (shell script) will connect to LDAP
  server and add accounts directly.
* `tools/create_mail_user_OpenLDAP.py` (Python script) will read mail accounts
  from a plain text file and generate a LDIF file, you can import this LDIF
  file to create mail users.

## Create mail users with create_mail_user_OpenLDAP.sh

* Open this script and update some variables related to your LDAP server (note:
  you can find them in `iRedMail.tips` file):

    * `LDAP_SUFFIX`: the ldap suffix of your OpenLDAP server. default is
      `dc=example,dc=com`
    * `BINDPW`: password of LDAP root dn (`cn=Manager,dc=example,dc=com`).

    Notes:

    * Default password is same as username. if you prefer to set a password for all
      created users, please open the script and update variable `DEFAULT_PASSWD`
      with new password and set `USE_DEFAULT_PASSWD='YES'`.
    * Password scheme is defined in variable `PASSWORD_SCHEME` (or `CRYPT_MECH` in
      old iRedMail releases), default is `SSHA`.
    * Per-user mailbox quota is defined in variable `QUOTA`, default is
      `104857600` (100 MB, equals to 100 * 1024 * 1024).
    * Maildir path is hashed like  `domain.ltd/u/s/e/username-20150929`. If you
      prefer `domain.ltd/username/`, please set `MAILDIR_STYLE='normal'`.
    * Mailbox storage path is defined in variable `STORAGE_BASE_DIRECTORY`, default
      is `/var/vmail/vmail1`.

* Create mail users:

```shell
# cd iRedMail-0.9.6/tools/
# bash create_mail_user_OpenLDAP.sh example.com user1 user2 user3
```

It will create users `user1@example.com`, `user2@example.com`, `user3@example.com`.

Note: you don't need to create the mail domain name `example.com` with iRedAdmin first.

## Create mail users with create_mail_user_OpenLDAP.py

!!! attention

    You must modify this file and update some variables related to your LDAP
    server (note: you can find them in `iRedMail.tips` file) before importing
    user:

    - `LDAP_URI`. The URI of your ldap server, defaults to `ldap://127.0.0.1:389`.
    - `BASEDN`. The base dn which contains all mail accounts. Defaults to
      `o=domains,dc=example,dc=com`, you should replace `dc=example,dc=com`
      by your ldap suffix.
    - `BINDDN`. The bind dn used to update LDAP data. Defaults to
      `cn=Manager,dc=example,dc=com`. Note: this dn must have read and
      write privilege, so both `cn=Manager` and `cn=vmailadmin` are ok, but
      not `cn=vmail` (it has only read privilege).
    - `BINDPW`. Password of the bind dn.

    While importing the generated LDIF file, you should use same BINDDN which
    has write privilege.

`tools/create_mail_user_OpenLDAP.py` reads mail accounts from a plain
text file and generate a LDIF file, you can import this LDIF file later to
create the mail users.

Format of the plain text file is:

```
domain name, username, password, [display name], [quota_in_bytes], [groups]
```

Note: domain name, username and password are __required__, others are optional.

* __username__: do not append domain part (`@domain.com`) in username.
* __display name__:
    * It will be the same as username if it's empty.
    * Non-ascii character is allowed in this field, they will be
      encoded automaticly. Such as Chinese, Korea, Japanese, etc.
* __quota__: It will be 0 (unlimited quota) if it's empty.
* __groups__:
    * user will become member of specified groups.
    * it must be valid/existing group names without domain part (`@domain.com`).
      For example, group name `support` will become `support@domain.com` (the
      domain part will be appended automaticly).
    * Multiple groups must be seperated by colon `:`.
* Leading and trailing whitespaces will be ignored.

3 examples:

```
mydomain.com, user1, plain_password, John Smith, 104857600, group1:group2
mydomain.com, user2, plain_password, Michael Jordan, ,
mydomain.com, user3, plain_password, , 104857600, group1:group2
```

* Create mail domain `mydomain.com` with iRedAdmin first.
* Run this script with plain text file `my_users.csv`:

```
cd iRedMail-1.4.2/tools/
python3 create_mail_user_OpenLDAP.py my_users.csv
```

It generates file `my_users.csv.ldif` under same directory, 
import it with command `ldapadd` to add like below to add the accounts:
    * Please replace `cn=Manager,dc=example,dc=com` by the real LDAP base dn.
    * Please replace `my_users.csv.ldif` by the file generated in above commands.


```
ldapadd -x -D cn=Manager,dc=example,dc=com -W -f my_users.csv.ldif
```

Notes:

* Password scheme is defined in variable `DEFAULT_PASSWORD_SCHEME`, defaults to
  `SSHA512`.

    ```DEFAULT_PASSWORD_SCHEME = "SSHA512"```

* Path to mailbox storage is defined in variable `STORAGE_BASE_DIRECTORY`, default
  is `/var/vmail/vmail1`.

      ```STORAGE_BASE_DIRECTORY = "/var/vmail/vmail1"```

* Maildir path is hashed like  `domain.ltd/u/s/e/username-20150929`. If you
  prefer `domain.ltd/username/` style, please update parameter in the script:

      ```HASHED_MAILDIR = False```

      The mailbox path will become
      `/var/vmail/vmail1/domain.ltd/u/s/e/username-20150929/`, and Dovecot is
      configured to append `Maildir/` in the path, so the final path will be
      `/var/vmail/vmail1/domain.ltd/u/s/e/username-20150929/Maildir/`.

      Dovecot is configured to store per-user managesieve script (a.k.a
      mail filter rules) under `sieve/` directory, which will be
      `/var/vmail/vmail1/domain.ltd/u/s/e/username-20150929/sieve/`.

## See Also

* [SQL: Bulk create mail users](./sql.bulk.create.mail.users.html)
