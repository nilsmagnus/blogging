+++
title= 'Fra bits og bytes til datastrukturer'
tags= ['go']
date = '2023-09-27T23:36:09+01:00'
draft = true
+++

_Først publisert på kodemaker.no/blogg_

Hobbyprosjektene mine har en tendens til å være tett koblet med binære dataformater. Bli med å se
hva som skjer under panseret når bytearrays leses til meningsfulle datastrukturer

Jeg har hatt 2 ganske tidkrevende hobbyprosjekter der binære protokoller har stått sentralt: mitt kjære
[bibliotek for å parse værdata](https://github.com/nilsmagnus/grib) i GRIB2-formatet, og en applikasjon som
leser binære AIS-meldinger fra en TCP-socket som kystverket publiserer.

GRIB-biblioteket startet jeg på fordi jeg hadde høye ambisjoner om å lagre rådata om værmeldinger og observasjoner i lengre tid som jeg kan gjøre maskinlæring på, men som så mange andre hobbyprosjekter strandet
det etter at jeg hadde laget den første biten. Så nå har jeg et kult bibliotek for å lese binære værdata og noen terrabytes med GRIB-filer som ligger og venter på motivasjon for å bruke maskinlæring til å spå strømpriser og vær.

AIS-meldingene parser jeg i dag og holder på med en mobil-app for å visualisere posisjoner og historikk for skip i norske farvann. Hvis du er veldig tålmodig kommer det kanskje en app og en bloggpost om dette senere.

Begge prosjektene har lært meg en hel del om hvordan man kan lese bytearrays for å få ut meningsfulle data. Jeg har brukt Go
for å lese de binære dataene, noe som har vist seg å være veldig fordelaktig.

I denne bloggposten har jeg oppsumert 3 metoder å lese binære data på, med økende kompleksitet:

* datatypene aligner fint med bytearrayen vi skal lese
* data ligger i hele bytes, men ikke aligner med innebygde datatyper
* data er representert som bits, som kan gå fra en byte til en annen


## Metode 1: Når binærdataene matcher datatyper med kjent lengde

Når en binær protokoll har meldinger med felter av datatyper av fast størrelse som matcher de vanligste datatypene er det
ganske rett frem å parse bytearrays til datastrukturer.

Ta f.eks headeren til [meldingstype 1 i GRIB2](https://www.nco.ncep.noaa.gov/pmb/docs/grib2/grib2_doc/grib2_sect1.shtml) spesifikasjonen.

| Octet number | Content                             |
|--------------|-------------------------------------|
| 1-4          | Length                              |
| 5            | Number of the section               |
| 6-7          | Identification of generating center |

_de 3 første feltene i meldingstype 1 i GRIB2_

Her har første felt 4-bytes lengde og er et positivt heltall. Dette tilsvarer en `uint32` fordi denne datatypen er 4 byte (4 byte = 32 bit, derav 32 i `uint32`). De neste feltene er 1 byte tall, så det blir felter av typen `uint8`.


For å lese inn bare disse feltene
lager vi derfor en datatype med

```go
type PartialGrib1Header struct{
	Length      uint32
	Number      uint8
	GenCenterId uint8
}
```

Og her har vi en fordel av å bruke `go`, for go sine structer har minnelayout i samme rekkefølge som feltene er definert.

Det vil si at vi kan opprette en tom `PartialGrib1Header` og lese rett fra en byte-reader inn til pekeren av structen:

```go
import (
	"encoding/binary"
	"io"
)
// reader er en io.Reader som leser fra en bytearray
partialHeader := PartialGrib1Header{}
binary.Read(reader, binary.BigEndian, &partialHeader)
```

Her bruker vi bare funksjoner fra standardbiblioteket i Go. Denne metoden fungerer vel og merke _bare_ når vi vet lengden på alle feltene vi skal lese og når alle feltene har samme lengde som en primitiv i Go.

En streng, som har variabel lengde, eller en 3-bytes integer kan ikke leses på denne måten.

## Metode 2: Når data går opp i hele bytes

Hvis et binært format spesifiserer at et tall er f.eks 3 byte eller en annen lengde som ikke samsvarer med de innebygde datatypene våre må vi gå grundigere til
verks og ta frem gamle kunnskaper om byte-operatorer.

Ta eksempelet om et tall som er 3 byte som vi skal lese fra en spesifikk plass i en bytearray. I dette tilfellet må vi lese en og en byte og left-shifte resultatet for hver byte.


```go
func extractNumber(payload []byte, offset uint, width uint) int64 {
	result := uint64(0) // initielt resultat, en 0-verdi av en 8-byte heltalls primitiv

	for i := offset; i < offset+width; i++ {
		result <<= 1 // shift resultatet med 1  for å gjøre plass til neste byte-verdi
		if i < uint(len(payload)) {
			result |= uint64(payload[i]) // les inn den nye byten og bruk OR-operatoren
		}
	}

	return int64(result)
}
```
_Den observante leseren ser at vi leser "fra høyre", big-endian_

Denne metoden funker helt fint så lenge verdiene vi skal lese har en lengde som går opp i bytes.

## Metode 3: Komprimerte formater i bits

Grunnen til å bruke binære formater er ofte at man vil spare plass ved å komprimere data så mye som mulig. I dataformater for vær og vind er det ofte store matriser med tall som skal representeres,
og hvis nabotall er ca like trenger man bare noen få bits for å uttrykke differansen til forrige tall istedenfor å lagre en hel tall-verdi. Så hvis temperaturen i Oslo er 19,1 grader og temperaturen i
Bærum er 19,8 og Asker 19,2, kan man se for seg at man bare oppgir temperaturen for Oslo som tallverdi og de andre verdiene som deltaer av denne. Siden differansen er en mindre tallverdi kan den også lagres
med færre bytes og bits.

Da kan man f.eks finne på at en tall-verdi skal kunne lagres i 3 bits istedenfor bytes. Da holder det ikke lenger å lese hele bytes, men vi må ned på bit-nivå.

|  Byte-1   |  Byte-2  |  Byte-3  |  Byte-4  |  Byte-5  |  Byte-6  |
|:---------:|:--------:|:--------:|:--------:|:--------:|:--------:|
| 000000011 | 10100001 | 00000010 | 00000011 | 00000100 | 00000101 |

Hvis vi tenker at tabellen over er en bytearray vi skal tolke, så kan vi se for oss at tallet vi skal lese inn har en offset på 7 og en bredde på 3 bits. Da må vi lese 1 bit fra Byte-1 og 2 bits fra Byte-2.

Koden for dette er over middels kompleks, men hvis vi graver helt ned i bunnen av GRIB-biblioteket så finner vi en funksjon for å lese ut bits og en funksjon som ligner veldig på forrige metode.

Her har jeg laget meg en egen `BitReader` som holder styr på gjeldende offset og leser ut bit for bit, med bitwise OR og left-shifting.


```go
func (r *BitReader) readBit() (uint, error) {
    if r.offset == 8 || r.offset == 0 { // les ny byte fra underliggende bytearray kun hvis forrige byte er utlest
        r.offset = 0
        if b, err := r.reader.ReadByte(); err == nil {
            r.byte = b
		} else {
            return 0, err
        }
    }
    bit := uint((r.byte >> (7 - r.offset)) & 0x01) // her er den viktige linjen for å lese ut 1 bit
    r.offset++
    return bit, nil
}


func (r *BitReader) readUint(nbits int) (uint64, error) {
	var result uint64
	for i := nbits - 1; i >= 0; i-- {  // nbits er lengden til datatypen i bytearrayen
		if bit, err := r.readBit(); err == nil { // lese 1 og 1 bit
			result |= uint64(bit << uint(i))     // bruke OR for å legge til bitten i resultatet
		} else {
			return 0, err
		}
	}

	return result, nil
}
```

Her leser vi inn et tall av lengde `nbits` fra `BitReader` og bruker OR-operatoren for å legge til resultatet, ganske likt som i forrige metode.


## Trenger jeg dette da?

Forhåpentligvis trenger de færreste av oss å bry seg med bitwise operatorer for å lese binære formater, og heller bruke ferdige biblioteker for å lese sånt.
Men neste gang du ser en binær protokoll så vet du akkurat hva som foregår under panseret.

Og hva er vel en bedre ice-breaker på en fest enn å snakke om OR og AND operatorer på binære data?



<style type="text/css">
table {
  overflow:scroll;
  border-collapse: unset;
  width: 100%;
}

td{
  border: 1px solid black;

}

</style>
