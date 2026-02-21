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
  const previewSelection = siteConfig.gallery.slice(0, 6);
  const fallbackAlt = t.pages.gallery;

  if (scope === "preview") {
    if (previewSelection.length > 0) {
      return previewSelection.map((image, index) => ({
        ...buildResponsiveImage(image.src, {
          widths: galleryImageWidths,
          sizes: galleryImageSizes,
          defaultWidth: 1920,
        }),
        alt: image.alt?.[locale] ?? image.alt?.en ?? `${fallbackAlt} ${index + 1}`,
      }));
    }

    if (galleryFiles.length > 0) {
      return galleryFiles.slice(0, 6).map((file, index) => ({
        ...buildResponsiveImage(`${basePath}/${file}`, {
          widths: galleryImageWidths,
          sizes: galleryImageSizes,
          defaultWidth: 1920,
        }),
        alt: `${fallbackAlt} ${index + 1}`,
      }));
    }
  }

  if (galleryFiles.length === 0) {
    return siteConfig.gallery.map((image, index) => ({
      ...buildResponsiveImage(image.src, {
        widths: galleryImageWidths,
        sizes: galleryImageSizes,
        defaultWidth: 1920,
      }),
      alt: image.alt?.[locale] ?? image.alt?.en ?? `${fallbackAlt} ${index + 1}`,
    }));
  }

  return galleryFiles.map((file, index) => {
    return {
      ...buildResponsiveImage(`${basePath}/${file}`, {
        widths: galleryImageWidths,
        sizes: galleryImageSizes,
        defaultWidth: 1920,
      }),
      alt: `${t.pages.gallery} ${index + 1}`,
    };
  });
}
