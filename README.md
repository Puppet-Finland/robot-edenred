# robot-edenred

This repository contains [Robot Framework](https://robotframework.org/)
scripts for automating Edenred operations.

These scripts have been created because charging Edenred cards manually is
such a painful and confusing operation that we often did not get our benefits
because of user errors, or simply because we forgot to charge the cards in
time. So, we wanted to make the process standardized, automated and reliable.
These scripts are a core part of that process. Automation can be handled from
cron by a Linux-based Robot with a graphical desktop (e.g. xfce4). While
Robot scripts tend to be fairly reliable, we recommend monitoring them with
[Prometheus](https://prometheus.io/) using our Textfile Collector script called
[robot-collector](https://github.com/Puppet-Finland/robot-collector). That
way, if the Edenred website ever changes and the script break, you get an
alert.

# Mass operations using CSV files

Edenred cards can be charged with the following benefits:

* **Lounas**: *lunch* and *recreational*
* **Työmatka**: *transportation*

The charging process for these is identical, except that you (or Robot) needs
to select the correct card type at the beginning.

The [ticket.edenred.fi](ticket.edenred.fi) service allows manipulating users
and charging their Edenred cards by uploading a specially formatted CSV file
(see [cardholder list page](https://ticket.edenred.fi/cardholder-management/cardholder-list/) for details).

The sample CSV file Edenred provides uses the ISO-8859-1 (ISO Latin 1)
character set. It is a legacy character set that does not support non-latin
European languages. Modern information systems on the Internet and elsewhere
use UTF-8 character encoding, so when you edit the CSV file make sure you keep
it in the legacy ISO-8859-1 format or strange things may happen.

The format of the CSV file is documented in the CSV file itself, copied here
for convenience:

```
# VERSIO: 1.0.0.7,,,,,,,,,,,,,,,,,
# ,,,,,,,,,,,,,,,,,
#TYHJÄT RIVIT JA RIVIT JOTKA ALKAVAT #-MERKILLÄ JÄTETÄÄN HUOMIOIMATTA,,,,,,,,,,,,,,,,,
#TÄHDELLÄ * MERKITYT KENTÄT OVAT PAKOLLISIA,,,,,,,,,,,,,,,,,
#TÄHDELLÄ ** MERKITYÍSTÄ KENTISTÄ TOINEN TULEE TÄYTTÄÄ,,,,,,,,,,,,,,,,,
# ,,,,,,,,,,,,,,,,,
# TOIMINTO KOODIT:,,,,,,,,,,,,,,,,,
#    N = TILAA UUSI KORTTI,,,,,,,,,,,,,,,,,
#    R = TILAA KORTTI UUDELLEEN,,,,,,,,,,,,,,,,,
#    U = PÄIVITÄ TYÖNTEKIJÄN TIEDOT (PL. HENKILÖTUNNUS JA ASIAKASNUMERO),,,,,,,,,,,,,,,,,
#    D = POISTA KORTINHALTIJA,,,,,,,,,,,,,,,,,
#    H = MUUTA KORTINHALTIJA POISSA TILAPÄISESTI TILAAN,,,,,,,,,,,,,,,,,
#    L = LATAA SALDOA,,,,,,,,,,,,,,,,,
# ,,,,,,,,,,,,,,,,,
# TYÖNTEKIJÄN TYÖSUHTEEN MUOTO:,,,,,,,,,,,,,,,,,
#    F = KOKOAIKAINEN,,,,,,,,,,,,,,,,,
#    P = OSA-AIKAINEN,,,,,,,,,,,,,,,,,
#    T = MÄÄRÄAIKAINEN,,,,,,,,,,,,,,,,,
#    I = PASSIIVINEN,,,,,,,,,,,,,,,,,
# ,,,,,,,,,,,,,,,,,
#TOIMINTOKOODI*,HENKILÖTUNNUS*,ETUNIMI*,SUKUNIMI*,OSOITE*,POSTINUMERO*,KAUPUNKI*,PUHELINNUMERO**,SÄHKÖPOSTIOSOITE**,TYÖNTEKIJÄNUMERO,KUSTANNUSPAIKKA,OSASTO,KERROS,ALUE,TYÖSUHTEEN MUOTO,LOUNAS_LATAUS,VIRIKE_LATAUS,TRANSPORT_LATAUS
#N,xxxxxx-xxxx,Eija,Esimerkki,Esimerkkikatu 3 A,510,Helsinki,0401111111,eija.esimerkki@esimerkki.net,1234,2222,Finance,8 krs,Helsinki,F,,,
```

So, for example, to load 226€ lunch and 33€ recreational benefits to John Doe
you'd craft a line like this:

    L,241298-3500,John,Doe,Esimerkkitie 5 A 10,20100,Turku,,john.doe@example.org,,,,,,F,226,33,

To charge 55€ transport benefit to the same person you'd use this:

    L,241298-3500,John,Doe,Esimerkkitie 5 A 10,20100,Turku,,john.doe@example.org,,,,,,F,,,55

Note that in practice you need separate CSV files for loading the
lunch/recreational and travel benefits. The only exception is if all your
employees get the same set of benefits. To illustrate the issue take this CSV
file used to load public transportation cards:

    L,241298-3500,John,Doe,Esimerkkitie 5 A 10,20100,Turku,,john.doe@example.org,,,,,,F,,,55
    L,050896-493Y,Jane,Doe,Esimerkkitie 1 B 20,20100,Turku,,jane.doe@example.org,,,,,,F,,,
    L,061088-103X,Jack,Doe,Esimerkkitie 3 D 15,20100,Turku,,jack.doe@example.org,,,,,,F,,,0

Edenred will fail to validate line 2 is because no public transportation charge
amount is empty for Jane. Line 3 fails because Jack's charge amount is set to 0.

Most of the fields in the CSV can *probably* be left empty when charging. I
have not experimented which are absolutely necessary. However, *Henkilötunnus*
(social security number) is almost certainly used to link the CSV line to an
empoyee, because name would not work given the limitation of ISO-8859-1
character set.

## charge-edenred.robot

This Robot script allows you to charge employee Edenred cards. It depends on
the
[Browser](https://marketsquare.github.io/robotframework-browser/Browser.html)
and
[String](https://robotframework.org/robotframework/2.1.2/libraries/String.html)
libraries. Credentials and the path to the CSV file are passed as environment
variables.



As the charging process seems to be somewhat unreliable, the script verifies
the date of the latest (CSV) order and its status in attempt to catch any
charging errors.

This script probably will not work for other CSV operations which may or may
not present the user (or Robot) with completely different prompts.

Example usage from a Linux terminal:

    EDENRED_USERNAME=my_email EDENRED_PASSWORD=secret LOUNAS_CSV_FILE_PATH=normaali-lounas-virike.csv TYOMATKA_CSV_FILE_PATH=normaali-tyomatka.csv robot tasks/charge-edenred.robot
