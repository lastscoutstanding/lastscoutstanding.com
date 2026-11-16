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
| `reunie25/privacy.html` | Privacyverklaring, nog concept |
| `reunie25/speltakken.txt` | Speltakken met instapleeftijd, `opgericht = 2001`; regel zonder leeftijd = rol zonder speltak (Bestuur / vrijwilliger) |
| `reunie25/reunie.js` | Gedeeld: speltakken.txt inlezen, jaren berekenen, persoonskaartje, `esc()`, jaarvelden-pijltjes |
| `reunie25/data.js` | Datalaag: de enige plek die met opslag praat. Nu DEMO (localStorage), later Supabase |
| `reunie25/nav.js` | Kop, navigatie, footer en de gele testversie-balk (bij DEMO) |
| `reunie25/theme.css` | Stijl; kleuren van scoutingbrandevoort.nl (#2c4696) en het logo (geel). Licht/donker volgt het systeem |

## Reünie

- Zondag 23 mei 2027, blokhut de Brandnetel, Helmond. Scouting Brandevoort is opgericht in 2001.
- "Scobra" alleen heel spaarzaam gebruiken (nu één keer, in de footer): niet iedereen vindt het een goede naam.
- Logo wordt nu direct van scoutingbrandevoort.nl geladen (`LOGO` in `nav.js`), 120×110 PNG voor een blauwe achtergrond.
- Persoon: voornaam, achternaam, e-mail, geboortejaar, `takken: [{speltak, rol: 'lid'|'leiding', van, tot}]` (`tot` null = heden), `toon: {voornaam, achternaam, leeftijd, takken}`, `sinds`.
- Jeugdlid-jaren worden berekend uit geboortejaar + `speltakken.txt` (je zit in een speltak tot de leeftijd van de volgende), in kalenderjaren, en zijn met de hand aan te passen. Leiding-jaren vult iemand zelf in.
- Leeftijd = 2027 − geboortejaar (één te hoog voor wie na 23 mei jarig is).
- Privacy: verborgen velden zijn `null` in de publieke rij (`Data.publiek`). Bij een filter op speltak/jaar verschijnen mensen met verborgen speltakken alleen in het vaste blok "Ook ingeschreven, speltak niet getoond", zodat het filter niets verraadt.
- Inlogflow: inschrijven → formulier in sessionStorage → code → pas dan opslaan. E-mailadres nooit in de URL.
- DEMO: inlogcode `123456`, 20 verzonnen voorbeelddeelnemers, inschrijvingen in localStorage (`reunie25.demo`, sessie `reunie25.sessie`).

## Open punten

- [ ] Supabase koppelen in `data.js`: Bas maakt het account/project aan (EU-regio). Tabel + view voor de publieke rij + row level security, inloggen met e-mailcode (OTP). Uitzoeken of eigen SMTP nodig is voor de inlogmails.
- [ ] Logo lokaal opslaan (groter of SVG) in plaats van hotlinken.
- [ ] Privacyverklaring afmaken: contactadres comité, wanneer gegevens gewist worden.
- [ ] Programma en vragen invullen (`programma.txt`, `vragen.txt`).
- [ ] Jaarvelden-pijltjes niet getest in Safari.
- [ ] `README.md` noemt de oude reponaam.
