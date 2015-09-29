# LDAP: Bulk create mail users

iRedMail ships 2 scripts to help you create many mail users quickly.

* `tools/create_mail_user_OpenLDAP.sh` (shell script) will connect to LDAP
  server and add accounts directly.
* `tools/create_mail_user_OpenLDAP.py` (Python script) will read mail accounts
  from a plain text file and generate a LDIF file, you can import this LDIF
  file to create mail users.

## Create mail users with `tools/create_mail_user_OpenLDAP.sh`

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
      `1048576000` (100 MB, equals to 100 * 1024 * 1024).
    * Maildir path is hashed like  `domain.ltd/u/s/e/username-20150929`. If you
      prefer `domain.ltd/username/`, please set `MAILDIR_STYLE='normal'`.
    * Mailbox storage path is defined in variable `STORAGE_BASE_DIRECTORY`, default
      is `/var/vmail/vmail1`.

* Create mail users:

```shell
# cd iRedMail-0.9.2/tools/
# bash create_mail_user_OpenLDAP.sh example.com user1 user2 user3
```

It will create users `user1@example.com`, `user2@example.com`, `user3@example.com`.

Note: you don't need to create the mail domain name `example.com` with iRedAdmin first.

## Create mail users with `tools/create_mail_user_OpenLDAP.py`

`tools/create_mail_user_OpenLDAP.py` will read mail accounts from a plain
text file and generate a LDIF file, you can import this LDIF file to create
mail users.

The plain text file format is:

```
domain name, username, password, [common name], [quota_in_bytes], [groups]
```

Note: domain name, username and password are __required__, others are optional.

* __username__: do not append `@domain.com` part in username.
* __common name__:
    * It will be the same as username if it's empty.
    * Non-ascii character is allowed in this field, they will be
      encoded automaticly. Such as Chinese, Korea, Japanese, etc.
* __quota__: It will be 0 (unlimited quota) if it's empty.
* __groups__:
    * user will become member of specified groups.
    * it must be valid group names without `@domain.com` part. for example,
      use `support` for group `support@domain.com`. The `@domain.com` part
      will be appended automaticly.
    * Multiple groups must be seperated by colon `:`.
* Leading and trailing Space will be ignored.

3 examples:

```
mydomain.com, user1, plain_password, John Smith, 104857600, group1:group2
mydomain.com, user2, plain_password, Michael Jordan, ,
mydomain.com, user3, plain_password, , 104857600, group1:group2
```

* Now create mail domain `mydomain.com` with iRedAdmin first.
* Run this script with plain text file `my_users.csv`:

```
# cd iRedMail-0.9.2/tools/
# python create_mail_user_OpenLDAP.py my_users.csv
```

It will generate a plain LDIF file `my_users.csv.ldif` under current directory,
you can import it (after reviewed the LDIF data) with command `ldapadd` like
below:

```
# ldapadd -x -D cn=Manager,dc=example,dc=com -W -f the_output_file.ldif
```

Notes:

* Please replace `cn=Manager,dc=example,dc=com` by the real LDAP root dn.
* Please replace `the_output_file.ldif` by the real output file.

Additional Notes:

* Password scheme is defined in variable `DEFAULT_PASSWORD_SCHEME`, default is
  `SSHA`.
* Maildir path is hashed like  `domain.ltd/u/s/e/username-20150929`. If you
  prefer `domain.ltd/username/`, please set `HASHED_MAILDIR = False`.
* Mailbox storage path is defined in variable `STORAGE_BASE_DIRECTORY`, default
  is `/var/vmail/vmail1`.


## See Also

* [SQL: Bulk create mail users](./sql.bulk.create.mail.users.html)
