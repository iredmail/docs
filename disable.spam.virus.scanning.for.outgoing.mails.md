<http://iredmail.org/wiki/index.php?title=IRedMail/FAQ/Disable.Spam.Virus.Scanning.for.Outgoing.Mails>
#How to disable spam virus scanning for outgoing mails
To disable spam/virus scanning for outgoing mails, you can add bypass settings in Amavisd config file: /etc/amavisd.conf (RHEL/CentOS/Scientific Linux) or /etc/amavis/conf.d/50-user (Debian/Ubuntu) or /usr/local/etc/amavisd.conf (FreeBSD).

* bypass_spam_checks_maps
* bypass_virus_checks_maps
* bypass_header_checks_maps
* bypass_banned_checks_maps

These settings can be added in Amavisd policy_bank: MYUSERS.

<pre>
$policy_bank{'MYUSERS'} = {
    [...OMIT OTHER SETTINGS HERE...]

    # don't perform spam/virus/header check.
    bypass_spam_checks_maps => [1],
    bypass_virus_checks_maps => [1],
    bypass_header_checks_maps => [1],

    # allow sending any file names and types
    bypass_banned_checks_maps => [1],
}
</pre>

Restarting Amavisd service is required after changing settings.
