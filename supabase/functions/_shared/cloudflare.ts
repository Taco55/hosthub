// The Cloudflare side of attaching a domain to a site.
//
// A `site_domains` row on its own resolves nothing: the public sites are served
// by one Worker (`hosthub-sites`) that reads the request's Host header, so a
// hostname only reaches it once DNS points at Cloudflare *and* a Worker route
// claims the pattern. This module owns those two facts.
//
// Everything here is deliberately idempotent and covering-aware. A zone that
// already carries `*.example.com` (DNS) and `*.example.com/*` (route) — the
// shape this platform uses — needs nothing at all for a new subdomain, and
// creating a redundant record per site would grow clutter no one prunes.

const CF_API = "https://api.cloudflare.com/client/v4";

// TEST-NET-1 (RFC 5737). A proxied record never connects to its origin — the
// Worker answers first — so the address only has to be one that can never be
// reached by accident. This mirrors the records the zone already carries.
const PROXY_PLACEHOLDER_IP = "192.0.2.1";

export type CloudflareZone = { id: string; name: string };

export type EnsureOutcome = "created" | "covered";

type CfEnvelope<T> = {
  success: boolean;
  result: T;
  errors?: Array<{ code: number; message: string }>;
};

export class CloudflareError extends Error {
  constructor(message: string, readonly status: number) {
    super(message);
    this.name = "CloudflareError";
  }
}

async function cf<T>(
  token: string,
  path: string,
  init: RequestInit = {},
): Promise<T> {
  const response = await fetch(`${CF_API}${path}`, {
    ...init,
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
      ...(init.headers ?? {}),
    },
  });

  let body: CfEnvelope<T> | null = null;
  try {
    body = await response.json();
  } catch {
    // Fall through to the status-based error below.
  }

  if (!response.ok || !body?.success) {
    const detail = body?.errors?.map((e) => e.message).join("; ") ??
      `HTTP ${response.status}`;
    throw new CloudflareError(detail, response.status);
  }

  return body.result;
}

/// Normalizes user input into a bare hostname, or null when it cannot be one.
///
/// Accepts what an owner is likely to paste (`https://www.example.com/`,
/// `Example.COM`, a trailing dot) and rejects the rest — this value ends up in
/// a UNIQUE column that decides whose content a request gets served.
export function normalizeHostname(input: string): string | null {
  let value = input.trim().toLowerCase();
  if (!value) return null;

  value = value.replace(/^[a-z][a-z0-9+.-]*:\/\//, "");
  value = value.split("/")[0].split("?")[0].split("#")[0];
  value = value.split("@").pop() ?? value;
  value = value.replace(/\.+$/, "");
  if (value.includes(":")) return null; // No ports, no IPv6 literals.
  if (value.length > 253) return null;

  const labels = value.split(".");
  if (labels.length < 2) return null;
  for (const label of labels) {
    if (!/^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$/.test(label)) return null;
  }
  // A numeric last label means an IP address, not a domain.
  if (!/^[a-z]{2,}$/.test(labels[labels.length - 1])) return null;

  return value;
}

/// Zone candidates for a hostname, most specific first.
/// `a.b.example.com` → `a.b.example.com`, `b.example.com`, `example.com`.
/// The single-label tail is never a candidate: no one delegates a whole TLD.
export function zoneCandidates(hostname: string): string[] {
  const labels = hostname.split(".");
  const candidates: string[] = [];
  for (let i = 0; i <= labels.length - 2; i += 1) {
    candidates.push(labels.slice(i).join("."));
  }
  return candidates;
}

/// The zone in this Cloudflare account that hosts `hostname`, or null when the
/// domain lives somewhere else entirely (the customer has not delegated it yet).
export async function findZone(
  token: string,
  hostname: string,
): Promise<CloudflareZone | null> {
  for (const candidate of zoneCandidates(hostname)) {
    const zones = await cf<CloudflareZone[]>(
      token,
      `/zones?name=${encodeURIComponent(candidate)}&status=active`,
    );
    if (zones.length > 0) {
      return { id: zones[0].id, name: zones[0].name };
    }
  }
  return null;
}

/// Hostnames that a DNS record or route could carry to cover `hostname`:
/// itself, plus a wildcard one level up (`*.example.com` covers `a.example.com`,
/// but not `a.b.example.com` — DNS wildcards match a single label).
function coveringNames(hostname: string): string[] {
  const labels = hostname.split(".");
  if (labels.length < 3) return [hostname];
  return [hostname, `*.${labels.slice(1).join(".")}`];
}

/// Points `hostname` at Cloudflare's edge so the Worker route can claim it.
/// Returns "covered" when an existing record (its own, or a wildcard) already
/// does the job.
export async function ensureDnsRecord(
  token: string,
  zoneId: string,
  hostname: string,
): Promise<EnsureOutcome> {
  for (const name of coveringNames(hostname)) {
    const records = await cf<Array<{ id: string; proxied: boolean }>>(
      token,
      `/zones/${zoneId}/dns_records?name=${encodeURIComponent(name)}`,
    );
    if (records.some((record) => record.proxied)) return "covered";
  }

  await cf(token, `/zones/${zoneId}/dns_records`, {
    method: "POST",
    body: JSON.stringify({
      type: "A",
      name: hostname,
      content: PROXY_PLACEHOLDER_IP,
      proxied: true,
      comment: "HostHub site (proxied to the hosthub-sites Worker)",
    }),
  });
  return "created";
}

/// Hands requests for `hostname` to the sites Worker. Returns "covered" when a
/// route already matches — including the wildcard route a zone gets once its
/// first site is attached.
export async function ensureWorkerRoute(
  token: string,
  zoneId: string,
  hostname: string,
  script: string,
): Promise<EnsureOutcome> {
  const routes = await cf<Array<{ id: string; pattern: string; script: string }>>(
    token,
    `/zones/${zoneId}/workers/routes`,
  );
  const wanted = new Set(coveringNames(hostname).map((name) => `${name}/*`));
  if (routes.some((route) => wanted.has(route.pattern) && route.script === script)) {
    return "covered";
  }

  await cf(token, `/zones/${zoneId}/workers/routes`, {
    method: "POST",
    body: JSON.stringify({ pattern: `${hostname}/*`, script }),
  });
  return "created";
}
