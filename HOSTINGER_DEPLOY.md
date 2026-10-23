# Hostinger deployment — Xogta Hub

## Architecture

Xogta Hub is a static HTML/CSS/JavaScript frontend backed by the existing Supabase project. It requires no Node.js build command and no new Hostinger database. Keep Supabase as the shared database and authentication provider.

Production domain: `https://xogtahub.co`

## 1. Download the safe deployment package

Use the dedicated GitHub Actions workflow to build a ZIP containing only the public website files. This avoids accidentally uploading developer documentation, GitHub workflows, or the Supabase SQL file to the public website.

1. Open the repository: https://github.com/ebeautifulsounds-arch/ebeautifulsounds
2. Select **Actions**.
3. Open **Package Xogta Hub for Hostinger**.
4. Select the latest successful run.
5. Under **Artifacts**, download `xogta-hub-hostinger`. Extract the downloaded artifact ZIP to get `xogta-hub-hostinger.zip`.
6. The deployment ZIP contains only `.htaccess`, the homepage, CSS/JS, admin files, and the About, Privacy, Editorial and Contact pages.

Do not upload the full GitHub repository ZIP to `public_html`. Never publish `.github/`, `supabase/`, `render.yaml`, `README.md`, or internal deployment documentation in the website root.

## 2. Connect the domain and enable HTTPS

1. In Hostinger hPanel, open **Websites** and select the hosting plan.
2. Add or assign `xogtahub.co` to the shared hosting website.
3. In the domain's DNS / nameserver settings, use the exact records or nameservers Hostinger shows for this hosting account. Do not copy an IP address from an unrelated tutorial.
4. Wait for DNS changes to propagate.
5. In hPanel, open the website's **Security → SSL** section and verify that the certificate for `xogtahub.co` is active before enabling forced HTTPS. Also check whether you want `www.xogtahub.co` to redirect to the apex domain.

Hostinger's official guides:
- https://www.hostinger.com/support/1583214-how-to-add-a-website-in-hostinger/
- https://support.hostinger.com/en/articles/1863967-how-to-point-a-domain-to-hostinger
- https://www.hostinger.com/support/1575761-how-to-claim-a-free-ssl-that-comes-with-a-hostinger-hosting-plan/

## 3. Upload the public website files

1. Open **Websites → Manage → File Manager** for `xogtahub.co`.
2. Open the domain's document root, normally `public_html`.
3. If it already contains files, back them up before replacing anything.
4. Upload `xogta-hub-hostinger.zip` and extract it directly into `public_html`. Confirm that `index.html`, `styles.css`, `app.js`, and `.htaccess` are directly inside `public_html`, not inside another nested folder.
5. Confirm the archive has been extracted correctly. The ZIP can then be deleted from the document root.
6. Verify that `.htaccess` is in the document root. It forces HTTPS and sets security headers, so first confirm the domain's SSL certificate is active.

## 4. Configure Supabase Auth for the new domain

Use the existing Supabase project; do not create a replacement project or database.

Open:
https://supabase.com/dashboard/project/acjxegnfrbfnouzlltlf/auth/url-configuration

Set **Site URL** to:

`https://xogtahub.co`

Add the following to **Redirect URLs**:
- `https://xogtahub.co/**`
- `https://www.xogtahub.co/**` (only if you intend to serve or redirect the www hostname)

The admin password-recovery code redirects to the current origin and `/admin.html`. After saving the allowlist, test email/password sign-in and password recovery on the deployed domain.

The frontend uses the Supabase publishable key. Do not replace it with a service-role or secret key. No database migration is required merely to change the website domain.

## 5. Verify the deployment

Check both `https://xogtahub.co/` and `https://xogtahub.co/admin.html`:

- Homepage, CSS, JavaScript, navigation, policy pages, article search and category filters load.
- Supabase returns published articles from the existing shared database.
- The live database currently has 15 published articles and 3 drafts (18 total). Verify these statuses again after deployment; do not delete or recreate articles.
- Admin login succeeds only for the authorized admin account; a non-admin account is rejected.
- Test article create/edit/draft/publish, comment moderation, and newsletter signup.
- Test password recovery and confirm the redirect returns to the new domain.
- Check browser console and network requests for failed scripts, CSP violations, or Supabase errors.
- Verify the database row counts and content remain intact.

## 6. Security notes and remaining tasks

- The live Supabase Security Advisor has reported leaked-password protection as disabled. Enable it in Supabase Auth settings when available.
- The repository's `supabase/security-remediation.sql` is a reference/migration file only; it is not run by Hostinger or GitHub Pages. Review the live policies and take a backup before applying any SQL manually.
- Never place database passwords, service-role keys, Resend API keys, or other secrets in public files or GitHub.
- The current contact page uses the project's GitHub Issues page. Before an AdSense application, add a reliable public contact method that you actually control.
- About, Privacy, Editorial Standards and Contact pages exist, but review them for accuracy after the domain goes live.
- Google AdSense approval is Google's decision and cannot be guaranteed.

## Deployment status

This guide documents the intended deployment procedure. It does not itself prove that DNS, SSL, file upload, Supabase redirect settings, email delivery, or production testing have completed. Record those as complete only after verification.
