#  Disabilitare greylisting in Cluebringer

!!! warning

    Cluebringer è stato rimosso da iRedMail sin dalla versione 0.9.3,se stai ancora
    usando Cluebringer, cortesemente segui la nostra guida per migrare verso 
    iRedAPD: [Migrare da Cluebringer to iRedAPD](./cluebringer.to.iredapd.html).


* Trova il file di configurazione di Cluebringer `cluebringer.conf` sul tuo 
  server con questo documento: [Posizione dei file di configurazione e log dei 
  principali componenti](./file.locations.html#cluebringer)

* Trova le seguenti righe in `cluebringer.conf`:

```
[Greylisting]
enable=1
```

Per disabilitare il greylisting, cambiare `enabled=1` in `enabled=0` e riavviare
e il servizio Cluebringer.
