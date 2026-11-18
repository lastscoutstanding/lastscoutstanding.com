# lastscoutstanding.com

Domein van Bas. Nu vooral de site voor de reünie van 25 jaar Scouting Brandevoort (Helmond) in `reunie25/`; de root stuurt daarheen door.
Repo: github.com/lastscoutstanding/lastscoutstanding.com, gehost op GitHub Pages (lastscoutstanding.com, via `CNAME`).
Stand: 17 november 2026.

## Werkwijze in Claude Code

- Werk direct in deze lokale repo. Begin een taak met `git pull`; Bas past soms zelf bestanden aan via GitHub.
- Eén logische wijziging = één commit. Push pas na akkoord van Bas: de site staat live.
- Testen via `python3 -m http.server 8000` in de repo-root (config `site` in `.claude/launch.json`), dan `/reunie25/`. De txt-bestanden worden met `fetch` geladen en werken niet via `file://`.
- Het push-token in de sleutelhanger dekt sinds 16 november 2026 ook deze repo.
- Werk dit bestand bij na elke grotere wijziging, vooral "Reünie" en "Open punten".

## Architectuur

Vanilla HTML/CSS/JS, geen build-stap. Alleen relatieve paden, zodat `reunie25/` als geheel kan verhuizen (bijv. later via een doorverwijzing vanaf reunie.scoutingbrandevoort.nl). Geen cookies of tracking. Alleen NL.

