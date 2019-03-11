# iRedAdmin-Pro (LDAP backend): Add and manage custom services for mail user

It's reasonable that you want to use OpenLDAP server running on iRedMail
server as a central identity management database. If you have other
softwares/services, and need to restrict some users to use these
software/services, the easiest and most elegent soluion is adding extra service
name in LDAP database, and update your softwares to use a proper LDAP filter to
query users.

We assume you have a GitLab server and Jabber (XMPP) server running on internal
servers, and allow different users to use them.
In this tutorial, we use service name `gitlab` for GitLab service, and `jabber`
for Jabber.

With iRedAdmin-Pro, please open its config file
`/opt/www/iredadmin/settings.py` (old iRedMail releases may deploy iRedAdmin-Pro
to different path, please check [this tutorial](./file.locations.html#iredadmin)
to figure it out, add a new parameter `ADDITIONAL_ENABLED_USER_SERVICES` like
below:

```
ADDITIONAL_ENABLED_USER_SERVICES = ['gitlab', 'jabber']
```

Then restart `iredadmin` service.

__Newly__ created mail user will have these 2 services enabled by default, but
for existing users, you have to add them either manually or do it with some
scripting/programming.

You can find these 2 custom service names after logged in to iRedAdmin-Pro,
in user profile page, under tab `Advanced`. Screenshot attached.

![](./images/iredadmin/custom_user_services.png){: width="700px" }

In OpenLDAP, mail user with these 2 services enabled will have 2 new LDAP
attribute/value pairs:

```
enabledService=gitlab
enabledService=jabber
```
