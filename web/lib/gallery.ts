import "server-only";

import type { SiteConfig } from "@/lib/content";
import { getDictionary, type Locale } from "@/lib/i18n";
import {
  buildResponsiveImage,
  galleryImageSizes,
  galleryImageWidths,
  type ResponsiveImage,
} from "@/lib/responsive-images";

export type GalleryImage = ResponsiveImage & {
  alt: string;
  category?: string;
};

export type GalleryScope = "preview" | "all";

const buildGalleryImage = (src: string, alt: string): GalleryImage => ({
  ...buildResponsiveImage(src, {
    widths: galleryImageWidths,
    sizes: galleryImageSizes,
    defaultWidth: 1920,
  }),
  alt,
});

export function getGalleryImages(
  siteConfig: SiteConfig,
  locale: Locale,
  scope: GalleryScope = "all",
): GalleryImage[] {
  const t = getDictionary(locale);
  const galleryFiles = (siteConfig.galleryAllFilenames ?? [])
    .map((file) => file.trim())
    .filter(Boolean);
  const basePath = siteConfig.imagePaths.galleryAll;
  const fallbackAlt = t.pages.gallery;

  // Hand-curated highlights with localized alt text, shown as the homepage preview grid.
  const curated = siteConfig.gallery.map((image, index) => ({
    src: image.src,
    alt: image.alt?.[locale] ?? image.alt?.en ?? `${fallbackAlt} ${index + 1}`,
  }));

  // Full gallery in file order with generic alt text. Falls back to the curated
  // set when no full-gallery filenames are configured.
  const all =
    galleryFiles.length === 0
      ? curated
      : galleryFiles.map((file, index) => ({
          src: `${basePath}/${file}`,
          alt: `${fallbackAlt} ${index + 1}`,
        }));

  if (scope === "all") {
    return all.map((image) => buildGalleryImage(image.src, image.alt));
  }

  // scope === "preview": curated highlights first, then the rest of the gallery
  // (deduplicated) so visitors can keep browsing every photo once they open the
  // lightbox from the homepage preview — the 6 highlights flow into the full set.
  const curatedSrcs = new Set(curated.map((image) => image.src));
  const rest = all.filter((image) => !curatedSrcs.has(image.src));

  return [...curated, ...rest].map((image) => buildGalleryImage(image.src, image.alt));
}
