# Completely disable Amavisd + ClamAV + SpamAssassin

[TOC]

In iRedMail, Amavisd provides below features:

* content-based spam scanning (invoke SpamAssassin)
* Virus scanning (invoke ClamAV)
* DKIM singing
* DKIM verification (through SpamAssassin + Perl module)
* SPF verification (through SpamAssassin + Perl module)
* Disclaimer (throught AlterMIME)

### Stop virus/spam scanning, keep DKIM signing/verification and Disclaimer

If you want to disable virus and spam scanning, but keep DKIM signing and disclaimer, please try this:

* Keep `content_filter = smtp-amavis:[127.0.0.1]:10024` in Postfix config file `/etc/postfix/main.cf`.

* Find below lines in /etc/amavisd/amavisd.conf:
```perl
# @bypass_virus_checks_maps = (1);  # controls running of anti-virus code
# @bypass_spam_checks_maps  = (1);  # controls running of anti-spam code
```

Uncomment above lines (removing "# " at the beginning of each line), and restart Amavisd service.

### Completely disable all features

If you want to completely disable spam and virus scanning services, steps:

* Comment out below two lines in Postfix config file `/etc/postfix/main.cf`, then restart Postfix service.

```perl
content_filter = smtp-amavis:[127.0.0.1]:10024
receive_override_options = no_address_mappings  # <- it's ok if you don't have this line
```

* Disable network services: Amavisd, ClamAV.

Notes:

* ClamAV and SpamAssassin will be invoked by Amavisd, so if you disable Amavisd, those two are disabled too.
* SpamAssassin doesn't have daemon service running in iRedMail solution, so there's no need to stop SpamAssassin service.
