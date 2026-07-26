-- Which properties a portfolio screen is filtered to, per user.
--
-- A view preference, like `export_columns` beside it: it follows the user rather
-- than the device, and it must survive a reload. Keyed by page, because
-- Boekingen and Omzet each remember their own selection — one shared value would
-- make changing the filter on one screen silently change the other.
--
-- Shape: {"bookings": [1, 3], "revenue": [1, 2, 3, 4]}. A page that is absent
-- means "all properties", which is also the default for a new user, so nothing
-- has to be written before a filter is first touched.
--
-- Stale ids are harmless: the client clamps the stored selection to the
-- properties that currently exist, and an empty result falls back to all of them
-- (an empty portfolio view reads as broken, not as a filter).

alter table public.user_settings
  add column if not exists portfolio_scope jsonb;

comment on column public.user_settings.portfolio_scope is
  'Per-page property filter for the portfolio screens: {"<page>": [property_id, ...]}. Absent page = all properties.';
