import "server-only";

import { site } from "@/lib/content";
import {
  buildResponsiveImage,
  heroImageSizes,
  heroImageWidths,
  type ResponsiveImage,
} from "@/lib/responsive-images";

const heroImages = site.heroImages ?? [];

export function getHeroImages(): ResponsiveImage[] {
  return heroImages.map((image) =>
    buildResponsiveImage(image, {
      widths: heroImageWidths,
      sizes: heroImageSizes,
      defaultWidth: 1920,
    }),
  );
}
