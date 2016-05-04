# Migrate or upgrade iRedAdmin

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](../support.html) and [contact us](../contact.html).

This tutorial describes how to update or migrate iRedAdmin (either open source
edition or old iRedAdmin-Pro release) to the latest iRedAdmin release (again,
either open source edition or iRedAdmin-Pro).

## Requirements

1. The latest iRedAdmin-Pro always requires the latest iRedMail stable release,
   so you __MUST__ upgrade iRedMail to the latest stable release before
   upgrading iRedAdmin-Pro.

    * If you run the latest iRedAdmin-Pro with old iRedMail release, you may
      get error due to missing some required ldap attribute/value pairs
      (OpenLDAP backend), or missing some required SQL columns.
     
    * If you run the latest iRedMail with old iRedAdmin-Pro, you may get error
      due to missing dropped SQL columns, or created accounts may miss some
      properties required by the latest iRedMail.

1. You __MUST__ have iRedAdmin open source edition or old iRedAdmin-Pro release
   installed and running on your server before upgrading.

## Download the latest iRedAdmin

* iRedAdmin open source edition is available for download [here](http://www.iredmail.org/yum/misc/).
* iRedAdmin-Pro customers can get download link of new release by following
  steps below:
    * Login to iRedAdmin-Pro as global admin.
    * Click `License` button on the top-right corner. it will show you basic
      license info and a `Download` button if new version is available.
    * Click `Download` button, your mailbox (license owner) will receive an email
      with download link in a short time. Note: if your mail server has greylisting
      enabled, it may take longer, please be patient and don't request download
      link again and again.

    If you cannot download iRedAdmin-Pro for some reason, please [contact us](../contact.html).

## Upgrade Steps

* Upload or copy the latest iRedAdmin to your server which has iRedAdmin
  open source edition or old iRedAdmin-Pro release running. We assume you
  uploaded it to `/root/iRedAdmin-x.y.z.tar.bz2` (`x.y.z` is a placeholder of
  the version number).
* Uncompress and upgrade iRedAdmin:

```
# cd /root/
# tar xjf iRedAdmin-x.y.z.tar.bz2
# cd iRedAdmin-x.y.z/tools/
# bash upgrade_iredadmin.sh
```

That's all. If it doesn't work for you, please post a new topic in our
[online support forum](http://www.iredmail.org/forum/).

## Additional steps

* To quarantine SPAM/Virus into SQL database and manage them with
  iRedAdmin-Pro, please follow this tutorial to update Amavisd settings:
  [Quarantining SPAM and Virus emails into SQL database](./quarantining.html)

* To manage white/blacklist with iRedAdmin-Pro, please enable
  per-recipient policy lookup in Amavisd, and enable plugin `amavisd_wblist`
  in iRedAPD config file (`/opt/iredapd/settings.py`, parameter `plugins =`):
  [Amavisd: Enable per-recipient policy lookup](./amavisd.per-recipient.policy.lookup.html)

    Note: Cluebringer still provides white/blacklists, but iRedAdmin-Pro
    doesn't manage them anymore after iRedMail-0.9.0 release. So please
    migreate Cluebringer white/blacklists to Amavisd database by following
    this [forum post](http://www.iredmail.org/forum/post35480.html#p35480).
