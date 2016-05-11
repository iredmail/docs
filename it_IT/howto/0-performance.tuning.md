# Ottimizzazione delle prestazioni

[TOC]

Se avete in esecuzione un server di posta con un alto carico di lavoro (molte 
mail al giorno in entrata ed in uscita), potete seguire questi suggerimenti per
migliorare le prestazioni,

###  Configura un server DNS in rete o localmente per mettere in cache 
le richieste

I server di posta usano __pesantetemente__ il server DNS ed effettuta molte,
molte richieste al DNS che esso sia inrete locale o sullo stesso server 
può aiutare __molto__:

* Velocizza le richiste DNS. Questo aiuta molto.
* riduce le richieste DNS verso i server DNSBL, così che possiate usare i 
  loro eccellenti servizi senza superare il limite massimo di interrogazioni.

### Attiva il servizio postscreen aiuta a ridurre lo spam

* [Attiva servizio postscreen](./enable.postscreen.html)

Se non vuoi usare il servizio postscreeen puoi, alternativamente, 
[abilitare il servizio DNSBL](./enable.dnsbl.html), anche questo può aiutare
parecchio. Anche se entrambi i servizi `postscreen` e DNSBL puro utilizzano 
gli stessi server DNSBL, `postscreen` offre soluzioni aggiuntive per
ridurre lo modalità postscreen è migliore.

postscreen ed il servizio DNSBL aiutano ad intercettare molto spam prima ancora
che lo spam venga inviato alla coda della posta, risparmiando cosi un bel po'
di risorse del sistma.

###  Aggiora i file di configurazione di Amavisd + Postfix per elaborare
molte più mail contemporaneamente.

* [Elaborare più mail contemporaneamente](./concurrent.processing.html)
