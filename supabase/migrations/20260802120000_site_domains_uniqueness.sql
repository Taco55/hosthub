-- A hostname must resolve to exactly one site. runtime-site-context.ts looks it
-- up with .eq("domain", …).limit(1).order(is_primary desc), so a duplicate row
-- across two sites would not error — it would silently serve one customer's
-- content on another customer's domain. The constraint is the boundary.
DO $$ BEGIN
  ALTER TABLE public.site_domains ADD CONSTRAINT site_domains_domain_key UNIQUE (domain);
EXCEPTION WHEN duplicate_table OR duplicate_object THEN NULL;
END $$;

-- Likewise a site with two primaries leaves fetchPrimaryDomain()'s
-- .maybeSingle() to pick one non-deterministically — and that is the domain the
-- console shows and the website editor builds its preview URL from.
CREATE UNIQUE INDEX IF NOT EXISTS site_domains_one_primary_per_site
  ON public.site_domains (site_id)
  WHERE is_primary;
