# Major components used in iRedMail

<table cellpadding="4px;">
<thead>
<tr>
<th>Name</th>
<th>Comment</th>
</tr>
</thead>
<tbody>

<tr>
<th>Postfix</th>
<td>Mail Transfer Agent (MTA)</td>
</tr>

<tr>
<th>Dovecot</th>
<td>POP3, IMAP and Managesieve server</td>
</tr>

<tr>
<td>Apache, Nginx</td>
<td>Web server</td>
</tr>

<tr>
<td>OpenLDAP</td>
<td>LDAP server, an optional for storing mail accounts.</td>
</tr>

<tr>
<td>MySQL, MariaDB, PostgreSQL</td>
<td>SQL server used to store application data. Could be used to store mail accounts too.</td>
</tr>

<tr>
<td>Amavisd</td>
<td>Interface between Postfix and SpamAssassin, ClamAV. it calls SpamAssassin and ClamAV for content-based spam/virus scanning.</td>
</tr>

<tr>
<td>SpamAssassin</td>
<td>content-based spam scanner</td>
</tr>

<tr>
<td>ClamAV</td>
<td>Virus scanner</td>
</tr>

<tr>
<td>Cluebringer</td>
<td>A third-party postfix policy server</td>
</tr>

<tr>
<td>iRedAPD</td>
<td>A very simple postfix policy server developed by iRedMail team</td>
</tr>

<tr>
<td>Roundcube</td>
<td>Webmail (PHP)</td>
</tr>

<tr>
<td>SOGo Groupware</td>
<td>A groupware which provides calendar (CalDAV), contact (CardDAV) and ActiveSync services.</td>
</tr>

<tr>
<td>Fail2ban</td>
<td>Scans log files and bans IPs that show the malicious signs -- too many password failures, seeking for exploits, etc.</td>
</tr>

<tr>
<td>Awstats</td>
<td>Apache and Postfix log analyzer</td>
<td></td>
</tr>

</tbody>
</table>

# See also

* [Locations of configuration and log files of mojor components](./file.locations.html)
* [Which network ports are open by iRedMail](./network.ports.html)
