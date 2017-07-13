# Turn on debug mode in Postfix

There're few ways to turn on debug mode in Postfix, you can choose the one you
prefer.

## Verbose logging for specific SMTP connections

To debug smtp connection from particular client or sender server,  list client
hostname or IP address in the `debug_peer_list` parameter (in
`/etc/postfix/main.cf`). For example:

```
debug_peer_list = 192.168.0.1
```

You can specify one or more hosts, domains, addresses or net/masks. Execute
command `postfix reload` to make the change effective immediately.

## Making Postfix daemon programs more verbose

There're many daemon services defined in `/etc/postfix/master.cf`, for example:

```
smtp      inet  n       -       n       -       -       smtpd
```

To make Postfix logging verbose info of this daemon, please append one or more
`-v` options to selected daemon and execute command `postfix reload`.

```
smtp      inet  n       -       n       -       -       smtpd -v
```

* To diagnose problems with address rewriting specify a `-v` option for the
  `cleanup(8)` and/or `trivial-rewrite(8)` daemon.
* To diagnose problems with mail delivery specify a `-v` option for the
  `qmgr(8)` or `oqmgr(8)` queue manager, or for the `lmtp(8)`, `local(8)`,
  `pipe(8)`, `smtp(8)`, or `virtual(8)` delivery agent.

## See also

* [Postfix Debugging Howto](http://www.postfix.org/DEBUG_README.html)
