import Image from "next/image";
import type { LucideIcon } from "lucide-react";

import { IconBadge } from "@/components/ui/IconBadge";
import type { ResponsiveImage } from "@/lib/responsive-images";

type HighlightImage = ResponsiveImage & {
  alt: string;
};

type HighlightsGridProps = {
  highlights: { title: string; description?: string }[];
  icons?: LucideIcon[];
  images?: HighlightImage[];
};

const fallbackImageSrc = "/images/highlight-item-placeholder.svg";

export function HighlightsGrid({ highlights, icons, images }: HighlightsGridProps) {
  return (
    <div className="grid gap-6 sm:grid-cols-2 md:grid-cols-4">
      {highlights.map((highlight, index) => {
        const image = images?.[index];
        const imageAlt = image?.alt ?? "";
        const Icon = icons?.[index];
        return (
          <div
            key={`${highlight.title}-${index}`}
            className="grid aspect-[4/5] h-full grid-rows-[1fr_1fr] overflow-hidden rounded-2xl border border-border/60 bg-white shadow-sm"
          >
            <div className="relative w-full bg-muted/30">
              <Image
                src={image?.src ?? fallbackImageSrc}
                alt={imageAlt}
                fill
                className="object-cover object-center"
                sizes={image?.sizes ?? "(min-width: 768px) 22vw, (min-width: 640px) 45vw, 100vw"}
              />
            </div>
            <div className="flex flex-col items-center justify-center gap-4 p-4 text-center">
              {Icon ? <IconBadge size="sm" icon={<Icon />} /> : null}
              <div className="space-y-1">
                <div className="text-base font-medium text-[color:rgb(var(--heading-warm-light))]">
                  {highlight.title}
                </div>
                {highlight.description ? (
                  <p className="text-sm text-muted-foreground">{highlight.description}</p>
                ) : null}
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
}
