+++
title = 'Lagre JSON-objekter i postgresql!?'
date = '2023-11-15T23:36:09+01:00'
tags = ['postgresql', 'json']
+++

_Først publisert på kodemaker.no/blogg_

De aller fleste av oss som bruker postgres bruker det som en vanlig relasjonell database med
skjemaer for det vi vil lagre. Men visste du at du kan slippe unna de strenge skjemaene ved å bruke den
innebygde støtten for JSON i postgres? Og det er ikke så dumt som det kanskje høres ut heller!

## Hvorfor skal vi lagre JSON-dokumenter?

Hele greia med relasjonelle databaser er jo at du har et skjema som definerer hva slags data du vil lagre. Et tidspunkt
lagres i en kolonne av typen `timestamptz` og en tekst i en kolonne av typen `text`. Men i en fase av prosjektet der du
ikke har landet datamodellen din enda, eller hvis du har data med veldig varierende struktur kan det å lagre JSON være
en god måte å starte på, sammenlignet med å definere hele datamodellen din tidlig i prosjektet.

## Støtte for JSON-type(r) i Postgres

På lik linje med datatyper som `text`, `int` og `boolean` så har postgres en type for JSON som de kaller `jsonb`. `b`
i `jsonb` står for _binary_, og det finnes en tidligere versjon som bare heter `json`. Forskjellen mellom ny og gammel
er
at `jsonb` rett og slett er bedre på ytelse, ellers er de nesten identiske. Så `b` kunne like godt stått for `better`
istedenfor `binary`.

`jsonb` gjør en del optimaliseringer når man setter data inn i en tabell som gjør den litt tregere ved lagring. Men
siden denne typen lagrer dataene i et optimalisert format så går spørringer mye raskere enn `json`-typen.

For alle praktiske formål vil du velge `jsonb`-typen.

## Lag en tabell og litt data

Vi lager en tabell med kolonnen content av typen `jsonb` og lager litt innhold:

```postgresql
create table artikler
(
    id           serial primary key,
    article_type int   not null,
    content      jsonb not null
);

insert into artikler(article_type, content)
values (1, '{"nr": "42", "meta":{"tag":"bil", "title":"ny elbil", "codes":["a","b"]}}'::jsonb);
```

Her ser vi med en gang det som er litt fremmed i forhold til sql med de "vanlige" datatypene. Vi bruker innebygde
funksjoner, her bruker vi funksjonen `::jsonb` for å hanskes med datatypen. Dette er innebygde funksjoner i postgres for å
jobbe med JSON, så vi trenger ikke installere noen extension for å komme i gang.

## Hent ut data

For å hente ut hele JSON-objektet som en vanlig tekst-streng bruker vi funksjonen `::text` på kolonnen `content`.

```postgresql
select content::text
from artikler;
```

Men da får vi jo ut hele JSON-strukturen som tekst og vi må serialisere til den datatypen vi bruker for å lese
enkeltfeltene og det er jo litt kronglete når vi bare ville lese ut tittelen på artiklene. Da har vi heldigvis
operatorer som kan hjelpe oss for å hente ut tittelen for alle bil-artikler:

```postgresql
select content -> 'meta' ->> 'title' as tittel
from artikler
where content -> 'meta' ->> 'tag' = 'bil'
-- henter ut feltet "meta.title" fra et nøstet JSON-objekt
```

Operatoren `->`  henter ut et felt fra objektet, og `->>` er en variant som henter ut feltet og konverterer det
til `text`. Pil-operatorene `->` og `->>` er bare to av mange operatorer og funksjoner for å håndtere JSON som er
innebygd i postgres.

Hvis vi vil gjøre samme spørringen med andre operatorer kan vi f.eks bruke operatoren `#>` som tar inn en path som
parameter:

```postgresql
select content #>> '{meta,title}'
from artikler
where content #>> '{meta,tag}' = 'bil'
```

Eller hvis du vil hente ut id og kodene for artikler som har koden "a" så kommer de lettere kryptiske funksjonene `@>`
og `jsonb_array_elements()` godt med:

```postgresql
select id, id, jsonb_array_elements(content -> 'meta' -> 'codes')
from artikler
where content @> '{"meta":{"codes":["a"]}}'
```

