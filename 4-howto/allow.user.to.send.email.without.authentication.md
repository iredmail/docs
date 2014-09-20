# Allow user to send email without authentication

[TOC]

Create a plain text file: `/etc/postfix/accepted_unauth_senders`:

<pre>
fax-machine-12@mydomain.tld OK
</pre>

Use postmap to create hash db file:

<pre>
# postmap hash:/etc/postfix/accepted_unauth_senders```
</pre>

Modify Postfix to use this text file: `/etc/postfix/main.cf`

<pre>
smtpd_sender_restrictions = 
    check_sender_access hash:/etc/postfix/accepted_unauth_senders,
    [...OTHER RESTRICTIONS HERE...]
</pre>

Restart/reload postfix to make it work:

<pre>
# /etc/init.d/postfix restart
</pre>
