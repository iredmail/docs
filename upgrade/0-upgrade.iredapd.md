# Upgrade iRedAPD

> iRedAPD source code is hosted on [BitBucket](https://bitbucket.org/zhb/iredapd/overview).

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

Important notes:

* Plugin `amavisd_wblist` is required if you manage white/blacklists with
  iRedAdmin-Pro.

* It's recommended to enable plugin `reject_null_sender` in iRedAPD-1.4.4 or
  newer releases to prevent authenticated user sending spam as null sender.

* Since version 1.4.4, iRedAPD supports Postfix smtp protocol state
  `END-OF-MESSAGE`, so you can enable iRedAPD in Postfix parameter
  `smtpd_end_of_data_restrictions` like below:

    ```smtpd_end_of_data_restrictions = check_policy_service inet:127.0.0.1:7777, ...```

    Currently, only plugin `amavisd_message_size_limit` works in `END-OF-MESSAGE`
    state, other plugins work in `RCPT` state.
  
* If you want to develop your own plugin for iRedAPD, please read document
  `README_PLUGINS.md` in iRedAPD source code.
