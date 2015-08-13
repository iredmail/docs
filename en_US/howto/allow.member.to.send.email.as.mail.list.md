# Allow member to send email as mailing list or mail alias

To allow member of mailing list (or mail alias) account to send email as this
mailing list (or mail alias), please follw steps below:

* Remove `reject_sender_login_mismatch` in Postfix config file `/etc/postfix/main.cf`.
* Enable iRedAPD plugin `reject_sender_login_mismatch` in iRedAPD config file
  `/opt/iredapd/settings.py`.
* Add new setting in `/opt/iredapd/settings.py` to allow member to send email
  as mail list or mail alias:

```
ALLOWED_LOGIN_MISMATCH_LIST_MEMBER = True
```

* Restart both Postfix and iRedAPD services.
