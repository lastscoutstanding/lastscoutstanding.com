# lastscoutstanding.com

Basispagina's voor het domein lastscoutstanding.com. Nog vrijwel leeg: een placeholder-homepage en een muziekzoekpagina.
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
| `music/index.html` | "Muziek Zoeker": zoekveld dat Discogs en AllMusic elk in een nieuw tabblad opent. Donker thema, NL |
| `README.md` | Eén regel beschrijving |
| `CNAME` | `lastscoutstanding.com` |

Geschiedenis van `music/` (april 2026): eerst zoekresultaten in iframes, daarna een "proxy-versie" met `x-frame-bypass` van unpkg.com en een Wikipedia-frame, toen teruggebracht naar twee nieuwe tabbladen. Er zitten nu geen externe scripts meer in.

## Open punten

- [ ] `music/index.html` werkt niet: de zoek-URL's zijn `'https://discogs.com{encodedQuery}'` en `'https://allmusic.com{encodedQuery}'` (gewone quotes, geen `$`, geen zoekpad). Ze openen alleen de homepages met de letterlijke tekst erachter. Nodig: template literals met het juiste zoekpad per site.
- [ ] Twee `window.open`-aanroepen na één klik: browsers blokkeren vaak het tweede tabblad als pop-up.
- [ ] Titel is "2 Muziek Zoeker - Dubbele Tab" (de "2" lijkt een testrestant); `h1` is "Muziek Zoeker".
- [ ] Geen NL/EN-toggle, geen gedeelde stijl met de andere sites.
- [ ] Homepage is nog een placeholder; `README.md` noemt de oude reponaam.
