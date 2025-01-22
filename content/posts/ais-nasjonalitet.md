+++
date = '2025-01-22T08:25:29+01:00'
draft = false
title = 'AIS og nasjonalitet i Farvann'
tags = ['ais', 'farvann']
featured_image = '/images/russian-senara.png'

+++

# Visning av nasjonalitet i Farvann
I dag ble Farvann oppdatert med en bitteliten ny funksjonalitet: vise nasjonalitet til båter. Nasjonaliteten dukker opp på både popupen som kommer opp når man trykker på et fartøy og på siden for detaljer. 

Det er planlagt mer funksonalitet rundt dette på et senere tidspunkt. Da med tanke på fartøyer som er på sanksjonslister og fartøyer fra fremmede makter som oppholder seg i nærheten av undersjøiske kabler og annen infrastruktur.

# AIS og nasjonalitet

Farvann-appen baserer dataene sine i bunn og grunn på AIS-data fra Kystverket. 

Ingen steder i ais-meldingene står det eksplisitt noe om nasjonalitet. Men det er gjemt i feltet "user-id", også kalt mmsi(Maritime Mobile Service Identity). Dette
er et tall på formatet *257064900*, altså et helt vanlig tall ser det ut som. Men de tre første sifferene sier noe om _hvor_
skipet er registrert. 

For tilfellet **257**064900 er skipet Norsk. Det er 3 prefikser som er norske, 257, 258 og 259. De fleste land har bare ett prefiks tilknyttet seg.

Tabellen for prefiksene for alle land finnes f.eks på [itu.com](https://www.itu.int/en/ITU-R/terrestrial/fmd/Pages/mid.aspx).


# Last ned

Appen farvann kan lastes ned til [iOS](https://apps.apple.com/no/app/farvann/id6502554133) og [Android](https://play.google.com/store/apps/details?id=no.bytecode.aisapp2&hl=no).