"use client";

import { useMemo, useState } from "react";
import Image from "next/image";
import { GalleryLightbox } from "@/components/gallery-lightbox";
import type { GalleryImage } from "@/lib/gallery";

type GalleryGridProps = {
  images: GalleryImage[];
  allLabel?: string;
};

export function GalleryGrid({ images, allLabel = "All" }: GalleryGridProps) {
  const [index, setIndex] = useState<number | null>(null);
  const [activeCategory, setActiveCategory] = useState<string>("all");
  const categories = useMemo(() => {
    const unique = new Set<string>();
    images.forEach((image) => {
      if (image.category) {
        unique.add(image.category);
      }
    });
    return Array.from(unique);
  }, [images]);
  const hasCategories = categories.length > 1;
  const visibleImages = useMemo(() => {
    if (!hasCategories || activeCategory === "all") {
      return images;
    }
    return images.filter((image) => image.category === activeCategory);
  }, [activeCategory, hasCategories, images]);

  return (
    <>
      {hasCategories ? (
        <div className="flex flex-wrap gap-2">
          <button
            type="button"
            onClick={() => {
              setActiveCategory("all");
              setIndex(null);
            }}
            className={`rounded-full border px-4 py-1 text-xs font-semibold uppercase tracking-wide transition ${
              activeCategory === "all"
                ? "border-transparent bg-foreground text-background"
                : "border-border/60 text-muted-foreground hover:border-foreground/40"
            }`}
          >
            {allLabel}
          </button>
          {categories.map((category) => (
            <button
              key={category}
              type="button"
              onClick={() => {
                setActiveCategory(category);
                setIndex(null);
              }}
              className={`rounded-full border px-4 py-1 text-xs font-semibold uppercase tracking-wide transition ${
                activeCategory === category
                  ? "border-transparent bg-foreground text-background"
                  : "border-border/60 text-muted-foreground hover:border-foreground/40"
              }`}
            >
              {category}
            </button>
          ))}
        </div>
      ) : null}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {visibleImages.map((image, imageIndex) => (
          <button
            key={image.src}
            type="button"
            className="group relative overflow-hidden rounded-2xl border border-border/60 bg-white shadow-sm"
            onClick={() => setIndex(imageIndex)}
          >
            <div className="relative aspect-[4/3] w-full">
              <Image
                src={image.src}
                alt={image.alt}
                fill
                priority={imageIndex === 0}
                className="object-cover transition-transform duration-300 group-hover:scale-105"
                sizes={image.sizes}
              />
            </div>
          </button>
        ))}
      </div>
      <GalleryLightbox
        images={visibleImages}
        index={index}
        onClose={() => setIndex(null)}
      />
    </>
  );
}
