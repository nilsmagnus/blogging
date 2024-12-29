+++
date = '2024-12-28T12:45:29+01:00'
draft = false
title = 'FFSBS - Flinke Folk Som Bryr Seg'
tags = ['ffsbs', 'metodikk']
+++

Hva skal egentlig til for å lykkes med IT? Dette spørsmålet er like aktuelt
i dag som for 14 år siden når jeg startet som utvikler. Den gangen jobbet jeg
i IBM som hadde sine oppskrifter for å gjøre IT-prosjekter. Metodikker lange som
vonde år med dokumentasjon for detaljstyring av hver lille del av prosjektet. Når jeg gikk over
til Accenture hadde de sin egen _V-modell_ som var like detaljert og komplisert. Der ble
det brukt store excel-regneark for å fylle ut hvilke behov kunden hadde for å kunne
regne ut hvilke deler av metodikken man kunne bruke og for å estimere prosjektkostnadene.
Excel-kunnskapene der overgikk alt jeg har sett i hele mitt liv.


## Ny, skinnende metodikk

Senere i karrieren min ble jeg kjent med nye metodikker som "smidig", agile, lean,
extreme programming, OKR etc. Alle med gode intensjoner og alle ble fortløpende tatt opp av de store
konsulentselskapene under ulike navn og solgt inn til kunder som det nye vidundermiddelet for å minimere
risikoen for at prosjektene gikk dårlig. Men likevel gikk de store prosjektene stort sett
over budsjett og over tid.

Hos en nylig kunde jeg var hos ble vi plutselig fortalt at nå skulle vi bli "outcome-teams" fordi
det var det [spotify-modellen](https://www.atlassian.com/agile/agile-at-scale/spotify) sa at man skulle gjøre. Det
viste seg at selskapet jeg jobbet for ikke var sammenlignbart med spotify hverken i produkt eller størrelse og etter
en stund hørte vi ikke mer om outcome-teams før vi ble fortalt at nå var det OKR som var det nye store fordi OKR har
fungert hos [google siden 1999](https://www.whatmatters.com/resources/google-okr-playbook). Året ble delt inn i 3 T`er, T1, T2 og T3 med tilhørende OKRer.
og vi satte oss mål i starten av første "T1" når vi startet. Merkelig nok ble vi ikke ferdig med alle målene vi
hadde satt oss, så vi måtte ta med oss ting over til T2. Og T3. Og til neste år når T1 startet. Heldigvis var ikke
denne kunden veldig rigid på metodikken, så vi fikk også gjort ting som ikke var satt som objektiver i starten av en T.

Denne kunden hadde i utgangspunktet svært dyktige folk og hadde lagd fantastiske produkter til markedet i en årrekke.
Det som ble levert var stort sett det samme som før de gikk all-in på outcome-teams og OKRer.

Misforstå meg rett, både outcome teams, OKR og smidig tankegang er ting jeg liker og har mye bra for seg.
Men er det metodikker i form av rammeverk som avgjør om organisasjonen lykkes med å ta i bruk IT eller å kjøre
utviklings-prosjekter?

## Ny, skinnende teknologi

Utviklingen for oss programmerer har vært i stor endring de siste 14 årene og ingenting tyder på at det vil bli mindre
endringer de neste 14 årene. Ting går fortere, verktøy blir enklere å bruke, nye programmeringsspråk ser dagens lys.
Rammeverk som lover å løse alt™ popper opp som paddehatter og det er til tider vanskelig å ta de riktige valgene.

Etter min erfaring så er det slik at når man velger rammeverk som løser alt for deg, så får du mye gratis med en gang, men
når du treffer edge-casene (og det gjør du), så går vinningen opp i spinningen med å prøve å forstå hvordan rammeverkene er
bygd opp.

I et av de morsomste prosjektene jeg har vært med på brukte vi hibernate, et ORM-rammeverk for å håndtere lesing og skriving av
data til en database. Det fungerte fint i starten, men jeg tror vi brukte like mye tid på å håndtere hibernate som vi brukte
på å løse de faktiske oppgavene vi skulle gjøre. Fra den gang har jeg alltid tenkt at alle typer for ORM-rammeverk er
rammeverk som prøver å innføre et abstraksjonsnivå for databasen, men som du ender opp med å bruke mer tid på enn
om du bare hadde gjort alle databaseoperasjonene manuelt.

I det samme prosjektet (og flere senere prosjekter) har jeg til min ergrelse måtte bruke spring fordi det var enten
bestemt av andre eller allerede bestemt av teamet før jeg kom inn. Spring er et rammeverk som også løser mange
vanskelige problemer og lar deg komme fort i gang med nye prosjekter. Men det har en kostnad. Det tar ikke lang
tid før du graver deg ned i detaljene av hvordan diverse spring-annotasjoner fungerer og stacktracene blir lange som
kafkaesque prosesser og du ønsker deg mer eksplisitt kode enn det spring og hibernate kan tilby.

Funksjonell programmering bringer mye godt med seg og sammen med mindre rammeverk som vil gjøre alt for deg så har verden
blitt bedre for mange utviklere. Men så har du de som trekker det kanskje litt for langt i andre retningen. Når
programmering plutselig glir over i akademiske retninger og selve programmeringen og programmeringsspråket
blir målet i seg selv så kommer det faktiske problemene vi skal løse i andre rekke. Jeg har på følelsen av at
noen av oss programmerer burde være litt mer pragmatiske mht valg av teknologier og litt mindre religiøse
som enkelte fremstår (jeg ser på dere blodfans av [sett-inn-programmeringsspråk-som-skal-løse-alle-problemer]).

## Flinke folk som bryr seg, FFSBS

Så hva skal egentlig til for å lykkes med IT når vi ikke kan stole 100% på at hverken valg av metodikk eller teknologi
kan sikre oss suksess?

Hvis du har vært med på prosjekter som har lykkes så vil du helt sikkert huske at det er en del flinke folk
som har vært nøkkelfaktoren. Kanskje du har en [Alf Kristian](https://www.kodemaker.no/alf-kristian/) på laget
som gjorde en uvurderlig innsats og tok mange riktige teknologi-valg? Eller en [Christin](https://www.kodemaker.no/christin/)
som høylytt og uredd sa meningene sine når ting ikke henger på grep?

Jeg er hvertfall ganske sikker på at prosjektene som lykkes ikke har så veldig mye med metodikk X og programmeringsspråk N
å gjøre. Det er de flinke folka som bryr seg om produktet som skal leveres som er avgjørende. Når du har disse
om bord vil sjansene for å lykkes øke betraktelig.

Selvfølgelig hjelper det med andre ting som små team, autonomitet og kort vei til produksjon, men jeg har troa på de flinke folka som bryr seg.

FFSBS for the win!
