import "server-only";

import { headers } from "next/headers";
import { notFound } from "next/navigation";

import { getSiteBaseUrl } from "./site-url";
import { getServiceClient } from "./supabase/service";

export type RuntimeSiteContextSource =
  /** The host matched a `site_domains` row. `siteId` is set. */
  | "domain_lookup"
  /** The lookup succeeded and this host belongs to no site. */
  | "unknown_domain"
  /** The lookup itself failed, so which site this is remains unknown. */
  | "lookup_failed";

export type RuntimeSiteContext = {
  siteId: string | null;
  domain: string | null;
  baseUrl: string;
  source: RuntimeSiteContextSource;
};

function normalizeForwardedValue(value: string | null): string | null {
  if (!value) return null;
  const first = value
    .split(",")
    .map((part) => part.trim())
    .find(Boolean);
  return first ?? null;
}

function stripSchemeAndPath(value: string): string {
  const withoutScheme = value.replace(/^https?:\/\//i, "");
  return withoutScheme.split("/")[0] ?? withoutScheme;
}

function stripPort(host: string): string {
  // IPv6 hosts are enclosed in [] and can include a trailing :port.
  if (host.startsWith("[")) {
    const end = host.indexOf("]");
    if (end !== -1) {
      return host.slice(0, end + 1);
    }
  }
  const colonIndex = host.indexOf(":");
  if (colonIndex === -1) return host;
  return host.slice(0, colonIndex);
}

function normalizeDomain(value: string | null): string | null {
  if (!value) return null;
  const trimmed = value.trim().toLowerCase();
  if (!trimmed) return null;
  const normalized = stripPort(stripSchemeAndPath(trimmed)).replace(/\.$/, "");
  return normalized || null;
}

function isLocalDomain(domain: string) {
  const host = domain.replace(/^\[(.*)\]$/, "$1");
  return host === "localhost" || host === "127.0.0.1" || host === "::1";
}

function resolveProtocol(domain: string | null, forwardedProto: string | null) {
  if (forwardedProto === "http" || forwardedProto === "https") {
    return forwardedProto;
  }
  if (domain && isLocalDomain(domain)) {
    return "http";
  }
  return "https";
}

type DomainLookup =
  | { outcome: "match"; siteId: string }
  | { outcome: "no_match" }
  | { outcome: "failed" };

/**
 * "No such domain" and "could not ask" are different answers, and the caller
 * has to treat them differently: the first is a 404, the second must not become
 * one — a 404 would tell crawlers a live customer site is gone because Supabase
 * blinked.
 */
async function findSiteIdByDomain(domain: string): Promise<DomainLookup> {
  const lookupClient = getServiceClient();
  if (!lookupClient) return { outcome: "failed" };

  try {
    const { data, error } = await lookupClient
      .from("site_domains")
      .select("site_id, is_primary")
      .eq("domain", domain)
      .order("is_primary", { ascending: false })
      .limit(1)
      .maybeSingle();

    if (error) return { outcome: "failed" };
    if (!data) return { outcome: "no_match" };

    const siteId = data["site_id"];
    return typeof siteId === "string" && siteId.trim()
      ? { outcome: "match", siteId }
      : { outcome: "no_match" };
  } catch {
    return { outcome: "failed" };
  }
}

export async function resolveRuntimeSiteContext(): Promise<RuntimeSiteContext> {
  const requestHeaders = await headers();
  const forwardedHost = normalizeForwardedValue(
    requestHeaders.get("x-forwarded-host"),
  );
  const directHost = normalizeForwardedValue(requestHeaders.get("host"));
  const domain = normalizeDomain(forwardedHost ?? directHost);

  const forwardedProto = normalizeForwardedValue(
    requestHeaders.get("x-forwarded-proto"),
  );
  const protocol = resolveProtocol(domain, forwardedProto);
  const baseUrl = domain ? `${protocol}://${domain}` : getSiteBaseUrl();

  // No env default: the host is what identifies a site, in production and
  // locally alike (`localhost` is a row in site_domains). A second way to arrive
  // at a site id is how a console and a preview end up editing and rendering
  // different sites without anything saying so.
  const lookup = domain
    ? await findSiteIdByDomain(domain)
    : ({ outcome: "no_match" } as const);

  if (lookup.outcome === "match") {
    return {
      siteId: lookup.siteId,
      domain,
      baseUrl,
      source: "domain_lookup",
    };
  }

  return {
    siteId: null,
    domain,
    baseUrl,
    source: lookup.outcome === "failed" ? "lookup_failed" : "unknown_domain",
  };
}

export type SiteContentOptions = {
  preview?: boolean;
  siteId: string;
};

/**
 * Thrown when the request cannot be attributed to a site. Deliberately not a
 * 404: see [findSiteIdByDomain].
 */
export class SiteLookupFailedError extends Error {
  constructor(domain: string | null) {
    super(
      `Could not resolve a site for host ${domain ?? "(none)"}: the site_domains lookup failed`,
    );
    this.name = "SiteLookupFailedError";
  }
}

/**
 * Turns a resolved context into the options every content read needs, and
 * refuses to produce them when there is no site.
 *
 * Failing closed is the point. One Next.js worker serves every customer domain,
 * and the content fallbacks bundled into it (`content.generated.ts`,
 * `content.ts`) hold one specific site's copy. Returning `{}` here — which is
 * what this used to do — made every unresolved host render that site: an
 * unknown domain pointed at the worker, and any real customer domain during a
 * Supabase hiccup, both served another customer's pages, prices and contact
 * details under their own name.
 */
export function toSiteContentOptions(
  context: RuntimeSiteContext,
  preview = false,
): SiteContentOptions {
  if (context.siteId) return { preview, siteId: context.siteId };
  if (context.source === "lookup_failed") {
    throw new SiteLookupFailedError(context.domain);
  }
  notFound();
}
