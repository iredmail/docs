# Zet debug modus aan in Dovecot

> Weet je niet waar de Dovecot configuratiebestanden zijn? Bekijk deze tutorial:
> [ Locaties van configuratie and log bestanden van belangrijke componenten](file.locations.html#dovecot).

Om debug modus te activeren in Dovecot, moet onderstaande parameter worden geüpdate in het Dovecot configuratiebestand `dovecot.conf`:

```
mail_debug = yes
```

Herstart Dovecot service.

Als je authenticatie en paswoord gerelateerde debug berichten nodig hebt, zet dan gerelateerde instellingen aan en herstart dovecot service.
```
auth_verbose = yes
auth_debug = yes
auth_debug_passwords = yes

# Set to 'yes' or 'plain', to output plaintext password (NOT RECOMMENDED).
auth_verbose_passwords = plain
```

Als Dovecot service niet kan starten moet je het manueel starten, het zal een error geven in de console:

```shell
dovecot -c /etc/dovecot/dovecot.conf
```

## Debug LDAP queries

Als je iRedMail met OpenLDAP backend draait, kan je het debugniveau
voor LDAP instellen in `/etc/dovecot/dovecot-ldap.conf` met parameter `debug_level`,
voeg  `1` toe of vernieuw het naar `1`, herstart dan dovecot service:

```
debug_level = 1
```

Je kunt het ook instellen op `-1`, wat 'log alles' betekent.
