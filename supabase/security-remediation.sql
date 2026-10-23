-- Xogta Hub database security baseline
-- Corrected, repeatable migration. This file is NOT run automatically by GitHub Pages.
-- Review the live policies and take a database backup before manually applying changes.

begin;

-- Enable row-level security on every table exposed through Supabase's public API.
alter table public.admin_users enable row level security;
alter table public.articles enable row level security;
alter table public.comments enable row level security;
alter table public.newsletter_subscribers enable row level security;

-- Keep the admin predicate in the non-exposed private schema.
revoke execute on function public.rls_auto_enable() from public, anon, authenticated;
revoke usage on schema private from public, anon;
grant usage on schema private to authenticated;
revoke execute on function private.is_xogta_hub_admin() from public, anon;
grant execute on function private.is_xogta_hub_admin() to authenticated;

-- Articles: anonymous visitors can read published rows; admins can manage all rows.
drop policy if exists "Anyone can read published articles" on public.articles;
drop policy if exists "Public can read published articles" on public.articles;
drop policy if exists "Admins can read all articles" on public.articles;
drop policy if exists "Admins insert articles" on public.articles;
drop policy if exists "Admins update articles" on public.articles;
drop policy if exists "Admins delete articles" on public.articles;

create policy "Public can read published articles"
  on public.articles for select to anon
  using (status = 'published');

create policy "Admins can read all articles"
  on public.articles for select to authenticated
  using ((select private.is_xogta_hub_admin()));

create policy "Admins insert articles"
  on public.articles for insert to authenticated
  with check ((select private.is_xogta_hub_admin()));

create policy "Admins update articles"
  on public.articles for update to authenticated
  using ((select private.is_xogta_hub_admin()))
  with check ((select private.is_xogta_hub_admin()));

create policy "Admins delete articles"
  on public.articles for delete to authenticated
  using ((select private.is_xogta_hub_admin()));

-- Comments: public visitors can read approved comments and submit pending comments.
-- Only admins can inspect all comments, moderate them, or delete them.
drop policy if exists "Public read approved comments" on public.comments;
drop policy if exists "Public read approved comments only" on public.comments;
drop policy if exists "Admins read all comments" on public.comments;
drop policy if exists "Admins moderate comments" on public.comments;
drop policy if exists "Admins delete comments" on public.comments;
drop policy if exists "Public submit pending comments" on public.comments;

create policy "Public read approved comments"
  on public.comments for select to anon
  using (status = 'approved');

create policy "Admins read all comments"
  on public.comments for select to authenticated
  using ((select private.is_xogta_hub_admin()));

create policy "Public submit pending comments"
  on public.comments for insert to anon, authenticated
  with check (
    status = 'pending'
    and exists (
      select 1
      from public.articles a
      where a.id = article_id
        and a.status = 'published'
    )
  );

create policy "Admins moderate comments"
  on public.comments for update to authenticated
  using ((select private.is_xogta_hub_admin()))
  with check ((select private.is_xogta_hub_admin()));

create policy "Admins delete comments"
  on public.comments for delete to authenticated
  using ((select private.is_xogta_hub_admin()));

-- Newsletter addresses are private. Public visitors may only submit an address.
drop policy if exists "Admins read subscribers" on public.newsletter_subscribers;
drop policy if exists "Public subscribe to newsletter" on public.newsletter_subscribers;

create policy "Admins read subscribers"
  on public.newsletter_subscribers for select to authenticated
  using ((select private.is_xogta_hub_admin()));

create policy "Public subscribe to newsletter"
  on public.newsletter_subscribers for insert to anon, authenticated
  with check (
    email = lower(btrim(email))
    and char_length(email) <= 254
    and email ~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'
  );

-- Admin membership is readable only by an already-authorized administrator.
drop policy if exists "Admins can read admin list" on public.admin_users;
create policy "Admins can read admin list"
  on public.admin_users for select to authenticated
  using ((select private.is_xogta_hub_admin()));

-- Enforce normalized email format in the database, without altering existing rows.
do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conrelid = 'public.newsletter_subscribers'::regclass
      and conname = 'newsletter_subscribers_email_format_check'
  ) then
    alter table public.newsletter_subscribers
      add constraint newsletter_subscribers_email_format_check
      check (
        email = lower(btrim(email))
        and email ~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'
        and char_length(email) <= 254
      );
  end if;
end
$$;

-- Remove broad client privileges (including TRUNCATE), then grant only needed operations.
revoke all privileges on table
  public.admin_users,
  public.articles,
  public.comments,
  public.newsletter_subscribers
from anon, authenticated;

grant select on table public.articles to anon;
grant select on table public.comments to anon;
grant insert (article_id, author_name, body, status) on table public.comments to anon;
grant insert (email) on table public.newsletter_subscribers to anon;

grant select on table public.admin_users to authenticated;
grant select, insert, update, delete on table public.articles to authenticated;
grant select, insert, update, delete on table public.comments to authenticated;
grant select, insert on table public.newsletter_subscribers to authenticated;

commit;

-- Verification queries (run separately after applying):
-- select c.relname, c.relrowsecurity
-- from pg_class c join pg_namespace n on n.oid = c.relnamespace
-- where n.nspname = 'public'
--   and c.relname in ('admin_users','articles','comments','newsletter_subscribers')
-- order by c.relname;
--
-- select schemaname, tablename, policyname, roles, cmd, qual, with_check
-- from pg_policies
-- where schemaname = 'public'
-- order by tablename, policyname;
--
-- select grantee, table_name, privilege_type
-- from information_schema.role_table_grants
-- where table_schema = 'public'
--   and grantee in ('anon','authenticated')
--   and table_name in ('admin_users','articles','comments','newsletter_subscribers')
-- order by table_name, grantee, privilege_type;
