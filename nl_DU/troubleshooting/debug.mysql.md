# Log uitgevoerde SQL commando's in MySQL/MariaDB

> Weet je niet waar het MySQL configuratiebestand zich bevindt? Check deze tutorial:
> [Locaties van configuratie and log bestanden van belangrijke componenten](file.locations.html#mysql-mariadb).

Om uitgevoerde SQL commando's te loggen moet je onderstaande instellingen toevoegen aan MySQL/MariaDB configuratiebestand `my.cnf`:

```
[mysqld]
general_log = 1
general_log_file = /var/log/mysql.log
```

Dan MySQL/MariaDB service herstarten.

Merk op: MySQL/MariaDB daemon gebruiker moet de bemachtigingen hebben om te kunnen schrijven naar dit logbestand.
