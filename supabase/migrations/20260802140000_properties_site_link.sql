-- Which site a property's website lives on, stated instead of guessed.
--
-- Until now the console matched a property to a site by name: exact, then
-- substring, then "the first site" — and that list is ordered newest-first.
-- So an account whose property name does not happen to resemble its site name
-- fell through to the last branch, and every newly created site silently
-- became the one the website editor and Site-instellingen operated on. Adding
-- a second site is a normal thing to do; repointing the editor at it is not.
--
-- ON DELETE SET NULL rather than CASCADE: deleting a site must not take the
-- property (its bookings, pricing and channel config) with it. The link goes
-- back to null and the name heuristic takes over again, which is exactly the
-- behaviour a property with no site should have.
DO $$ BEGIN
  ALTER TABLE public.properties
    ADD COLUMN site_id UUID REFERENCES public.sites(id) ON DELETE SET NULL;
EXCEPTION WHEN duplicate_column THEN NULL;
END $$;

CREATE INDEX IF NOT EXISTS idx_properties_site_id ON public.properties(site_id);

COMMENT ON COLUMN public.properties.site_id IS
  'The site whose website this property owns. NULL falls back to name matching.';

-- Backfill in the order the app used to guess, with one correction: the last
-- resort is the owner's OLDEST site, not the newest. A fallback should land on
-- the site the account has been running, never on whatever was created last.
UPDATE public.properties AS p
SET site_id = COALESCE(
  (
    SELECT s.id FROM public.sites AS s
    WHERE lower(btrim(s.name)) = lower(btrim(p.name))
      AND (p.owner_profile_id IS NULL OR s.owner_profile_id = p.owner_profile_id)
    ORDER BY s.created_at
    LIMIT 1
  ),
  (
    SELECT s.id FROM public.sites AS s
    WHERE (
        lower(btrim(s.name)) LIKE '%' || lower(btrim(p.name)) || '%'
        OR lower(btrim(p.name)) LIKE '%' || lower(btrim(s.name)) || '%'
      )
      AND (p.owner_profile_id IS NULL OR s.owner_profile_id = p.owner_profile_id)
    ORDER BY s.created_at
    LIMIT 1
  ),
  (
    SELECT s.id FROM public.sites AS s
    WHERE s.owner_profile_id = p.owner_profile_id
    ORDER BY s.created_at
    LIMIT 1
  )
)
WHERE p.site_id IS NULL;
