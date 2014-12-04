# Allow certain users to send email as another user

iRedMail configures Postfix to 
reject the request when sender specifies an owner for the MAIL FROM address
(`From:` header), but the client is not (SASL) logged in as that MAIL FROM
address owner; or when the client is (SASL) logged in, but the client login
name doesn't own the MAIL FROM address.

Sometimes we do need to send email as another user, this tutorial describes
how to allow certain users to do this with iRedAPD plugin
`reject_sender_login_mismatch`.

* Remove `reject_sender_login_mismatch` restriction rule in Postfix
  setting `smtpd_sender_restrictions` (`/etc/postfix/main.cf`). Out iRedAPD
  plugin will do the same restriction for you.

    After removed `reject_sender_login_mismatch`, Postfix setting looks like
    below:

```
smtpd_sender_restrictions = permit_mynetworks, permit_sasl_authenticated
```

* Enable plugin `reject_sender_login_mismatch` in iRedAPD config file
  `/opt/iredapd/settings.py`:

```python
plugins = ['reject_sender_login_mismatch', ...]
```

* List senders who are allowed to send email as different users in iRedAPD
  config file `/opt/iredapd/settings.py`, in parameter
  `ALLOWED_LOGIN_MISMATCH_SENDERS`. For example:

```python
ALLOWED_LOGIN_MISMATCH_SENDERS = ['user1@here.com', 'user2@here.com']
```

    NOTE: this parameter does not present by default, please add it manually.

Restart iRedAPD service. That's all.
