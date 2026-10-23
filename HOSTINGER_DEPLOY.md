# Hostinger deployment — Xogta Hub

This repository is a static HTML/CSS/JavaScript website backed by Supabase. It does not require a Node build step.

## Upload the site

1. In GitHub, open the repository and choose **Code → Download ZIP**.
2. Sign in to Hostinger hPanel and open **Websites → Manage → File Manager** for the domain's hosting.
3. Open the domain's document root, normally `public_html`.
4. Upload the ZIP and extract it there. The files `index.html`, `styles.css`, `app.js`, `admin.html`, `admin.css`, and the policy pages must be directly inside `public_html`, not buried inside an extra repository folder.
5. Visit the domain over HTTPS and verify the home page, article search, article modal, and policy pages.
6. Keep HTTPS enabled. Do not upload private keys, passwords, or a Supabase service-role key.

## Supabase settings before launch

The frontend uses a Supabase **publishable** key. Never replace it with a service-role or secret key.

In Supabase Dashboard → Authentication → URL Configuration:
- Set the Site URL to the final HTTPS domain.
- Add the final domain's admin URL and password-recovery URL to the allowed redirect URLs. The admin reset flow redirects to the current origin plus `/admin.html`.
- Verify email/password sign-in and password recovery after updating the allowlist.

## Launch verification

- Confirm that exactly 15 new educational posts are published.
- Test article categories and search on desktop and mobile.
- Test an admin login with the real administrator account; verify a non-admin account is rejected.
- Test article create/edit/draft/publish, comment moderation, and newsletter signup.
- Check the browser console and network requests for failed scripts or Supabase requests.
- Review Supabase Security Advisor. Leaked-password protection is currently reported as disabled; enable it in Supabase Auth settings when available.
- Submit the site for Google AdSense review only after the domain is live, HTTPS works, the privacy/contact/about pages are accurate, and all content and navigation have been reviewed. Approval is Google's decision and cannot be guaranteed.

## Domain-specific items

The exact domain name was not present in the project information available during this build. For that reason, this repository does not contain a guessed canonical URL, sitemap host, or domain-specific Supabase redirect. Configure those with the actual domain in hPanel and Supabase before launch.
