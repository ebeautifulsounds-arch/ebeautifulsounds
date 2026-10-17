# Xogta Hub

Warbaahin dijitaal ah oo af-Soomaali ku soo bandhigta warar iyo falanqayn ku saabsan AI, tignoolajiyada, ciyaaraha, sayniska iyo dabeecadda.

## Faylasha
- `index.html` — bogga ugu weyn, metadata iyo qaab-dhismeedka bogga
- `styles.css` — naqshadda responsive ee desktop iyo mobile
- `app.js` — soo rarista maqaallada Supabase, raadinta, qaybaha, daawashada maqaalka, faallooyinka iyo newsletter-ka
- `render.yaml` — Render Static Site Blueprint (build uma baahna)

## Daabacaadda Render
1. Fur Render Dashboard oo dooro **New → Blueprint** ama **New → Static Site**.
2. Ku xidh repository-ga `ebeautifulsounds-arch/ebeautifulsounds`, branch `main`.
3. Blueprint-ku wuxuu adeegsadaa `echo "No build step required"` iyo publish directory `.` maadaama boggu yahay HTML/CSS/JS saafi ah.
4. Daar auto-deploy si isbeddellada `main` loogu daabaco.

**Fiiro gaar ah:** Isku daygii otomaatiga ahaa ee abuurista adeegga Render waxaa joojiyay Render isagoo dalbanaya in xogta billing-ka lagu daro akoonka (`402 Payment information is required`). Ma jiro URL live ah oo la xaqiijiyay ilaa adeegga la abuuro oo deploy-ku guuleysto.

## Supabase
Boggu wuxuu adeegsadaa Supabase project-ka loo habeeyay ee ku jira `app.js`. Kaliya publishable/anon key ayaa browser-ka ku jira; waligaa ha gelin `service_role` key ama password sir ah repository-ga.

Maqaallada waa inay ku jiraan `public.articles` oo leh `status = 'published'`. Qaybaha ay boggu kala saaro waa `ai`, `sports`, iyo `nature` (wuxuu aqbalaa sidoo kale `tech`). Faallooyinka waxaa lagu kaydiyaa `public.comments` iyadoo xaaladdoodu tahay `pending`; liiska newsletter-ka wuxuu ku kaydiyaa `public.newsletter_subscribers`.

## Tijaabinta
Marka la daabaco, hubi bogga guriga, in maqaallada soo baxaan, raadinta iyo filter-yadu shaqeeyaan, faallooyinka la gudbin karo, iyo newsletter-ka la diiwaangelin karo. Haddii xogtu soo bixi weydo, hubi RLS policies-ka Supabase iyo in maqaallada la daabacay ay jiraan.

## Beddel bilaash ah: GitHub Pages
Haddii Render wali dalbado xog billing, repository-gu wuxuu leeyahay workflow `.github/workflows/deploy-pages.yml` oo ku daabici kara GitHub Pages:
1. Tag **Settings → Pages** ee repository-ga.
2. Qaybta **Build and deployment**, dooro **GitHub Actions**.
3. Tag **Actions → Deploy Xogta Hub to GitHub Pages** oo riix **Run workflow** (ama samee commit cusub oo branch-ka `main` ah).
4. Marka workflow-gu guuleysto, URL-ku wuxuu ka muuqan doonaa summary-ga deployment-ka.

GitHub Pages waxay u adeegtaa faylasha static-ka oo keliya; xogta maqaalada iyo foomamku waxay weli ku tiirsan yihiin Supabase. Workflow-ga wuxuu adeegsadaa habka GitHub Pages custom workflow ee rasmiga ah.