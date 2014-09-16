<http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/Allow.Insecure.POP3.IMAP.Connection.without.STARTTLS>
#How to allow insecure POP3/IMAP connection without STARTTLS
Since iRedMail-0.8.0, all clients are forced to use IMAPS and POPS (via STARTTLS) for better security by default. If your mail clients try to access mailbox via protocol POP3 (port 110) or IMAP (port 143) withourt TLS support, you will get error message like below:
<pre>Plaintext authentication disallowed on non-secure (SSL/TLS) connections</pre>

If you want to enable POP3/IMAPS without STARTTLS, please update below two parameters in __dovecot.conf__ and restart Dovecot service:
<pre>
disable_plaintext_auth=no
ssl=yes
</pre>

__Again, it's strongly recommended to use only POP3S/IMAPS for better security.__

Default and recommended setting configured by iRedMail is:
<pre>
disable_plaintext_auth=yes
ssl=required
</pre>

