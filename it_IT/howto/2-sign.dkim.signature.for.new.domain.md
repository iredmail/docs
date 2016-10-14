# Apponi firma DKIM su e-mail in uscita per il nuovo dominio di posta elettronica

[TOC]

> Non sapete cosa DKIM sia? Leggete il nostro tutorial qui:
> [Cos'è un record DNS DKIM](./setup.dns.html#dkim-record-for-your-mail-domain-name).

> Non sapete dove sia il file di configurazione di Amavisd? Leggete il nostro tutorial qui:
> [Posizione dei file di configurazioni e log dei maggiori componenti](file.locations.html#amavisd).

iRedMail configura Amavisd per firmare le mail in uscita con il primo dominio di posta che avete
aggiunto durante l'installazione di iRedMail. Se aggiungete un nuovo dominio di posta, dovrete modificare
il file di configurazione di Amavisd affinché apponga la firma DKIM.

Mettiamo che il primo dominio di posta aggiunto durante l'installazione di iRedMail sia `mydomain.com`,  
ed il nuovo dominio aggiunto sia `new_domain.com`, eseguite i seguenti passi per abilitare la firma DKIM per 
mail in uscita per il nuovo dominio.

## Usare la chiave esistente DKIM per il nuovo dominio

Se avete già una chiave DKIM ed il relativo record DNS DKIM, va bene se usate la chiave DKIM  esistente per
firmare le mail in uscita per il nuovo dominio. Così facendo non dovrete chiedere al cliente che detiene il nuovo 
dominio di creare un nuovo record DNS DKIM.

* Cercate le configurazioni qui sotto nel file di configurazione di Amavisd, `amavisd.conf`:

```
dkim_key('mydomain.com', "dkim", "/var/lib/dkim/mydomain.com.pem");

@dkim_signature_options_bysender_maps = ( {
    ...
    "mydomain.com"  => { d => "mydomain.com", a => 'rsa-sha256', ttl => 10*24*3600 },
    ...
});
```

Aggiungete una riga  nel blocco `@dkim_signature_options_bysender_maps`, dopo la linea `"mydomain.com"` come 
riportato qui sotto:

```
@dkim_signature_options_bysender_maps = ( {
    ...
    "mydomain.com"  => { d => "mydomain.com", a => 'rsa-sha256', ttl => 10*24*3600 },
    "new_domain.com"  => { d => "mydomain.com", a => 'rsa-sha256', ttl => 10*24*3600 },
    ...
});
```

* Riavviate il servizio Amavisd.

## Generate una nuova chiave DKIM per il nuovo dominio.

Se il vostro cliente preferisce usare una propria chiave DKIM, potete generare una nuova chiave DKIM e chiedere al 
vostro cliente di aggiungere un record DNS DIKIM sul proprio dominio. Fate riferimento al nostro tutorial
[Aggiungere un record DNS DKIM](setup.dns.html#dkim-record-for-your-mail-domain-name).

* Generare una  nuova chiave DKIM (lunghezza della chiave 1024`) per il nuovo dominio.

```shell
amavisd-new genrsa /var/lib/dkim/new_domain.com.pem 1024
chown amavis:amavis /var/lib/dkim/new_domain.com.pem
chmod 0400 /var/lib/dkim/new_domain.com.pem
```

> * se state eseguendo CentOS, potrebbe essere necessario specificare il file di configurazione sulla linea di comando
>    per esempio:
>
>    `# amavisd -c /etc/amavisd/amavisd.conf genrsa /var/lib/dkim/new_domain.com.pem 1024`

* Cercate le seguenti righe nel file di configurazione di Amavisd, `amavisd.conf`:

```
dkim_key('mydomain.com', "dkim", "/var/lib/dkim/mydomain.com.pem");
```

Aggiungere una riga dopo le righe sopra, come di seguito:

```
dkim_key('new_domain.com', "dkim", "/var/lib/dkim/new_domain.com.pem");
```

* Cercate le seguenti righe nel file di configurazione di Amavisd, `amavisd.conf`:

```
@dkim_signature_options_bysender_maps = ( {
    ...
    "mydomain.com"  => { d => "mydomain.com", a => 'rsa-sha256', ttl => 10*24*3600 },
    ...
});
```

Aggiungete una riga dopo la linea contenente `"mydomain.com"` come la linea che segue:

```
@dkim_signature_options_bysender_maps = ( {
    ...
    "mydomain.com"  => { d => "mydomain.com", a => 'rsa-sha256', ttl => 10*24*3600 },
    "new_domain.com"  => { d => "new_domain.com", a => 'rsa-sha256', ttl => 10*24*3600 },
    ...
});
```
 
* Riavviate il servizio Amavids.

Di nuovo, non dimenticate di aggiungere un nuovo record DNS DKIM nel nuovo dominio. Il valore del record DKIM
può essere verificato con il seguente comando;

```shell
# amavisd-new showkeys
```

Dopo aver aggiunto il record DNS DKIM, verificatelo con il seguente comando;

```shell
# amavisd-new testkeys
```

Nota: I provider DNS generalmente tengono in cache per due ore i record DNS, per cui se il comando ritorna " invalid" 
invece di "pass", dovrete seguire nuovamente il test dopo un po' di tempo.

## Uso di uanchiave DKIM per tutti i domini di posta

Per compatibilità verso dkim_milter il dominio che firma puo includere un "*" come carattere jolly - questo non è raccomandato in quanto Amavisd, in questo caso, potrebbe produrre firme che non hanno corrispondenza con la chiave pubblicata nel DNS. Il modo corretto è di avere una chiave dkim per ogni dominio di posta.

Se comunque volete provare questa configurazione, eseguite i passi seguenti:

* Cercate la seguente riga nel file di configurazione di Amavisd, `amavisd.conf`:

```
dkim_key('mydomain.com', "dkim", "/var/lib/dkim/mydomain.com.pem");
```

* Sostituitela con la riga seguente:

* Replace it by below line:

```
dkim_key('*', "dkim", "/var/lib/dkim/mydomain.com.pem");
```

* Riavviate il servizio Amavisd.

Con questa configurazione, tutte le mail in uscita saranno firmata con questa  chiave dkim. Ed Amavisd mostrerà un messaggio di avviso quando avviate il servizio Amavisd:

> dkim: wildcard in signing domain (key#1, *), may produce unverifiable
> signatures with no published public key, avoid!

## Referenze

* Documenti ufficiali di Amavisd: [Configurazione della firma e verifica DKIM](http://www.ijs.si/software/amavisd/amavisd-new-docs.html#dkim)
