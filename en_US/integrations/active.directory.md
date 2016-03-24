# Integrate Microsoft Active Directory in iRedMail

[TOC]

__NOTES__:

* iRedAdmin-Pro doesn't work with Active Directory, so if you choose to
  authenticate mail users against Active Directory, you have to manage mail
  accounts with Active Directory management tools.

* This tutorial has been verified on Windows 2000, 2003, 2008, 2012 server, if
  you tested it on other versions and works well, please let us know.
  [Contact us](http://www.iredmail.org/contact.html)

## Summary

With Active Directory (AD) integration, you can get below features:

* User authentication against Windows Active Directory. You can now manage mail
  user accounts, mail lists with AD.
* Mail list support with group in AD.
* Global LDAP Address Book with AD in Roundcube Webmail.
* Account status support. Disable user in AD will cause this account disabled
  in iRedMail.

Since AD uses different LDAP schema, you will lose some iRedMail special features. e.g.

* Per-user, per-domain service control with LDAP (e.g. enable/disable
  POP3/IMAP/SMTP services).
* Advanced mail polices implemented by iRedAPD which relies on iRedMail
  LDAP scheme.

## Requirements

To integrate Microsoft Active Directory with iRedMail, you should have:

* A working Linux/BSD server with iRedMail (OpenLDAP backend) installed.
* A working Microsoft Windows (2000/2003) server, with Active Directory
  installed and working properly, listen on port 389 (ldap://) or 636
  (ldaps://), and allow LDAP connections from iRedMail server.

## Install iRedMail

Please follow [iRedMail installaion guides](./index.html)
to install iRedMail on Linux/BSD with OpenLDAP backend first, we will
achieve this AD integration by simply modifying some configure files.

## Integrate Microsoft Active Directory with Postfix

We assume:

* Hostname of your AD server is `ad.example.com`, listen on port `389`. And it's
  accessible from iRedMail server.

    * We will use this hostname below, you can replace it by IP address of this
       AD server if you want.
    * If you want to force LDAP connection with LDAPS, use port `636` instead.

* Base dn in AD is `dc=example,dc=com`, email addresses of all users end with
  `@example.com` (Your mail domain is `example.com`).
* All user accounts and mail list accounts are placed under dn
  `cn=Users,dc=example,dc=com`. __Note:__ LDAP dn is case-insensitive.
* For ldap connection, protocol version `3` is recommended.
* Store all mails on Linux/BSD servers, not on AD server.

    * Storage directory is `/var/vmail/vmail1`, same as default in iRedMail.
    * Mailbox of user `support@example.com` will be
       `/var/vmail/vmail1/example.com/support/Maildir/` (Maildir format).

### Create user account in AD, used for LDAP query

With iRedMail (OpenLDAP backend), we have a low-privileged account
`cn=vmail,dc=xxx,dc=xxx` with read-only privilege. And we suggest you create a
same account `vmail` in AD, with strong and complex password.

__NOTE__: [Dovecot will treat characters as comment after a inline `#`, so
please just don't use `#` in password](http://www.iredmail.org/forum/post8630.html#p8630)

Please make sure this newly created user is able to connect to AD server with
below command on iRedMail server:

```shell
# ldapsearch -x -h ad.example.com -D 'vmail' -W -b 'cn=users,dc=example,dc=com'
Enter password: password_of_vmail
```

If it prints all users stored in AD server, then it's working as expected.

### Enable LDAP query with AD in Postfix

Disable unused iRedMail special settings:

```shell
# postconf -e virtual_alias_maps=''
# postconf -e sender_bcc_maps=''
# postconf -e recipient_bcc_maps=''
# postconf -e relay_domains=''
# postconf -e relay_recipient_maps=''
```

Add your mail domain name in `smtpd_sasl_local_domain` and `virtual_mailbox_domains`:

```shell
# postconf -e smtpd_sasl_local_domain='example.com'
# postconf -e virtual_mailbox_domains='example.com'
```

Change transport maps setting:

```
# postconf -e transport_maps='hash:/etc/postfix/transport'
```

Enable AD query. __Note__: We will create these 3 files later.

* Verify SMTP senders

```shell
# postconf -e smtpd_sender_login_maps='proxy:ldap:/etc/postfix/ad_sender_login_maps.cf'
```

* Verify local mail users

```shell
# postconf -e virtual_mailbox_maps='proxy:ldap:/etc/postfix/ad_virtual_mailbox_maps.cf'
```

* Verify local mail lists/groups.

```
# postconf -e virtual_alias_maps='proxy:ldap:/etc/postfix/ad_virtual_group_maps.cf'
```

* Create/edit file: `/etc/postfix/transport`.

```
example.com dovecot
```

__Note__: `dovecot` used here is a Postfix transport defined in
`/etc/postfix/master.cf`, used to deliver received emails to local user mailboxes.

Run `postmap` so that postfix can read it:

```
# postmap hash:/etc/postfix/transport
```

* Create file: `/etc/postfix/ad_sender_login_maps.cf`:

```
server_host     = ad.example.com
server_port     = 389
version         = 3
bind            = yes
start_tls       = no
bind_dn         = vmail
bind_pw         = password_of_vmail
search_base     = cn=users,dc=example,dc=com
scope           = sub
query_filter    = (&(userPrincipalName=%s)(objectClass=person)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))
result_attribute= userPrincipalName
debuglevel      = 0
```

* Create file: `/etc/postfix/ad_virtual_mailbox_maps.cf`:

```
server_host     = ad.example.com
server_port     = 389
version         = 3
bind            = yes
start_tls       = no
bind_dn         = vmail
bind_pw         = passwd_of_vmail
search_base     = cn=users,dc=example,dc=com
scope           = sub
query_filter    = (&(objectclass=person)(userPrincipalName=%s))
result_attribute= userPrincipalName
result_format   = %d/%u/Maildir/
debuglevel      = 0
```

__Note__: Here, we hard-code user's mailbox path in
`[domain]/[username]/Maildir/` format (`result_format` parameter). for example:
`example.com/postmaster/Maildir/`.

* Create file: `/etc/postfix/ad_virtual_group_maps.cf`:

```
server_host     = ad.example.com
server_port     = 389
version         = 3
bind            = yes
start_tls       = no
bind_dn         = vmail
bind_pw         = password_of_vmail
search_base     = cn=users,dc=example,dc=com
scope           = sub
query_filter    = (&(objectClass=group)(mail=%s))
special_result_attribute = member
leaf_result_attribute = mail
result_attribute= userPrincipalName
debuglevel      = 0
```

__Note__:

* If your user have email address in both `mail` and `userPrincipalName`, you
  will get duplicate result. Comment out `leaf_result_attribute` line will fix it.
* If your mail group account doesn't contain attribute `mail` and
  `userPrincipalName`, please try `query_filter = (&(objectClass=group)(sAMAccountName=%u))` instead.

Also, we need to remove iRedAPD related settings in Postfix:

1. Open Postfix config file `/etc/postfix/main.cf`
1. Remove setting `check_policy_service inet:127.0.0.1:7777`.

### Verify LDAP query with AD in Postfix

We can now use command line tool `postmap`  to verify AD integration in postfix.
Before testing, we have to create two testing mail accounts first:

1. Create a mail user in AD. e.g. `user@example.com`.
1. Create a mail group in AD. e.g. `testgroup@example.com`, then assign mail
   user `user@example.com` as group member.
1. Query mail user account with below command:

```shell
# postmap -q user@example.com ldap:/etc/postfix/ad_virtual_mailbox_maps.cf
example.com/user/Maildir/
```

If nothing returned by the command, it means LDAP query doesn't get expected
result. Please set `debuglevel = 1` file `/etc/postfix/ad_virtual_mailbox_maps.cf`,
then query again, it now will print detailed debug message. If you're not
familiar with LDAP related info, please post the debug message in our
[online support forum](http://www.iredmail.org/forum/) to get help.

Verify sender login check:

```
# postmap -q user@example.com ldap:/etc/postfix/ad_sender_login_maps.cf
user@example.com
```

Verify mail group

```
# postmap -q testgroup@example.com ldap:/etc/postfix/ad_virtual_group_maps.cf
user@example.com
```

__NOTE__: `postmap` return nothing if:

1. mail group doesn't exist
1. mail group doesn't have any members

### Remove iRedAPD integration in Postfix

iRedAPD relies on iRedMail LDAP scheme, so it's useless if you integrate
iRedMail with Active Directory. We should remove the integration in Postfix
to save some system resource.

To disable iRedAPD, please read tutorial: [Manage iRedAPD](./manage.iredapd.html).

## Enable Active Directory integration in Dovecot

To query AD instead of local LDAP server, we have to modify Dovecot config file
`/etc/dovecot/dovecot-ldap.conf` like below:

```
hosts           = ad.example.com:389
ldap_version    = 3
auth_bind       = yes
dn              = vmail
dnpass          = passwd_of_vmail
base            = cn=users,dc=example,dc=com
scope           = subtree
deref           = never
user_filter     = (&(userPrincipalName=%u)(objectClass=person)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))
pass_filter     = (&(userPrincipalName=%u)(objectClass=person)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))
pass_attrs      = userPassword=password
default_pass_scheme = CRYPT
user_attrs      = =home=/var/vmail/vmail1/%Ld/%Ln/Maildir/,=mail=maildir:/var/vmail/vmail1/%Ld/%Ln/Maildir/
```

Restart dovecot service to make it work.

__Note__: we don't have per-user quota limit here, you can set a hard-coded
quota for all users in `/etc/dovecot/dovecot.conf`. For example:

```
plugin {
    [... omit other settings here ...]

    # Format: integer number + M/G/T (M -> MB, G -> GB, T -> TB).
    quota_rule = *:storage=1G
}
```

Now use command `telnet` to verify AD query after restarted Dovecot service:

```
# telnet localhost 143                     # <- Type this
* OK [...] Dovecot ready.

. login user@example.com password_of_user  # <- Type this. Do not miss the dot in the beginning
. OK [...] Logged in

^]                                         # <- Quit telnet with "Ctrl+]", then type 'quit'.
```

Note: Do NOT miss the dot character before `login` command. if it returns
`Logged in`, then dovecot + AD works.

## Enable Active Directory integration in Roundcube webmail for Global LDAP Address Book

Edit roundcube config file `config/config.inc.php`, comment out the LDAP
address book setting added by iRedMail, and add new setting for AD like below:

* on RHEL/CentOS and OpenBSD: it's `/var/www/roundcubemail/config/config.inc.php`
* on Debian/Ubuntu: it's `/usr/share/apache2/roundcubemail/config/config.inc.php`
* on FreeBSD: it's `/usr/local/www/roundcubemail/config/config.inc.php`

```php
#
# "sql" is personal address book stored in roundcube database.
# "global_ldap_abook" is the new LDAP address book for AD, we will create it below.
#
$config['autocomplete_addressbooks'] = array("sql", "global_ldap_abook");

#
# Global LDAP Address Book with AD.
#
$config['ldap_public']["global_ldap_abook"] = array(
    'name'          => 'Global Address Book',
    'hosts'         => array("ad.example.com"), // <- Set AD hostname or IP address here.
    'port'          => 389,
    'use_tls'       => false,   // <- Set to true if you want to use LDAP over TLS.
    'ldap_version'  => '3',
    'network_timeout' => 10,
    'user_specific' => false,

    'base_dn'       => "cn=users,dc=example,dc=com", // <- Set base dn in AD
    'bind_dn'       => "vmail",             // <- bind dn
    'bind_pass'     => "password_of_vmail", // <- bind password
    'writable'      => false,               // <- Do not allow mail user write data back to AD.

    'search_fields' => array('mail', 'cn', 'sAMAccountName', 'displayname', 'sn', 'givenName'),

    // mapping of contact fields to directory attributes
    'fieldmap' => array(
        'name'        => 'cn',
        'surname'     => 'sn',
        'firstname'   => 'givenName',
        'title'       => 'title',
        'email'       => 'mail:*',
        'phone:work'  => 'telephoneNumber',
        'phone:mobile' => 'mobile',
        'street'      => 'street',
        'zipcode'     => 'postalCode',
        'locality'    => 'l',
        'department'  => 'departmentNumber',
        'notes'       => 'description',
        'name'        => 'cn',
        'surname'     => 'sn',
        'firstname'   => 'givenName',
        'title'       => 'title',
        'email'       => 'mail:*',
        'phone:work'  => 'telephoneNumber',
        'phone:mobile' => 'mobile',
        'phone:workfax' => 'facsimileTelephoneNumber',
        'street'      => 'street',
        'zipcode'     => 'postalCode',
        'locality'    => 'l',
        'department'  => 'departmentNumber',
        'notes'       => 'description',
        'photo'       => 'jpegPhoto',
    ),
    'sort'          => 'cn',
    'scope'         => 'sub',
    'filter'        => "(&(objectclass=person)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))",
    'fuzzy_search'  => true,
    'vlv'           => false,   // Enable Virtual List View to more
                                // efficiently fetch paginated data
                                // (if server supports it)
    'sizelimit'     => '0',     // Enables you to limit the count of
                                // entries fetched. Setting this to 0
                                // means no limit.
    'timelimit'     => '0',     // Sets the number of seconds how long
                                // is spend on the search. Setting this
                                // to 0 means no limit.
    'referrals'     => false,   // Sets the LDAP_OPT_REFERRALS option.
                                // Mostly used in multi-domain Active
                                // Directory setups
);
```

## Additions documents

* If your mail domain name is different than Windows Active Directory domain: [http://www.iredmail.org/forum/topic3165-integration-with-windows-domain.html](http://www.iredmail.org/forum/topic3165-integration-with-windows-domain.html)
