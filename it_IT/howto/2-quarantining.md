# Messa in quarantena

[TOC]

Sin dalla versione 0.7.0 di IredMail, la messa in quarantena e le relative configurazioni in Amavisd sono configurate da iRedMail, ma disabilitate per default, potere facilmente abilitate il sistema di messa in quarantena tramite questo tutoria.

Con le modifiche che trovare sotto, mail Virus/Spam/Banned saranno messe in quarantena in un database SQL. Potrete a questo punto gestire le mail in quarantena con iRedAdmin-Pro.

## Messa in quarantena di spam, virus,  banned e messaggi con intestazioni scorrette.

Modificare il file di configurazione di Amavisd, trovate le configurazioni sotto riportate ed aggiornatele. Se non esistono, aggiungetele. 

* in Red Hat Enterprise Linux, CentOS, Scientific Linux, il file è `/etc/amavisd/amavisd.conf` oppure `/etc/amavisd.conf`.
*in Debian/Ubuntu è `/etc/amavis/conf.d/50-user`.
* in FreeBSD è `/usr/local/etc/amavisd.conf`.
* in OpenBSD è  `/etc/amavisd.conf`.

```
# Part of file: /etc/amavisd/amavisd.conf

# Change values of below parameters to D_DISCARD.
# Detected spams/virus/banned messages will not be delivered to user's mailbox.
$final_virus_destiny = D_DISCARD;
$final_spam_destiny = D_DISCARD;
$final_banned_destiny = D_DISCARD;
$final_bad_header_destiny = D_DISCARD;

# Quarantine SPAM into SQL server.
$spam_quarantine_to = 'spam-quarantine';
$spam_quarantine_method = 'sql:';

# Quarantine VIRUS into SQL server.
$virus_quarantine_to = 'virus-quarantine';
$virus_quarantine_method = 'sql:';

# Quarantine BANNED message into SQL server.
$banned_quarantine_to = 'banned-quarantine';
$banned_files_quarantine_method = 'sql:';

# Quarantine Bad Header message into SQL server.
$bad_header_quarantine_method = 'sql:';
$bad_header_quarantine_to = 'bad-header-quarantine';
```
Inoltre verificare di avere le righe sottostanti presenti nello stesso file di configurazione:

```perl
# For MySQL/MariaDB/OpenLDAP backends
@storage_sql_dsn = (
    ['DBI:mysql:database=amavisd;host=127.0.0.1;port=3306', 'amavisd', 'password'],
);

# For PostgreSQL
#@storage_sql_dsn = (
#    ['DBI:Pg:database=amavisd;host=127.0.0.1;port=5432', 'amavisd', 'password'],
#);
```

Il riavvio del servizio Amavaisd è richiesto per confermare le modifiche.

## Configurare iRedAdmin-Pro affinché gestisca le mail in quarantena.

Aggiornate il file di configurazione di iRedAdmin-Pro, siate certi di avere le configurazioni corrette per Amavisd:

* in Red Hat Enterprise Linux, CentOS, Scientific Linux è `/var/www/iredadmin/settings.py`.
* in Debian/Ubuntu è `/opt/www/iredadmin/settings.py` oppure `/usr/share/apache2/iredadmin/settings.py`.
* in FreeBSD è `/usr/local/www/iredadmin/settings.py`.
* in OpenBSD è `/var/www/iredadmin/settings.py`.

```python
# File: settings.py

amavisd_db_host = '127.0.0.1'
amavisd_db_port = 3306
amavisd_db_name = 'amavisd'
amavisd_db_user = 'amavisd'
amavisd_db_password = 'password'

# Log basic info of inbound/outbound, no mail body stored.
amavisd_enable_logging = True

# Quarantining management
amavisd_enable_quarantine = True
amavisd_quarantine_port = 9998

# Per-recipient policy lookup
amavisd_enable_policy_lookup = True
```

Il riavvio del web server Apache o servizio `uwsgi` (se usate Nginx come web server) è necessario.

Adesso potete autenticarvi in iRedAdmin-Pro e gestire i messaggi in quarantena dal menu `System -> Quarantined Mails`. Scegliete l'azione adatta nella lista del menu a tendina per rilasciarli o cancellarli.

Copie delle videate sono allegate in fondo.

### Notifiche agli utenti riguardo le mail in quarantena.

!!! note
   È necessario affinché questa funzione sia operativa che abilitiate il self-service dal dominio della 
   posta -- Lo potete abilitare nella pagina del profilo del dominio.

iRedAdmin-Pro mette a disposizione uno script che potete eseguire per notificare gli agli utenti le mail messe in quarantena: `tools/notify_quarantined_recipients.py`.

La mail di notifica viene legga dal file template `tools/notify_quarantined_recipients.html`, siete liberi di modificarlo affinché soddisfi le vostre necessità. (non dimenticatevi di salvare il file prima di aggiornare iRedAdmin-Pro.)

La mail di notifica conterrà il link ad iRedAdmin-Pro affinché l'utente possa cliccarlo ed autenticarsi per poter gestire le mail in quarantena. Dovete cambiare l'URL aggiungendo il parametro sotto riportato, con l'URL corretto, nel file di configurazione di iRedAdmin-Pro:

```
NOTIFICATION_IREDADMIN_URL = 'https://[tuo_server]/iredadmin/'
```

Per mandare le notifiche aggiungete un cron job che esegua: `tools/notify_quarantined_recipients.py` . Esempio per inviare notifiche ogni 6 ore:

```
1 */12 * * * python /path/to/tools/notify_quarantined_recipients.py >/dev/null
```

Non dimenticare di usare il percorso corretto verso il file `notify_quarantined_recipients.py` nel vostro server.

Potete anche eseguire lo script manualmente per notificare diversi utenti. Per esempio su RHEL/CentOS:

```
cd /var/www/iredadmin/tools/
python notify_quarantined_recipients.py
```

## Messa in quarantena di mail pulite.

Nota: se volete mettere in quarantena mail invitate da/per certi utenti locali, fate invece  riferimento a questo documento: [Quarantine clean emails sent from/to certain local user](./quarantine.clean.mails.per-user.html)

Se volete mettere in quarantena mail pulite in un database SQL per una futura approvazione o qualunque altra ragione, seguite i seguenti passi:

* Modificare i parametri sotto riportati nel file di configurazione di Amavisd `amavisd.conf`:

```perl
$clean_quarantine_method = 'sql:';
$clean_quarantine_to = 'clean-quarantine';
```

* Trovate la policy bank `ORIGINATING`, ed aggiungeteci due linee come mostrato sotto:

```perl
$policy_bank{'ORIGINATING'} = {
    ...
    clean_quarantine_method => 'sql:',
    final_destiny_by_ccat => {CC_CLEAN, D_DISCARD},
}
```

* Riavviate il servizio Amavisd.

Ora tutte le mail pulite inviate dal vostro utente verranno messe in quarantena in un database SQL.

## Screenshots

* Vedi mail in quarantena:

![](../images/iredadmin/system_maillog_quarantined.png)

* Espandi la mail in quarantena cosi da vedere il corpo e le intestazioni.

![](../images/iredadmin/system_maillog_quarantined_expanded.png)