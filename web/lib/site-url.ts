const fallbackBaseUrl = "https://example.com";

function normalizeBaseUrl(raw: string | undefined) {
  if (!raw) {
    return fallbackBaseUrl;
  }

  const trimmed = raw.trim();
  if (!trimmed) {
    return fallbackBaseUrl;
  }

  const withScheme = /^https?:\/\//i.test(trimmed) ? trimmed : `https://${trimmed}`;

  try {
    const url = new URL(withScheme);
    return url.origin;
  } catch {
    return fallbackBaseUrl;
  }
}

export function getSiteBaseUrl(override?: string) {
  return normalizeBaseUrl(override ?? process.env.NEXT_PUBLIC_SITE_URL);
}
