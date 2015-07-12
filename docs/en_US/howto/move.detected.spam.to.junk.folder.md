# Move detected spam to Junk folder

To move detected spam to user's Junk folder, you need to enable global sieve
script in Dovecot.

You can find sample sieve rule file `/var/vmail/sieve/dovecot.sieve.sample`
if you chose `/var/vmail` to store mailboxes during iRedMail installation.
If you have a custom mailbox storage directory, the sample sieve rule file
should be `sieve/dovecot.sieve.sample` under that directory. If you cannot
find it, you can still download one from iRedMail project:
[here](https://bitbucket.org/zhb/iredmail/src/default/iRedMail/samples/dovecot/dovecot.sieve)

This file must be owned by user `vmail` and group `vmail`, permission `0500`.

Now open Dovecot config file `/etc/dovecot/dovecot.conf` (on Linux/OpenBSD)
or `/usr/local/etc/dovecot/dovecot.conf` (FreeBSD), find parameter `sieve_before =`
like below:

```
# Part of file: /etc/dovecot/dovecot.conf

plugin {
    ...
    #sieve_before = 
    ...
}
```

Uncomment it and set its value to `/var/vmail/sieve/dovecot.sieve` (Note:
use the correct path on your server).

```
    sieve_before = /var/vmail/sieve/dovecot.sieve
```

Restart Dovecot service to enable it.

Note: we don't use `sieve_default =` for global sieve script, because it
will be ignored if users have their own personal sieve rule files.
