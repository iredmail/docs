# WhiteList e BlackList

[TOC]

questo tutorial mostra come mettere in whitelist e blacklist mittenti o destinatari con iRedAmdin-Pro e gli script annessi ad iRedADP (sin dalla versione 1.7.1).

## Gestire whitelist e blaclist con iRedAdmin-Pro

Con iRedAdmin-Pro potete gestire diversi livelli di whitelist e blacklist:

* White/Blacklist: nel menu `System -> Anti Spam -> Whitelists & Blacklists`.
* White/Balcklist per dominio: nel pagina del profilo dominio, nel pannello `Whitelists and Blacklists`.
*  White/Balcklist per utente: nella pagina del profilo utente, nel pannello `Whitelists and Blacklists`.

Screenshot allegati in alla fine del documento.

## Gestire whitelist e blacklist con comandi SQL

Dalla versione 1.7.1 di iRedAPD viene allegato lo script `tools/wblist_admin.py` per aiutarvi a gestire whitelist/blacklist. Per avere la lista dei parametri di utilizzo eseguire lo script senza argomenti così come riportato sotto:

```
# cd /opt/iredapd/tools/
# python wblist_admin.py
```

Esempi di utilizzo:

* Aggiungere globalmente in whitelist o blacklist mittenti:

```
# python wblist_admin.py --add --whitelist 202.96.134.133 john@example.com @test.com @.abc.com
# python wblist_admin.py --add --blacklist 202.96.134.133 john@example.com @test.com @.abc.com
```

* Elencare mittenti inseriti in whitelist o blacklist a livello globale:

```
# python wblist_admin.py --list --whitelist
# python wblist_admin.py --list --blacklist
```

* Per gestire a livello utente o dominio le white/backlist aggiungete il parametro `--account` come sotto riportato:

```
# python wblist_admin.py --account mydomain.com --add --whitelist 202.96.134.133
# python wblist_admin.py --account user@mydomain.com --add --blacklist 202.96.134.133

# python wblist_admin.py --account mydomain.com --list --whitelist
# python wblist_admin.py --account user@mydomain.com --list --blacklist
```

* Per le mail in uscita aggiungete il parametro `--outbound` come sotto riportato:

```
# python wblist_admin.py --outbound --account mydomain.com --add --whitelist 202.96.134.133
```

Screenshot di iRedAdmin-Pro:

![](http://www.iredmail.org/images/iredadmin/system_wblist.png)

