# Veiktspējas regulēšana

> Thanks to [Simona Auglis](http://www.autonvaraosastore.fi) for the contribution.

Ja jūs aizņemts pasta serveri (daudz ienākošo/izejošo e-pastu katru dienu), jūs varat sekot zemāk ierosinājumus, lai uzlabotu veiktspēju.

## Uzstādīšana DNS serveri LAN vai localhost DNS cache vaicājumus

Pasta pakalpojumiem lielā mērā paļaujas uz DNS pakalpojumu un veikt daudzas daudzas queries DNS, cache DNS serveris LAN vai localhost palīdz daudz:

Tas paātrina DNS vaicājumu. Tas palīdz daudz.
Tas samazina DNS vaicājumu DNSBL serveriem, lai varētu turpināt izmantot savu lielisko servisu, nepārkāpjot Maks vaicājuma ierobežojumu.

## Lespējot postscreen pakalpojums, kas palīdz samazināt surogātpasta daudzumu

* [Lespējot postscreen pakalpojumu](./enable.postscreen.html)

Ja nevēlaties izmantot postscreen pakalpojumu, varat iespējot DNSBL pakalpojumu vietā, tas palīdz daudz. Kaut gan postscreen, gan tīri DNSBL pakalpojumus izmanto vienu un to pašu DNSBL serverus, bet postscreen piedāvā papildu risinājumus, lai samazinātu surogātpastu, tāpēc postscreen ir labāka.

postscreen un DNSBL pakalpojums palīdz daudz surogātpasta pirms nodošanas spams vietējais e-pasta rinda, tāpēc viņi ietaupīt daudz sistēmas resursu nozvejas.

##  Atjaunots Amavisd + Postfix config failus, lai apstrādātu papildu e-pasta ziņojumus vienlaicīgi

* [Vienlaicīgi apstrādāt vairāk e-pastu](./concurrent.processing.html)
