#!/usr/bin/env node

import process from "node:process";

function usage() {
  return [
    "Usage: node scripts/provision_cms_site.mjs --name <site-name> --domain <domain> [options]",
    "",
    "Creates a new CMS site, adds a primary domain, and clones baseline cms_documents",
    "from a template site in one run.",
    "",
    "Required:",
    "  --name <text>                 New site name",
    "  --domain <host>               Domain/subdomain (e.g. chalet2.example.com)",
    "",
    "Options:",
    "  --source-site-id <uuid>       Template source site (default: NEXT_PUBLIC_CMS_SITE_ID or oldest site)",
    "  --owner-profile-id <uuid>     Owner profile (default: template owner_profile_id)",
    "  --default-locale <code>       Default locale (default: template default_locale)",
    "  --locales <csv>               Locales csv (default: template locales, e.g. nl,en,no)",
    "  --timezone <tz>               Timezone (default: template timezone or Europe/Oslo)",
    "  --copy-statuses <mode>        all|published (default: all)",
    "  --dry-run                     Print plan without writing data",
    "  --help                        Show this help",
    "",
    "Environment:",
    "  SUPABASE_SERVICE_ROLE_KEY     Required",
    "  NEXT_PUBLIC_SUPABASE_URL      Required (or SUPABASE_URL)",
    "",
    "Example:",
    "  node scripts/provision_cms_site.mjs \\",
    "    --name \"Fjell Lodge 2\" \\",
    "    --domain lodge2.trysilpanorama.com \\",
    "    --source-site-id <template-site-uuid>",
  ].join("\n");
}

function parseArgs(argv) {
  const args = {};
  const booleanFlags = new Set(["dry-run", "help"]);

  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (!token.startsWith("--")) {
      throw new Error(`Unexpected argument: ${token}`);
    }
    const key = token.slice(2);
    if (booleanFlags.has(key)) {
      args[key] = true;
      continue;
    }
    const next = argv[i + 1];
    if (!next || next.startsWith("--")) {
      throw new Error(`Missing value for argument: ${token}`);
    }
    args[key] = next;
    i += 1;
  }
  return args;
}

