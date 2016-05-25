# Amavisd: attiva polixy di ricerca per destinatario

Con la policy di ricerca per destinatario, potete archiviare whitelist/blacklist per destinatario, preferenze di base per spamassassin etc. Le configurazioni sono disponibili come configurazioni globali, o per dominio o per utente. iRedMail usa queste configurazioni per rigettare mittenti in blacklist e far passare mittenti in whitelist durante la sessione smtp, il tutto per risparmiare risorse di sistema (il tutto implementato dal plugin `amavisd_wblist`, nuovo dalla versione 1.4.4 si iRedAPD).

iRedMail ha, nella configurazione di Amavisd, `@storage_sql_dsn`m abilitato di default, per cui è molto facile abilitare la policy per destinatario. Aggiungete semplicemente una linea dopo `@storage_sql_dsn`, come sotto riportato:

```
# Part of file: amavisd.conf

@storage_sql_dsn = [...]
@lookup_sql_dsn = @storage_sql_dsn;
```

Acqueo punto riavviate il servizio Amavisd.

Se non sapete dove sia il file di configurazione di Amavisd, fate riferimento a questo documento: [Posizione dei file di configurazione e log dei componenti maggiori](./file.locations.html#amavisd)

## Referenze:

* [Documentazione Amavisd : Usare SQL per ricerche, log/rapporti e messa in quarantena](http://www.ijs.si/software/amavisd/README.sql.txt)
*  [Documentazione Amavisd: Mappa delle ricerche (hash, SQL) e spiegazione della lista di accesso](http://www.ijs.si/software/amavisd/README.lookups.txt)

