# Disabilitare completamente Amavisi + ClamAV + SpaAssassin

[TOC]

in iRedMail Amavisd rende disponibili le seguenti opzioni:

* scansione per contesto di spam (attraverso SpamAssassin)
* Scansione Virus (attraverso ClamAV)
* Firma DKIM
* Verifica firma DKIM (attraverso SpanAssassin + modulo Perl)
* Verifica SPF (attraverso SpamAssassin + modulo Perl)
* Esclusione di responsabilità (attraverso AlterMIME)

### Arresti della scansione  virus/spam, mantenendo in funzione la firma/verifica DKIM e L'esclusione di responsabilità.

Se volete disabilitare la scansione anti virus e anti spam, mantenendo però la fila DIKIM e la Esclusione di responsabilità, provare così:

* Nel file di configurazione di Posfix ad `/etc/postfix/main.cf` mantenete `content_filter = smtp-amavis:[127.0.0.1]:10024`

* Trovate le seguenti linee in /etc/amavisd/amavisd.conf:
```perl
# @bypass_virus_checks_maps = (1);  # controls running of anti-virus code
# @bypass_spam_checks_maps  = (1);  # controls running of anti-spam code
```
Decommentate le righe sopra  (rimuovendo il carattere # da ogni riga), e riavviate il servizio Amavisd.

### Disabilitare completamente tutte le opzioni:

 Se volete disabilitare completamente sia il servizio anti spam che anti virus, fate:

* Commentate le due righe sotto nel file di configurazione di Postfix `/etc/postfix/main.cf`:

```cfg
content_filter = smtp-amavis:[127.0.0.1]:10024
receive_override_options = no_address_mappings  # <- it's ok if you don't have this line
```

* Commentate le righe sottostanti nel file di configurazione di Postfix `/etc/postfix/main.cf`:

```cfg
  -o content_filter=smtp-amavis:[127.0.0.1]:10026
```

* Il riavvio del servizio Postfix è necessario.
* Disabilitare i seguenti servizi di rete: Amavisd, ClamAV.

Note:

* ClamAV e SpamAssassin sono invocati da Amavisd, per cui se disabilitate Amavisd i due servizi sanno anch'essi disabitati.
* SpamAssassin non ha un demone in esecuzione in iRedMail, per cui non serve fermare il servizio SpamAssassin.
 
