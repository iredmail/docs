# Turn on debug logging in Fail2ban

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

To turn on debug mode in Fail2ban, please set its log level to `debug` in
config file `/etc/fail2ban/fail2ban.local`, then restart fail2ban service.
If file `/etc/fail2ban/fail2ban.local` doesn't exist, use
`/etc/fail2ban/fail2ban.conf` instead.

```
loglevel = DEBUG
```

## Log File

Fail2ban may log to different log files on different Linux/BSD distributions:

- `/var/log/fail2ban.log`
- `/var/log/fail2ban/fail2ban.log`
- `/var/log/messages`
- `/var/log/syslog`
