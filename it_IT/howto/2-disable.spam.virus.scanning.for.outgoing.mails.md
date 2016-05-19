# Disabilitare per le mail in uscita la scansione per spam e virus

Per disabilitare la scansione per le mail in uscita riguardo spam/virus, potete aggiungere
un bypass nel file `/etc/amavisd/amavisd.conf`, file di configurazione di Amavisd (per RHEL/CentOS)
oppure in `/etc/amavis/conf.d/50-user` (per Debian/Ububtu) oppure `/usr/local/etc/amavisd.conf`
(per FreeBSD).

* bypass_spam_checks_maps
* bypass_virus_checks_maps
* bypass_header_checks_maps
* bypass_banned_checks_maps

Queste configurazioni possono essere aggiunti nel blocco di configurazione `$policy_bank{'ORIGINATING'}`:

```perl
$policy_bank{'ORIGINATING'} = {
    [...OMETTERE ALTRE CONFIGURAZIONI QUI...]

    # don't perform spam/virus/header check.
    bypass_spam_checks_maps => [1],
    bypass_virus_checks_maps => [1],
    bypass_header_checks_maps => [1],

    # allow sending any file names and types
    bypass_banned_checks_maps => [1],
}
```

Il riavvio del servizio Amavisd è necessario dopo aver effettuato le modifiche.