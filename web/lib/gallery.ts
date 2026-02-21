import "server-only";

import { site } from "@/lib/content";
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

export function getGalleryImages(locale: Locale, scope: GalleryScope = "all"): GalleryImage[] {
  const t = getDictionary(locale);
  const galleryFiles = site.galleryAllFilenames ?? [];
  const basePath = site.imagePaths.galleryAll;
  const fallbackAlt = t.pages.gallery;

  if (scope === "preview") {
    return site.gallery.map((image, index) => ({
      ...buildResponsiveImage(image.src, {
        widths: galleryImageWidths,
        sizes: galleryImageSizes,
        defaultWidth: 1920,
      }),
      alt: image.alt?.[locale] ?? image.alt?.en ?? `${fallbackAlt} ${index + 1}`,
    }));
  }

  if (galleryFiles.length === 0) {
    return site.gallery.map((image, index) => ({
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
