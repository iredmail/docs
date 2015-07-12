# Restrict mail user to login from specified IP addresses or networks

Since iRedMail-0.9.1, it's able to restrict mail users to login from specified
IP addresses or networks.

Below sample usage shows how to restrict mail user `user@domaim.com` to login
from only IP address `172.16.244.1` or network `192.168.1.0/24`.

## SQL backends

```
sql> USE vmail;
sql> UPDATE mailbox SET allow_nets='172.16.244.1,192.168.1.0/24' WHERE username='user@domain.com';
```

To remove this restriction (allow to login from anywhere), just set
value of SQL column `mailbox.allow_nets` to NULL. WARNING: It must be NULL,
not empty string.

## OpenLDAP backend

To allow user `user@domain.com` to login from IP `172.16.244.1` and network
`192.168.1.0/24`, please add new attribute `allowNets` to this user:

```
allowNets: 192.168.1.10,192.168.1.0/24
```

To remove this restriction, just remove attribute `allowNets` for this user.

# References

* This feature is implemented in iRedMail-0.9.1, and mentioned in iRedMail
  [upgrade tutorial for iRedMail-0.9.0](./upgrade.iredmail.0.9.0-0.9.1.html]

* Dovecot document: [AllowNets](http://wiki2.dovecot.org/PasswordDatabase/ExtraFields/AllowNets)
