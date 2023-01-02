# Migrate or upgrade iRedAdmin / iRedAdmin-Pro

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

!!! attention

    Since iRedAdmin-0.9.2 (open source edition), and iRedAdmin-Pro-SQL-3.0,
    iRedAdmin-Pro-LDAP-3.2, iRedAdmin or iRedAdmin-Pro is running as a
    standalone service named "iredadmin", each time you modified its config
    file, please restart the service ("iredadmin").

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

* iRedAdmin open source edition is available for [download here](https://github.com/iredmail/iRedAdmin/tags).
  Downloaded file might be in `<version>.tar.gz` format, e.g. `1.2.tar.gz`,
  please rename it to `iRedAdmin-1.2.tar.gz` instead.
* iRedAdmin-Pro customers can get download link of new release by following
  steps below:
    * Login to iRedAdmin-Pro as global admin.
    * Click `License` button on the top-right corner. it will show you basic
      license info and a `Download` button if new version is available.
    * Click `Download` button, your mailbox (license owner) will receive an email
      with download link in a short time. Note: if your mail server has greylisting
      enabled, it may take longer, please be patient and don't request download
      link again and again.

    If you cannot download iRedAdmin-Pro for some reason, please [contact us](https://www.iredmail.org/contact.html).

## Upgrade Steps

* Upload or copy the latest iRedAdmin to your server which has iRedAdmin
  open source edition or old iRedAdmin-Pro release running. We assume you
  uploaded it to `/root/iRedAdmin-x.y.z.tar.bz2` (`x.y.z` is a placeholder of
  the version number).
* Uncompress and upgrade iRedAdmin:

!!! warning

    - Do not rename the extracted directory (`iRedAdmin-x.y.z`), otherwise
      upgrade may fail.
    - iRedAdmin open source edition is packed as `.tar.gz` (compressed with
      gzip) file, but iRedAdmin-Pro is `.tar.bz2` (compressed with bzip2).

For iRedAdmin open source edition:

```
cd /root/
tar zxf iRedAdmin-x.y.z.tar.gz
cd iRedAdmin-x.y.z/tools/
sudo bash upgrade_iredadmin.sh
```

For iRedAdmin-Pro:

```
cd /root/
tar xjf iRedAdmin-Pro-x.y.z.tar.bz2
cd iRedAdmin-Pro-x.y.z/tools/
sudo bash upgrade_iredadmin.sh
```

That's all. If it doesn't work for you, please post a new topic in our
[online support forum](https://forum.iredmail.org/).