function normalizeDomain(raw) {
  const trimmed = (raw ?? "").trim().toLowerCase();
  if (!trimmed) return "";
  const withoutScheme = trimmed.replace(/^https?:\/\//i, "");
  const hostAndMaybePath = withoutScheme.split("/")[0] ?? withoutScheme;
  return hostAndMaybePath.replace(/\/+$/, "").replace(/\.$/, "");
}

function parseLocalesCsv(raw) {
  return Array.from(
    new Set(
      (raw ?? "")
        .split(",")
        .map((value) => value.trim())
        .filter(Boolean),
    ),
  );
}

function ensure(value, message) {
  if (!value) {
    throw new Error(message);
  }
  return value;
}

async function requestJson({ supabaseUrl, apiKey, path, query, method = "GET", body, prefer }) {
  const url = new URL(`/rest/v1/${path}`, supabaseUrl);
  if (query) {
    for (const [key, value] of Object.entries(query)) {
      if (value === undefined || value === null || value === "") continue;
      url.searchParams.set(key, String(value));
    }
  }

  const headers = {
    apikey: apiKey,
    Authorization: `Bearer ${apiKey}`,
    Accept: "application/json",
  };
  if (prefer) {
    headers.Prefer = prefer;
  }

  const hasBody = body !== undefined;
  if (hasBody) {
    headers["Content-Type"] = "application/json";
  }

  const response = await fetch(url, {
    method,
    headers,
    body: hasBody ? JSON.stringify(body) : undefined,
  });

  if (!response.ok) {
    const errorText = await response.text().catch(() => "");
    throw new Error(`${method} ${path} failed (${response.status}): ${errorText}`);
  }

  if (response.status === 204) return null;
  const text = await response.text();
  if (!text) return null;
  return JSON.parse(text);
}

async function fetchSiteById({ supabaseUrl, apiKey, siteId }) {
  const rows = await requestJson({
    supabaseUrl,
    apiKey,
    path: "sites",
    query: {
      select: "id,name,owner_profile_id,default_locale,locales,timezone,created_at",
      id: `eq.${siteId}`,
      limit: 1,
    },
  });
  return Array.isArray(rows) ? rows[0] ?? null : null;
}

async function resolveTemplateSiteId({ supabaseUrl, apiKey, explicitSourceSiteId }) {
  if (explicitSourceSiteId) return explicitSourceSiteId;
  if (process.env.NEXT_PUBLIC_CMS_SITE_ID?.trim()) {
    return process.env.NEXT_PUBLIC_CMS_SITE_ID.trim();
  }

  const rows = await requestJson({
    supabaseUrl,
    apiKey,
    path: "sites",
    query: {
      select: "id",
      order: "created_at.asc",
      limit: 1,
    },
  });
  if (!Array.isArray(rows) || rows.length === 0 || typeof rows[0]?.id !== "string") {
    throw new Error("Could not resolve a template site id (no sites found).");
  }
  return rows[0].id;
}

async function fetchTemplateDocuments({ supabaseUrl, apiKey, siteId, copyStatuses }) {
  const query = {
    select: "content_type,slug,locale,content,status,published_at",
    site_id: `eq.${siteId}`,
    order: "content_type.asc,slug.asc,locale.asc",
    limit: 5000,
  };
  if (copyStatuses === "published") {
    query.status = "eq.published";
  }

  const rows = await requestJson({
    supabaseUrl,
    apiKey,
    path: "cms_documents",
    query,
  });
  return Array.isArray(rows) ? rows : [];
}

async function ensureDomainIsAvailable({ supabaseUrl, apiKey, domain }) {
  const rows = await requestJson({
    supabaseUrl,
    apiKey,
    path: "site_domains",
    query: {
      select: "site_id,domain,is_primary",
      domain: `eq.${domain}`,
      limit: 1,
    },
  });
  if (Array.isArray(rows) && rows.length > 0) {
    const existing = rows[0];
    throw new Error(
      `Domain ${domain} already exists on site ${existing.site_id}. Choose another domain or reassign it first.`,
    );
  }
}

async function createSite({ supabaseUrl, apiKey, payload }) {
  const rows = await requestJson({
    supabaseUrl,
    apiKey,
    path: "sites",
    method: "POST",
    body: payload,
    prefer: "return=representation",
  });
  if (!Array.isArray(rows) || rows.length === 0) {
    throw new Error("Site creation returned no row.");
  }
  return rows[0];
}

async function createSiteDomain({ supabaseUrl, apiKey, siteId, domain }) {
  await requestJson({
    supabaseUrl,
    apiKey,
    path: "site_domains",
    method: "POST",
    body: {
      site_id: siteId,
      domain,
      is_primary: true,
    },
    prefer: "return=minimal",
  });
}

async function insertDocumentsInBatches({ supabaseUrl, apiKey, rows, batchSize = 200 }) {
  for (let index = 0; index < rows.length; index += batchSize) {
    const batch = rows.slice(index, index + batchSize);
    if (batch.length === 0) continue;
    await requestJson({
      supabaseUrl,
      apiKey,
      path: "cms_documents",
      method: "POST",
      body: batch,
      prefer: "return=minimal",
    });
  }
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    process.stdout.write(`${usage()}\n`);
    return;
  }

  const name = ensure(args.name?.trim(), "Missing --name.");
  const domain = normalizeDomain(args.domain);
  ensure(domain, "Missing or invalid --domain.");

  const copyStatuses = (args["copy-statuses"] ?? "all").trim().toLowerCase();
  if (copyStatuses !== "all" && copyStatuses !== "published") {
    throw new Error(`Invalid --copy-statuses value: ${copyStatuses}. Use all|published.`);
  }

  const supabaseUrl = (
    args["supabase-url"] ??
    process.env.NEXT_PUBLIC_SUPABASE_URL ??
    process.env.SUPABASE_URL ??
    ""
  )
    .trim()
    .replace(/\/+$/, "");
  const apiKey = (args["api-key"] ?? process.env.SUPABASE_SERVICE_ROLE_KEY ?? "").trim();

  ensure(
    supabaseUrl,
    "Missing Supabase URL. Set --supabase-url, NEXT_PUBLIC_SUPABASE_URL, or SUPABASE_URL.",
  );
  ensure(
    apiKey,
    "Missing API key. Set --api-key or SUPABASE_SERVICE_ROLE_KEY.",
  );

  const templateSiteId = await resolveTemplateSiteId({
    supabaseUrl,
    apiKey,
    explicitSourceSiteId: args["source-site-id"]?.trim(),
  });
  const templateSite = await fetchSiteById({
    supabaseUrl,
    apiKey,
    siteId: templateSiteId,
  });
  if (!templateSite) {
    throw new Error(`Template site not found: ${templateSiteId}`);
  }

  const ownerProfileId = (args["owner-profile-id"] ?? templateSite.owner_profile_id ?? "").trim();
  ensure(
    ownerProfileId,
    "Missing owner profile id. Provide --owner-profile-id or ensure template has owner_profile_id.",
  );

  const defaultLocale = (args["default-locale"] ?? templateSite.default_locale ?? "nl").trim();
  const locales = args.locales
    ? parseLocalesCsv(args.locales)
    : Array.isArray(templateSite.locales)
      ? templateSite.locales
      : [];
  ensure(locales.length > 0, "Missing locales. Provide --locales or ensure template has locales.");
  if (!locales.includes(defaultLocale)) {
    locales.unshift(defaultLocale);
  }
  const timezone = (args.timezone ?? templateSite.timezone ?? "Europe/Oslo").trim();

  await ensureDomainIsAvailable({ supabaseUrl, apiKey, domain });

  const templateDocs = await fetchTemplateDocuments({
    supabaseUrl,
    apiKey,
    siteId: templateSiteId,
    copyStatuses,
  });

  const dryRun = Boolean(args["dry-run"]);
  if (dryRun) {
    process.stdout.write(
      [
        "Dry run: no changes written.",
        `- New site name: ${name}`,
        `- Domain: ${domain}`,
        `- Template site: ${templateSiteId} (${templateSite.name})`,
        `- Owner profile: ${ownerProfileId}`,
        `- Locales: ${locales.join(", ")}`,
        `- Default locale: ${defaultLocale}`,
        `- Timezone: ${timezone}`,
        `- Documents to clone: ${templateDocs.length} (${copyStatuses})`,
      ].join("\n") + "\n",
    );
    return;
  }

  const createdSite = await createSite({
    supabaseUrl,
    apiKey,
    payload: {
      owner_profile_id: ownerProfileId,
      name,
      default_locale: defaultLocale,
      locales,
      timezone,
    },
  });
  const newSiteId = createdSite.id;

  await createSiteDomain({
    supabaseUrl,
    apiKey,
    siteId: newSiteId,
    domain,
  });

  const docsToInsert = templateDocs.map((doc) => ({
    site_id: newSiteId,
    content_type: doc.content_type,
    slug: doc.slug,
    locale: doc.locale,
    content: doc.content,
    status: doc.status,
    published_at: doc.published_at,
  }));

  await insertDocumentsInBatches({
    supabaseUrl,
    apiKey,
    rows: docsToInsert,
  });

  process.stdout.write(
    [
      "Provisioning complete.",
      `- New site id: ${newSiteId}`,
      `- Name: ${name}`,
      `- Domain: ${domain}`,
      `- Cloned docs: ${docsToInsert.length} (${copyStatuses})`,
      "",
      "Next:",
      `1) Verify content in HostHub for site ${newSiteId}.`,
      `2) Point DNS for ${domain} to your website deployment.`,
    ].join("\n") + "\n",
  );
}

main().catch((error) => {
  process.stderr.write(`${error instanceof Error ? error.message : String(error)}\n`);
  process.stderr.write(`${usage()}\n`);
  process.exitCode = 1;
});
