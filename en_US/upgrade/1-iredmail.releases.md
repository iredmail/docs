# iRedMail release notes and upgrade tutorials

!!! attention

    * iRedMail source code: <https://github.com/iredmail/iRedMail>.
    * Download the [latest iRedMail stable release](https://www.iredmail.org/download.html).

[TOC]

### Why keep your iRedMail server up to date

* The latest iRedMail release brings new features, improvements, and bug fixes.
* If you plan to migrate to a new iRedMail server someday, migrating iRedMail
  to another server which runs the same release is the easiest path.

### How upgrading works

* Usually, upgrading iRedMail is just updating some config files to achieve new
  features or fix bugs, you do __NOT__ need to download and run the latest
  iRedMail installer (`bash iRedMail.sh`).

* __Do NOT skip releases__. Upgrades are only supported from one release to the
  release immediately following it.

* If you're looking for upgrading a very old iRedMail server to the latest
  iRedMail release, there's an alternative solution:
  [Migrating to a new iRedMail server](./migrate.to.new.iredmail.server.html).

### Release notes and upgrade tutorials

!!! note "Paid Remote Upgrade Support"

    We offer remote upgrade support if you don't want to get your hands dirty,
    check [the details](https://www.iredmail.org/support.html) and
    [contact us](https://www.iredmail.org/contact.html).

Release Notes | Date | Upgrade tutorial | Comment
---|---|---|---
[1.4.2](https://forum.iredmail.org/topic18407.html) | Sep 13, 2021 | [Upgrade from iRedMail-1.4.1](./upgrade.iredmail.1.4.1-1.4.2.html) | Contains SQL/LDAP structure change.
[1.4.1](https://forum.iredmail.org/topic18392.html) | Sep 8, 2021 | [Upgrade from iRedMail-1.4.0](./upgrade.iredmail.1.4.0-1.4.1.html) | Contains SQL/LDAP structure change.
[1.4.0](https://forum.iredmail.org/topic18033.html) | Apr 13, 2021 | [Upgrade from iRedMail-1.3.2](./upgrade.iredmail.1.3.2-1.4.0.html) | Contains SQL/LDAP structure change.
[1.3.2](https://forum.iredmail.org/topic17474.html) | Oct 28, 2020 | [Upgrade from iRedMail-1.3.1](./upgrade.iredmail.1.3.1-1.3.2.html) | Bug fix release.
[1.3.1](https://forum.iredmail.org/topic17065.html) | Jul 7, 2020 | [Upgrade from iRedMail-1.3](./upgrade.iredmail.1.3-1.3.1.html) | New Roundcube release (1.4.7) with one security fix.
[1.3](https://forum.iredmail.org/topic17020.html) | Jun 29, 2020 | [Upgrade from iRedMail-1.2.1](./upgrade.iredmail.1.2.1-1.3.html) | New Roundcube release (1.4.6) with few security fixes.
[1.2.1](https://forum.iredmail.org/topic16756.html) | Apr 30, 2020 | [Upgrade from iRedMail-1.2](./upgrade.iredmail.1.2-1.2.1.html) | New Roundcube release (1.4.4) with few security fixes.
[1.2](https://forum.iredmail.org/topic16714.html) | Apr 16, 2020 | [Upgrade from iRedMail-1.1](./upgrade.iredmail.1.1-1.2.html) | Bug fix release.
[1.1](https://forum.iredmail.org/topic16507.html) | Feb 11, 2020 | [Upgrade from iRedMail-1.0](./upgrade.iredmail.1.0-1.1.html) | Bug fix release.
[1.0](https://forum.iredmail.org/topic16275.html) | Dec 9, 2019 | [Upgrade from iRedMail-0.9.9](./upgrade.iredmail.0.9.9-1.0.html) | Contains SQL/LDAP structure change
[0.9.9](https://forum.iredmail.org/topic15064.html) | Dec 17, 2018 | [Upgrade from iRedMail-0.9.8](./upgrade.iredmail.0.9.8-0.9.9.html) | Contains SQL/LDAP structure change
[0.9.8](https://forum.iredmail.org/topic14077.html) | Apr 3, 2018 | [Upgrade from iRedMail-0.9.7](./upgrade.iredmail.0.9.7-0.9.8.html) | Contains SQL/LDAP structure change
[0.9.7](https://forum.iredmail.org/topic12944.html) | Jul 1, 2017 | [Upgrade from iRedMail-0.9.6](./upgrade.iredmail.0.9.6-0.9.7.html) | Contains SQL structure change
[0.9.6](https://forum.iredmail.org/topic12262.html) | Jan 23, 2017 | [Upgrade from iRedMail-0.9.5-1](./upgrade.iredmail.0.9.5.1-0.9.6.html) | Contains SQL/LDAP structure changes
[0.9.5-1](https://forum.iredmail.org/topic11049.html) | May 10, 2016 | [Upgrade from iRedMail-0.9.5](./upgrade.iredmail.0.9.5-0.9.5-1.html) | Small bug fix release
[0.9.5](https://forum.iredmail.org/topic10994.html) | May 3, 2016 | [Upgrade from iRedMail-0.9.4](./upgrade.iredmail.0.9.4-0.9.5.html) | Contains SQL/LDAP structure changes
[0.9.4](https://forum.iredmail.org/topic10512.html) | Jan 25, 2016 | [Upgrade from iRedMail-0.9.3](./upgrade.iredmail.0.9.3-0.9.4.html)
[0.9.3](https://forum.iredmail.org/topic10261.html) | Dec 14, 2015 | [Upgrade from iRedMail-0.9.2](./upgrade.iredmail.0.9.2-0.9.3.html) | Contains SQL/LDAP structure changes
[0.9.2](https://forum.iredmail.org/topic9280.html) | Jun 3, 2015 | [Upgrade from iRedMail-0.9.1](./upgrade.iredmail.0.9.1-0.9.2.html)
[0.9.1](https://forum.iredmail.org/topic9144.html) | May 15, 2015 | [Upgrade from iRedMail-0.9.0](./upgrade.iredmail.0.9.0-0.9.1.html) | Contains SQL/LDAP structure changes
[0.9.0](https://forum.iredmail.org/topic8443.html) | Dec 31, 2014 | [Upgrade from iRedMail-0.8.7](./upgrade.iredmail.0.8.7-0.9.0.html) | Contains SQL/LDAP structure changes
[0.8.7](https://forum.iredmail.org/topic6872-news-announcements-bug-fixes-iredmail087-has-been-released.html) | May 13, 2014 | [Upgrade from iRedMail-0.8.6](./upgrade.iredmail.0.8.6-0.8.7.html) | Contains SQL/LDAP structure changes
[0.8.6](https://forum.iredmail.org/topic5831-iredmail086-has-been-released.html) | Dec 16, 2013 | [Upgrade from iRedMail-0.8.5](./upgrade.iredmail.0.8.5-0.8.6.html)
[0.8.5](https://forum.iredmail.org/topic5167-news-announcements-bug-fixes-iredmail085-has-been-released.html) | Jul 16, 2013 | [Upgrade from iRedMail-0.8.4](./upgrade.iredmail.0.8.4-0.8.5.html)
[0.8.4](https://forum.iredmail.org/topic4646-news-announcements-bug-fixes-iredmail084-has-been-released.html) | Mar 26, 2013 | [Upgrade from iRedMail-0.8.3](./upgrade.iredmail.0.8.3-0.8.4.html)
[0.8.3](https://forum.iredmail.org/topic4016-news-announcements-bug-fixes-iredmail083-has-been-released.html) | Oct 13, 2012 | [Upgrade from iRedMail-0.8.2](./upgrade.iredmail.0.8.2-0.8.3.html)
[0.8.2](https://forum.iredmail.org/topic3913-news-announcements-bug-fixes-iredmail082-has-been-released.html) | Sep 19, 2012 | [Upgrade from iRedMail-0.8.1](./upgrade.iredmail.0.8.1-0.8.2.html)
[0.8.1](https://forum.iredmail.org/topic3499-news-announcements-bug-fixes-iredmail081-has-been-released.html) | Jun 8, 2012 | [Upgrade from iRedMail-0.8.0](./upgrade.iredmail.0.8.0-0.8.1.html)
[0.8.0](https://forum.iredmail.org/topic3345.html) | May 10, 2012 | [Upgrade from iRedMail-0.7.4](./upgrade.iredmail.0.7.4-0.8.0.html)
[0.7.4](https://forum.iredmail.org/topic2816-iredmail074-has-been-released.html) | Jan 9, 2012 | [Upgrade from iRedMail-0.7.3](./upgrade.iredmail.0.7.3-0.7.4.html)
0.7.3| Aug 17, 2011 | [Upgrade from iRedMail-0.7.2](./upgrade.iredmail.0.7.2-0.7.3.html)
0.7.2 | Jun 10, 2011 | [Upgrade from iRedMail-0.7.1](./upgrade.iredmail.0.7.1-0.7.2.html)
0.7.1 | May 1, 2011 | [Upgrade from iRedMail-0.7.0](./upgrade.iredmail.0.7.0-0.7.1.html)
0.7.0 | Apr 1, 2011 | [Upgrade from iRedMail-0.6.1](./upgrade.iredmail.0.6.1-0.7.0.html)
0.6.1 | Aug 14, 2010 | [Upgrade from iRedMail-0.6.0](./upgrade.iredmail.0.6.0-0.6.1.html)
0.6.0 | May 31, 2010 | [Upgrade from iRedMail-0.5.1](./upgrade.iredmail.0.5.1-0.6.0.html)
0.5.1 | Oct 31, 2009 | [Upgrade from iRedMail-0.5.1](./upgrade.iredmail.0.5.0-0.5.1.html)
0.5.0 | Aug 16, 2009 | [Upgrade from iRedMail-0.4.0](./upgrade.iredmail.0.4.0-0.5.0.html)
0.4.0 | Mar 10, 2009 | [Upgrade from iRedMail-0.3.2](./upgrade.iredmail.0.3.2-0.4.0.html)
0.3.2 | Dec 11, 2008
0.3.1 | Oct 21, 2008
0.3.0 | Sep 22, 2008
0.2 |  Aug 20, 2008
0.1 | Jun 28, 2008
