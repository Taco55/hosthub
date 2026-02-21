import type { SiteConfig } from "./content";

function firstNonEmpty(...values: Array<string | null | undefined>) {
  for (const value of values) {
    if (typeof value === "string" && value.trim()) {
      return value.trim();
    }
  }
  return "";
}

export function resolveBookingUrl(siteConfig: Partial<SiteConfig> | null | undefined) {
  return firstNonEmpty(
    siteConfig?.bookingUrl,
    process.env.NEXT_PUBLIC_LODGIFY_CHECKOUT_URL,
    process.env.LODGIFY_BOOKING_URL,
  );
}
