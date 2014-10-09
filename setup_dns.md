# Setup DNS records for your mail server

[TOC]

__NOTE: STILL WORKING IN PROGRESS__

## A record for server hostname

Understand the different types of DNS records. The most common is the "A" record. These records map a FQDN (fully qualified domain name) to an IP address. This is usually the most often used record type in any DNS system that maps domain names to IP addresses. This is the DNS record you should add if you want to point a domain name to a Web server.

### Creating a DNS A Record
___Name___: This will be the host for your domain which is actually a computer within your domain. Your domain name is automatically appended to your name. If you are trying to make a record for the system www.mydomain.com. Then all you enter in the textbox for the name value is www.

Note: If you leave the name field blank it will default to be the record for your base domain. The record for your base domain is called the root record or apex record.

___IP___: The IP address of your FQDN. An IP (Internet Protocol) can be thought of as the telephone number to your computer. It is how one computer knows how to reach another computer. Similar to the country codes, area codes, and phone number it is used to call someone.

___TTL___: The TTL (Time to Live) is the amount of time your record will stay in cache on systems requesting your record (resolving nameservers, browsers, etc.). The TTL is set in seconds, so 60 is one minute, 1800 is 30 minutes, etc..

Systems that have a static IP should usually have a TTL of 1800 or higher. Systems that have a dynamic IP should usually have a TTL of 1800 of less.

The lower the TTL the more often a client will need to query the name servers for your host’s (record’s) IP address this will result in higher query traffic for your domain name. Where as a very high TTL can cause downtime when you need to switch your IPs quickly.

___Best Practice Tip___
If you plan on changing your IP you should set your TTL to a low value a few hours before you make the change. This way you won’t have any downtime during the change. Once your IP is changed you can always raise your TTL to a higher value again.

___A record details___:
<pre>
NAME	TTL	TYPE	DATA
www.mydomain.com.	1800	A	192.168.1.2
</pre>
___Name___: www.mydomain.com. is the host which we are making an entry for. In the data entry screen we only enter www.
___IP___: 192.168.1.2 is the IP address.
___TTL___ (time to live): The 1800 indicates how often (in seconds) that this record will be cached in resolving name servers.
The end result of this record is that www.mydomain.com. points to 192.168.1.2

### Creating a DNS Alias(CNAME) Record

Sometimes it is useful to be able to access a server (or any host) by using a name other than its DNS host name. 

For example, you have an Mail Server whose DNS configuration is as follows: 

<pre>
   Host Name:	mx01
   Domain Name:	mydomain.com
</pre>

You have also setup your server as a WWW server so Internet or Intranet browsers can access Web pages from it. You want people to access your Web server by specifying mail.mydomain.com as its name instead of mx01.mydomain.com. 

To accomplish this, an alias (or canonical name) record needs to be added to your DNS server. 

The DNS server should already have the following record under the mydomain.com zone (IPAddress should be the IP address of your server): 

`mx01   A   <IPAddress>`

The following record should be added to the mydomain.com zone: 

`mail   CNAME   mx01.mydomain.com`			

When a DNS server looks up a name and finds a "CNAME" record, it replaces the name with the canonical name, and looks up the new name, in this case, mail.mydomain.com.

## Reverse PTR record for server IP address

### What Is A Reverse PTR Record?

PTR record or more appropriately a reverse PTR record is a process of resolving an IP address to its associated hostname. This is the exact opposite of the process of resolving a hostname to an IP address. Example, when you ping a name mail.somedomain.com it will get resolved to the ip address using the DNS to something like 192.168.1.5. Reverse PTR record does the opposite; it looks up the hostname for the given IP address. In the example above the PTR record for IP address 192.168.1.5 will get resolved to mail.somedomain.com.

### Why Do You Need A Reverse PTR Record?

The most common use for looking up a PTR record is done by spam filters. Concept behind this idea is that fly by night spammers who send e-mails out using fake domains generally will not have the appropriate reverse PTR setup at the ISP DNS zone. This criterion is used spam filters to detect spam. If your domain does not have an appropriate reverse PTR record setup then chances are most e-mail spam filtering software will block e-mails from your mail server.

### How Do You Setup A Reverse PTR?

You would most likely need to contact your ISP and make a request to create a reverse PTR record for your mail server IP address. For example, if your mail server is mail.somedoamin.com then ask your ISP to setup a reverse PTR record 192.168.1.5 (your internet public IP address) in their revesre DNS zone. Reverse DNS zones are handled by your ISP even though you may have your own forward lookup DNS zone that you manage.

## MX record for mail domain name

### What Is An MX Record?

Mail Exchanger Record or more commonly known as MX record is an entry in the DNS server of your domain that tells other mail servers where your mail server is located. When someone sends an e-mail to a user that exists on your mail server from the internet, MX provides the location or IP address where to send that e-mail. MX record is the location of your mail server that you have provided to the outside world via the DNS.

