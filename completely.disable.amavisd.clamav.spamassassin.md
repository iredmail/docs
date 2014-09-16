<http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/Completely.Disable.Amavisd.ClamAV.SpamAssassin>
#How to completely disable amavisd/ClamAV/SpamAssassin
In iRedMail, Amavisd provides below features:

* content-based spam scanning (invoke SpamAssassin)
* Virus scanning (invoke ClamAV)
* DKIM singing
* DKIM verification (through SpamAssassin + Perl module)
* SPF verification (through SpamAssassin + Perl module)
* Disclaimer (throught AlterMIME)

##Stop virus/spam scanning, keep DKIM signing/verification and Disclaimer

If you want to disable virus and spam scanning, but keep DKIM signing and disclaimer, please try this:

* Keep "content_filter =" setting in Postfix main.cf.
<pre>
content_filter = smtp-amavis:[127.0.0.1]:10024
</pre>

* Find below lines in /etc/amavisd/amavisd.conf:

<pre>
# @bypass_virus_checks_maps = (1);  # controls running of anti-virus code
# @bypass_spam_checks_maps  = (1);  # controls running of anti-spam code
</pre>

Uncomment above lines (removing "# " at the beginning of each line), and restart Amavisd service.

##Completely disable all features

If you want to completely disable spam and virus scanning services, steps:

1. Comment out __content\_filter = smtp-amavis:[127.0.0.1]:10024__ and __receive\_override\_options = no\_address\_mappings__ in Postfix config file __/etc/postfix/main.cf__, and restart Postfix service.
* Disable network services: Amavisd, ClamAV.

Notes:

* ClamAV and SpamAssassin will be invoked by Amavisd, so if you disable Amavisd, those two are disabled too.
* SpamAssassin doesn't have daemon service running in iRedMail solution, so there's no need to stop SpamAssassin service.
