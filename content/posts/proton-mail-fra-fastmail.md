+++
date = '2025-03-29T20:25:27+01:00'
draft = false
title = 'Bytte fra bigtech til europeisk tech'
featured_image = '/images/proton.png'
tags = ['proton', 'hetzner', 'big-tech']
+++

Det er i vinden å bytte fra amerikanske leverandører til Europeiske leverandører og jeg støtter dette fullt ut. Her er det jeg har gjort i det siste.

## Mail

For noen år siden byttet jeg fra gmail til fastmail.com. Fastmail er jo egentlig australsk, så det er jo ikke så farlig? Men de benytter tjenester fra AWS, så da antar jeg at de har dataene mine lagret i USA. Derfor bytter jeg nå til [protonmail](https://protonmail.com). De er sveitsiske og lagrer data i Europa.

 Når jeg byttet fra gmail til fastmail så brukte jeg i tilleg jeg mitt eget domene, `bytecode.no`, slik at jeg kunne beholde mail-addressen min neste gang jeg byttet. Så denne gangen ble byttet helt udramatisk; bytte noen MX-records og migrer all mailen. 

 For å få tak i imap-passordet fra fastmail måtte jeg forøvrig gå til Settings->Migration->Set up Thunderbird. Deretter gikk alt lekende lett.

## Nettleser

Jeg har alltid likt Firefox, men nå har ting tatt en uventet vending når de nå tillater seg å dele data om deg med tredjeparter. Jeg tror ikke de kommer til å være den verste i klassen her, men det er en dealbreaker for meg. I tillegg så finnes det jo en veldig fin norsk nettleser som heter [Vivaldi](https://vivaldi.com) som ser ut til å ta privacy på alvor. Det er et minus at de ikke er open-source, men jeg gir dem en sjanse. 

 ## VPN

Jeg benytter [Mullvad VPN](https://mullvad.net/en). Det er svenskt og de har en veldig kul modell der du ikke trenger å oppgi navn eller mail. Du får et nummer som er ditt og betaler med den betalingsformen du vil (bitcoin, kredittkort, paypal etc.). Du kan tilmed sende kontanter hvis du ønsker det!

Tidligere har jeg brukt [ProtonVPN](https://protonvpn.com) og kommer nok til å prøve det igjen når tiden jeg har betalt for hos Mullvad går ut. 

Både Mullvad og Proton VPN er såkalte "no-logs" vpn, det vil si at de ikke lagrer logger på serverene sine om hva kundene sine surfer på. Det er jo greit å vite at surfehistorikken din ikke _kan_ bli delt med noen uansett hvor mye noen måtte ønske dette. 

Vivaldi har dessuten teamet opp med Proton for å tilby gratis VPN, dette kan jeg like!

 ## Lagring av filer

Kona og jeg bruker [Jottacloud](https://Jottacloud.no), noe vi har gjort en årrekke. Det gjør bildedeling lett på tvers av Android/iOS/Desktop, så dette er gull. Siden dette er norsk er det en no-brainer for meg som nordmann å velge dette. Dataene blir lagret i Norge. 

Hvis jeg ikke hadde vært norsk hadde jeg sterkt vurdert [Proton Drive](https://https://proton.me/drive) til dette.


## Passord

Jeg har heldigvis ikke låst meg til google eller apple sine passord-lommebøker nettopp fordi jeg ikke vil låse meg til enkeltleverandører eller plattformer. Bitwarden har vært min passord-wallet, noe jeg har betalt for. Men siden de er amerikanske så vender jeg nå nesen mot [Proton Pass](https://proton.me/pass). Den er dessuten både mer brukervennlig og penere. Funker på alle platformer og nettlesere også, så dette er fint. 

Proton er gratis til en viss grad, men du må betale for å få synke til ubegrenset antall devicer og noen andre features

## Hosting av tjenester

Jeg hoster alle mine ting hos [Hetzner.com](https://hetzner.com) og er storfornøyd med det. Jeg betalte lenge 40kr/mnd for en 4cpu/4gbRam/40GBdisk, men har oppgradert til det dobbelte av alt etter at jeg har fått litt trafikk på noen av tjenestene jeg hoster. 

På en sånn maskin kjører jeg flere database-instanser i docker og flere backender for blant annet appene `Vintilbud` og `Farvann` i tillegg til denne bloggen. 


# Betal vs gratis. 

Alle disse tjenestene med unntak av fil-lagring får du jo gratis hvis du vil hos de store tjenestene, men de forbeholder seg stort sett retten til å dele data om deg med tredjeparter eller til å bruke dataene for å servere deg tilpasset reklame. Med andre ord er det du som er produktet når tjenestene er gratis. 

For å slippe å være produktet må man som oftest betale for tjenestene nevnt over, med mindre man klarer seg med en gratis-kvote. 

Proton har f.eks gratis-varianter som er begrenset, men man må betale for å få alle features og nok lagringsplass til bilder og en solid historikk med email. 

Jeg betaler gladelig for disse tjenestene for å vite at dataene mine er i trygge hender og ikke i hendene på amerikanske reklameselskaper eller fremmede myndigheter. 