Most mail servers generally have more than one MX record, meaning you could have more than one mail server setup to receive e-mails. Each MX record has a priority number assigned to it in the DNS. The MX record with lowest number has the highest priority and that is considered your primary MX record or your main mail server. The next lowest mx number has the next highest primary and so on. You generally have more than one mail server, one being the primary and the others as backups.

### How To Setup The MX Record

If your ISP or domain name registrar is providing the DNS service, you can request them to set one up for you. If you manage your own DNS servers then you need to create the MX records in your DNS zone yourself.

## SPF record for your mail domain name

### What Is An SPF Record?
SPF is a spam and phishing scam fighting method which uses DNS SPF-records to define which hosts are permitted to send e-mails for a domain. For details on SPF, please see http://www.openspf.org/

This works by defining a DNS SPF-record for the e-mail domain name specifying which hosts (e-mail servers) are permitted to send e-mail from the domain name.
Other e-mail servers can lookup this record when receiving an e-mail from this domain name to verify that sending e-mail server is connecting from a permitted IP address.

### How To Setup The SPF Record
A new SPF-record type was recently added to the DNS protocol to support this ([RFC4408](http://www.rfc-editor.org/rfc/rfc4408.txt)).
However not all DNS and e-mail servers support this new record type yet, so SPF can also be configured in DNS using the TXT-record type.
We recommend that you only use the SPF-record type and let Simple DNS Plus synthesize matching TXT-records for backwards compatibility.
 
This is a simply example:

* SPF record refer to A record.
`mydomain.com.           3600    IN      TXT     "v=spf1 mx mx:mail.mydomain.com -all"`

* or SPF record refer to ip address.
`mydomain.com.          3600    IN      TXT     "v=spf1 ip4:192.168.1.100 -all"`

## DKIM record for your mail domain name
### What Is An DomainKeys/DKIM Record?
DomainKeys is a spam and phishing scam fighting method which works by signing outbound e-mail messages with a cryptographic signature which can be verified by the recipient to determine if the messages originates from an authorized system.
The process of signing outbound messages and verifying this signature is typically done by the e-mail servers at each end - not by end-users client software.

DomainKeys uses DNS TXT-records to define DomainKeys policy and public encryption keys for a domain name.
DomainKeys is developed and patented by Yahoo!. For details please see http://domainkeys.sourceforge.net/

DKIM is an extension of DomainKeys which uses the same style DNS records.
For details see http://www.dkim.org

A domain name using DomainKeys should have a single policy record configured.
This is a DNS TXT-record with the name "_domainkey" prefixed to the domain name - for example "_domainkey.mydomain.com".
The data of this TXT-record contains the policy which is basically either "o=-" or "o=~".
"o=-" means "all e-mails from this domain are signed", and "o=~" means "some e-mails from this domain are signed".
Additional fields for test (t), responsible e-mail address (r), and notes (n) may also be included - for example "o=-; n=some notes".

### How To Setup The DKIM Record
After installation, please reboot your system, then use amavisd to help you setup DNS record.

* Run command in terminal to show your DKIM keys:

```bash
# amavisd showkeys
dkim._domainkey.iredmail.org.   3600 TXT (
  "v=DKIM1; p="
  "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDYArsr2BKbdhv9efugByf7LhaK"
  "txFUt0ec5+1dWmcDv0WH0qZLFK711sibNN5LutvnaiuH+w3Kr8Ylbw8gq2j0UBok"
  "FcMycUvOBd7nsYn/TUrOua3Nns+qKSJBy88IWSh2zHaGbjRYujyWSTjlPELJ0H+5"
  "EV711qseo/omquskkwIDAQAB")
```

Note: On some Linux/BSD distribution, you should use command `amavisd-new` instead of `amavisd`.
if it complains `/etc/amavisd.conf not found`, you should tell amavisd the correct path of its config file. For example:
`# amavisd -c /etc/amavisd/amavisd.conf showkeys`
Note: Bind can handle this kind of multi-line format, so you can paste it in your domain zone file directly.
* Copy output of above command into one line, like below. It will be the value of DNS record.
`v=DKIM1; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDYArsr2BKbdhv9efugByf7LhaKtxFUt0ec5+1dWmcDv0WH0qZLFK711sibNN5LutvnaiuH+w3Kr8Ylbw8gq2j0UBokFcMycUvOBd7nsYn/TUrOua3Nns+qKSJBy88IWSh2zHaGbjRYujyWSTjlPELJ0H+5EV711qseo/omquskkwIDAQAB`
* Add a `TXT` type DNS record, set value to the line you copied above.
* After you added this in DNS, type below command to verify it:

```bash
# amavisd testkeys
TESTING: dkim._domainkey.iredmail.org      => pass
```

If it shows `pass`, it works.

Note: If you use DNS service provided by ISP, new DNS record might take some hours to be available.


## References :

* http://www.emailtalk.org/MX.aspx
* http://en.wikipedia.org/wiki/MX_record
* http://www.openspf.org/RFC_4408
* http://www.simpledns.com/