Og det finnes mange flere slike spesialiserte operatorer og funksjoner for de ulike use-casene som du kan lese om
i [postgres-docen](https://www.postgresql.org/docs/16/functions-json.html#FUNCTIONS-JSON-PROCESSING).

I forhold til vanlig sql blir spørringene litt fremmede med alle disse kryptiske funksjonene og operatorene, men de er
effektive for å jobbe med JSON.

Og hvis du skulle spørre etter et felt i JSON-strukturen som ikke finnes får du ikke en feilmelding, men `null` som
resultat.

## Men hva med indekser?

Ja, man kan faktisk legge på indekser på feltene i et JSON-objekt! Med forrige avsnitt og de noe kryptiske funksjonene i
mente så kommer det kanskje som en overraskelse at dette er ganske rett frem:

```postgresql
create index article_tag_idx on artikler using gin ((content -> 'meta' -> 'tag'))
```

Her har vi spesifisert at det er en index av `gin`-typen som er den man vanligvis velger, men man kan velge en `btree`-
eller `hash`- index hvis man vil.

Dette er ganske awesome! Vi kan altså legge på indekser inne i en JSON-struktur som vi ikke har skjema for!  Hvis du
bruker postgis-extensionen kan du til og med lagre geolokasjoner i JSON-strukturen din
kan du gå helt bananas og legge på index på geolokasjonene også!

## WTF-faktoren med JSON i postgres

De få operatorene og funksjonene jeg nevnte i forrige avsnitt ser ganske fremmede ut. Og det skal ikke gå mange dagene
før jeg skrev en sql for å massere JSON før jeg kommer tilbake til koden og lurer litt på hva som egentlig foregår.
Andre sine spørringer ser enda mer fremmed ut og wtf-faktoren er ganske stor sammenlignet med "vanlige" sqler.

## The good, the bad and the ugly

Jeg har brukt JSON i et hobbyprosjekt og et prosjekt i finn.no en stund nå og må si at jeg synes at dette har sine klare
fordeler, men ikke alt har vært helt rosenrødt. For å oppsummere hva jeg har tenker om JSON i postgres har jeg delt inn
tankene mine om hva jeg synes i _good_, _bad_ og _ugly_.

### The Good:

* Fleksibilitet. JSON gir deg muligheten til å lagre semi-strukturerte data. Du trenger ikke å definere en fast
  datamodell som i tradisjonelle relasjonsdatabaser.

* Innebygde funksjoner funker utmerket. PostgreSQL har støtte for JSON, inkludert mange funksjoner
  for å manipulere og hente data i nøstede datastrukturer.

* Indeksering: Du kan bruke GIN-indekser for å effektivt søke i JSON-data.

### The Bad:

* Wtf-faktoren i koden din øker. Arbeid med JSON-data kan være mer komplekst enn å arbeide med tradisjonelle tabeller,
  spesielt for komplekse spørringer. Kryptiske operatorer som `#>`, `@>` gjør spørringene fremmed for de som skal ta
  over koden etter deg.

* Ytelse: Selv om PostgreSQL har støtte for indeksering av JSON-data, kan ytelsen være dårligere enn for tradisjonelle
  tabeller, spesielt for store datasett.

* Hvis du bruker `jsonb`-typen så bevares ikke rekkefølgen av typene i dokumentet ditt. Duplikate nøkler blir også
  fjernet, slik at du bare sitter igjen med siste definerte nøkkel. Whitespace blir fjernet. Dette slipper du med den
  gamle `json`-typen, men da må du ofre ytelse.

### The Ugly:

* Ingen fremmednøkler. Du kan ikke lage en fremmednøkkel direkte på et JSON-felt. Det finnes workarounds, men
  disse er knotete.

* Ingen støtte for primærnøkkel i JSON-felt. Du kan ikke direkte bruke et felt inne i et JSON-felt som en primærnøkkel.

* Ingen skjemavalidering. Siden JSON er semi-strukturert, er det ingen innebygd måte å validere skjemaet for det du skal
  lagre. Du må håndtere skjemavalidering på applikasjonsnivå hvis du skal ha dette.

## Konklusjon

Postgres har innebygd støtte for lagring og spørring på JSON som er effektiv og moden. Men selv om det er fristende å
lagre alt som JSON, så er ikke alt rosenrødt når wtf-faktoren i koden din øker i takt med bruken av kryptiske operatorer
og funksjoner for å håndtere `jsonb`. Men det er et kraftig verktøy når du trenger å være fleksibel med
hensyn på datamodellen din.

Koden fra bloggposten finnes som en [gist her](https://gist.github.com/nilsmagnus/8302c63c0252101ce3e5d479a493c124).
