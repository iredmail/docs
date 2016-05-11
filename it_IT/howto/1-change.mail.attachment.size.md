# Modifica dimensione massima per un'allegato di una mail

[TOC]

Per cambiare la dimensione dell'allegato, dobbiamo modificare 3 configurazioni

## Cambia la dimensione massima del messaggio in postfix

Postfix è un MTA, per cui dobbiamo cambiare la sua configurazione per trasferire mail
con allegati di grosse dimensioni.

Per esempio, per permettere un allegato che sia di 100Mb, modificate i valori sia di
`message_size_limit` che di `mailbox_size_limit` come mostrato sotto:

```
# postconf -e message_size_limit='104857600'
# postconf -e mailbox_size_limit='104857600'
```

Riavviate postfix per applicare le modifiche.

```
# /etc/init.d/postfix restart
```

__NOTE__:

* `104857600` corrisponde a 100 (MB) x 1024 (KB) x 1024 (Bit).
* La mail sarà codificata dal vostro client (OutLook, Thunderbird, etc) prima di essere inviata,
   quindi la dimensione totale del messaggio più l'allegato sarà superiore a 100MB. 
   Puoi risolvere il problema portando il limite massimo a 110Mb o 120Mb.
* Se configurate `mailbox_size_limit` con un valore inferiore a quello di `message_size_limit`
   Postfix riporterà il seguente errore nel suo log: `fatal: main.cf configuration  error:  
   mailbox_size_limit is smaller than message_size_limit`.

Se usate client di posta come OutLook o Thunderbird per inviare le mail, adesso è possibile 
inviare grossi allegati con le configurazioni appena spiegate.

## Modifica dimensione di upload nel client web Roundcube

Se usare Roundcube webmail, dovrete cambiare altri due parametri:

### Modificate le configurazioni di PHP in modo di caricare grossi allegati

Dovrete cambiare nel file di configurazione di PHP in `/etc/php.ini` le seguenti 
configurazioni: `memory_limit`, `upload_max_filesize` e `post_max_size`  

* in RHEL/CentOS: in `/etc/php.ini`
* in Debian/Ububtu: in `/etc/php5/apache2/php.ini`
* in FreeBSD: in `/usr/local/etc/php.ini` per quanto riguarda Apache, per Nginx
   invece in `/etc/php5/fpm/php.ini` 
*in OpenBSD: in `/etc/php-5.4.ini`. Se usate una release diversa di PHP il numero di versione 
  `5.4` sarà diverso rispetto all'esempio.

```
memory_limit = 200M;
upload_max_filesize = 100M;
post_max_size = 100M;
```

### Modifica configurazioni di Roundcube webmail per permettere allegati di grosse dimensioni

Modificate le stesse configurazioni in `.htaccess` nella directory root di roundcube:

* in RHEL/CentOS: in `/var/www/roundcubemail/.htaccess`
* in Debian/Ububtu: in  `/usr/share/apache2/roundcubemail/.htaccess` oppure
  `/opt/www/roundcubemail/.htaccess`.
* in FreeBSD: in`/usr/local/www/roundcubemail/.htaccess`
*in OpenBSD: in  `/var/www/roundcubemail/.htaccess`

Nota: il file `.htaccess` può non esistere in alcune distribuzioni Linux/BSD, nel qual caso 
ignorare le seguenti modifiche

```
php_value    memory_limit   200M
php_value    upload_max_filesize    100M
php_value    post_max_size  100M
```

Riavviate il servizio di Apache o php-frm per accettare le modifiche fin qui applicate.

### Modifica dimensione di upload in Nginx

Trovate, nel file di configurazione di Nginx, cher si trova a `/etc/nginx/nginx.conf`,  la riga con `client_max_body_size`e modificate il valore assegnato alle vostre specifiche esigenze.


```
http {
    ...
    client_max_body_size 100m;
    ...
}
```
