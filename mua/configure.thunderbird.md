# Configure Thunderbird as mail client (POP3/IMAP, SMTP and global ldap address book)

[TOC]

iRedMail provides POP3S (POP3 over TLS), IMAPS (IMAP over TLS), SMTPS (SMTP over TLS) for receiving and sending emails by default.

## Create new mail account

To create a new mail account with Thunderbird, please click menu: `File -> New -> Mail Account`.

Add your name, email address and password in this screen.

![](./images/thunderbird/new.mail.account.png)

Click continue, it will detect IMAP and SMTP server automatically.

Note:

* Login username must be full email address. You may want to click `Edit` to ensure it is correct.
* If you want to use POP3 instead of IMAP, click "Edit" and change it to POP3 in this screen with port `110`, `STARTTLS`.

![](./images/thunderbird/new.mail.account.setup.png)

## Configure Thunderbird as POP3 client
Warning: Make sure you are using full email address as username.

![](./images/thunderbird/pop3.png)

## Configure Thunderbird as IMAP client

Warning: Make sure you are using full email address as username.

![](./images/thunderbird/imap.png)

## Configure Thunderbird to send mail via SMTP

Menu: Tools -> Account settings... -> Outgoing server (SMTP) -> Choose the server you are using.

Warning: Make sure you are using full email address as username.

![](./images/thunderbird/smtp.png)

## Use OpenLDAP as Global LDAP Address Book

__IMPORTANT NOTE__: Thunderbird won\'t show contacts in LDAP address book directly, but it works when you starting typing email address in recipient field while composing email.

Here we take Thunderbird 5.0 for example. Steps:

* Click `Address Book` in main Thunderbird window. 
* In Address Book window, click menu `File -> New -> LDAP Directory`.
* In tab `General`:
    * `Name`: use whatever name you like. e.g. Global LDAP Address Book.
    * `Hostname`: IP address or hostname of your iRedMail server.
    * `Base DN`: Base dn of your domain in LDAP directory. Normally, it's `domainName=domain.ltd,o=domains,dc=xxx,dc=xxx`. For example, `domainName=example.com,o=domains,dc=iredmail,dc=org`.
    * `Port Number`: 389. __Note__: If you prefer to connect to OpenLDAP server over SSL, please check the `Use secure connection (SSL)` under same tab.
    * `Bind DN`: It's full LDAP dn of your mail account. Normally, it's `mail=user@domain.ltd,ou=Users,domainName=domain.ltd,o=domains,dc=xxx,dc=xxx`. For example: `mail=john@example.com,ou=Users,domainName=example.com,o=domains,dc=iredmail,dc=org`.

* In tab `Advanced`:
    * `Don't return more than xxx results`: depends on how many accounts stored in same domain, you may want to increase or descrease it. Default value in 100.
    * `Scope`: Subtree.
    * `Search filter`: `(&(enabledService=mail)(enabledService=deliver)(enabledService=displayedInGlobalAddressBook)(|(objectClass=mailList)(objectClass=mailAlias)(objectClass=mailUser)))`
    * `Login method`: `Simple`.

* Now switch to tab `Offline`, click button `Download Now` to test your settings. It will prompt to input password for this LDAP server, just type password of your mail account. With correct bind dn and password, it will display `Replicated succeeded`.

That's all.
