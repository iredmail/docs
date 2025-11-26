# Upgrade milter manually

This tutorial describes how to upgrade milter program to the latest stable
release manually, usually you should upgrade it with one click with iRedMail
Enterprise Edition ("EE" for short).

- Find the latest release here: <https://dl.iredmail.org/milter/>. We use
  release `milter-v1.3.0-linux-amd64` for example here.
- Run commands below on EE server to upgrade and restart milter service:

```
cd /usr/local/bin/
wget https://dl.iredmail.org/milter/milter-v1.3.0-linux-amd64
chown milter:milter milter-v1.3.0-linux-amd64
chmod 0500 milter-v1.3.0-linux-amd64
ln -sf milter-v1.3.0-linux-amd64 milter
systemctl restart milter
```

That's all.
