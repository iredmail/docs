# Integrate ejabberd with iRedMail

!!! attention

	 Check out the lightweight on-premises email archiving software developed by iRedMail team: [Spider Email Archiver](https://spiderd.io/).

[TOC]

## Install Ejabberd

```
apt-get install ejabberd
```

## Configure ejabberd

### Use a proper LDAP bind dn/password to query accounts

iRedMail generates a LDAP bind dn `cn=vmail,dc=xxx,dc=xxx` with read-only
access to all mail accounts, we use it in ejabberd to query accounts.

Password of `cn=vmail,dc=xxx,dc=xxx` was generated randomly during iRedMail
installation, you can find the full dn and password in
`/etc/postfix/ldap/catchall_maps.cf`:

```
# grep 'bind_' /etc/postfix/ldap/catchall_maps.cf
bind_dn         = cn=vmail,dc=example,dc=com
bind_pw         = InYTi8qGjamTb6Me2ESwbb6rxQUs5y
```

### Configure ejabberd

Ejabberd's configuration files are written in Erlang syntax, which might be difficult to comprehend. Thankfully, the modifications we need to make are relatively minor and straightforward. The main ejabberd configuration file is located at /etc/ejabberd/ejabberd.cfg. We'll cover each relevant option in turn.

In Erlang, comments begin with the % sign.

* Setting admin and domain, now we setting `www@example.com` as admin.
* Auth not use internal.
* LDAP auth

Open /etc/ejabberd/ejabberd.cfg and set correct values:

```
%% Admin user
{acl, admin, {user, "www", "example.com"}}.

%% Hostname
{hosts, ["example.com"]}.

%% Comment out this line (to not use internal auth method)
%{auth_method, internal}.

%
% Add below lines at the bottom.
%

% Authenticate against LDAP.
{auth_method, ldap}.
{ldap_servers, ["127.0.0.1"]}.
% {ldap_encrypt, tls}.
{ldap_port, 389}.
{ldap_base, "o=domains,dc=example,dc=com"}.
{ldap_rootdn, "cn=vmail,dc=example,dc=com"}.
{ldap_password, "InYTi8qGjamTb6Me2ESwbb6rxQUs5y"}.

% LDAP filter used to query mail accounts
%
% If you prefer to restrict ejabberd service to certain users, you can append
% filter rule `enabledService=ejabberd` like below, then add LDAP attribute/value
% pair `enabledService=ejabberd` to these users.
%{ldap_filter, "(&(objectClass=mailUser)(accountStatus=active)(enabledService=ejabberd))"}.
{ldap_filter, "(&(objectClass=mailUser)(accountStatus=active))"}.
{ldap_uids, [{"mail", "%u@%d"}]}.
```

### Start ejabberd service

```
# /etc/init.d/ejabberd start
Starting jabber server: ejabberd.

# ejabberdctl status
Node ejabberd@u910 is started. Status: started
ejabberd is running
```

### Config iptables

Ejabberd uses some standard ports:

* 5222 Main client port
* 5223 Obsolete secure jabber port
* 5269 Server to server port
* 5280 Web administration

Open `/etc/default/iptables`, append rules below:

```
-A INPUT -p tcp --dport 5222 -j ACCEPT
-A INPUT -p tcp --dport 5223 -j ACCEPT
-A INPUT -p tcp --dport 5269 -j ACCEPT
-A INPUT -p tcp --dport 5280 -j ACCEPT
```

Restart the iptables service.

```
/etc/init.d/iptables restart
```

### Web Access Ejabberd Admin Console

Now you can access <http://192.168.1.10:5280/admin/>

Login in the ejabberd web admin, We have seting www@example.com as admin for the ejabberd server

You can not create user in webadmin. If you want to create user, you need first add user in iRedAdmin, then enable the jabber service for the user in phpldapadmin.

If you want to add the second virtual domain, you need first create a new domain in iRedAdmin, then modify /etc/ejabberd/ejabberd.cfg .

* Open `/etc/ejabberd/ejabberd.cfg` and set correct values:

```
% Hostname
{hosts, ["example.com","test.com"]}.
```

### XMPP Clients

There're many free and open source XMPP clients available, you can choose the
one you prefer listed on this page: <http://xmpp.org/software/clients.html>

On Linux/BSD, Pidgin is a good choice: <http://pidgin.im>

### XMPP Federation and DNS Link

To ensure that your ejabberd instance will federate properly with the rest of
the XMPP network, we must set the SRV records for the domain to point to the
server where the ejabberd instance is running. We need two records, which can
be created in the DNS Management tool of your choice:

```
_xmpp-client._tcp.example.net. 86400 IN SRV 5 0 5222 example.net.
_xmpp-server._tcp.example.net. 86400 IN SRV 5 0 5269 example.net.
```

For more examples, please read this tutorial: <http://wiki.xmpp.org/web/SRV_Records>

## Troubleshooting

1. [Debug OpenLDAP](./debug.openldap.html)
2. Monitor the OpenLDAP and Ejabberd log files
