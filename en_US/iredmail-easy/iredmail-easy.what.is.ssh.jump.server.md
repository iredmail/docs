# iRedMail Easy: What is SSH jump server

It's common that you have a protected Linux/BSD server that isn’t publicly
accessible. Typically, you may have what is commonly referred to as a
*__jump server__* or *__bastion server__* which is accessible from a public
network (sometimes this jump server would be in a DMZ, and also Linux/BSD),
you connect to this jump server first, then connect to the protected server
from jump server.

Sample setup:

```
+--------+       +-------------+      +------------------+
| Laptop | <---> | Jump server | <--> | Protected server |
+--------+       +-------------+      +------------------+
```

You can connect to the protected server through jump server via ssh with
command like below:

```
ssh -v -J user1@jump-server user2@protected-server
```

## References

- [SSH manual page](https://man.openbsd.org/ssh#J)
