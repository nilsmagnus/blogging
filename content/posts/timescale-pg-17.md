+++
date = '2025-03-27T12:45:29+01:00'
draft = false
title = 'Oppgradering av database for farvann'
featured_image = '/images/timescale.webp'
tags = ['farvann', 'docker']
+++

Farvann-appen bruker en postgres som database med timescaledb og postgis extensions. 

Denne databasen har nå blitt oppdatert til siste tilgjengelige versjon fra dockerhub(timescaledb-ha:pg17), som beskrevet [her](https://docs.timescale.com/self-hosted/latest/install/installation-docker/). Denne versjonen er pakket med både timescale og postgis, så dette gjør livet lett for meg som bruker begge disse extensionene. 

Oppgraderingen gikk smertefritt uten behov for å gjøre noen kode-endringer. Det ser også ut til at den nye versjonen bruker en del mindre cpu enn den forrige versjonen, så dette var en særdeles god og smertefri oppgradering!


Dette er kommandoen jeg bruker for å starte databasen på hetzner-instansen min (noe redigert med tanke på brukernavn og passord). Som du ser så er det veldig lite custom parametere jeg bruker for å starte databasen, med unntak av at dataene til databasen lagres utenfor docker-imaget. 

     docker start aisdb || docker run  -v /home/hetzneruser/ais-backend/pgdata17/data:/home/postgres/pgdata/data  -e POSTGRES_USER=dbuser -e POSTGRES_PASSWORD=pwd -e POSTGRES_DB=aisdb --name aisdb -dt -p 5433:5432 timescale/timescaledb-ha:pg17-all

🐘 ❤️‍🔥