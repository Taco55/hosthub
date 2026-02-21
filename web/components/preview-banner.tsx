/**
 * Sticky banner shown at the top of preview pages.
 * Links back to the production version of the site.
 */
export function PreviewBanner({ locale }: { locale: string }) {
  return (
    <div className="sticky top-0 z-50 flex items-center justify-center gap-3 bg-amber-500 px-4 py-2 text-sm font-medium text-white shadow-md">
      <span>Preview mode</span>
      <span className="text-amber-100">—</span>
      <span className="text-amber-100">Content loaded from CMS</span>
      <a
        href={`/${locale}`}
        className="ml-2 rounded bg-white/20 px-3 py-0.5 text-white transition-colors hover:bg-white/30"
      >
        View production site
      </a>
    </div>
  );
}
