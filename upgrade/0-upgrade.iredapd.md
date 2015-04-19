# Upgrade iRedAPD

> iRedAPD source code is hosted on [BitBucket](https://bitbucket.org/zhb/iredapd/).

> Release Notes are available here: [iRedAPD Release Notes](./iredapd.releases.html).

This tutorial describes how to upgrade iRedAPD from `1.4.0` or later releases
to the latest stable release. It's applicable on all Linux/BSD distributions
supported by iRedMail.

* Download the latest stable release here: [http://www.iredmail.org/yum/misc/](http://www.iredmail.org/yum/misc/)
  For example, iRedAPD-1.4.4.tar.bz2.
* Upload it to your iRedMail server. Assume it's `/root/iRedAPD-1.4.4.tar.bz2`.
* Extract downloaded package and execute upgrade script:

```
# cd /root
# tar xjf iRedAPD-1.4.4.tar.bz2
# cd iRedAPD-1.4.4/tools/
# bash upgrade_iredapd.sh
```

That's all.

----

Important notes:

* It's recommended to enable plugin `reject_null_sender` in iRedAPD-1.4.4 or
  newer releases to prevent authenticated user sending spam as null sender.

* Plugin `amavisd_wblist` and `amavisd_message_size_limit` requires access
  to Amavisd SQL database, if you're upgrading iRedAPD from iRedAPD-1.4.3
  or older releases, don't forget to copy `amavisd_db_*` settings from
  sample config file and set correct values:

```
# For Amavisd policy lookup
amavisd_db_server = '127.0.0.1'
amavisd_db_port = '3306'
amavisd_db_name = 'amavisd'
amavisd_db_user = 'amavisd'
amavisd_db_password = 'password'
```

* Plugin `amavisd_wblist` is required if you manage white/blacklists with
  iRedAdmin-Pro.

* Since version 1.4.4, iRedAPD supports other Postfix smtp protocol states,
  e.g. `END-OF-MESSAGE`, so you can enable iRedAPD in Postfix setting
  `smtpd_end_of_data_restrictions` like below:

    ```smtpd_end_of_data_restrictions = check_policy_service inet:127.0.0.1:7777, ...```

    Currently, only plugin `amavisd_message_size_limit` works in `END-OF-MESSAGE`
    state, other plugins work in `RCPT` state.
