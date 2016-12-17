# iRedAdmin-Pro: Domain ownership verification

[TOC]

## Summary

Since iRedAdmin-Pro-SQL-2.5.0 and iRedAdmin-Pro-LDAP-2.7.0, it's able to grant
permission to normal domain admin to create new mail domains. All new domains
added by normal domain admin requires domain ownership verification, to ensure:

* the newly added mail domain is an valid domain
* the domain admin have the required privileges in the domain to manage the
  email services.

Mail services are disabled for pending domains, and will be activated
automatically after verified.

## How to enable or disable domain ownership verification

There're few parameters used to control domain ownership verifivation, you can
find default settings in file `libs/default_settings.py` under iRedAdmin-Pro
directory. If you want to change any of them, please copy the parameter to
iRedAdmin-Pro config file `settings.py`, set proper value, then restart
Apache or uwsgi (if you're running Nginx) service to reload the changes.

```
# Require domain ownership verification if it was added by normal domain admin.
REQUIRE_DOMAIN_OWNERSHIP_VERIFICATION = True

# How long should we remove verified or (inactive) unverified domain ownerships.
#
# iRedAdmin-Pro stores verified ownership in SQL database, if (same) admin
# removed the domain and re-adds it, no verification required.
#
# Usually normal domain admin won't frequently remove and re-add same domain
# name, so it's ok to remove saved ownership after X days.
DOMAIN_OWNERSHIP_EXPIRE_DAYS = 30

# The string prefixed to verify code. Must be shorter than than 60 characters.
DOMAIN_OWNERSHIP_VERIFY_CODE_PREFIX = 'iredmail-domain-verification-'

# Timeout while performing each verification.
DOMAIN_OWNERSHIP_VERIFY_TIMEOUT = 10
```

## How to verify domain ownership

There're several ways to verify domain ownership:

* Create a text file under top directory of the web site of new domain, both
  file name and file content must be same as verify code. For example, for
  pending domain `example.com` with verify code
  `iredmail-domain-verification-5tzh5gHjU688yyWK7cSV`, we will verify 2 URLs:

    * http: `http://example.com/iredmail-domain-verification-5tzh5gHjU688yyWK7cSV`
    * https: `https://example.com/iredmail-domain-verification-5tzh5gHjU688yyWK7cSV`

    If you visit the URL with a web browser, it's expected to display verify
    code as page content.

* Create a TXT type DNS record of the domain name, use the verify code as its
  value. For example, for pending domain `example.com` with verify code
  `iredmail-domain-verification-5tzh5gHjU688yyWK7cSV`, DNS query by command
  `nslookup -type=txt example.com` should return a record which is same as
  verify code.

    Sample DNS query with `nslookup`:
```
$ nslookup -type=txt example.com

Non-authoritative answer:
example.com     text = "iredmail-domain-verification-5tzh5gHjU688yyWK7cSV"
example.com     text = "v=spf1 ..."
example.com     text = "..."
```

    Sample DNS query with `dig`:
```
$ dig -t txt example.com

...
;; ANSWER SECTION:
iredmail.org.		4173	IN	TXT	"iredmail-domain-verification-5tzh5gHjU688yyWK7cSV"
iredmail.org.		4173	IN	TXT	"v=spf1 ..."
iredmail.org.		4173	IN	TXT	"..."
```
