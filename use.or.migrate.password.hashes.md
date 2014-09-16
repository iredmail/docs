<http://www.iredmail.org/wiki/index.php?title=IRedMail/FAQ/use.or.migrate.password.hashes>

#How to use or migrate password hashes

## Password hashes supported by iRedMail
iRedMail configures Postfix to use Dovecot as SASL authenticate server, so all password schemes supported by Dovecot can be used in iRedMail. Please refer to Dovecot wiki page for more details: <http://wiki2.dovecot.org/Authentication/PasswordSchemes>

Below password schemes are supported in iRedAdmin-Pro (which means you can add new mail user with either one):

* Plain text. (e.g. '123456')
* MD5. (salted. e.g. $1$GfHYI7OE$vlXqMZSyJOSPXAmbXHq250)
* PLAIN-MD5. (unsalted. e.g. 0d2bf3c712402f428d48fed691850bfc)
* SSHA. (e.g. {SSHA}OuCrqL2yWwQIu8a9uvyOQ5V/ZKfL7LJD)
* SSHA512. (e.g. {SSHA512}FxgXDhBVYmTqoboW+ibyyzPv/wGG7y4VJtuHWrx+wfqrs/lIH2Qxn2eA0jygXtBhMvRi7GNFmL++6aAZ0kXpcy1fxag=)

##Default password schemes used in iRedMail
* In MySQL and PostgreSQL backends, iRedMail stores password as salted MD5 hash. For example: __$1$GfHYI7OE$vlXqMZSyJOSPXAmbXHq250__
* In OpenLDAP backend, iRedMail stores password as SSHA hash. For example: __{SSHA}OuCrqL2yWwQIu8a9uvyOQ5V/ZKfL7LJD__.

##How to use different password hashes in iRedMail

###For MySQL and PostgreSQL backends

All mail users are stored in SQL table "vmail.mailbox", user password is stored in SQL column "mailbox.password".

* To store standard MD5 password (salted MD5 hash) or SSHA, SSHA512, just store the password hash in column "mailbox.password". For example:
<pre>sql> UPDATE mailbox SET password='$1$GfHYI7OE$vlXqMZSyJOSPXAmbXHq250' WHERE username='xx@xx';
sql> UPDATE mailbox SET password='{SSHA}OuCrqL2yWwQIu8a9uvyOQ5V/ZKfL7LJD' WHERE username='xx@xx';
sql> UPDATE mailbox SET password='{SSHA512}FxgXDhBVYmTqoboW+ibyyzPv/wGG7y4VJtuHWrx+wfqrs/lIH2Qxn2eA0jygXtBhMvRi7GNFmL++6aAZ0kXpcy1fxag=' WHERE username='xx@xx';
</pre>

* To store PLAIN-MD5, you have to prepend __{PLAIN-MD5}__ in your password hash:
<pre>sql> UPDATE mailbox SET password='{PLAIN-MD5}0d2bf3c712402f428d48fed691850bfc' WHERE username='xx@xx';</pre>

* To store plain password, you have to prepend __{PLAIN}__:
<pre>sql> UPDATE mailbox SET password='{PLAIN}123456' WHERE username='xx@xx';</pre>

###For OpenLDAP backends
User password is stored in LDAP user object, in attribute "userPassword".

* To store plain password, SSHA, SSHA512 password hash, just store them in original format. For example:
<pre>userPassword: 123456
userPassword: {SSHA}OuCrqL2yWwQIu8a9uvyOQ5V/ZKfL7LJD
userPassword: {SSHA512}FxgXDhBVYmTqoboW+ibyyzPv/wGG7y4VJtuHWrx+wfqrs/lIH2Qxn2eA0jygXtBhMvRi7GNFmL++6aAZ0kXpcy1fxag=</pre>

* To store standard MD5 password (salted MD5 hash), please prepend __{crypt}__ in your password hash. For example:
<pre>userPassword: {crypt}$1$GfHYI7OE$vlXqMZSyJOSPXAmbXHq250</pre>
__IMPORTANT NOTE__: If you want to input password hash with phpLDAPadmin, please choose "clear" in the password hash list in phpLDAPadmin, then input "{crypt}$1$GfHYI7OE$vlXqMZSyJOSPXAmbXHq250" (without quotes, of course).
