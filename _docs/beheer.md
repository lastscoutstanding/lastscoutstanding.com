# Beheerhandleiding lastscoutstanding.com / reünie 25 jaar Scouting Brandevoort

Alle instellingen buiten de code: GitHub, Webreus (DNS), Resend (mail) en Supabase (database en inloggen).
Werk dit bestand bij als er iets verandert. Geheime sleutels staan hier **nooit** in.

Legenda: ✅ gecontroleerd (DNS of live site) · 👤 door Bas ingesteld in een dashboard, niet door Claude gezien

Laatst bijgewerkt: 19 november 2026

---

## Overzicht

```
bezoeker ──▶ lastscoutstanding.com (GitHub Pages, statische site)
                │  fetch met publishable key
                ▼
            Supabase (Ierland) ── database + inloggen met code
                │  SMTP
                ▼
            Resend ── verstuurt de mail met de inlogcode vanaf noreply@lastscoutstanding.com
```

DNS van het domein staat bij Webreus. Mail naar het domein zelf (mailboxen) loopt via Webreus; alleen de verzendmails van de site lopen via Resend.

---

## GitHub

| Wat | Waarde |
| --- | --- |
| Repo | `github.com/lastscoutstanding/lastscoutstanding.com`, branch `main` ✅ |
| Hosting | GitHub Pages, eigen domein via bestand `CNAME` (`lastscoutstanding.com`) ✅ |
| HTTPS | `http://` en `www.` sturen door naar `https://lastscoutstanding.com/` ✅ |
| Lokale kopie | `/Users/familiekrom/Websites/lastscoutstanding.com` |
| Pushen | HTTPS met een fine-grained token in de macOS-sleutelhanger, ook geldig voor deze repo (sinds 16 november 2026). **Verloopt rond 30 december 2026**: op tijd vernieuwen. |

Let op:
- GitHub Pages (Jekyll) publiceert geen mappen die met `_` of `.` beginnen. Daarom staan `_supabase/`, `_docs/` en `.claude/` wel in de repo maar niet op de site (gecontroleerd: `/_supabase/schema.sql` geeft 404 ✅).
- Geen `.nojekyll` toevoegen: dan worden die mappen wél gepubliceerd.
- Na een push duurt het ongeveer een minuut voordat de site bijgewerkt is. Verversen met Cmd+Shift+R.

---

## Webreus (domein en DNS)

Domein `lastscoutstanding.com`, parkeerabonnement. Nameservers `ns10.webreus.net` en `ns11.webreus.net` ✅.
DNS-records (gecontroleerd met `dig`, 18 november 2026 ✅):

| Type | Naam | Waarde | Voor |
| --- | --- | --- | --- |
| A | `lastscoutstanding.com` | `185.199.108.153`, `.109.153`, `.110.153`, `.111.153` | GitHub Pages |
| AAAA | `lastscoutstanding.com` | `2606:50c0:8000::153`, `8001::153`, `8002::153`, `8003::153` | GitHub Pages |
| CNAME | `www` | `lastscoutstanding.github.io.` | GitHub Pages |
| TXT | `resend._domainkey` | `p=MIGfMA0…` (lange sleutel van Resend) | Resend, DKIM |
| CNAME | `send` | `send.forge.rmta.net.` | Resend, afzender/bounces (MX en SPF lopen via deze doorverwijzing) |
| TXT | `_dmarc` | `v=DMARC1; p=none;` | DMARC |
| MX | `lastscoutstanding.com` | `10 mx-in-3.webreus.nl.`, `10 mx-in-4.webreus.nl.` | mail van Webreus |
| TXT | `lastscoutstanding.com` | `v=spf1 include:spf.webreus.email -all` | SPF van Webreus |
| CNAME | `autoconfig`, `autodiscover`, `imap`, `mail`, `pop3`, `smtp` | `autoconfig.webreus.email.` / `autodiscover.webreus.email.` / `webreus.email.` | standaardrecords van Webreus |

Niet aankomen: de records voor GitHub Pages en de drie van Resend. De records van Webreus mogen blijven staan; ze zitten Resend niet in de weg.

---

## Resend (verzendmail)

| Wat | Waarde |
| --- | --- |
| Account | 👤 aangemaakt door Bas |
| Domein | `lastscoutstanding.com`, geverifieerd 👤 (DNS-records zie Webreus ✅) |
| Regio | Ireland (eu-west-1) 👤, bevestigd door Bas |
| API-sleutel | 👤 alleen "Sending access", staat alleen in Supabase (SMTP-wachtwoord). Nergens anders bewaren. |
| Gratis limiet | 3.000 mails per maand, **100 per dag** (resend.com/pricing, 18 november 2026) |

Bij veel aanmeldingen op één dag (aankondiging): na 100 mails krijgen mensen pas de volgende dag een code. Aankondiging spreiden of Resend tijdelijk upgraden.

---

## Supabase (database en inloggen)

| Wat | Waarde |
| --- | --- |
| Account | 👤 aangemaakt door Bas, inloggen via GitHub |
| Project | `glvrsppggmfksimpfckp`, URL `https://glvrsppggmfksimpfckp.supabase.co` ✅ |
| Regio | Ierland (eu-west-1) 👤, bevestigd door Bas |
| Abonnement | Free: 500 MB database, 1 GB opslag, 5 GB verkeer per maand, 50.000 gebruikers per maand. Geen automatische backups. |
| Publishable key | `sb_publishable_drDnd…` staat in `reunie25/data.js` ✅. Is openbaar bedoeld. De **secret / service_role key** nooit in de site, de repo of een chat. |
| Schema | `_supabase/schema.sql` gedraaid in de SQL Editor 👤, rechten gecontroleerd ✅. Mag opnieuw gedraaid worden na wijzigingen. |

