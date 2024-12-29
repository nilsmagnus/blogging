+++
title ='Go på kommandolinjen'
date ='2023-08-04'
tags = ['go']
+++

_Først publisert på kodemaker.no/blogg_

Go har blitt brukt til å lage mange av de verktøyene vi bruker i dag. Kubernetes, docker, prometheus og [mye mer](https://github.com/avelino/awesome-go). Men hvordan passer det for å lage programmer til kommandolinjen? Og er det like bra som Rust som Odin beskriver i sin [bloggpost](https://www.kodemaker.no/blogg/2023-07-rust-cli/)?

Denne bloggposten er en kopi av Odin sin bloggpost, men der han bruker Rust har jeg brukt Go for sammenligning.

## Hva skal vi lage?

Vi skal skamløst kopiere ideen til Odin om å lage et cli for å hente dagens og morgendagens priser fra tibber sitt api og presentere det på kommandolinja.


* Lese argumenter til programmet fra kommandolinjen
* Lese inn et personlig Tibber API token
* Hente priser fra Tibber APIet med tokenet
* Tegne en graf med priser

```shell
 0.494 ┤                                                                   ╭───╮
 0.475 ┤                                           ╭───╮                   │   ╰───────────╮
 0.455 ┤                                       ╭───╯   │                   │               ╰───╮
 0.436 ┤                       ╭───╮       ╭───╯       │                   │                   ╰───╮
 0.417 ┤                       │   │   ╭───╯           ╰───╮           ╭───╯                       ╰───
 0.398 ┼───╮               ╭───╯   │   │                   │           │
 0.379 ┤   │               │       ╰───╯                   │           │
 0.360 ┤   │               │                               ╰───╮       │
 0.341 ┤   │               │                                   │       │
 0.321 ┤   │               │                                   │       │
 0.302 ┤   │               │                                   ╰───────╯
 0.283 ┤   │               │
 0.264 ┤   │               │
 0.245 ┤   │               │
 0.226 ┤   │               │
 0.206 ┤   │               │
 0.187 ┤   ╰───╮           │
 0.168 ┤       │       ╭───╯
 0.149 ┤       │       │
 0.130 ┤       │   ╭───╯
 0.111 ┤       ╰───╯
	00:00			06:00			12:00			18:00			24:00
```
(Dette er det ferdige resultatet)

## Komme i gang

Først må du [installere go](https://go.dev/doc/install).

Deretter oppretter vi prosjektet og en fil for kildekoden:

    $ go mod init github.com/nilsmagnus/energipris
    $ touch main.go

Vi kjører programmet med `go run main.go`.

## Avhengigheter

I motsetning til Rust og mange andre språk så har filosofien til Go vært at man skal kunne bygge verdifulle programmer med kjernebiblioteket, altså uten å dra inn avhengigheter.

Lese argumenter fra kommandolinjen, håndtere json, logging, lage http-requester og asynkrone operasjoner gjøres helt fint med kjernebiblioteket.

Men funksjonalitet som f.eks ascii-grafer er ikke i kjernebiblioteket, så det må vi legge til manuelt som en dependency:

    go get -u github.com/guptarohit/asciigraph@latest

Hvis man ikke liker kjernebiblioteket sin tilnærming til noen av disse tingene, så finnes det selvfølgelig en drøss med eksterne biblioteker man kan dra inn for å løse de samme bibliotekene.

## func main()

`main()` er funksjonen som starter programmet vårt. Den legger vi her i filen `main.go`

og fyller ut med følgende "hello tibber"

```go
package main

import (
	"log"
)

func main() {
	log.Println("Hello tibber")
}
```
Enkelt og greit, ingen magi her som trenger forklaring. Vi importerer og bruker `log`-pakken som er en del av standardbiblioteket.

## Argumenter

For å lese argumenter bruker vi den innebygde pakken `flag`. Den gir oss en del fine ting ut av boksen, men gir oss dessverre ekle pekere istedenfor verdier tilbake når vi leser argumentene.

```go
prisDag := flag.String("prisdag", "idag", "Vise priser for i dag eller i morgen. Gyldige verdier: idag , imorgen")

flag.Parse()

if *prisDag != "idag" && *prisDag != "imorgen" {
    flag.Usage()
    log.Fatalf("Ugyldig prisdag: %s", *prisDag)
}
```

Her oppretter vi `prisDag` som et gyldig argument til programmet med en default verdi. Vi må kalle på funksjonen `flag.Parse()` for at den skal få lest inn argumentet fra kommandolinjen.

Go sin `flag` pakke kommer med en del funksjonalitet, som blant annet lar brukeren printe ut gyldige flag og verdier.



```shell
# bygge programmet
$ go build

# kjøre programmet
$ ./energipris -help
Usage of ./energipris:
  -prisdag string
    	Vise priser for i dag eller i morgen. Gyldige verdier: idag , imorgen (default "idag")

#teste ugyldig verdi for prisdag
$ ./energipris -prisdag overimorgen
Usage of ./energipris:
  -prisdag string
    	Vise priser for i dag eller i morgen. Gyldige verdier: idag , imorgen (default "idag")
2023/08/03 20:37:32 Ugyldig prisdag: overimorgen
```

## Strømpriser

For å hente ut strømpriser som gjelder for din husstand må du hente et api-token fra tibber. Som Odin sier så vil ikke hardkode dette eller lagre det i historikken til terminalen, så vi lager det som en miljøvariabel.

```go
apiToken, hasToken := os.LookupEnv("TIBBER_API_TOKEN")

if !hasToken {
    log.Fatal("TIBBER_API_TOKEN is not set.")
}
```

Ikke noe magi her, `os.LookupEnv` returnerer en `bool` for om miljøvariabelen finnes og selve variabelen. Hvis miljøvariabelen ikke finnes logger vi en melding med `log.Fatal` som skriver ut meldingen med en pen timestamp og terminerer programmet med exit-kode 1.


For å hente strømprisene med tibber sitt graphql api kunne jeg brukt et graphql-bibliotek, men siden jeg bare skal gjøre 1 oppslag så hardkoder jeg requesten med go sitt innebygde `http`-bibliotek:

```go
client := &http.Client{}

requestMap := map[string]string{"query": requestBody}
requestJson, err := json.Marshal(requestMap)
if err != nil {
    log.Fatalf("Klarte ikke lage json av requesten")
}

req, err := http.NewRequest("POST", "https://api.tibber.com/v1-beta/gql", bytes.NewBuffer(requestJson))
if err != nil {
    log.Fatalf("Det er noe galt med requesten: %v", err)
}
req.Header.Add("Content-Type", "application/json")
req.Header.Add("Accept", "application/json")
req.Header.Add("Authorization", fmt.Sprintf("Bearer %s", apiToken))

response, err := client.Do(req)
if err != nil {
    log.Fatalf("Feil ved henting av data fra tibber: %v", err)
}
```

Wow. Det var mye `if err != nil` ! Men sånn er det når man ikke har et typesikkert språk og man tillater null-verdier. Vi sjekker alltid om funksjonen feilet ved å sjekke den returnerte feilen for å være sikre på at programmet ikke skal terminere uventet.

Requesten vi skal sende ser sånn ut:
```go
const requestBody = `{
  viewer {
    homes {
     currentSubscription {
       priceInfo {
         current {
           total
           energy
           tax
           startsAt
         }
       }
     }
   }
 }
}`
```

## Parsing av resultatet til JSON

For å kunne tolke json til en type i go så lager vi en struct der vi annoterer feltene med json og hvilket navn det tilsvarer i json-strukturen:

```go
type TibberResponse struct {
	Data struct {
		Viewer struct {
			Homes []struct {
				CurrentSubscription struct {
					PriceInfo struct {
						Current struct {
							Total    float64   `json:"total"`
							Energy   float64   `json:"energy"`
							Tax      float64   `json:"tax"`
							StartsAt time.Time `json:"startsAt"`
						} `json:"current"`
						Today    []Day `json:"today"`
						Tomorrow []Day `json:"tomorrow"`
					} `json:"priceInfo"`
				} `json:"currentSubscription"`
			} `json:"homes"`
		} `json:"viewer"`
	} `json:"data"`
}

type Day struct {
	Total    float64   `json:"total"`
	Energy   float64   `json:"energy"`
	Tax      float64   `json:"tax"`
	StartsAt time.Time `json:"startsAt"`
}
```

for å serialisere http-responsen inn i denne structen bruker vi den innebygde pakken `json`:

```go
tibberResponse := TibberResponse{}

if err := json.Unmarshal(body, &tibberResponse);err!=nil{
	log.Fatalf("Klarte ikke deserialisere responsen til tibber:%v \n %s", err, body)
}
```

Her lager vi først en tom struct av tibberResponse før vi lar `json.Unmarshal()` gjøre jobben for oss og sjekker om returnerer en feil. Mer at vi sender pekeren til structen til `json.Unmarshal()`.

## ASCII-graf

For å visualisere noe på kommandolinjen så må vi presentere det som ascii-art. For dette bruker vi biblioteket `asciigraph`:

```go
...
data := mapTibberData(tibberResponse.Data.Viewer.Homes[0].CurrentSubscription.PriceInfo.Tomorrow)
graph := asciigraph.Plot(data, asciigraph.Precision(3), asciigraph.Height(20), asciigraph.SeriesColors(asciigraph.Green))
fmt.Println(graph)
...


func mapTibberData(days []Day) []float64 {
	result := make([]float64, len(days))
	for i, f := range days {
		result[i] = f.Total
	}
	return result
}
```

Ja, du leser riktig. Go har ikke en innebygd map-funksjon, så denne må du skrive selv. Heldigvis har man fått støtte for generics i go, så det finnes gode biblioteker som kan gjøre dette for deg.

Ascii-biblioteket er ikke av det mest avanserte heller, så jeg lager en egen linje for å skrive ut timestamps på x-aksen:

```go
	fmt.Println("\t00:00\t\t\t06:00\t\t\t12:00\t\t\t18:00\t\t\t24:00")
```

Resultatet blir **smellvakkert**:

```shell
$ go run main.go --prisdag idag
 0.494 ┤                                                                   ╭───╮
 0.475 ┤                                           ╭───╮                   │   ╰───────────╮
 0.455 ┤                                       ╭───╯   │                   │               ╰───╮
 0.436 ┤                       ╭───╮       ╭───╯       │                   │                   ╰───╮
 0.417 ┤                       │   │   ╭───╯           ╰───╮           ╭───╯                       ╰───
 0.398 ┼───╮               ╭───╯   │   │                   │           │
 0.379 ┤   │               │       ╰───╯                   │           │
 0.360 ┤   │               │                               ╰───╮       │
 0.341 ┤   │               │                                   │       │
 0.321 ┤   │               │                                   │       │
 0.302 ┤   │               │                                   ╰───────╯
 0.283 ┤   │               │
 0.264 ┤   │               │
 0.245 ┤   │               │
 0.226 ┤   │               │
 0.206 ┤   │               │
 0.187 ┤   ╰───╮           │
 0.168 ┤       │       ╭───╯
 0.149 ┤       │       │
 0.130 ┤       │   ╭───╯
 0.111 ┤       ╰───╯
	00:00			06:00			12:00			18:00			24:00

```

## Fordeler med Go

* Lett å lære, rakst å komme i gang med avanserte oppgaver
* Koden blir eksplisitt og det er lite overraskelser
* Økosystemet er stort siden så mange store selskaper har investert mye i go. Det finnes gode biblioteker for alt mulig
* Det kompilerer raskt og kjører raskt
* Det er garbage-collected, så du slipper å tenke på allokeringer og deallokeringer
* Godt standardbibliotek som tar deg langt uten at du trenger eksterne avhengigheter
* Det kompilerer til en native binærfil, noe som gjør deployment til en lek. Alle mainstream OS og cpuer støttes av go.

## Ulemper med Go

* Mutability. Alt er muterbart, så vær forsiktig
* Feilhåndtering  kan bli i overkant mye. Onde tunger vil ha det til at språket burde blitt kalt errlang siden man ender opp med veldig mange `if err != nil`
* Det mangler innebygd støtte for å mappe over arrays. Man kan bruke biblioteker, men her har de en jobb å gjøre
* Ikke null-safe, men det er lagt opp til at man skal håndtere feil


## Oppsummert

Go er såpass enkelt at det tar kort tid å komme i gang. Feilmeldingene fra kompilatoren er forståelig og det er lett å feilsøke, selv for nybegynnere.

For å komme i gang raskt anbefaler jeg [tour of go](https://go.dev/tour/welcome/1) som lar deg utforske språket i nettleseren og "The Go Programming Language" av Kernighan.

Vil jeg anbefale go i et prosjekt? Nja. Til CLI og enkle web-apper funker det fint, men jeg ville valgt noe annet hvis du skal transformere mye data og har behov for map/fold/reduce funksjoner. Eller hvertfall sjekke at det finnes biblioteker for å jobbe ergonomisk med arrays.

For hobbyprosjekter er dette mitt favorittspråk siden det er lett å lage noe og det kompilerer til en statisk binærfil.

Entusiaster kan hente [kildekoden min](https://github.com/nilsmagnus/energipris) fra github.
