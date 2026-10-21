-- Xogta Hub security remediation
-- REVIEWED AGAINST THE CURRENT PROJECT SCHEMA ON 2026-10-21.
-- Run in Supabase SQL Editor only after reviewing the changes below.
-- This script does not drop tables or change existing article data.
--
-- Existing policies were found for all four tables. Enabling RLS makes those
-- policies enforce access instead of leaving the tables exposed to API roles.
-- Verify the policies again after applying this script.

begin;

alter table public.admin_users enable row level security;
alter table public.articles enable row level security;
alter table public.comments enable row level security;
alter table public.newsletter_subscribers enable row level security;

-- The security advisor reports this SECURITY DEFINER function as callable by
-- anon/authenticated. It is an event-trigger helper, not a public API.
revoke execute on function public.rls_auto_enable() from public, anon, authenticated;

commit;

-- Verification (run after the transaction):
-- select schemaname, tablename, rowsecurity
-- from pg_tables
-- where schemaname = 'public'
--   and tablename in ('admin_users','articles','comments','newsletter_subscribers')
-- order by tablename;
--
-- Expected: rowsecurity = true for all four tables.
--
-- IMPORTANT: test these flows after applying:
-- 1. Anonymous visitors can read published articles only.
-- 2. Anonymous visitors cannot read admin_users, drafts, or newsletter_subscribers.
-- 3. Anonymous visitors can submit pending comments and newsletter subscriptions.
-- 4. Only the registered admin can create/update/delete articles and moderate comments.
-- 5. The registered admin can sign in and read their admin_users row.