### Authentication

| Instelling | Waarde |
| --- | --- |
| Inloggen | e-mail met code (OTP), geen wachtwoord. Inschrijven maakt de login aan, inloggen niet. |
| SMTP | 👤 custom SMTP aan: host `smtp.resend.com`, poort `465`, gebruiker `resend`, wachtwoord = Resend API-sleutel, afzender `noreply@lastscoutstanding.com`, naam `Reünie Scouting Brandevoort` |
| Mailtemplates | 👤 "Magic Link" en "Confirm signup" bevatten `{{ .Token }}` (de code van 6 cijfers), geen link. Getest door Bas: werkt. |
| Rate limit mails | standaard 30 per uur. **Nog ophogen** (bijv. 100) vóór de aankondiging: Authentication → Rate Limits. |

### Database (zie `_supabase/schema.sql`)

| Onderdeel | Wat het doet |
| --- | --- |
| tabel `deelnemers` | één rij per persoon, gekoppeld aan de login; alleen eigen rij lezen/wijzigen/verwijderen (row level security). Comité leest alle rijen. Kolom `betaald_op`: datum waarop het comité de betaling zag, alleen te wijzigen door het comité |
| tabel `beheerders` | e-mailadressen van het comité, niet leesbaar via de site. **Nog leeg.** Toevoegen in de SQL Editor: `insert into public.beheerders (email) values ('naam@example.com');` |
| `publieke_deelnemers()` | lijst voor "Wie komen er?", verborgen velden zijn leeg; e-mail komt nooit mee |
| `aantal_deelnemers()` | totaal aantal inschrijvingen |
| `verwijder_mij()` | uitschrijven: wist login en inschrijving (alleen ingelogd) |
| `zet_betaald()` | comité: betaling afvinken of terugzetten (pagina Beheer) |
| `is_beheerder()` | bepaalt of iemand de pagina Beheer en de link in het menu krijgt |
| trigger `deelnemers_stempel` | vult e-mail en datums zelf in; een deelnemer kan `betaald_op` niet zelf veranderen. Wijzigingen in de Table Editor of SQL Editor laat hij met rust |

### Let op bij het gratis abonnement

- Een project **pauzeert na een week zonder activiteit**. De site werkt dan niet tot het project in het dashboard weer wordt aangezet. Oplossing (keep-alive) nog uitzoeken.
- Geen backups: af en toe zelf een export maken (Table Editor → `deelnemers` → Export CSV).

---

## Website (code in de repo)

| Wat | Waar |
| --- | --- |
| Reüniesite | `reunie25/`; de root `index.html` stuurt door naar `reunie25/` |
| Koppeling met Supabase | alleen `reunie25/data.js`. `SUPABASE_KEY` leeg maken = terug naar demomodus (alles in de browser, code `123456`) |
| Inhoud die je zelf bijhoudt | `reunie25/programma.txt`, `reunie25/vragen.txt`, `reunie25/speltakken.txt`, `reunie25/betalen.txt` (uitleg bovenin elk bestand) |
| Betalen | `reunie25/betalen.txt`: bedrag, betaallink, IBAN. Leeg = geen betaalblok. Verlopen link: nieuwe erin zetten. Het comité vinkt betalingen af op `beheer.html` |
| Beheer | `reunie25/beheer.html`: alle inschrijvingen, zoeken, details, CSV, betaald afvinken. Alleen voor adressen in `beheerders` |
| Privacyverklaring | `reunie25/privacy.html`: contact Reüniecomité, Blokhut de Brandnetel, Brandevoort 13-A, 5706 KA Helmond, info@scoutingbrandevoort.nl |
| Lokaal testen | in de repo: `python3 -m http.server 8000`, dan `http://localhost:8000/reunie25/` (let op: praat met de echte database) |
| Projectcontext voor Claude | `.claude/CLAUDE.md` |

---

## Terugkerende taken en deadlines

- [ ] Rate limit mails in Supabase ophogen vóór de aankondiging.
- [ ] Comité-adressen toevoegen aan `beheerders`.
- [ ] GitHub-token vernieuwen vóór ongeveer 30 december 2026.
- [ ] Keep-alive regelen tegen het pauzeren van Supabase.
- [ ] Af en toe een CSV-export van `deelnemers` bewaren.
- [ ] **Uiterlijk 23 augustus 2027 alle gegevens wissen** (belofte in de privacyverklaring): in Supabase de tabel `deelnemers` leegmaken en onder Authentication → Users alle gebruikers verwijderen. Daarna de site aanpassen (inschrijven dicht).

---

## Wijzigingen

| Datum | Wat |
| --- | --- |
| 16 nov 2026 | Repo hernoemd naar lastscoutstanding.com; token uitgebreid naar deze repo |
| 17 nov 2026 | Reüniesite in `reunie25/` live in demomodus; root stuurt door |
| 18 nov 2026 | Supabase-project (Ierland), schema, Resend + DNS bij Webreus, SMTP en templates; site live gekoppeld; privacyverklaring af |
| 19 nov 2026 | Kolommen `bijnaam` en `toon_bijnaam`; `publieke_deelnemers()` geeft ook de bijnaam. Schema opnieuw gedraaid vóór de push |
| 19 nov 2026 | Pagina Beheer, kolom `betaald_op`, functie `zet_betaald()`, aangepaste trigger; betaalblok via `betalen.txt`. **Schema opnieuw draaien vóór de push** |
