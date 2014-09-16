<http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/Turn.On.Debug.Mode.In.Dovecot>
#Turn on debug mode in Dovecot
In __/etc/dovecot.conf__ or __/etc/dovecot/dovecot.conf__, change __mail\_debug__ to __yes__, then restart dovecot service.
<pre>
mail_debug = yes
</pre>

If you need authentication and password related debug message, turn on related settings and restart dovecot service.
<pre>
auth_verbose = yes
auth_debug = yes
auth_debug_passwords = yes
auth_verbose_passwords = yes
</pre>

