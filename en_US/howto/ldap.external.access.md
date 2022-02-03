# How to allow external access to OpenLDAP service

[TOC]

## Configure OpenLDAP to listen on all network interfaces

### On CentOS, Rocky Linux

Open file `/etc/systemd/system/slapd.service.d/override.conf`, you can find
line like below:

```
ExecStart=/usr/sbin/slapd -u ldap -h "ldapi:/// ldap://127.0.0.1:389/" -f /etc/openldap/slapd.conf
```

Remove `127.0.0.1:389`:

```
ExecStart=/usr/sbin/slapd -u ldap -h "ldapi:/// ldap:///" -f /etc/openldap/slapd.conf
```

Save the changes and restart openldap service:

```
systemctl daemon-reload
service slapd restart
```

### On Debian, Ubuntu Linux

Open file `/etc/default/slapd`, find parameter `SLAPD_SERVICES` and update it
to below value:

```
SLAPD_SERVICES="ldap:/// ldapi:///"
```

Save the changes and restart openldap service:

```
service slapd restart
```

## Configure firewall rules to allow access from external network

### On CentOS, Rocky Linux

Please open file `/etc/firewalld/zones/iredmail.xml`, add 2 lines before the
last `</zone>` line:

```
    <port port="389" protocol="tcp"/>
    <port port="636" protocol="tcp"/>
```

Restart the firewall:

```
servivce firewalld restart
```

### On Debian, Ubuntu Linux

Debian 11 and Ubuntu 20.04 uses nftables as the default firewall software,
please add 2 lines in its config file `/etc/nftables.conf`, inside the
`chain input {}` block (before `counter drop` line) like below:

```
table inet filter {
    chain input {
        ...

        # Add below 3 lines.
        # ldap, ldaps
        tcp dport 389 accept
        tcp dport 636 accept

        counter drop
    }

    ...
}
```

Restart the firewall:

```
service nftables restart
```
