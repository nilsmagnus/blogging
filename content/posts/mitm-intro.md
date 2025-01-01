+++
title ='Analyser nettverks-trafikken fra appen din'
date= 2022-10-16
tags=['mitm']
draft = true
+++

_Først publisert på kodemaker.no/blogg_

Lurer du på hva appen din _egentlig_ gjør av nettverkstrafikk? Mitm-proxy gir deg det eksakte svaret.

## Hvorfor skal jeg det?

Mest sannsynlig har du full kontroll på hvike tjenester mobil-appen du har laget bruker.
Men hva slags tjenester blir brukt av de bibliotekene og SDK-ene du bruker og hva slags data sendes til disse tjenestene?

## Hva er en proxy?

En proxy er en applikasjon som fungerer som en slags gateway mellom enheten din og internett. All nettverkstrafikk går gjennom den, og det kan være nyttig til å sile ut
ondsinnet nettverkstrafikk, eller som i dette tilfellet: analysere trafikken mellom devicen din og internett.

## mitmproxy

[mitmproxy](https://mitmproxy.org/) er en open-source proxy som lar deg inspisere trafikk fra en fysisk device. Det er et veldig fleksibelt verktøy som kan konfigureres med mange parametere,
men for vanlig bruk kan vi bruke docker for å starte en ny instans. Jeg bruker mitm såpass ofte at jeg har et eget alias for å starte det jeg trenger:

    alias startMitm='docker run -it -v ~/.mitmproxy:/home/mitmproxy/.mitmproxy \
        -p 8081:8081 -p 8080:8080 \
        mitmproxy/mitmproxy mitmweb \
        --web-host 0.0.0.0'

Denne besvergelsen av en docker-kommando starter mitm og et web-grensesnitt lokalt på  `localhost:8081`. I tillegg lagrer den genererte sertifikater i `~/.mitmproxy/` slik at du slipper å installere nye sertifikater på devicen din hver gang du kjører trafikken gjennom mitm-proxy.

For å bruke denne proxyen må du ha en telefon som er på samme nettverk som pcen som kjører mitm. Dette gjør du ved å konfigurere en proxy i instillingene for wifi-nettverket ditt.

1. Finn ip-adressen til pcen som kjører mitmproxy (f.eks med `ifconfig`)
2. Åpne innstillingene for wifi-nettverket på telefonen og fyll inn ip-adressen og port 8080 for proxyen
3. Åpne nettleseren på en iOS-device (iOS er lettere å konfigurere enn android til dette)
og gå til adressen `mitm.it`. Da vil du få instruksjoner for å installere sertifikatet på din device. Følg disse nøye. Det innebærer blant annet å installere en nettverksprofil og installere mitm-sertifikatet i telefonen sin keychain.

Når du har gått gjennom alle instruksjonene kan du åpne appen på telefonen se trafikken som blir sendt og mottatt i web-grensesnittet til mitmproxy:

![mitmproxy](/images/blogg/mitmproxy.png "Slem app sender trafikk til facebook")

På bildet over ser vi at jeg har filtrert ut trafikk til facebook, og kan se hvilke data som sendes. I dette tilfellet er det en
app der jeg har skrudd på alt av privacy og skrudd av alt som heter "dele data med 3.part", likevel sendes det altså data til facebook. Dette kan selvfølgelig skyldes at sdk-et selv sender data når det blir lastet inn i appen.

## Certificate pinning
En del av trafikken fra apper kan ikke analyseres. Dette er fordi noen apper, spesielt de innebygde fra apple og google bruker "certificate pinning". Det vil si at de kun stoler på et subsett av sertifikater, og ikke alle
sertifikater som ligger i keychainen din på telefonen. Mitmproxy kan dermed ikke dekode trafikken fra disse appene.

## Andre metoder for å analysere trafikk.

Hvis du har appen du lager kjørende i en emulator(android) eller simulator(ios) på pcen din finnes det andre verktøy som kanskje er lettere å bruke enn mitmproxy. [Wireshark](https://www.wireshark.org/) og [tcpdump](https://www.tcpdump.org/) er gode open-source alternativer. [Little-snitch](https://www.obdev.at/products/littlesnitch/index.html) er populært på macOS.
