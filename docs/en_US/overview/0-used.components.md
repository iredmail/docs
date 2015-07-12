# Major open source softwares used in iRedMail

<table cellpadding="4px;">
<thead>
<tr>
<th>Name</th>
<th>Comment</th>
</tr>
</thead>
<tbody>

<tr>
<td><a href="http://www.postfix.org" target="_blank">Postfix</a></td>
<td>Mail Transfer Agent (MTA)</td>
</tr>

<tr>
<td><a href="http://www.dovecot.org" target="_blank">Dovecot</a></td>
<td>POP3, IMAP and Managesieve server</td>
</tr>

<tr>
<td><a href="http://httpd.apache.org" target="_blank">Apache</a>, <a href="http://nginx.org" target="_blank">Nginx</a></td>
<td>Web server</td>
</tr>

<tr>
<td><a href="http://www.openldap.org" target="_blank">OpenLDAP</a>, <a href="http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man8/ldapd.8?query=ldapd&arch=i386" target="_blank">ldapd(8)</a></td>
<td>LDAP server, used for storing mail accounts (optional).</td>
</tr>

<tr>
<td><a href="http://www.mysql.com" target="_blank">MySQL</a>, <a href="https://mariadb.org" target="_blank">MariaDB</a>, <a href="http://www.postgresql.org" target="_blank">PostgreSQL</a></td>
<td>SQL server used to store application data. Could be used to store mail accounts too.</td>
</tr>

<tr>
<td><a href="http://www.amavis.org" target="_blank">Amavisd-new</a></td>
<td>Interface between Postfix and SpamAssassin, ClamAV. it calls SpamAssassin and ClamAV for content-based spam/virus scanning.</td>
</tr>

<tr>
<td><a href="http://spamassassin.apache.org" target="_blank">SpamAssassin</a></td>
<td>content-based spam scanner</td>
</tr>

<tr>
<td><a href="http://www.clamav.net/index.html" target="_blank">ClamAV</a></td>
<td>Virus scanner</td>
</tr>

<tr>
<td><a href="http://www.policyd.org" target="_blank">Cluebringer</a></td>
<td>A third-party postfix policy server</td>
</tr>

<tr>
<td><a href="https://bitbucket.org/zhb/iredapd/" target="_blank">iRedAPD</a></td>
<td>A very simple postfix policy server developed by iRedMail team</td>
</tr>

<tr>
<td><a href="http://roundcube.net" target="_blank">Roundcube</a></td>
<td>Webmail (PHP)</td>
</tr>

<tr>
<td><a href="http://sogo.nu" target="_blank">SOGo Groupware</a></td>
<td>A groupware which provides calendar (CalDAV), contact (CardDAV) and ActiveSync services.</td>
</tr>

<tr>
<td><a href="http://www.fail2ban.org" target="_blank">Fail2ban</a></td>
<td>Scans log files and bans IPs that show the malicious signs -- too many password failures, seeking for exploits, etc.</td>
</tr>

<tr>
<td><a href="http://www.awstats.org" target="_blank">Awstats</a></td>
<td>Apache and Postfix log analyzer</td>
<td></td>
</tr>

</tbody>
</table>

# The Big Picture

![](./images/big.picture.png)

# See also

* [Locations of configuration and log files of mojor components](./file.locations.html)
* [Which network ports are open by iRedMail](./network.ports.html)
