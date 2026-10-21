-- Xogta Hub database security baseline
-- Safe to re-run. Keeps existing articles and user data.
-- Applies row-level rules and least-privilege table grants for the public API roles.
-- Review policies in Supabase before changing the intended access model.

begin;

-- RLS must be enabled for every table exposed through the public Data API.
alter table public.admin_users enable row level security;
alter table public.articles enable row level security;
alter table public.comments enable row level security;
alter table public.newsletter_subscribers enable row level security;

-- Do not expose the event-trigger helper as a callable public function.
revoke execute on function public.rls_auto_enable() from public, anon, authenticated;

-- Remove default/broad table privileges, including TRUNCATE, from client API roles.
revoke all privileges on table
  public.admin_users,
  public.articles,
  public.comments,
  public.newsletter_subscribers
from anon, authenticated;

-- Anonymous visitors can only read articles (RLS limits this to published rows),
-- read approved comments (RLS), submit pending comments, and subscribe.
grant select on table public.articles to anon;
grant select, insert on table public.comments to anon;
grant insert on table public.newsletter_subscribers to anon;

-- Authenticated users receive only operations needed by the admin app.
-- Existing RLS policies must still identify the actual administrator.
grant select on table public.admin_users to authenticated;
grant select, insert, update, delete on table public.articles to authenticated;
grant select, insert, update, delete on table public.comments to authenticated;
grant select, insert on table public.newsletter_subscribers to authenticated;

commit;

-- Verify after applying:
-- select c.relname, c.relrowsecurity
-- from pg_class c join pg_namespace n on n.oid=c.relnamespace
-- where n.nspname='public'
--   and c.relname in ('admin_users','articles','comments','newsletter_subscribers')
-- order by c.relname;
--
-- Verify least privilege:
-- select grantee, table_name, privilege_type
-- from information_schema.role_table_grants
-- where table_schema='public'
--   and grantee in ('anon','authenticated')
--   and table_name in ('admin_users','articles','comments','newsletter_subscribers')
-- order by table_name, grantee, privilege_type;
--
-- Expected anonymous access:
-- - SELECT articles only; the RLS policy limits rows to published articles.
-- - SELECT/INSERT comments; RLS limits reads to approved comments and inserts to pending.
-- - INSERT newsletter_subscribers only; no SELECT or UPDATE/DELETE.
-- - No access to admin_users and no UPDATE/DELETE/TRUNCATE on protected tables.
--
-- Expected admin access:
-- - The signed-in user must have a matching row in public.admin_users.
-- - Admin CRUD/moderation is still governed by private.is_xogta_hub_admin() policies.
-- - Test admin login, article CRUD, comment moderation, and subscriber list in the browser.
