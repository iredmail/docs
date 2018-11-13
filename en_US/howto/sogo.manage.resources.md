# SOGo: Manage resources (Free/Busy)

[TOC]

> This tutorial is a slight rewritten of SOGo wiki tutorial for iRedMail:
> [Use Resources with SOGo](http://wiki.sogo.nu/ResourceConfiguration).

SOGo supports the management of resources like meeting rooms. A resource has,
just like a person, a calendar, an email address and may be invited to events.
The big difference is that resources auto accept invitations.

When you mark a mail user as a meeting room resource, SOGo will display its
Free/Busy info when you invite this user in a calendar event.


## OpenLDAP backend

### Add missing LDAP schema files

We need 2 new LDAP schema files, you can click links below to download them:

* [calresource](./files/sogo/calresource.schema). It's defined in
  [IETF draft](https://tools.ietf.org/id/draft-cal-resource-schema-03.txt)
  (not final yet). Contributed by Martin Lehman on the
  [SOGo mailing list](https://www.mail-archive.com/users@sogo.nu/msg05186.html)
  (in 29 April 2011).
* [calentry](./files/sogo/calentry.schema), defined in RFC 2739.

Upload downloaded schema files to iRedMail server which runs OpenLDAP backend,
copy them to default schema directory:

* On RHEL/CentOS, it's `/etc/openldap/schema/`
* On Debian/Ubuntu, it's `/etc/ldap/schema/`
* On FreeBSD, it's `/usr/local/etc/openldap/schema/`
* On OpenBSD, it's `/etc/openldap/schema/`

Edit OpenLDAP config file `slapd.conf` with your favourite text editor, add 2
new `include` directives right after the `iredmail.schema` line like
below:

* On RHEL/CentOS, it's `/etc/openldap/slapd.conf`
* On Debian/Ubuntu, it's `/etc/ldap/slapd.conf`
* On FreeBSD, it's `/usr/local/etc/openldap/slapd.conf`
* On OpenBSD, it's `/etc/openldap/slapd.conf`

!!! attention

    Please make sure you're using the correct schema directory.

```
# this line already exists
include /etc/openldap/schema/iredmail.schema

# Add below 2 new lines
include /etc/openldap/schema/calresource.schema
include /etc/openldap/schema/calentry.schema
```

Since we don't use any new ldap attribute names in LDAP query filter, no index
required for new attribute names.

Now restart OpenLDAP service.

### Add missing settings in SOGo config file

SOGo needs 2 parameters to understand which LDAP attributes it should query
to understand the resources:

* `KindFieldName`: specify the LDAP attribute name which stores resource type.

    SOGo will try to determine if the value of the field corresponds to either
    "group", "location" or "thing". If that’s the case, SOGo will consider the
    returned entry to be a resource.

* `MultipleBookingsFieldName`: specify the LDAP attribute name ewhich stores
  multiple booking type.

    The value of this LDAP attribute is the maximum number of concurrent events
    to which a resource can be part of at any point in time.

    * If this is set to __0__, or if the attribute is __missing__, it means no limit.
    * If set to __-1__, no limit is imposed but the resource will be marked as
      busy the first time it is booked.

Edit SOGo config file `sogo.conf`, add these 2 new parameters in the global
address book section like below:

* On RHEL/CentOS, it's `/etc/sogo/sogo.conf`
* On Debian/Ubuntu, it's `/etc/sogo/sogo.conf`
* On FreeBSD, it's `/usr/local/etc/sogo/sogo.conf`
* On OpenBSD, it's `/etc/sogo/sogo.conf`

```
    SOGoUserSources = (
        ...
        {
            // Used for global address book
            type = ldap;
            id = global_addressbook;
            ...

            // Add below 2 lines
            KindFieldName = "Kind";
            MultipleBookingsFieldName = "MultipleBookings";
        }
        ...
```

Now restart SOGo service.

### Testing

We use mail domain name `example.com` for example below, you need to replace it
by your real domain name during testing.

* Create a testing mail user with iRedAdmin. for example, user `meetingroom@example.com`.
* Install package `ldapvi` on iRedMail server, then run command `ldapvi` like this:

!!! attention

    * `ldapvi` is like vi/vim text editor for editing LDIF data directly.
    * You need to replace `dc=xx,dc=xx` by the real LDAP suffix.
    * It will ask you to input password of `cn=manager,dc=xx,dc=xx`.

```
ldapvi -D 'cn=manager,dc=xx,dc=xx' -b 'o=domains,dc=xx,dc=xx' -W "mail=meetingroom@example.com"
```

In the ldapvi editor, you should see full LDIF data of user
`meetingroom@example.com`. Please append few lines for this user:

```
objectClass: CalendarResource
objectClass: calEntry
Kind: location
MultipleBookings: 1
```

Save your change and quit ldapvi (just like quitting vi/vim text editor).

* Login to SOGo webmail as `meetingroom@example.com`, then click the `Calendar`
  icon on top-right corner.

* Click the three-dot icon beside `Personal Calendar`, and choose `Sharing...`.
* In the popup modal window, click `Any Authenticated User`, set values of
  options `Public`, `Confidential` and `Private` to `View the Date & Time`.
  Save your changes.

![](./images/sogo/resources/access-rights.png){: width=600px }

* Now logout of SOGo webmail, re-login as a different user under same domain.
* Create a new testing event, invite `meetingroom@example.com` as attendee.
* Create second testing event in same day as first event, invite
  `meetingroom@example.com` as attendee, this time SOGo will indicate
  `meetingroom@example.com` is busy in the time window of first event.

![](./images/sogo/resources/free-busy.png){: width=600px }

## References

* [Use Resources with SOGo](http://wiki.sogo.nu/ResourceConfiguration)
