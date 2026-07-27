import type { PreviewContentStatus } from "@/lib/content-provider";

/**
 * Sticky banner shown at the top of preview pages.
 *
 * It states what is actually on screen. The banner used to read "Content
 * loaded from CMS" unconditionally, which is the one thing a preview must never
 * do: when a document is missing or unreadable the pages fall back to the
 * site's built-in snapshot, and an owner comparing the preview with their
 * editor then sees copy that exists nowhere in the CMS.
 */
type BannerTone = "ok" | "warn";

export function describePreviewStatus(status: PreviewContentStatus): {
  tone: BannerTone;
  message: string;
  detail?: string;
} {
  switch (status.kind) {
    case "no_site":
      return {
        tone: "warn",
        message: "No CMS site configured — showing the site's fallback content",
      };
    case "unavailable":
      return {
        tone: "warn",
        message:
          status.reason === "no_preview_key"
            ? "Drafts cannot be read (no server key configured) — showing fallback content"
            : `CMS could not be read (${status.reason}) — showing fallback content`,
        detail: status.detail,
      };
    case "documents": {
      const total =
        status.missing.length + status.draft.length + status.published.length;
      if (status.missing.length > 0) {
        return {
          tone: "warn",
          message: `Fallback content for ${status.missing.length} of ${total} documents`,
          detail: `No CMS document for this language: ${status.missing.join(", ")}`,
        };
      }
      return {
        tone: "ok",
        message:
          status.draft.length > 0
            ? `CMS content — ${status.draft.length} unpublished draft${
                status.draft.length === 1 ? "" : "s"
              }`
            : "CMS content — published",
      };
    }
  }
}

export function PreviewBanner({
  locale,
  status,
}: {
  locale: string;
  status: PreviewContentStatus;
}) {
  const { tone, message, detail } = describePreviewStatus(status);
  const background = tone === "ok" ? "bg-amber-500" : "bg-rose-600";

  return (
    <div
      className={`sticky top-0 z-50 flex flex-wrap items-center justify-center gap-x-3 gap-y-1 px-4 py-2 text-sm font-medium text-white shadow-md ${background}`}
    >
      <span>Preview mode</span>
      <span className="text-white/70">—</span>
      <span className="text-white/90">{message}</span>
      <a
        href={`/${locale}`}
        className="ml-2 rounded bg-white/20 px-3 py-0.5 text-white transition-colors hover:bg-white/30"
      >
        View production site
      </a>
      {detail ? (
        <span className="w-full text-center text-xs font-normal text-white/85">
          {detail}
        </span>
      ) : null}
    </div>
  );
}
