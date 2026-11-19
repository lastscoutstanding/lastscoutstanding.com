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
| `reunie25/herinneringen.html` | Herinneringen (menu na "Wie komen er?"): tabblad Verhalen (lezen, zoeken/filteren, delen, eigen verhaal aanpassen/verwijderen, "Meld het") en Foto's (`#fotos`: grid, groot bekijken met pijltjes/vegen, meerdere tegelijk delen, eigen foto verwijderen, "Meld het"). Alleen voor deelnemers en comité; anderen zien een teaser met het aantal |
| `reunie25/programma.html` + `programma.txt` | Programma (`tijd | omschrijving`, andere regels = alinea) |
| `reunie25/vragen.html` + `vragen.txt` | FAQ (`V:` / `A:`); `{bedrag}` = bedrag uit `betalen.txt`, e-mailadressen worden links |
| `reunie25/beheer.html` | Comité. Tabblad Inschrijvingen: zoeken, filter (betaald / nieuw deze week), details, verwijderen (+ blokkeren, `<dialog>`), CSV, adressen kopiëren, betaald afvinken. Tabblad Te beoordelen (`#beoordelen`): foto's per inzending (plaatsen / afwijzen = wissen, "Alle N plaatsen"), opslaggebruik, en nieuwe/aangepaste en gemelde verhalen plaatsen, afwijzen (met opmerking), aanpassen, verwijderen. Tabblad Comité (`#comite`): lijst, hoofdbeheerder voegt beheerders toe/haalt weg, geblokkeerde adressen (deblokkeren), tabel "Wie mag wat?". Link "Beheer" alleen voor beheerders (`Data.beheerder()`, rol via `Data.rol()`) |
| `reunie25/betalen.txt` | Bedrag, betaallink, IBAN voor het betaalblok op `mijn.html`; leeg = geen blok |
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
- Contactadres van het comité: reunie@scoutingbrandevoort.nl (sinds 19 november 2026). Bijdrage € 5 per persoon (bedrag in `betalen.txt`). Alleen oud-leden, geen introducés. Op Beheer → Comité worden de hoofdbeheerders bij naam genoemd, uit de lijst zelf.
- "Scobra" alleen heel spaarzaam gebruiken (nu één keer, in de footer): niet iedereen vindt het een goede naam.
- Logo: `reunie25/logo.svg` (zwarte letters) en `logo-wit.svg` (witte letters, in de blauwe kop; ook favicon via `nav.js`). Omgezet van het originele Illustrator-bestand uit 2011 (`~/Documents/Peter/Scouting Brandevoort/Nieuwe logo/20110503 Definitief/`), een PDF-compatibel `.ai`. macOS rendert dat bestand met een zwarte lelie; de SVG heeft de juiste kleuren (geel #ffe400, rood #fa0000, blauw #495faa).
- Persoon: voornaam, achternaam, bijnaam (optioneel, max. 40, getoond als Sanne “Snoes” Jansen), e-mail, geboortejaar, `takken: [{speltak, rol: 'lid'|'leiding', van, tot}]` (`tot` null = heden), `toon: {voornaam, achternaam, bijnaam, leeftijd, takken}`, `sinds`.
- Jeugdlid-jaren worden berekend uit geboortejaar + `speltakken.txt` (je zit in een speltak tot de leeftijd van de volgende), in kalenderjaren, en zijn met de hand aan te passen. Leiding-jaren vult iemand zelf in.
- Leeftijd = 2027 − geboortejaar, getoond als "58 in 2027" (klopt dus ongeacht de verjaardag).
- E-mailadressen ziet alleen het comité; `beheer.html` heeft CSV-download en "Kopieer e-mailadressen" (van de gefilterde rijen, voor BCC).
- Privacy: verborgen velden zijn `null` in de publieke rij (`Data.publiek`). Bij een filter op speltak/jaar verschijnen mensen met verborgen speltakken alleen in het vaste blok "Ook ingeschreven, speltak niet getoond", zodat het filter niets verraadt.
- Rollen (19 november 2026): bezoeker, deelnemer, beheerder, hoofdbeheerder (tabel `beheerders`, kolom `rol`). Hoofdbeheerders alleen via de SQL Editor; op de site voegt een hoofdbeheerder alleen gewone beheerders toe of haalt ze weg. Comitéleden kunnen inloggen zonder inschrijving (`is_comite_adres()` → login wordt aangemaakt) en komen dan op Beheer; `inschrijven.html` toont hun een noot. DEMO: ingelogd = hoofdbeheerder, comité in `reunie25.demo.comite`.
- Verwijderen en blokkeren (19 november 2026, na mockup): elke beheerder mag het; blokkeren alleen samen met verwijderen; geen goedkeuring vooraf. "Nieuw" = ingeschreven in de afgelopen 7 dagen. Geblokkeerd adres: geen code bij inschrijven (`is_geblokkeerd_adres()`) en de trigger weigert de rij; melding zonder verwijt met reunie@scoutingbrandevoort.nl. DEMO: `reunie25.demo.geblokkeerd`, verwijderde voorbeelden in `reunie25.demo.weg`.
- Inlogflow: inschrijven → formulier in sessionStorage → code → pas dan opslaan. E-mailadres nooit in de URL.
- DEMO: inlogcode `123456`, 20 verzonnen voorbeelddeelnemers, inschrijvingen in localStorage (`reunie25.demo`, sessie `reunie25.sessie`). Ingelogd = beheerder; betalingen in `reunie25.demo.betaald`.
- Betalen (19 november 2026): vaste betaallink van de bank, geen betaalprovider. Het comité vinkt betalingen af op `beheer.html` (`zet_betaald()`, kolom `betaald_op`); de trigger voorkomt dat een deelnemer zichzelf op betaald zet. Lokaal testen in DEMO: `SUPABASE_KEY` tijdelijk leeg maken, niet committen.

## Verhalen (19 november 2026, na mockup)

- Tabel `verhalen` (titel ≤ 80, tekst ≤ 3000, speltak, jaar, `toon_naam`, `status` nieuw/geplaatst/afgewezen/gemeld). Trigger `verhalen_stempel`: elke nieuwe of aangepaste versie door de schrijver wordt weer `nieuw`; comitéfuncties zetten `reunie.comite = '1'` om dat te omzeilen.
- Naam bij een verhaal volgt wat iemand op "Wie komen er?" toont; `toon_naam` uit = "gedeeld door een oud-lid".
- Toon: de controle door het comité niet benadrukken. Schrijver ziet "wordt binnenkort geplaatst" en na insturen "verschijnt zo snel mogelijk". Afgewezen: "niet geplaatst" + opmerking.
- DEMO: `reunie25.demo.verhalen` met drie voorbeeldverhalen.
- Verhalen worden met de rest gewist (uiterlijk 23 augustus 2027). Bewaren voor later (boekje/archief) zou toestemming bij het insturen vragen; nog niet besloten.

## Foto's (gebouwd 19 november 2026)

Besloten op 18 en 19 november 2026, na mockups:
- Tabblad Foto's op `herinneringen.html`. Alleen ingelogde deelnemers zien en uploaden foto's; bezoekers krijgen uitleg met inloggen/inschrijven.
- Nieuwe foto's zijn pas zichtbaar na goedkeuring door het comité (tab "Te beoordelen"); de uploader ziet ze zelf met "wacht op goedkeuring".
- Per foto: titel, jaar, speltak (filter zoals op "Wie komen er?"), "gedeeld door". Knop "Sta jij hierop…?" verbergt een foto en meldt het aan het comité.
- Verkleinen in de browser vóór upload: 1600 px (~200–350 KB) + miniatuur 400 px (~50 KB); opnieuw opslaan haalt ook GPS/EXIF weg. Supabase Free: 1 GB opslag, 5 GB verkeer per maand. Max. 30 foto's per persoon (trigger `fotos_stempel`).
- Opslag: privé-bucket `fotos` (alleen JPEG, max. 1 MB), bestanden `<auteur>/<id>.jpg` en `-klein.jpg`; tabel `fotos` met status nieuw/geplaatst/gemeld. Bekijken via ondertekende links (1 uur geldig). Bestanden wist de site via de Storage API (ook bij uitschrijven en bij verwijderen door het comité); SQL kan dat niet.
- Afwijzen = de foto wordt gewist (geen "niet geplaatst" zoals bij verhalen).
- DEMO: rijen in `reunie25.demo.fotos`, geüploade bestanden alleen in het geheugen (na herladen een gekleurd vlak).
- Let op bij testen: een browsertabblad op de achtergrond kan het verkleinen pauzeren.

## Open punten

- [x] Supabase gekoppeld (project `glvrsppggmfksimpfckp`, regio Ierland/eu-west-1, 18 november 2026): schema gedraaid, inloggen met code getest door Bas.
- [x] Mail via Resend (`noreply@lastscoutstanding.com`, DNS bij Webreus: `resend._domainkey`, `send` → forge.rmta.net, `_dmarc`). Gratis: 3.000/maand, 100/dag. Supabase-mailtemplates "Magic Link" en "Confirm signup" bevatten `{{ .Token }}`.
- [ ] Rate limit in Supabase (standaard 30 mails/uur) ophogen vóór de aankondiging; aankondiging eventueel spreiden vanwege 100 mails/dag bij Resend.
- [ ] Gratis project pauzeert na een week zonder activiteit: keep-alive (bijv. GitHub Action) uitzoeken.
- [x] Schema opnieuw gedraaid in Supabase (beheer + betaald), Bas staat in `beheerders` (19 november 2026).
- [ ] Bedrag en betaallink in `betalen.txt`; nagaan hoe lang de link van de bank geldig blijft.
- [x] Schema opnieuw gedraaid (rollen + comité), Bas hoofdbeheerder (19 november 2026).
- [x] Schema opnieuw gedraaid (verhalen), 19 november 2026.
- [x] Schema opnieuw gedraaid (foto's, bucket en opslagregels), 19 november 2026.
- [ ] Een echte foto-upload testen (uploaden, bekijken, verwijderen, uitschrijven met foto's).
- [ ] Menu te vol voor beheerders op laptopbreedte ("Mijn inschrijving" springt naar een tweede regel).
- [x] Privacyverklaring af (18 november 2026): contact Reüniecomité, Blokhut de Brandnetel, Brandevoort 13-A, 5706 KA Helmond, reunie@scoutingbrandevoort.nl; alles gewist uiterlijk 23 augustus 2027. Bij de foto's de verklaring aanvullen.
- [x] Schema opnieuw gedraaid (verwijderen/blokkeren), 19 november 2026.
- [ ] Gegevens wissen uiterlijk 23 augustus 2027 (tabellen `deelnemers`, `beheerders`, `geblokkeerd`, `verhalen`, `fotos`, de bucket `fotos` en de logins in Supabase).
- [ ] Programma en vragen invullen (`programma.txt`, `vragen.txt`).
- [ ] Jaarvelden-pijltjes niet getest in Safari.
- [ ] `README.md` noemt de oude reponaam.
