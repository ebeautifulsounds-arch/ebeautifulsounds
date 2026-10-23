# Xogta Hub

Madal af-Soomaali ah oo leh maqaallo waxbarasho iyo kuwo waxtar leh, naqshad editorial oo responsive ah, raadis, shaandhayn qaybo, faallooyin la dhexdhexaadiyo, newsletter iyo admin dashboard.

## Faylasha muhiimka ah
- `index.html` — bogga hore ee cusub
- `styles.css` — naqshadda responsive iyo theme
- `app.js` — akhrinta maqaallada, raadinta, faallooyinka iyo newsletter-ka
- `admin.html`, `admin.css`, `admin.js` — admin dashboard iyo login
- `about.html`, `privacy.html`, `editorial.html`, `contact.html` — bogagga kalsoonida iyo siyaasadaha
- `supabase/security-remediation.sql` — xeerarka database-ka iyo rukhsadaha
- `HOSTINGER_DEPLOY.md` — tallaabooyinka upload-ka Hostinger iyo launch checklist

## Content
15 maqaal cusub oo asal ah ayaa lagu daabacay Supabase. Saddexdii maqaal ee hore waxaa loo beddelay qabyo (draft), sidaas darteed booqdayaashu waxay arkaan 15-ka cusub oo keliya. Maqaalladu waa qoraallo waxbarasho; xaqiiqooyinka degdeg isu beddela waa in la hubiyaa ka hor daabacaad.

## Supabase iyo amniga
Frontend-ku wuxuu adeegsadaa publishable key oo keliya. Ha gelin service-role key, database password, ama secret kale faylasha browser-ka. RLS iyo least-privilege grants waa in la ilaaliyaa. Security Advisor wali wuxuu sheegayaa in leaked-password protection uu dansan yahay; tani waxay u baahan tahay in lagu shido Supabase Auth settings. Ammaan buuxa ama eber nuglaansho lama dammaanad qaadi karo, sidaas darteed samee tijaabooyin joogto ah.

## Daabacaadda
Website-ku waa static HTML/CSS/JS, sidaas darteed uma baahna build command. Raac `HOSTINGER_DEPLOY.md` si faylasha loogu geliyo document root-ka domain-ka Hostinger. Kadib ku cusboonaysii Supabase Auth Site URL iyo allowed redirect URLs domain-ka dhabta ah.

## Google AdSense
Bogagga About, Privacy, Editorial Standards iyo Contact waa la diyaariyey. Tani ma dammaanad qaadayso ansixinta AdSense; Google ayaa go'aanka leh. Kahor codsiga, xaqiiji in domain-ku live yahay, HTTPS shaqaynayo, xiriirka sax yahay, maqaalladu yihiin kuwo asal ah oo waxtar leh, mana jiraan bogag khaldan ama link-yo jaban.
