+++
date = '2025-04-12T09:36:29+02:00'
draft = false
title = 'Båter utenfor norske farvann'
tags = ['ais', 'farvann']
featured_image = '/images/farvann-20250412.png'

+++

*Farvann*-appen kan nå vise båter som seiler utenfor norske farvann.

# Kystverket som hoffleverandør

Dataene fra kystverket blir levert på binær format over en tcp-socket. Serveren til farvann lytter på denne socketen og lagrer data i en normal postgresql-database (med timescale og postgis). Data fra kystverket er helt gratis og åpent for publikum.

Kystverket har inntil nå vært hoffleverandør av data om båter til Farvann og de leverer data av høy kvalitet. Aberet med Kystverket er selvfølgelig at de kun leverer data fra den norske kysten, men også at de begrenser data om båter under 15 meter slik at disse ikke vises i datastrømmen. 

# Kompletterende data fra aisstream.io

[aisstream.io](https://aisstream.io) er en annen leverandør av data. Dette er en community-drevet tjeneste og leverer kun data fra de områder der entusiaster har satt opp private AIS-mottagere. Det er derfor ikke satelitt-dekning og derfor vil båter som befinner seg langt til havs ikke bli sporet. 

![aisstream dekningskart](/blogg/images/aisstream-coverage.png "Aisstream har begrenset dekning")
_Aisstream dekningskart._

Denne datakilden blir nå inkludert i farvann, og man vil derfor kunne se båter fra andre farvann enn norske-kysten. 

Dataene fra aisstream blir levert på en websocket og blir tolket av farvann-serveren på lignende måte som tcp-socketen fra kystverket. Dataene blir lagret i samme database

# Channels to the rescue

Nå har vi altså 2 datastrømmer til serveren og da kommer konseptet om `channels` til sin fulle rett. I `go` har man muligheten til å ha flere channels som man lytter på samtidig for å håndtere nettopp slike tilfeller. 

Det opprettes 2 channels, en for hver datakilde:

```golang
kystverketChannel := make(chan ais.Packet, 4)
aisstreamChannel := make(chan ais.Packet, 4)
```

Så spinner jeg opp en go-routine for hver av disse slik at de kan lese fra hver sine kilder samtidig. Hvis noen av streamene skulle feile, så venter jeg 5 sekunder før jeg prøver å koble opp på nytt:

```golang
go func() {
    for {
        if kystverketStream(kystverketChannel) != nil {
            // reconnect every 5 seconds when failed kystVerket
            time.Sleep(5 * time.Second)
        }
    }
}()

go func() {
    for {
        if aisstreamioStream(aisstreamChannel, config.AisStreamKey) != nil {
            // reconnect every 5 seconds when failed aisStream
            time.Sleep(5 * time.Second)
        }
    }
}()
```


Den vakreste kodesnutten har jeg spart til slutt, der jeg bruker det magiske keywordet `select` i go. Det gjør at jeg kan loope over flere channels samtidig og kun foreta meg noe hvis det er noen meldinger på en channel. Og sånn havner data fra begge datastrømmene i samme database:

```golang
for {
    select {
    case packet := <-kystverketChannel:
        SavePacket(packet, europeGeoJSON, config, db)
    case packet := <-aisstreamChannel:
        SavePacket(packet, europeGeoJSON, config, db)
    }
}
```



# Last ned

Appen Farvann kan lastes ned til [iOS](https://apps.apple.com/no/app/farvann/id6502554133) og [Android](https://play.google.com/store/apps/details?id=no.bytecode.aisapp2&hl=no).