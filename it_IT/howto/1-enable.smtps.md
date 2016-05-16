# Abilitare servizio SMTPS ( SMTP over SSL su porta 465)

[TOC]

### Perché iRedMail non abilita SMTPS (SMTP over SSL) per default.

SMTPS è deprecato, per cui iRedMail lo disabilita per default.
Estratto da [wikipedia.org](https://it.wikipedia.org/wiki/SMTPS)

>Originalmente, nel 1997, la IASNS registrò la porta 465 per l'SMTPS. Alla fine del 1998 questa fu revocata quando fu standardizzato lo STARTTLS. Con STARTTLS, la stessa porta può essere usata sia con che senza TLS. Per il protocollo SMTP ciò è stato particolarmente importante, perché i client di questo protocollo sono spesso altri server email, e ciò implica che non è dato sapere se i server con cui si vuole comunicare abbiano una porta separata per TLS. La porta 465 è ora registrata come SSM audio e video.

### Perché abilitare SMTPS sebbene sia deprecato ?

Sfortunatamente, ci sono alcuni tra i piu noti client di posta che non supportano 'presentazione ossia SMTP over STARTTLS su porta 587. Il piu famoso di questi è Microsoft Outlook. Da wikipedia.org:

> Ancora nel 2013 ci sono servizi che continuano ad offrire interfacce SMTPS su porta 465 seppure deprecate, in aggiunta, o al posto, dell'interfaccia di autenticazione messaggio RFC compatibili sulla porta 587 come definito dalla RFC 6409. I provider mantengono la porta 465 perché vecchie applicazioni Microsoft (Incluso Entourage v10.0) non supportano STARTTLS, e quindi non lo standard SMTP (SMTPS sulla porta 587). L'unico modo per i provider per offrire a questi utenti una connessione crittata è di mantenere in uso la porta 465.

### Come abilitare SMTPS

Per abilitare SMTPS, devi configurare postfix per ascoltare sulla porta 456 prima e successivamente aprire la porta 465 su iptalbes.

Aggiungete le righe sotto al file di configurazione di Postfix `/etc/postfix/master.cf` (per Linux/OpenBSD) oppure `/usr/local/etc/postfix/master.cf` per FreeBSD:

```
465     inet  n       -       n       -       -       smtpd
  -o syslog_name=postfix/smtps
  -o smtpd_tls_wrappermode=yes
  -o smtpd_sasl_auth_enable=yes
  -o smtpd_client_restrictions=permit_sasl_authenticated,reject
  -o content_filter=smtp-amavis:[127.0.0.1]:10026
```

Riavviate il servizio Postfix per abilitare SMTPS.

__WARNING__: Fare attenzione di avere  Amavisd in ascolto sulla porta 10026 (ed 10024, 9998).

### Aprirte la porta `465` sul firewall

### Su RHEL/CentOS

* su RHEL/CentOS 6, aggiornare il file delle regole di iptables `/etc/sysconfig/iptables` con una regola (la terza nelle righe di codice sottostante) per la porta 465; a quel punto riavviate il serio iptables.

```
# Part of file: /etc/sysconfig/iptables
-A INPUT -p tcp --dport 25 -j ACCEPT
-A INPUT -p tcp --dport 587 -j ACCEPT
-A INPUT -p tcp --dport 465 -j ACCEPT
```

* Su RHEL/CentOS 7, aggiungete il file `/etc/firewalld/services/smtps.xml`, che contiene quello che vedete qui sotto:


```
<?xml version="1.0" encoding="utf-8"?>
<service>
  <short>Enable SMTPS</short>
  <description>Enable SMTPS.</description>
  <port protocol="tcp" port="465"/>
</service>
```

Modificate il file `/etc/firewalld/zones/iredmail.xml` abilitando il servizio smtp inserendo la linea `<service name="smtps"/>` inside `<zone></zone>`  nel blocco seguente:

```
<zone>
    ...
    <service name="smtps"/>
</zone>
```

Riavviate il servizio firewall:

```
# firewall-cmd --complete-reload
```

### Su Debian/Ububtu

Su Debian/Ubuntu, se usate le regole per iptables configurate da iRedMail, aggiornate il file `/etc/default/iptables`,  aggiungete una regola (la terza del codice qui sotto) per la porta 465 e successivamente riavviate il servizio iptables.

```
# Part of file: /etc/default/iptables
-A INPUT -p tcp --dport 25 -j ACCEPT
-A INPUT -p tcp --dport 587 -j ACCEPT
-A INPUT -p tcp --dport 465 -j ACCEPT
```

### Su OpenBSD

Su OpenBSD, aggiungete il servizio `smtps` in `/etc/pf.conf`, parameter `mail_services=`:

```
# Part of file: /etc/pf.conf
mail_services="{www, https, submission, imap, imaps, pop3, pop3s, ssh, smtps}"
```

Ricaricate il file delle regole di PF

```
# pfctl -f /etc/pf.conf
```
