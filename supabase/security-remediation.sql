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

-- Split public reads from administrator reads. This allows the admin-check
-- SECURITY DEFINER helper to be unavailable to anonymous visitors.
drop policy if exists "Anyone can read published articles" on public.articles;
drop policy if exists "Public can read published articles" on public.articles;
create policy "Public can read published articles"
  on public.articles for select to anon, authenticated
  using (status = 'published');

drop policy if exists "Admins can read all articles" on public.articles;
create policy "Admins can read all articles"
  on public.articles for select to authenticated
  using ((select private.is_xogta_hub_admin()));

drop policy if exists "Public read approved comments" on public.comments;
drop policy if exists "Public read approved comments only" on public.comments;
create policy "Public read approved comments only"
  on public.comments for select to anon, authenticated
  using (status = 'approved');

-- Public comments must target a published article and remain pending until
-- explicitly approved by an administrator.
drop policy if exists "Public submit pending comments" on public.comments;
create policy "Public submit pending comments"
  on public.comments for insert to anon, authenticated
  with check (
    status = 'pending'
    and exists (
      select 1 from public.articles a
      where a.id = article_id and a.status = 'published'
    )
  );

-- Validate and normalize newsletter email addresses at the database boundary.
do $
begin
  if not exists (
    select 1 from pg_constraint
    where conrelid = 'public.newsletter_subscribers'::regclass
      and conname = 'newsletter_subscribers_email_format_check'
  ) then
    alter table public.newsletter_subscribers
      add constraint newsletter_subscribers_email_format_check
      check (
        email = lower(btrim(email))
        and email ~ '^[^[:space:]@]+@[^[:space:]@]+\\.[^[:space:]@]+
drop policy if exists "Admins read all comments" on public.comments;
create policy "Admins read all comments"
  on public.comments for select to authenticated
  using ((select private.is_xogta_hub_admin()));

-- The helper is only needed by authenticated RLS policies. Keep it in the
-- non-exposed private schema, remove PUBLIC/anon execution, and retain auth access.
revoke usage on schema private from public, anon;
grant usage on schema private to authenticated;
revoke execute on function private.is_xogta_hub_admin() from public, anon;
grant execute on function private.is_xogta_hub_admin() to authenticated;

-- Remove default/broad table privileges, including TRUNCATE, from client API roles.
revoke all privileges on table
  public.admin_users,
  public.articles,
  public.comments,
  public.newsletter_subscribers
from anon, authenticated;

-- Anonymous visitors can only read published articles (RLS), read approved
-- comments, submit pending comments, and subscribe to the newsletter.
grant select on table public.articles to anon;
grant select on table public.comments to anon;
grant insert (article_id, author_name, body, status) on table public.comments to anon;
grant insert (email) on table public.newsletter_subscribers to anon;

-- Authenticated users receive operations needed by the admin app.
-- Existing RLS policies still require private.is_xogta_hub_admin() for admin actions.
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
-- - SELECT published articles only; RLS limits visible rows.
-- - SELECT approved comments and INSERT pending comments.
-- - INSERT newsletter_subscribers only; no SELECT or UPDATE/DELETE.
-- - No access to admin_users and no UPDATE/DELETE/TRUNCATE on protected tables.
--
-- Expected admin access:
-- - The signed-in user must have a matching row in public.admin_users.
-- - Admin CRUD/moderation is governed by private.is_xogta_hub_admin() policies.
-- - Test admin login, article CRUD, comment moderation, and subscriber list in the browser.

        and char_length(email) <= 254
      );
  end if;
end $;

drop policy if exists "Admins read all comments" on public.comments;
create policy "Admins read all comments"
  on public.comments for select to authenticated
  using ((select private.is_xogta_hub_admin()));

-- The helper is only needed by authenticated RLS policies. Keep it in the
-- non-exposed private schema, remove PUBLIC/anon execution, and retain auth access.
revoke usage on schema private from public, anon;
grant usage on schema private to authenticated;
revoke execute on function private.is_xogta_hub_admin() from public, anon;
grant execute on function private.is_xogta_hub_admin() to authenticated;

-- Remove default/broad table privileges, including TRUNCATE, from client API roles.
revoke all privileges on table
  public.admin_users,
  public.articles,
  public.comments,
  public.newsletter_subscribers
from anon, authenticated;

-- Anonymous visitors can only read published articles (RLS), read approved
-- comments, submit pending comments, and subscribe to the newsletter.
grant select on table public.articles to anon;
grant select, insert on table public.comments to anon;
grant insert on table public.newsletter_subscribers to anon;

-- Authenticated users receive operations needed by the admin app.
-- Existing RLS policies still require private.is_xogta_hub_admin() for admin actions.
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
-- - SELECT published articles only; RLS limits visible rows.
-- - SELECT approved comments and INSERT pending comments.
-- - INSERT newsletter_subscribers only; no SELECT or UPDATE/DELETE.
-- - No access to admin_users and no UPDATE/DELETE/TRUNCATE on protected tables.
--
-- Expected admin access:
-- - The signed-in user must have a matching row in public.admin_users.
-- - Admin CRUD/moderation is governed by private.is_xogta_hub_admin() policies.
-- - Test admin login, article CRUD, comment moderation, and subscriber list in the browser.
