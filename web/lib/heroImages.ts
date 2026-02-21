import "server-only";

import type { SiteConfig } from "@/lib/content";
import {
  buildResponsiveImage,
  heroImageSizes,
  heroImageWidths,
  type ResponsiveImage,
} from "@/lib/responsive-images";

export function getHeroImages(siteConfig: SiteConfig): ResponsiveImage[] {
  const heroImages = siteConfig.heroImages ?? [];
  return heroImages.map((image) =>
    buildResponsiveImage(image, {
      widths: heroImageWidths,
      sizes: heroImageSizes,
      defaultWidth: 1920,
    }),
  );
}
