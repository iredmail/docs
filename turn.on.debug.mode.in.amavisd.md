<http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/Turn.On.Debug.Mode.In.Amavisd>
# Turn on debug mode in Amavisd
In `amavisd.conf`, change `$log_level`, then restart amavis service.

<pre>
$log_level = 5;              # verbosity 0..5, -d
</pre>
