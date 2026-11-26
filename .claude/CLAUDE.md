# lastscoutstanding.com

Domein van Bas. Hier stond tot de verhuizing de site voor de reünie van 25 jaar Scouting Brandevoort; die staat nu in de eigen repo `lastscoutstanding/reunie25` op https://reunie.scoutingbrandevoort.nl (lokaal `~/Websites/reunie25`, met een eigen `.claude/CLAUDE.md`). Werk aan de reünie hoort dáár.
Repo: github.com/lastscoutstanding/lastscoutstanding.com, gehost op GitHub Pages (lastscoutstanding.com, via `CNAME`).
Stand: 26 november 2026 (voorbereid op tak `overstap`; geldt zodra die in `main` staat).

## Werkwijze in Claude Code

- Werk direct in deze lokale repo. Begin een taak met `git pull`; Bas past soms zelf bestanden aan via GitHub.
- Eén logische wijziging = één commit. Push pas na akkoord van Bas: de site staat live.
- Testen via `python3 -m http.server 8000` in de repo-root (config `site` in `.claude/launch.json`).
- Het push-token in de sleutelhanger dekt deze repo (Contents + Workflows).

## Inhoud

| Pad | Rol |
| --- | --- |
| `index.html` | Stuurt door naar https://reunie.scoutingbrandevoort.nl/. Vervangen als de root iets anders moet worden |
| `reunie25/*.html` | Elf doorstuurpagina's (index, inschrijven, inloggen, mijn, deelnemers, herinneringen, programma, vragen, beheer, privacy, over). Ze nemen paginanaam, `?…` en `#…` mee naar het nieuwe adres, zodat oude links en het oude agendabestand blijven werken. Laten staan tot de reünie voorbij is |
| `CNAME` | `lastscoutstanding.com` |

De geschiedenis van de reüniesite (tot de verhuizing) staat ook in deze repo; in `reunie25` staat dezelfde geschiedenis, afgesplitst met `git subtree split`.

## DNS (Webreus)

Records voor GitHub Pages en Resend (afzender noreply@lastscoutstanding.com voor de inlogmails van de reünie) staan beschreven in `_docs/beheer.md` in de repo `reunie25`. Niet aankomen zolang de reüniesite mail verstuurt. Het testrecord `reunie` (CNAME) mag weg na de overstap.

## Open punten

- [ ] `README.md` noemt de oude reponaam ("mijnwebpagina").
- [ ] Na de reünie (uiterlijk augustus 2027): doorstuurpagina's in `reunie25/` weghalen en bedenken wat de root wordt.
