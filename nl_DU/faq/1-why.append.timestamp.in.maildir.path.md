# Waarom tijdstip toevoegd aan e-mailfolder path

iRedMail voegt standaard een tijdstip toe aan een gebruiker hun e-mailfolder path, mensen vroegen ons vele keren waarom we dit doen, hier is waarom. :)

Stel je deze situatie voor:

* Werknemer __Michael Jordan__ heeft email adres `mj@domain.ltd`. Zonder timestamp in
  e-mailfolder, zou zijn e-mailfolder path `/var/vmail/vmail1/domain.ltd/mj/` zijn.

* Michael verlaat het bedrijf, je bedrijf verwijdert zijn e-mail account, en er wordt ingepland dat zijn e-mailbox zal worden vernietigd in een bepaald aantal jaar (om lokale wetten te volgen die je verplichten om het bij te houden, oftewel wil je gewoon een lokale backup).

* Een nieuw talent, __Mike Jackson__, komt werken in je bedrijf, hij wil
  `mj@domain.ltd` gebruiken omdat dat momenteel door niemand wordt benuttigd. Je maakt dat aan voor hem. Zonder een tijdstip in het e-mailfolder zal die hetzelfde zijn als __Michael Jordan__'s, namelijk `/var/vmail/vmail1/domain.ltd/mj/`.
  In dat geval zal __Mike Jackson__ alle oude e-mails zien die overblijven in __Michael Jordan__'s
  e-mailbox.

Om dit probleem te voorkomen, voegt iRedMail een tijdstip toe aan alle e-mailfolders om te verzekeren dat alle gebruikers unieke e-mailfolder paths hebben.

!!! attention

    Als je een e-mail gebruiker creëert met iRedAdmin of iRedAdmin-Pro kan dat worden aangepast:

    - [Pas e-mailfolder path aan](https://docs.iredmail.org/iredadmin-pro.customize.maildir.path.html)