| Pad | Rol |
| --- | --- |
| `index.html` | Stuurt door naar `reunie25/` (meta refresh). Vervangen als de root iets anders moet worden |
| `reunie25/index.html` | Home: datum, aftelling, aantal inschrijvingen, een paar namen |
| `reunie25/inschrijven.html` | Inschrijven; ingelogd = gegevens aanpassen |
| `reunie25/inloggen.html` | Inloggen met e-mail + code van 6 cijfers (stap `#code`) |
| `reunie25/mijn.html` | Eigen inschrijving: kaartje, links "wie was er tegelijk met jou", aanpassen, uitschrijven, uitloggen |
| `reunie25/deelnemers.html` | "Wie komen er?": zoeken, filter speltak + jaar (`?speltak=&jaar=`), tabblad "Per jaar" |
| `reunie25/programma.html` + `programma.txt` | Programma (`tijd | omschrijving`, andere regels = alinea) |
| `reunie25/vragen.html` + `vragen.txt` | FAQ (`V:` / `A:`) |
| `reunie25/privacy.html` | Privacyverklaring (noemt Supabase en Resend, wissen uiterlijk 23 augustus 2027) |
| `reunie25/speltakken.txt` | Speltakken met instapleeftijd, `opgericht = 2001`; regel zonder leeftijd = rol zonder speltak (Bestuur / vrijwilliger) |
| `reunie25/reunie.js` | Gedeeld: speltakken.txt inlezen, jaren berekenen, persoonskaartje, `esc()`, jaarvelden-pijltjes |
| `reunie25/data.js` | Datalaag: de enige plek die met opslag praat. `SUPABASE_KEY` leeg = DEMO (localStorage), ingevuld = Supabase via `fetch` (geen bibliotheek) |
| `_docs/beheer.md` | Beheerhandleiding: alle instellingen bij GitHub, Webreus (DNS), Resend en Supabase. Bijwerken bij elke wijziging daar |
| `_supabase/schema.sql` | Tabellen, row level security en functies voor Supabase; één keer draaien in de SQL-editor. Map met `_`, dus niet gepubliceerd |
| `reunie25/nav.js` | Kop (blauwe band met logo, titel en datum) + lichte menubalk eronder (sticky, actieve pagina geel onderstreept, laatste link rechts als knop), footer, testversie-balk bij DEMO |
| `reunie25/logo.svg`, `logo-wit.svg` | Logo als vector, zie "Reünie" |
| `reunie25/theme.css` | Stijl; kleuren van scoutingbrandevoort.nl (#2c4696) en het logo (geel). Licht/donker volgt het systeem |

## Reünie

- Zondag 23 mei 2027, blokhut de Brandnetel, Helmond. Scouting Brandevoort is opgericht in 2001.
- "Scobra" alleen heel spaarzaam gebruiken (nu één keer, in de footer): niet iedereen vindt het een goede naam.
- Logo: `reunie25/logo.svg` (zwarte letters) en `logo-wit.svg` (witte letters, in de blauwe kop; ook favicon via `nav.js`). Omgezet van het originele Illustrator-bestand uit 2011 (`~/Documents/Peter/Scouting Brandevoort/Nieuwe logo/20110503 Definitief/`), een PDF-compatibel `.ai`. macOS rendert dat bestand met een zwarte lelie; de SVG heeft de juiste kleuren (geel #ffe400, rood #fa0000, blauw #495faa).
- Persoon: voornaam, achternaam, bijnaam (optioneel, max. 40, getoond als Sanne “Snoes” Jansen), e-mail, geboortejaar, `takken: [{speltak, rol: 'lid'|'leiding', van, tot}]` (`tot` null = heden), `toon: {voornaam, achternaam, bijnaam, leeftijd, takken}`, `sinds`.
- Jeugdlid-jaren worden berekend uit geboortejaar + `speltakken.txt` (je zit in een speltak tot de leeftijd van de volgende), in kalenderjaren, en zijn met de hand aan te passen. Leiding-jaren vult iemand zelf in.
- Leeftijd = 2027 − geboortejaar (één te hoog voor wie na 23 mei jarig is).
- Privacy: verborgen velden zijn `null` in de publieke rij (`Data.publiek`). Bij een filter op speltak/jaar verschijnen mensen met verborgen speltakken alleen in het vaste blok "Ook ingeschreven, speltak niet getoond", zodat het filter niets verraadt.
- Inlogflow: inschrijven → formulier in sessionStorage → code → pas dan opslaan. E-mailadres nooit in de URL.
- DEMO: inlogcode `123456`, 20 verzonnen voorbeelddeelnemers, inschrijvingen in localStorage (`reunie25.demo`, sessie `reunie25.sessie`).

## Foto's (gepland)

Besloten op 18 november 2026, na een mockup:
- Alleen ingelogde deelnemers zien en uploaden foto's; bezoekers krijgen uitleg met inloggen/inschrijven.
- Nieuwe foto's zijn pas zichtbaar na goedkeuring door het comité (tab "Te beoordelen"); de uploader ziet ze zelf met "wacht op goedkeuring".
- Per foto: titel, jaar, speltak (filter zoals op "Wie komen er?"), "gedeeld door". Knop "Sta jij hierop…?" verbergt een foto en meldt het aan het comité.
- Verkleinen in de browser vóór upload: 1600 px (~350 KB) + miniatuur 400 px (~50 KB); opnieuw opslaan haalt ook GPS/EXIF weg. Supabase Free: 1 GB opslag, 5 GB verkeer per maand.

## Open punten

- [x] Supabase gekoppeld (project `glvrsppggmfksimpfckp`, regio Ierland/eu-west-1, 18 november 2026): schema gedraaid, inloggen met code getest door Bas.
- [x] Mail via Resend (`noreply@lastscoutstanding.com`, DNS bij Webreus: `resend._domainkey`, `send` → forge.rmta.net, `_dmarc`). Gratis: 3.000/maand, 100/dag. Supabase-mailtemplates "Magic Link" en "Confirm signup" bevatten `{{ .Token }}`.
- [ ] Rate limit in Supabase (standaard 30 mails/uur) ophogen vóór de aankondiging; aankondiging eventueel spreiden vanwege 100 mails/dag bij Resend.
- [ ] Gratis project pauzeert na een week zonder activiteit: keep-alive (bijv. GitHub Action) uitzoeken.
- [ ] Foto's bouwen (`fotos.html`); wie het comité is (beheer-e-mailadressen) is nog niet bepaald.
- [x] Privacyverklaring af (18 november 2026): contact Reüniecomité, Blokhut de Brandnetel, Brandevoort 13-A, 5706 KA Helmond, info@scoutingbrandevoort.nl; alles gewist uiterlijk 23 augustus 2027. Bij de foto's de verklaring aanvullen.
- [ ] Gegevens wissen uiterlijk 23 augustus 2027 (tabel `deelnemers` en de logins in Supabase).
- [ ] Programma en vragen invullen (`programma.txt`, `vragen.txt`).
- [ ] Jaarvelden-pijltjes niet getest in Safari.
- [ ] `README.md` noemt de oude reponaam.
