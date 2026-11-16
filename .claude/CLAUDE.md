# lastscoutstanding.com

Basispagina's voor het domein lastscoutstanding.com. Nog vrijwel leeg: alleen een placeholder-homepage.
Repo: github.com/lastscoutstanding/lastscoutstanding.com (hernoemd, README noemt nog "mijnwebpagina"), gehost op GitHub Pages (lastscoutstanding.com, via `CNAME`).
Stand: 16 november 2026, opgezet vanuit een Claude Code-sessie.

## Werkwijze in Claude Code

- Werk direct in deze lokale repo. Begin een taak met `git pull`; Bas past soms zelf bestanden aan via GitHub.
- Eén logische wijziging = één commit. Push pas na akkoord van Bas: de site staat live.
- Testen via `python3 -m http.server 8000` (config `site` in `.claude/launch.json` voor de preview).
- Push-token: het fine-grained token in de sleutelhanger is aangemaakt voor watchcafe.eu en crashalot.com. Mogelijk faalt of hangt `git push` hier; dan afbreken en Bas zelf laten pushen of het token laten uitbreiden.
- Werk dit bestand bij na elke grotere wijziging, vooral "Architectuur" en "Open punten".

## Architectuur

Vanilla HTML/CSS/JS, geen build-stap, alles inline per pagina. Geen localStorage, geen tracking (de Busuanzi-teller is op 1 juni 2026 verwijderd).

| Pad | Rol |
| --- | --- |
| `index.html` | Placeholder: "hello world". Taal: NL |
| `README.md` | Eén regel beschrijving |
| `CNAME` | `lastscoutstanding.com` |

Verwijderd op 16 november 2026: `music/index.html` ("Muziek Zoeker", zocht op Discogs en AllMusic, werkte niet meer). Staat nog in de git-geschiedenis.

## Open punten

- [ ] Homepage is nog een placeholder; `README.md` noemt de oude reponaam.
