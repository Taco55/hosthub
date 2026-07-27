import "server-only";

import { headers } from "next/headers";

import { getSiteBaseUrl } from "./site-url";
import { getServiceClient } from "./supabase/service";

export type RuntimeSiteContextSource = "domain_lookup" | "unresolved";

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

async function findSiteIdByDomain(domain: string): Promise<string | null> {
  const lookupClient = getServiceClient();
  if (!lookupClient) return null;

  try {
    const { data, error } = await lookupClient
      .from("site_domains")
      .select("site_id, is_primary")
      .eq("domain", domain)
      .order("is_primary", { ascending: false })
      .limit(1)
      .maybeSingle();

    if (error || !data) {
      return null;
    }

    const siteId = data["site_id"];
    return typeof siteId === "string" && siteId.trim() ? siteId : null;
  } catch {
    // Supabase unreachable or the query threw — fall back to env/default site
    // so the website keeps rendering when the CMS backend is down.
    return null;
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

  const matchedSiteId = domain ? await findSiteIdByDomain(domain) : null;
  if (matchedSiteId) {
    return {
      siteId: matchedSiteId,
      domain,
      baseUrl,
      source: "domain_lookup",
    };
  }

  // No env default any more: the host is what identifies a site, in production
  // and locally alike (`localhost` is a row in site_domains). A second way to
  // arrive at a site id is how a console and a preview end up editing and
  // rendering different sites without anything saying so.
  return {
    siteId: null,
    domain,
    baseUrl,
    source: "unresolved",
  };
}

export type SiteContentOptions = {
  preview?: boolean;
  siteId?: string;
};

export function toSiteContentOptions(
  context: RuntimeSiteContext,
  preview = false,
): SiteContentOptions {
  return context.siteId ? { preview, siteId: context.siteId } : { preview };
}
