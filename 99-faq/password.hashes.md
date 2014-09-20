# Password hashes

## Password hashes supported by iRedMail

iRedMail configures Postfix to use Dovecot as SASL authenticate server, so all
password schemes supported by Dovecot can be used in iRedMail. Please refer to
Dovecot wiki page
[`Password Schemes`](http://wiki2.dovecot.org/Authentication/PasswordSchemes) for more details.

Below password schemes are supported in iRedAdmin-Pro (which means you can add new mail user with either one):

* Plain text. e.g. `123456`
* MD5. (salted. e.g. `$1$GfHYI7OE$vlXqMZSyJOSPXAmbXHq250`
* PLAIN-MD5 (unsalted MD5). e.g. `0d2bf3c712402f428d48fed691850bfc`
* SSHA. e.g. `{SSHA}OuCrqL2yWwQIu8a9uvyOQ5V/ZKfL7LJD`
* SSHA512. e.g. `{SSHA512}FxgXDhBVYmTqoboW+ibyyzPv/wGG7y4VJtuHWrx+wfqrs/lIH2Qxn2eA0jygXtBhMvRi7GNFmL++6aAZ0kXpcy1fxag=`

__NOTE__: Dovecot claims it supports SSHA512, but I didn't get it work.
Please test it first if you choose SSHA512.

## Default password schemes used in iRedMail

* For MySQL and PostgreSQL backends: `MD5` (salted).
* For LDAP backend: `SSHA`.

## How to use different password hashes in iRedMail

### For MySQL and PostgreSQL backends

All mail users are stored in SQL table `vmail.mailbox`, user password is stored
in SQL column `mailbox.password`. For example:
<pre>
sql> UPDATE mailbox SET password='$1$GfHYI7OE$vlXqMZSyJOSPXAmbXHq250' WHERE username='xx@xx';
sql> UPDATE mailbox SET password='{SSHA}OuCrqL2yWwQIu8a9uvyOQ5V/ZKfL7LJD' WHERE username='xx@xx';
sql> UPDATE mailbox SET password='{SSHA512}FxgXDhBVYmTqoboW+ibyyzPv/wGG7y4VJtuHWrx+wfqrs/lIH2Qxn2eA0jygXtBhMvRi7GNFmL++6aAZ0kXpcy1fxag=' WHERE username='xx@xx';
</pre>

* To store PLAIN-MD5, you have to prepend `{PLAIN-MD5}` in your password hash:
<pre>
sql> UPDATE mailbox SET password='{PLAIN-MD5}0d2bf3c712402f428d48fed691850bfc' WHERE username='xx@xx';
</pre>

* To store plain password, you have to prepend `{PLAIN}`:
<pre>sql> UPDATE mailbox SET password='{PLAIN}123456' WHERE username='xx@xx';</pre>

### For LDAP backends

User password is stored in attribute `userPassword` of user object.

* To store plain password, SSHA, SSHA512 password hash, just store them in
original format. For example:
<pre>
userPassword: 123456
userPassword: {SSHA}OuCrqL2yWwQIu8a9uvyOQ5V/ZKfL7LJD
userPassword: {SSHA512}FxgXDhBVYmTqoboW+ibyyzPv/wGG7y4VJtuHWrx+wfqrs/lIH2Qxn2eA0jygXtBhMvRi7GNFmL++6aAZ0kXpcy1fxag=</pre>

* To store standard MD5 password (salted MD5 hash), please prepend `{CRYPT}`
(case insensitive) in your password hash. For example:
<pre>userPassword: {CRYPT}$1$GfHYI7OE$vlXqMZSyJOSPXAmbXHq250</pre>

__IMPORTANT NOTE__: If you want to input password hash with phpLDAPadmin,
please choose `clear` in the password hash list, then input password hash.
