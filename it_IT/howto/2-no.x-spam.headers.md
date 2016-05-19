# Amavisd + SpamAssassin non funzionano ? Mancano l'inserimento delle intestazioni (X-Spam-*) 

> Il file di configurazione di Amavisd cambia a seconda della distribuzione Linux/BSD; puoi 
> trovare, e correggere, nella maniera corretta la configurazione per il tuo server seguendo questo
> tutorial:
> [Posizione dei file di configurazione e di log dei maggiori componenti](./file.locations.html#amavisd)

Per default nel file di configurazione `/etc/amavisd/amavisd.conf` Amavisd ha:

```
$sa_tag_level_deflt  = 2.0;
```

Questo significa che Amavisd inserirà intestazioni come `X-Spam-Flag` ed altre come `X-Spam-*` quando il punteggio della mail sarà >=2.0. Se preferite che Amavisd inserisca sempre queste intestazioni, configurate il valore del punteggio piu basso, per esempio:

```
$sa_tag_level_deflt  = -999;
```

Il riavvio del servizio di Amavisd è necessario dopo aver modificato le configurazioni.
