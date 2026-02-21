import fs from "node:fs";
import path from "node:path";

export type ResponsiveImage = {
  src: string;
  srcSet: string;
  sizes: string;
};

export const heroImageWidths = [3840, 1920, 1280, 960, 640] as const;
export const heroImageSizes = "100vw";
export const galleryImageWidths = [1920, 1280, 960, 640] as const;
export const galleryImageSizes =
  "(min-width: 1024px) 33vw, (min-width: 768px) 50vw, 100vw";
export const highlightImageWidths = [1920, 1280, 640] as const;
export const highlightImageSizes =
  "(min-width: 768px) 22vw, (min-width: 640px) 45vw, 100vw";

const PUBLIC_DIR = path.join(process.cwd(), "public");

export function buildResponsiveImage(
  baseSrc: string,
  options: {
    widths: readonly number[];
    sizes: string;
    defaultWidth?: number;
  },
): ResponsiveImage {
  const normalized = baseSrc.replace(/^\/+/, "");
  const extension = path.extname(normalized);
  if (!extension) {
    const encoded = encodeURI(baseSrc);
    return {
      src: encoded,
      srcSet: encoded,
      sizes: options.sizes,
    };
  }

  const baseWithoutExt = normalized.slice(0, -extension.length);
  const available = options.widths
    .map((width) => {
      const candidatePath = path.join(PUBLIC_DIR, `${baseWithoutExt}@${width}w${extension}`);
      if (!fs.existsSync(candidatePath)) {
        return null;
      }
      const webPath = `/${baseWithoutExt}@${width}w${extension}`.replace(/\\/g, "/");
      return { width, webPath };
    })
    .filter((result): result is { width: number; webPath: string } => Boolean(result));

  if (!available.length) {
    const fallback = encodeURI(baseSrc);
    return { src: fallback, srcSet: fallback, sizes: options.sizes };
  }

  const sorted = available.sort((left, right) => left.width - right.width);
  const defaultWidth = options.defaultWidth ?? sorted[Math.floor(sorted.length / 2)].width;
  const defaultEntry =
    sorted.find((entry) => entry.width === defaultWidth) ?? sorted[sorted.length - 1];

  const srcSet = sorted
    .map((entry) => `${encodeURI(entry.webPath)} ${entry.width}w`)
    .join(", ");

  return {
    src: encodeURI(defaultEntry.webPath),
    srcSet,
    sizes: options.sizes,
  };
}
